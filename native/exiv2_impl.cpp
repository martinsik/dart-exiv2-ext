//
// Created by Martin Sikora on 19/06/15.
//

//#include "exiv2_impl.h"
#include "include/dart_native_api.h"
#include "exiv2/exiv2.hpp"
#include "exiv2_enums.h"


void GetExifRecord(Dart_NativeArguments arguments) {
    Dart_EnterScope();

    Dart_Handle result;
    const char *filename;
    const char *tag;
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 1), &tag);

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();
    try {
        Exiv2::ExifKey key = Exiv2::ExifKey(tag);
        Exiv2::ExifData::const_iterator pos = exifData.findKey(key);
        result = Dart_NewStringFromCString(pos->value().toString().c_str());
    } catch (Exiv2::AnyError &e) {
        result = Dart_Null();
    }

    Dart_SetReturnValue(arguments, result);
    Dart_ExitScope();
}

void GetAllExifRecords(Dart_NativeArguments arguments) {
    Dart_EnterScope();

    const char *filename;
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);

    // Use Map object instead?
    Dart_Handle dartMapType = Dart_GetType(
            Dart_LookupLibrary(Dart_NewStringFromCString("dart:core")),
            Dart_NewStringFromCString("Map"), 0, NULL);

    Dart_Handle map = Dart_New(dartMapType, Dart_Null(), 0, NULL);

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();
    Exiv2::ExifData::const_iterator end = exifData.end();
    Exiv2::ExifData::const_iterator pointer = exifData.begin();

    // iterate all EXIF records
    for (int j = 0; pointer != end; ++pointer, j++) {
        Dart_Handle mapSetKeyValueArgs[2];
        mapSetKeyValueArgs[0] = Dart_NewStringFromCString(pointer->key().c_str());
        mapSetKeyValueArgs[1] = Dart_NewStringFromCString(pointer->value().toString().c_str());
        Dart_Invoke(map, Dart_NewStringFromCString("[]="), 2, mapSetKeyValueArgs);
    }

    Dart_SetReturnValue(arguments, map);
    Dart_ExitScope();
}

void SetExifRecord(Dart_NativeArguments arguments) {
//    tag_definition_list

}