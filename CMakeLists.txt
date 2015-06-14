cmake_minimum_required(VERSION 3.2)
project(dart_exiv2_ext)


find_library(exiv2_LIBRARY "exiv2")
find_path(exiv2_HEADERS_DIR "exiv2/exiv2.hpp")

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(DART_SDK "/Applications/dart/dart-sdk")
#    set(DART_SDK $ENV{DART_SDK})
endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

#include_directories(DART_SDK_INCLUDE exiv2_HEADERS_DIR)

MESSAGE(STATUS "exiv2_LIBRARY: " ${exiv2_LIBRARY})
MESSAGE(STATUS "exiv2_HEADERS_DIR: " ${exiv2_HEADERS_DIR})
MESSAGE(STATUS "DART_SDK: " ${DART_SDK})
#MESSAGE(STATUS "CMAKE_SYSTEM_NAME: " ${CMAKE_SYSTEM_NAME})

link_libraries(${exiv2_LIBRARY})

#include_directories("${PROJECT_SOURCE_DIR}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wl,-undefined,dynamic_lookup -I${DART_SDK} -I${exiv2_HEADERS_DIR}")

add_library(exiv2_wrapper SHARED exiv2_wrapper.cpp)
#add_executable(dart_exiv2_ext ${SOURCE_FILES} exiv2_wrapper.c)