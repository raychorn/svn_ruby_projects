#include "ruby.h"
#include "st.h"
#include "amf3writer.h"

struct amf3_writer {
  AMF3Writer *writer;
  VALUE classNameMapping;
  VALUE transformer;
  VALUE strings;
  VALUE objects;
  VALUE classdefs;
};

static VALUE rb_AMF3, rb_AMF3Writer;

static AMF3Status writer_amf3_send(void *userData, const char *s, unsigned len);
static AMF3Status writer_amf3_flush(void *userData);
static AMF3Status _encodeRecursive(struct amf3_writer *w, VALUE value);

static int
_getReferenceIndex(VALUE hash, VALUE v)
{
  VALUE idx;
  
  /* Nil and empty string are not referenced. */
  if (v == Qnil || (TYPE(v) == T_STRING && RSTRING(v)->len == 0))
    return -1;

  idx = rb_hash_aref(hash, v);
  if (idx == Qnil)
    return -1;
  else
    return FIX2LONG(idx);
}

static void
_storeReferenceIndex(VALUE hash, VALUE v)
{
  int next;
  
  /* Empty string is not referenced. */
  if (TYPE(v) == T_STRING && RSTRING(v)->len == 0)
    return;

  next = (RHASH(hash)->tbl->num_entries);
  rb_hash_aset(hash, v, INT2FIX(next));
}

static int
_getClassReferenceIndex(struct amf3_writer *w, VALUE className, VALUE keys)
{
  return _getReferenceIndex(w->classdefs, rb_ary_new3(2, className, keys));
}

static void
_storeClassReferenceIndex(struct amf3_writer *w, VALUE className, VALUE keys)
{
  _storeReferenceIndex(w->classdefs, rb_ary_new3(2, className, keys));
}

static VALUE
_getMappedClassName(struct amf3_writer *w, const char *className)
{
  return rb_hash_aref(w->classNameMapping, rb_str_new2(className));
}

static VALUE
_transformObject(struct amf3_writer *w, VALUE obj)
{
  if (w->transformer != Qnil) {
    return rb_funcall(w->transformer, rb_intern("call"), 1, obj);
  }
  else
    return obj;
}

static void
writer_mark(struct amf3_writer *w)
{
  VALUE file = (VALUE)AMF3Writer_getUserData(w->writer);
  
  if (file)
    rb_gc_mark(file);
    
  rb_gc_mark(w->strings);
  rb_gc_mark(w->objects);
  rb_gc_mark(w->classdefs);
  rb_gc_mark(w->classNameMapping);
  rb_gc_mark(w->transformer);
}

static void
writer_free(struct amf3_writer *w)
{
  AMF3Writer_flush(w->writer);
  AMF3Writer_free(w->writer);
  free(w);
}

static VALUE
writer_allocate(VALUE klass)
{
  struct amf3_writer *w;

  AMF3Callbacks callbacks;
  callbacks.flush = writer_amf3_flush;
  callbacks.send = writer_amf3_send;
  
  w = malloc(sizeof(*w));
  w->writer = AMF3Writer_new(&callbacks);
  w->classNameMapping = rb_hash_new();
  w->transformer = Qnil;
  w->strings = rb_hash_new();
  w->objects = rb_hash_new();
  w->classdefs = rb_hash_new();
  
  return Data_Wrap_Struct(klass, writer_mark, writer_free, w);
}

static VALUE
handle_exception(VALUE unused)
{
  return Qfalse;
}

static VALUE
call_write(VALUE ary)
{
  rb_funcall(rb_ary_entry(ary, 0), rb_intern("<<"), 1, rb_ary_entry(ary, 1));
  
  return Qtrue;
}

static AMF3Status
writer_amf3_send(void *userData, const char *s, unsigned int len)
{
  VALUE file = (VALUE)userData;
  VALUE ary;
  
  if (!rb_respond_to(file, rb_intern("<<")))
    rb_raise(rb_eRuntimeError, "target must respond to '<<'");
  
  ary = rb_ary_new2(2);
  rb_ary_store(ary, 0, file);
  rb_ary_store(ary, 1, rb_str_new(s, len));
  
  if (rb_rescue(call_write, ary, handle_exception, Qnil) == Qfalse)
    return AMF3_IO_ERROR;
  else
    return AMF3_SUCCESS;
}

