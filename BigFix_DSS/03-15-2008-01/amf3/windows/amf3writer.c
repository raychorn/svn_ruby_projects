#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "amf3writer.h"

enum AMF3Types {
  AMF3_TYPE_UNDEF     = 0x00,
  AMF3_TYPE_NULL      = 0x01,
  AMF3_TYPE_FALSE     = 0x02,
  AMF3_TYPE_TRUE      = 0x03,
  AMF3_TYPE_INTEGER   = 0x04,
  AMF3_TYPE_NUMBER    = 0x05,
  AMF3_TYPE_STRING    = 0x06,
  AMF3_TYPE_XML       = 0x07,
  AMF3_TYPE_DATE      = 0x08,
  AMF3_TYPE_ARRAY     = 0x09,
  AMF3_TYPE_OBJECT    = 0x0a,
  AMF3_TYPE_XMLSTRING = 0x0b,
  AMF3_TYPE_BYTEARRAY = 0x0c
};

#define AMF3_BUFSIZ 1024

struct AMF3Writer {
  char buf[AMF3_BUFSIZ];
  unsigned int bufUsed;
  void *userData;
  AMF3Callbacks callbacks;
};

#define CHECK_BUF_SPACE(_nbytes)                                 \
  do {                                                           \
    unsigned int __wanted = (_nbytes);                           \
    assert(__wanted <= AMF3_BUFSIZ);                             \
    if (sizeof(writer->buf) - writer->bufUsed < __wanted) {      \
      AMF3Status __s;                                            \
                                                                 \
      __s = AMF3Writer_flushInternalBuffer(writer);              \
      if (__s != AMF3_SUCCESS)                                   \
        return (__s);                                            \
      assert(sizeof(writer->buf) - writer->bufUsed >= __wanted); \
    }                                                            \
  } while(0)

static AMF3Status
AMF3Writer_writeUTF8(AMF3Writer *writer, const unsigned char *str, unsigned int len);

static AMF3Status
AMF3Writer_flushInternalBuffer(AMF3Writer *writer)
{
  AMF3Status s;
  
  s = writer->callbacks.send(writer->userData, writer->buf, writer->bufUsed);
  if (s == AMF3_SUCCESS)
    writer->bufUsed = 0;
  
  return (s);
}

static AMF3Status
AMF3Writer_writeByte(AMF3Writer *writer, unsigned char byte)
{
  CHECK_BUF_SPACE(1);
  writer->buf[writer->bufUsed++] = byte;
  
  return AMF3_SUCCESS;
}

static AMF3Status
AMF3Writer_writeBytes(AMF3Writer *writer, const unsigned char *bytes, unsigned int len)
{
  CHECK_BUF_SPACE(len);
  memcpy(writer->buf + writer->bufUsed, bytes, len);
  writer->bufUsed += len;
  
  return AMF3_SUCCESS;
}

