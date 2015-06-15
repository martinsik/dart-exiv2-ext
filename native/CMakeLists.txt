cmake_minimum_required(VERSION 3.2)
project(dart_exiv2_ext)


find_library(exiv2_LIBRARY "exiv2")
find_path(exiv2_HEADERS_DIR "exiv2/exiv2.hpp")

if ($ENV{DART_SDK})
    set(DART_SDK $ENV{DART_SDK})
else ($ENV{DART_SDK})
    # Get full path to the Dart SDK.
    execute_process(COMMAND which dart OUTPUT_VARIABLE DART_EXEC OUTPUT_STRIP_TRAILING_WHITESPACE)
    # Expand symlinks.
    get_filename_component(DART_EXEC ${DART_EXEC} REALPATH)
    get_filename_component(DART_SDK ${DART_EXEC}/../.. ABSOLUTE)
endif ($ENV{DART_SDK})

message(STATUS "exiv2_LIBRARY: " ${exiv2_LIBRARY})
message(STATUS "exiv2_HEADERS_DIR: " ${exiv2_HEADERS_DIR})
message(STATUS "DART_SDK: " ${DART_SDK})

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/../../lib/src)

link_libraries(${exiv2_LIBRARY})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -arch i386 -arch x86_64 -Wl,-undefined,dynamic_lookup -I${DART_SDK} -I${exiv2_HEADERS_DIR}")

add_library(exiv2_wrapper SHARED exiv2_wrapper.cpp)