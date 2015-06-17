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
        result = result = Dart_Null();
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

// source: https://github.com/dart-lang/sdk/blob/master/samples/sample_extension/sample_extension.cc
struct FunctionLookup {
    const char* name;
    Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"GetAllExifRecords", GetAllExifRecords},
    {"GetExifRecord", GetExifRecord},
    {NULL, NULL}
};

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

    for (int i=0; function_list[i].name != NULL; ++i) {
        if (strcmp(function_list[i].name, cname) == 0) {
            *auto_setup_scope = true;
            result = function_list[i].function;
            break;
        }
    }

    Dart_ExitScope();
    return result;
}