static VALUE
call_flush(VALUE file)
{
  rb_funcall(file, rb_intern("flush"), 0);
  
  return Qtrue;
}

static AMF3Status
writer_amf3_flush(void *userData)
{
  VALUE file = (VALUE)userData;
  
  /*
   * Not having a "flush" method is okay.  We may just be appending to a
   * string or a list.
   */
  if (!rb_respond_to(file, rb_intern("flush")))
    return AMF3_SUCCESS;
  
  if (rb_rescue(call_flush, file, handle_exception, Qnil) == Qfalse)
    return AMF3_IO_ERROR;
  else
    return AMF3_SUCCESS;
}

static VALUE
writer_initialize(VALUE self, VALUE file, VALUE classNameMapping, VALUE transformer)
{
  struct amf3_writer *w;
  Data_Get_Struct(self, struct amf3_writer, w);
  
  if (!rb_respond_to(file, rb_intern("<<")))
    rb_raise(rb_eRuntimeError, "target must respond to '<<'");
  
  AMF3Writer_setUserData(w->writer, (void *)file);
  
  w->classNameMapping = classNameMapping;
  w->transformer = transformer;
  
  return Qnil;
}

static AMF3Status
_encodeArray(struct amf3_writer *w, VALUE ary)
{
  long i;
  AMF3Status s;
  
  s = AMF3Writer_writeArrayStart(w->writer, RARRAY(ary)->len);
  if (s != AMF3_SUCCESS)
    return (s);
  for (i=0; i < RARRAY(ary)->len; i++) {
    s = _encodeRecursive(w, RARRAY(ary)->ptr[i]);
    if (s != AMF3_SUCCESS)
      return (s);
  }
  
  return AMF3_SUCCESS;
}

struct encodeState {
  struct amf3_writer *w;
  AMF3Status status;
};

static int
_encodeObjectFieldName(VALUE key, VALUE value, struct encodeState *st)
{
  AMF3Status s;
  VALUE key_string;
  int idx;
  
  if (key == Qundef)
    return ST_CONTINUE;
  
  key_string = rb_obj_as_string(key);
  if ((idx=_getReferenceIndex(st->w->strings, key_string)) != -1) {
    s = AMF3Writer_writeFieldNameReference(st->w->writer, idx);
  }
  else {
    _storeReferenceIndex(st->w->strings, key_string);
    s = AMF3Writer_writeFieldName(st->w->writer, StringValueCStr(key_string));
  }
  
  if (s != AMF3_SUCCESS) {
    st->status = s;
    return ST_STOP;
  }
  
  return ST_CONTINUE;
}

static int
_encodeObjectFieldValue(VALUE key, VALUE value, struct encodeState *st)
{
  AMF3Status s;

  if (key == Qundef)
    return ST_CONTINUE;
  
  s = _encodeRecursive(st->w, value);

  if (s != AMF3_SUCCESS) {
    st->status = s;
    return ST_STOP;
  }
  
  return ST_CONTINUE;
}

static AMF3Status
_encodeObject(struct amf3_writer *w, VALUE className, VALUE attrs)
{
  AMF3Status s;
  struct encodeState st;
  int idx;
  VALUE keys;
  
  st.status = AMF3_SUCCESS;
  st.w = w;
  
  attrs = rb_check_convert_type(attrs, T_HASH, "Hash", "to_hash");
  
  keys = rb_funcall(attrs, rb_intern("keys"), 0);
  
  if ((idx = _getClassReferenceIndex(w, className, keys)) != -1) {
    s = AMF3Writer_writeObjectClassReference(w->writer, idx);
  }
  else {
    _storeClassReferenceIndex(w, className, keys);
    s = AMF3Writer_writeObjectStart(w->writer, RHASH(attrs)->tbl->num_entries);
    if (s != AMF3_SUCCESS)
      return (s);
  
    if (className == Qnil)
      s = AMF3Writer_writeFieldName(w->writer, "");
    else if ((idx = _getReferenceIndex(w->strings, className)) != -1)
      s = AMF3Writer_writeFieldNameReference(w->writer, idx);
    else {
      rb_check_safe_str(className);
      _storeReferenceIndex(w->strings, className);
      s = AMF3Writer_writeFieldName(w->writer, StringValueCStr(className));
    }
  
    if (s != AMF3_SUCCESS)
      return (s);
  
    st_foreach(RHASH(attrs)->tbl, _encodeObjectFieldName, (st_data_t)&st);
  
    if (st.status != AMF3_SUCCESS)
      return (st.status);
  }
  
  st_foreach(RHASH(attrs)->tbl, _encodeObjectFieldValue, (st_data_t)&st);
  
  return (st.status);
}

