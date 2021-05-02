#!/bin/bash
# Compile the program with code coverage flags and generate report

# Basedon information from
# https://github.com/mapbox/cpp/blob/master/docs/coverage.md

# How we want to call our executable, 
# possibly with some command line parameters
EXEC_PROGRAM="./a.out "

######################################################################
PROG=$0
EXE="a.out"
PROFDATA=$EXE.profdata
CC=clang++

rm $EXE $PROFDATA default.profraw 2>/dev/null

programs=($CC "llvm-profdata" "llvm-cov")
for p in "${programs[@]}"; do
    if ! hash $CC 2>/dev/null; then
        echo "ERROR: $PROG: cannot find $CC executable"
        exit 1
    fi
done

$CC -g -std=c++11 -fprofile-instr-generate -fcoverage-mapping *.cpp -o $EXE

if [ ! -f $EXE ]; then
    echo "ERROR: $PROG: Failed to create executable"
    exit 1
fi

# Execute the program
$EXEC_PROGRAM > /dev/null 2>/dev/null

if [ ! -f "default.profraw" ]; then
    echo "ERROR: $PROG: Failed to create default.profraw data"
    rm -rf ./a.out* 
    exit 1
fi

llvm-profdata merge default.profraw -output=$PROFDATA

if [ ! -f $PROFDATA ]; then
    echo "ERROR: $PROG: Failed to create $PROFDATA"
    rm -rf ./a.out* default.profraw 
    exit 1
fi


# GitHub actions do not have demangler program
if hash llvm-cxxfilt 2>/dev/null; then
    llvm-cov report -show-functions=1 -Xdemangler=llvm-cxxfilt $EXE -instr-profile=$PROFDATA *.cpp
else
    llvm-cov report -show-functions=1 $EXE -instr-profile=$PROFDATA *.cpp
fi

  echo "====================================================="
  echo "The lines below were never executed"
  echo "====================================================="
llvm-cov show $EXE -instr-profile=$PROFDATA | grep " 0|"

rm -rf ./a.out* $EXE $PROFDATA default.profraw 2>/dev/null
