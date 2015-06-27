cmake_minimum_required(VERSION 3.2)
project(dart_exiv2_ext)

find_library(exiv2_LIBRARY "exiv2")
find_path(exiv2_HEADERS_DIR "exiv2/exiv2.hpp")

# Get full path to the Dart executable.
execute_process(COMMAND which dart OUTPUT_VARIABLE DART_EXEC OUTPUT_STRIP_TRAILING_WHITESPACE)

if (NOT DART_EXEC)
    message(FATAL_ERROR "Error: Unable to find dart executable!")
endif (NOT DART_EXEC)
# Expand symlinks.
get_filename_component(DART_EXEC ${DART_EXEC} REALPATH)

# Get path to Dart's SDK.
if ($ENV{DART_SDK})
    set(DART_SDK $ENV{DART_SDK})
else ($ENV{DART_SDK})
    get_filename_component(DART_SDK ${DART_EXEC}/../.. ABSOLUTE)
endif ($ENV{DART_SDK})

message(STATUS "exiv2_LIBRARY: " ${exiv2_LIBRARY})
message(STATUS "exiv2_HEADERS_DIR: " ${exiv2_HEADERS_DIR})
message(STATUS "DART_SDK: " ${DART_SDK})

# Get target architecture.
execute_process(COMMAND ${DART_EXEC} ${CMAKE_HOME_DIRECTORY}/tool/get_target_platform.dart OUTPUT_VARIABLE TARGET_ARCHITECTURE OUTPUT_STRIP_TRAILING_WHITESPACE)
message(STATUS "Target architecture: " ${TARGET_ARCHITECTURE})

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/lib/src)

link_libraries(${exiv2_LIBRARY})

if (${CMAKE_SYSTEM_NAME} EQUAL "Darwin")
    if (${TARGET_ARCHITECTURE} EQUAL "32")
        set(CXX_ARCHITECTURE_FLAGS "-arch i386")
    elseif (${TARGET_ARCHITECTURE} EQUAL "64")
        set(CXX_ARCHITECTURE_FLAGS "-arch x86_64")
    endif (${TARGET_ARCHITECTURE} EQUAL "32")
else (${CMAKE_SYSTEM_NAME} EQUAL "Darwin")
    set(CXX_ARCHITECTURE_FLAGS "-m${TARGET_ARCHITECTURE}")
endif (${CMAKE_SYSTEM_NAME} EQUAL "Darwin")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 ${CXX_ARCHITECTURE_FLAGS} -Wl,-undefined,dynamic_lookup -I${DART_SDK} -I${exiv2_HEADERS_DIR}")
add_library(exiv2_wrapper SHARED native/exiv2_wrapper.cpp native/exiv2_impl.cpp)