static AMF3Status
_encodeMappedObject(struct amf3_writer *w, VALUE obj, VALUE className)
{
  VALUE attributes, attr_names;
  int i;
  
  attr_names = rb_ary_to_ary(rb_funcall(rb_obj_class(obj),
                                        rb_intern("get_attributes"), 0));

  attributes = rb_hash_new();
  for (i=0; i < RARRAY(attr_names)->len; i++) {
    VALUE attr_name = RARRAY(attr_names)->ptr[i];
    VALUE attr_value;
    
    attr_value = rb_funcall(obj, rb_to_id(attr_name), 0);
    rb_hash_aset(attributes, attr_name, attr_value);
  }
  
  return _encodeObject(w, className, attributes);
}

static AMF3Status
_encodeTime(struct amf3_writer *w, VALUE time_value)
{
  double msec;
  int idx;
  
  if (rb_funcall(time_value, rb_intern("utc?"), 0) != Qtrue) {
    time_value = rb_obj_clone(time_value);
    rb_funcall(time_value, rb_intern("utc"), 0);
  }
  
  msec = NUM2LONG(rb_funcall(time_value, rb_intern("to_i"), 0)) * 1000.0 +
         NUM2LONG(rb_funcall(time_value, rb_intern("usec"), 0)) / 1000.0;

  if ((idx = _getReferenceIndex(w->objects, time_value)) != -1) {
    return AMF3Writer_writeDateReference(w->writer, idx);
  }
  else {
    _storeReferenceIndex(w->objects, time_value);
    return AMF3Writer_writeDate(w->writer, msec);
  }
}

static AMF3Status
_encodeDate(struct amf3_writer *w, VALUE date)
{
  VALUE t;
  
  t = rb_funcall(rb_const_get(rb_cObject, rb_intern("Time")),
                 rb_intern("gm"),
                 3,
                 rb_funcall(date, rb_intern("year"), 0),
                 rb_funcall(date, rb_intern("month"), 0),
                 rb_funcall(date, rb_intern("day"), 0));

  return _encodeTime(w, t);
}

static AMF3Status
_encodeDateTime(struct amf3_writer *w, VALUE datetime)
{
   VALUE t;

   t = rb_funcall(rb_const_get(rb_cObject, rb_intern("Time")),
                  rb_intern("gm"),
                  6,
                  rb_funcall(datetime, rb_intern("year"), 0),
                  rb_funcall(datetime, rb_intern("month"), 0),
                  rb_funcall(datetime, rb_intern("day"), 0),
                  rb_funcall(datetime, rb_intern("hour"), 0),
                  rb_funcall(datetime, rb_intern("min"), 0),
                  rb_funcall(datetime, rb_intern("sec"), 0));

  return _encodeTime(w, t);
}

static AMF3Status
_encodeXML(AMF3Writer *writer, VALUE xml)
{
  VALUE xml_string;
  const unsigned char *str;
  long len;
  
  xml_string = rb_funcall(xml, rb_intern("to_s"), 0);
  str = (const unsigned char *)rb_str2cstr(xml_string, &len);  
  return AMF3Writer_writeXML(writer, str, len);
}

