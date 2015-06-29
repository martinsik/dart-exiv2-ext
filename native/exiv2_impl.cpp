//
// Created by Martin Sikora on 19/06/15.
//

//#include "exiv2_impl.h"
#include "include/dart_native_api.h"
#include "exiv2/exiv2.hpp"
#include "exiv2_enums.h"
#include <string.h>


Dart_Handle create_state_error(const char *message) {

    Dart_Handle type = Dart_GetType(Dart_LookupLibrary(Dart_NewStringFromCString("dart:core")),
                                    Dart_NewStringFromCString("StateError"), 0, NULL);

    Dart_Handle error;
    if (message == NULL) {
        error = Dart_New(type, Dart_Null(), 0, NULL);
    } else {
        Dart_Handle args[1];
        args[0] = Dart_NewStringFromCString(message);
        error = Dart_New(type, Dart_Null(), 1, args);
    }

    return error;
}


ExifTag_Type str_to_tag_type(const char *tag_name) {
    int i = 0;
    while (tag_definition_list[i].name != NULL) {
        ExifTagDefinition tag_def = tag_definition_list[i];
        if (strcmp(tag_def.name, tag_name) == 0) {
            return tag_def.tag;
        }
        i++;
    }
    return ExifTag_Unknown;
}

void set_exif_tag(Exiv2::ExifData *exifData, const char *tag, const char *value) {
    ExifTag_Type tag_type = str_to_tag_type(tag);
    if (tag_type == ExifTag_Unknown) {
        Dart_Handle error = Dart_NewUnhandledExceptionError(create_state_error("This tag doesn't exist"));
        Dart_PropagateError(error);
    }

    int i = 0;
    while (tag_definition_list[i].name != NULL) {
        ExifTagDefinition tagDef = tag_definition_list[i];

        // printf("%s\n", tag_definition_list[i].name);

        if (tag_type == tagDef.tag) {
            if (tagDef.type == ExifData_Ascii) {
                (*exifData)[tag] = value;
            } else {
                char *message = (char *)malloc(128);
                sprintf(message, "Value \"%s\" is not supported for tag \"%s\"", value, tag);
                Dart_Handle error = Dart_NewUnhandledExceptionError(create_state_error(message));
                Dart_PropagateError(error);
                // Should reach this point because of Dart_PropagateError.
                return;
            }
        }
        i++;
    }

}

void GetExifRecord(Dart_NativeArguments arguments) {
    Dart_EnterScope();

    Dart_Handle result = Dart_Null();
    const char *filename;
    const char *tag;
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);
    Dart_StringToCString(Dart_GetNativeArgument(arguments, 1), &tag);

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();

    Exiv2::ExifKey key = Exiv2::ExifKey(tag);
    Exiv2::ExifData::const_iterator pos = exifData.findKey(key);
    if (pos != exifData.end()) {
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
    while (pointer != end) {
        Dart_Handle mapSetKeyValueArgs[2];
        mapSetKeyValueArgs[0] = Dart_NewStringFromCString(pointer->key().c_str());
        mapSetKeyValueArgs[1] = Dart_NewStringFromCString(pointer->value().toString().c_str());
        Dart_Invoke(map, Dart_NewStringFromCString("[]="), 2, mapSetKeyValueArgs);
        pointer++;
    }

    Dart_SetReturnValue(arguments, map);
    Dart_ExitScope();
}

void SetExifRecords(Dart_NativeArguments arguments) {
//    tag_definition_list
    Dart_EnterScope();
    const char *filename;

    Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &filename);
    Dart_Handle exifTags = Dart_GetNativeArgument(arguments, 1);
    Dart_Handle keys = Dart_MapKeys(exifTags);

    intptr_t length;
    Dart_ListLength(keys, &length);
    // printf("%lu\n", length);

    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(filename);
    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();

    for (int i = 0; i < length; i++) {
        const char *tag;
        const char *value;

        Dart_Handle key = Dart_ListGetAt(keys, i);
        Dart_StringToCString(key, &tag);
        // printf("%s\n", tag);

        Dart_StringToCString(Dart_MapGetAt(exifTags, key), &value);
        // printf("%s\n", value);

        set_exif_tag(&exifData, tag, value);
    }

    image->setExifData(exifData);
    image->writeMetadata();

    Dart_Handle response = Dart_Null();

    Dart_SetReturnValue(arguments, response);
    Dart_ExitScope();
}
