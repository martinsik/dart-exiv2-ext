//
// Created by Martin Sikora on 14/06/15.
//

#include "include/dart_native_api.h"
#include "include/dart_api.h"
#include "exiv2/exiv2.hpp"
#include "exiv2_impl.h"

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