static AMF3Status
AMF3Writer_writeCompressedInteger(AMF3Writer *writer, unsigned int v)
{
  /* We can only write integers up to 29 bits in size. */
  assert((v & 0xe0000000) == 0);
  
  if (v < 0x80)
    AMF3Writer_writeByte(writer, v);
  else if (v < 0x4000) {
    AMF3Writer_writeByte(writer, ((v >> 7) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, v & 0x7f);
  }
  else if (v < 0x200000) {
    AMF3Writer_writeByte(writer, ((v >> 14) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, ((v >> 7) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, v & 0x7f);
  }
  else {
    /* 0x200000 <= v < 0x20000000 */
    AMF3Writer_writeByte(writer, ((v >> 22) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, ((v >> 15) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, ((v >> 8) & 0x7f) | 0x80);
    AMF3Writer_writeByte(writer, v & 0xff);
  }
  
  return AMF3_SUCCESS;
}

static AMF3Status
AMF3Writer_writeDouble(AMF3Writer *writer, double num)
{
  unsigned char nbuf[sizeof(num)];
  
#if BYTE_ORDER == LITTLE_ENDIAN
  int i;
  
  for (i = 0; i < sizeof(num); i++)
    nbuf[i] = ((const unsigned char *)&num)[sizeof(num)-1-i];
#else
  memcpy(nbuf, (const unsigned char *)&num, sizeof(num));
#endif

  return AMF3Writer_writeBytes(writer, nbuf, sizeof(nbuf));
}

AMF3Writer *
AMF3Writer_new(AMF3Callbacks *callbacks)
{
  AMF3Writer *writer;
  
  writer = malloc(sizeof(AMF3Writer));
  writer->userData = 0;
  writer->bufUsed = 0;
  memcpy(&writer->callbacks, callbacks, sizeof(AMF3Callbacks));
  
  return (writer);
}

void
AMF3Writer_free(AMF3Writer *writer)
{
  free(writer);
}

void
AMF3Writer_setUserData(AMF3Writer *writer, void *userData)
{
  writer->userData = userData;
}

void *
AMF3Writer_getUserData(AMF3Writer *writer)
{
  return (writer->userData);
}

AMF3Status
AMF3Writer_flush(AMF3Writer *writer)
{
  AMF3Status s;
  
  s = AMF3Writer_flushInternalBuffer(writer);
  if (s == AMF3_SUCCESS)
    return (writer->callbacks.flush(writer->userData));
  else
    return (s);
}

AMF3Status
AMF3Writer_writeNull(AMF3Writer *writer)
{
  return AMF3Writer_writeByte(writer, AMF3_TYPE_NULL);
}

AMF3Status
AMF3Writer_writeFalse(AMF3Writer *writer)
{
  return AMF3Writer_writeByte(writer, AMF3_TYPE_FALSE);
}

AMF3Status
AMF3Writer_writeTrue(AMF3Writer *writer)
{
  return AMF3Writer_writeByte(writer, AMF3_TYPE_TRUE);
}

AMF3Status
AMF3Writer_writeInteger(AMF3Writer *writer, int num)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_INTEGER);
  if (status != AMF3_SUCCESS)
    return status;

  /* We only have 29 bits to work with. */
  return AMF3Writer_writeCompressedInteger(writer, num & 0x1fffffff);
}

AMF3Status
AMF3Writer_writeNumber(AMF3Writer *writer, double num)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_NUMBER);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeDouble(writer, num);
}

AMF3Status
AMF3Writer_writeString(AMF3Writer *writer, const unsigned char *str, unsigned int len)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_STRING);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeUTF8(writer, str, len);
}

AMF3Status
AMF3Writer_writeXML(AMF3Writer *writer, const unsigned char *str, unsigned int len)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_XML);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeUTF8(writer, str, len);
}

AMF3Status
AMF3Writer_writeDate(AMF3Writer *writer, double msec)
{
  AMF3Status status;

  status = AMF3Writer_writeByte(writer, AMF3_TYPE_DATE);
  if (status != AMF3_SUCCESS)
    return status;
  
  status = AMF3Writer_writeByte(writer, 0x1); /* Inline date */
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeDouble(writer, msec);
}

AMF3Status
AMF3Writer_writeArrayStart(AMF3Writer *writer, unsigned int len)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_ARRAY);
  if (status != AMF3_SUCCESS)
    return status;

  status = AMF3Writer_writeCompressedInteger(writer, (len << 1) | 0x01);
  if (status != AMF3_SUCCESS)
    return status;

  return AMF3Writer_writeByte(writer, 0x01);
}

AMF3Status
AMF3Writer_writeObjectStart(AMF3Writer *writer, unsigned int nfields)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_OBJECT);
  if (status != AMF3_SUCCESS)
    return status;
    
  return AMF3Writer_writeCompressedInteger(writer, (nfields << 4) | 0x03);
}

AMF3Status
AMF3Writer_writeFieldName(AMF3Writer *writer, const char *fieldName)
{
  return AMF3Writer_writeUTF8(writer, (const unsigned char *)fieldName,
                              strlen(fieldName));
}

AMF3Status
AMF3Writer_writeStringReference(AMF3Writer *writer, int idx)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_STRING);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeCompressedInteger(writer, (idx << 1));
}

AMF3Status
AMF3Writer_writeDateReference(AMF3Writer *writer, int idx)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_DATE);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeCompressedInteger(writer, (idx << 1));
}

AMF3Status
AMF3Writer_writeArrayReference(AMF3Writer *writer, int idx)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_ARRAY);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeCompressedInteger(writer, (idx << 1));
}

AMF3Status
AMF3Writer_writeObjectReference(AMF3Writer *writer, int idx)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_OBJECT);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeCompressedInteger(writer, (idx << 1));
}

