#ifndef _AMF3WRITER_H_
#define _AMF3WRITER_H_

typedef enum {
  AMF3_SUCCESS,
  AMF3_IO_ERROR,
  AMF3_VALUE_TOO_LARGE,
  AMF3_UNSUPPORTED_FORMAT
} AMF3Status;

typedef struct AMF3Writer AMF3Writer;

typedef struct {
  AMF3Status (*flush)(void *);
  AMF3Status (*send)(void *, const char *, unsigned int);
} AMF3Callbacks;

AMF3Writer *AMF3Writer_new(AMF3Callbacks *callbacks);
void AMF3Writer_free(AMF3Writer *writer);
void AMF3Writer_setUserData(AMF3Writer *writer, void *userData);
void *AMF3Writer_getUserData(AMF3Writer *writer);
AMF3Status AMF3Writer_flush(AMF3Writer *writer);
AMF3Status AMF3Writer_writeNull(AMF3Writer *writer);
AMF3Status AMF3Writer_writeFalse(AMF3Writer *writer);
AMF3Status AMF3Writer_writeTrue(AMF3Writer *writer);
AMF3Status AMF3Writer_writeInteger(AMF3Writer *writer, int num);
AMF3Status AMF3Writer_writeNumber(AMF3Writer *writer, double num);
AMF3Status AMF3Writer_writeString(AMF3Writer *writer, const unsigned char *str,
                                  unsigned int len);
AMF3Status AMF3Writer_writeXML(AMF3Writer *writer, const unsigned char *str,
                               unsigned int len);
AMF3Status AMF3Writer_writeDate(AMF3Writer *writer, double msec);
AMF3Status AMF3Writer_writeArrayStart(AMF3Writer *writer, unsigned int len);
AMF3Status AMF3Writer_writeObjectStart(AMF3Writer *writer, unsigned int nfields);
AMF3Status AMF3Writer_writeFieldName(AMF3Writer *writer, const char *fieldName);
AMF3Status AMF3Writer_writeStringReference(AMF3Writer *writer, int idx);
AMF3Status AMF3Writer_writeDateReference(AMF3Writer *writer, int idx);
AMF3Status AMF3Writer_writeArrayReference(AMF3Writer *writer, int idx);
AMF3Status AMF3Writer_writeObjectReference(AMF3Writer *writer, int idx);
AMF3Status AMF3Writer_writeObjectClassReference(AMF3Writer *writer, int idx);
AMF3Status AMF3Writer_writeFieldNameReference(AMF3Writer *writer, int idx);

#endif /* !_AMF3WRITER_H_ */
