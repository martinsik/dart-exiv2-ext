#!/usr/bin/env bash
rm -rf CMakeFiles
rm Makefile
rm CMakeCache.txt
rm libexiv2_wrapper.*
rm ../../lib/src/libexiv2_wrapper.dylib
cmake ../..
make