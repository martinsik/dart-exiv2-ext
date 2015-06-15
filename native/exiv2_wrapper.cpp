//
// Created by Martin Sikora on 14/06/15.
//

#include "include/dart_native_api.h"
#include "include/dart_api.h"
#include "exiv2/exiv2.hpp"


Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope);

DART_EXPORT Dart_Handle exiv2_wrapper_Init(Dart_Handle parent_library) {
    if (Dart_IsError(parent_library)) {
        return parent_library;
    }

    Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName, NULL);
    if (Dart_IsError(result_code)) {
        return result_code;
    }

    return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
    if (Dart_IsError(handle)) {
        Dart_PropagateError(handle);
    }
    return handle;
}

void GetExifRecord(Dart_NativeArguments arguments) {
    Dart_EnterScope();

    const char *filename;
    const char *tag;
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 1), &tag);

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();
    Exiv2::ExifKey key = Exiv2::ExifKey(tag);
    Exiv2::ExifData::const_iterator pos = exifData.findKey(key);

    Dart_Handle result;

    if (pos == exifData.end()) { // not found
        result = Dart_Null();
    } else {
        result = Dart_NewStringFromCString(pos->value().toString().c_str());
    }

    Dart_SetReturnValue(arguments, result);
    Dart_ExitScope();
}

void GetAllExifRecords(Dart_NativeArguments arguments) {
    Dart_EnterScope();

    const char *filename;
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);

    // Use Map object instead?
    // Dart_Handle dartMapType = Dart_GetType(
    //     Dart_LookupLibrary(Dart_NewStringFromCString("dart:core")),
    //     Dart_NewStringFromCString("Map"), 0, NULL);

    // Dart_Handle map = Dart_New(dartMapType, Dart_Null(), 0, NULL);
//Dart_Invoke()

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();
    Exiv2::ExifData::const_iterator end = exifData.end();
    Exiv2::ExifData::const_iterator pointer = exifData.begin();

    Dart_Handle result = Dart_NewList(exifData.count());

    // iterate all EXIF records
    for (int j = 0; pointer != end; ++pointer, j++) {
        // create \t delimetered char*
        std::stringstream fmt;
        fmt << pointer->key() << "\t" << pointer->value();
        const char *record = fmt.str().c_str();
        Dart_ListSetAt(result, j, Dart_NewStringFromCString(record));
    }

    Dart_SetReturnValue(arguments, result);
    Dart_ExitScope();
}

Dart_NativeFunction ResolveName(Dart_Handle name,
                                int argc,
                                bool* auto_setup_scope) {
    if (!Dart_IsString(name)) {
        return NULL;
    }
    Dart_NativeFunction result = NULL;
    if (auto_setup_scope == NULL) {
        return NULL;
    }

    Dart_EnterScope();

    const char* cname;
    HandleError(Dart_StringToCString(name, &cname));

    if (strcmp("GetAllExifRecords", cname) == 0) {
        result = GetAllExifRecords;
    } else if (strcmp("GetExifRecord", cname) == 0) {
        result = GetExifRecord;
    }

    Dart_ExitScope();
    return result;
}