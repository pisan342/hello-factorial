#!/bin/bash

# remove executable
rm -f ./a.out

# compile
clang++ -g -std=c++11 -Wall -Wextra -Wno-sign-compare *.cpp

# execute
./a.out
