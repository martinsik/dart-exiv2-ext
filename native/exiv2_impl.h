#include "include/dart_native_api.h"
#include "include/dart_api.h"

#ifndef DART_EXIV2_EXT_EXIV2_IMPL_H
#define DART_EXIV2_EXT_EXIV2_IMPL_H

void GetExifRecord(Dart_NativeArguments);
void GetAllExifRecords(Dart_NativeArguments);
void SetExifRecords(Dart_NativeArguments);
void RemoveExifRecord(Dart_NativeArguments);
void RemoveAllExifRecords(Dart_NativeArguments);

#endif //DART_EXIV2_EXT_EXIV2_IMPL_H