AMF3Status
AMF3Writer_writeObjectClassReference(AMF3Writer *writer, int idx)
{
  AMF3Status status;
  
  status = AMF3Writer_writeByte(writer, AMF3_TYPE_OBJECT);
  if (status != AMF3_SUCCESS)
    return status;
  
  return AMF3Writer_writeCompressedInteger(writer, (idx << 2) | 0x01);  
}

AMF3Status
AMF3Writer_writeFieldNameReference(AMF3Writer *writer, int idx)
{
  return AMF3Writer_writeCompressedInteger(writer, (idx << 1));
}

#define UTF16_FIRST_SURROGATE(_v) (0xd800 | ((_v - 0x10000) >> 10))
#define UTF16_SECOND_SURROGATE(_v) (0xdc00 | ((_v - 0x10000) & 0x03ff))

/* This function encodes a UTF-8 string into Java "modified UTF-8" format. */
static AMF3Status
AMF3Writer_writeUTF8(AMF3Writer *writer, const unsigned char *str, unsigned int len)
{
  const unsigned char *p, *p_end = str + len;
  unsigned int encoded_len;
  AMF3Status s;
  
  /* Compute the encoded length of the string. */
  encoded_len = len;
  for (p=str; p < p_end; p++) {
    if (p[0] == '\0')
      /* Encoded NUL is 2 bytes. */
      encoded_len++;
    else if ((p[0] & 0xf8) == 0xf0) {
      unsigned int unichar;
      
      if (p_end - p < 4) {
        /* String too short. */
        encoded_len -= (p_end - p);
        break;
      }
        
      /* Assume that the UTF-8 is well-formed. */
      unichar = (p[0] & 0x0f) << 18 | (p[1] & 0x3f) << 12 | (p[2] & 0x3f) << 6 |
                (p[3] & 0x3f);

      p+=3; /* Skip other bytes of the character. */
      
      /* If this character's encoding is overly long, skip it. */
      if (unichar < 0xffff) {
        encoded_len-=4;
        continue;
      }
        
      /* Original encoding is 4 bytes; CESU-8 encoding is 6 bytes. */
      encoded_len+=2;
    }
  }
  
  /*
   * We set the low bit to 1 to indicate that this is an inline string.
   * The remainder of the length bits are shifted up by 1 bit.
   */
  s = AMF3Writer_writeCompressedInteger(writer, (encoded_len << 1) | 0x01);
  if (s != AMF3_SUCCESS)
    return (s);
  
  for (p=str; p < p_end; p++) {
    if (p[0] == '\0') {
      /* modified UTF-8 specially encodes the NUL character os "c0 80" */
      unsigned char mutf8_nul[2] = { 0xc0, 0x80 };

      s = AMF3Writer_writeBytes(writer, mutf8_nul, sizeof(mutf8_nul));
    }
    else if ((p[0] & 0xf8) == 0xf0) { /* 4 byte UTF-8 character (U+10000 or greater) */
      unsigned int unichar;
      unsigned char cesu8[6];
      unsigned int s0, s1;
      
      if (p_end - p < 4)
        /* String too short. */
        break;
        
      /* Assume that the UTF-8 is well-formed. */
      unichar = (p[0] & 0x0f) << 18 | (p[1] & 0x3f) << 12 | (p[2] & 0x3f) << 6 |
                (p[3] & 0x3f);

      p+=3; /* Skip other bytes of the character. */
      
      /* If this character's encoding is overly long, skip it. */
      if (unichar < 0xffff)
        continue;
      
      /* Emit the character in CESU-8 encoding. */
      s0 = UTF16_FIRST_SURROGATE(unichar);
      s1 = UTF16_SECOND_SURROGATE(unichar);
      
      cesu8[0] = 0xe0 | ((s0 >> 12) & 0x0f);
      cesu8[1] = 0x80 | ((s0 >> 6)  & 0x3f);
      cesu8[2] = 0x80 | (s0         & 0x3f);
      cesu8[3] = 0xe0 | ((s1 >> 12) & 0x0f);
      cesu8[4] = 0x80 | ((s1 >> 6)  & 0x3f);
      cesu8[5] = 0x80 | (s1         & 0x3f);
      s = AMF3Writer_writeBytes(writer, cesu8, sizeof(cesu8));
    }
    else {
      s = AMF3Writer_writeByte(writer, p[0]);
    }
    
    if (s != AMF3_SUCCESS)
      return (s);
  }

  return AMF3_SUCCESS;
}