static AMF3Status
_encodeRecursive(struct amf3_writer *w, VALUE value)
{
  AMF3Writer *writer = w->writer;
  int idx;
  
  switch (TYPE(value)) {
  case T_NIL:
    return AMF3Writer_writeNull(writer);
  case T_FALSE:
    return AMF3Writer_writeFalse(writer);
  case T_TRUE:
    return AMF3Writer_writeTrue(writer);
  case T_FIXNUM:
    {
      int v = NUM2LONG(value);
      
      if (v >= -0x10000000 && v <= 0x0fffffff)
        return AMF3Writer_writeInteger(writer, v);
    }
    /* fall-through */
  case T_BIGNUM:
  case T_FLOAT:
    return AMF3Writer_writeNumber(writer, rb_num2dbl(value));
  case T_STRING:
    {
      const unsigned char *str;
      long len;
      
      if ((idx = _getReferenceIndex(w->strings, value)) != -1) {
        return AMF3Writer_writeStringReference(writer, idx);
      }
      else {
        _storeReferenceIndex(w->strings, value);
        str = (const unsigned char *)rb_str2cstr(value, &len);
        return AMF3Writer_writeString(writer, str, len);
      }
    }
  default:
    {
      ID is_a = rb_intern("is_a?");
      const char *className = rb_obj_classname(value);
    
      if (rb_funcall(value, is_a, 1, rb_cArray) == Qtrue) {
        value = rb_ary_to_ary(value);
      
        if ((idx = _getReferenceIndex(w->objects, value)) != -1) {
          return AMF3Writer_writeArrayReference(writer, idx);
        }
        else {
          _storeReferenceIndex(w->objects, value);
          return _encodeArray(w, value);
        }
      }
      else if (rb_funcall(value, is_a, 1, rb_cHash) == Qtrue) {
        if ((idx = _getReferenceIndex(w->objects, value)) != -1) {
          return AMF3Writer_writeObjectReference(writer, idx);
        }
        else {
          _storeReferenceIndex(w->objects, value);
          return _encodeObject(w, Qnil, value);
        }
      }
      else if (strcmp(className, "Date") == 0)
        return _encodeDate(w, value);
      else if (strcmp(className, "Time") == 0)
        return _encodeTime(w, value);
      else if (strcmp(className, "DateTime") == 0)
        return _encodeDateTime(w, value);
      else if (strcmp(className, "REXML::Document") == 0)
        return _encodeXML(writer, value);
      else if ((idx = _getReferenceIndex(w->objects, value)) != -1) {
        return AMF3Writer_writeObjectReference(writer, idx);
      }
      else {
        VALUE r = rb_check_array_type(_transformObject(w, value));
        VALUE mappedClassName;
        
        if (r != Qnil) {
          VALUE tClassName;
          VALUE tValue;
          
          tClassName = rb_ary_entry(r, 0);
          tValue = rb_ary_entry(r, 1);
          
          if (tClassName == Qnil)
            return _encodeRecursive(w, tValue);
          else {
            _storeReferenceIndex(w->objects, value);
            return _encodeObject(w, tClassName, tValue);
          }
        }
        else if ((mappedClassName = _getMappedClassName(w, className)) != Qnil) {
          _storeReferenceIndex(w->objects, value);
          return _encodeMappedObject(w, value, mappedClassName);
        }
        else
          return AMF3_UNSUPPORTED_FORMAT;
      }
    }
  }
}

static VALUE
writer_encode(VALUE self, VALUE value)
{
  AMF3Status s;
  struct amf3_writer *w;
  Data_Get_Struct(self, struct amf3_writer, w);
  
  s = _encodeRecursive(w, value);

  if (s != AMF3_SUCCESS)
    rb_raise(rb_eRuntimeError, "AMF3 encoding error");

  return self;
}

static VALUE
writer_flush(VALUE self)
{
  AMF3Status s;
  struct amf3_writer *w;
  Data_Get_Struct(self, struct amf3_writer, w);

  s = AMF3Writer_flush(w->writer);
  
  if (s != AMF3_SUCCESS)
    rb_raise(rb_eRuntimeError, "AMF3 encoding error");

  return Qnil;
}

void
Init_amf3(void)
{
  rb_AMF3 = rb_define_module("AMF3");
  rb_AMF3Writer = rb_define_class_under(rb_AMF3, "Writer", rb_cObject);

  rb_define_alloc_func(rb_AMF3Writer, writer_allocate);
  rb_define_method(rb_AMF3Writer, "initialize", writer_initialize, 3);
  rb_define_method(rb_AMF3Writer, "<<", writer_encode, 1);
  rb_define_method(rb_AMF3Writer, "flush", writer_flush, 0);
}
