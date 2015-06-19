#include "include/dart_native_api.h"
#include "include/dart_api.h"

#ifndef DART_EXIV2_EXT_C_ENUMS_H
#define DART_EXIV2_EXT_C_ENUMS_H

/**
 * Automatically generated by /tool/generate_c_and_dart_enums_for_exiv2_tags.dart
 * Do not modify.
 */

struct ExifTagDefinition {
    ExifTag tag;
    ExifTagDataType type;
};

typedef enum {
// EXIF_TAGS_GO_HERE
} ExifTag;

typedef enum {
// EXIF_DATA_TYPES_GO_HERE
} ExifTagDataType;

ExifTagDefinition tag_definition_list[] = {
// EXIF_DEFINITIONS_GO_HERE
    {NULL, NULL}
};

#endif
