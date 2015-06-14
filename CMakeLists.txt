cmake_minimum_required(VERSION 3.2)
project(dart_exiv2_ext)

include_directories(DART_SDK)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES exiv2_wrapper.cpp)
#add_executable(dart_exiv2_ext ${SOURCE_FILES} exiv2_wrapper.c)