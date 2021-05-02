#!/bin/bash

# Run this script as `./create-output.sh > output.txt 2>&1`

# How we want to call our executable, 
# possibly with some command line parameters
EXEC_PROGRAM="./a.out "

# Timestamp for starting this script
date

MACHINE=""
# Display machine name if uname command is available
if hash uname 2>/dev/null; then
  uname -a
  MACHINE=`uname -a`
fi

# Display user name if id command is available
if hash id 2>/dev/null; then
  id
fi

# If we are running as a GitHub action, install programs
GITHUB_MACHINE='Linux fv-az'

if [[ $MACHINE == *"${GITHUB_MACHINE}"* ]]; then
  echo "====================================================="
  echo "Running as a GitHub action, attempting to install programs"
  echo "====================================================="
  sudo apt-get update
  sudo apt-get install llvm clang-tidy valgrind
fi

# If we are running on CSSLAB and 
# clang-tidy is not active, print a message
CSSLAB_MACHINE='Linux csslab'

CLANG_TIDY_EXE='/opt/rh/llvm-toolset-7.0/root/bin/clang-tidy'

if [[ $MACHINE == *"${CSSLAB_MACHINE}"* ]]; then
    if ! hash clang-tidy 2>/dev/null && [ -e "${CLANG_TIDY_EXE}" ] ; then
        echo "====================================================="
        echo "ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR "
        echo "clang-tidy NOT found in path (but is in $CLANG_TIDY_EXE )"
        echo "Add the following command to ~/.bashrc file"
        echo "     source scl_source enable llvm-toolset-7.0"
        echo "You can add the command by executing the following line"
        echo "     echo \"source scl_source enable llvm-toolset-7.0\" >> ~/.bashrc"
        echo "====================================================="
        exit
    fi
fi

# delete a.out, do not give any errors if it does not exist
rm ./a.out 2>/dev/null

echo "====================================================="
echo "1. Compiles without warnings with -Wall -Wextra flags"
echo "====================================================="

g++ -g -std=c++11 -Wall -Wextra -Wno-sign-compare *.cpp

echo "====================================================="
echo "2. Runs and produces correct output"
echo "====================================================="

# Execute program
$EXEC_PROGRAM

echo "====================================================="
echo "3. clang-tidy warnings are fixed"
echo "====================================================="

if hash clang-tidy 2>/dev/null; then
  clang-tidy *.cpp -- -std=c++11
else
  echo "WARNING: clang-tidy not available."
fi

echo "====================================================="
echo "4. clang-format does not find any formatting issues"
echo "====================================================="

if hash clang-format 2>/dev/null; then
  # different LLVMs have slightly different configurations which can break things, so regenerate
  echo "# generated using: clang-format -style=llvm -dump-config > .clang-format" > .clang-format
  clang-format -style=llvm -dump-config >> .clang-format
  for f in ./*.cpp; do
    echo "Running clang-format on $f"
    clang-format $f | diff $f -
  done
else
  echo "WARNING: clang-format not available"
fi

echo "====================================================="
echo "5. No memory leaks using g++"
echo "====================================================="

rm ./a.out 2>/dev/null

g++ -std=c++11 -fsanitize=address -fno-omit-frame-pointer -g *.cpp
# Execute program
$EXEC_PROGRAM > /dev/null 2> /dev/null


echo "====================================================="
echo "6. No memory leaks using valgrind, look for \"definitely lost\" "
echo "====================================================="

rm ./a.out 2>/dev/null

if hash valgrind 2>/dev/null; then
  g++ -g -std=c++11 *.cpp
  # redirect program output to /dev/null will running valgrind
  valgrind --log-file="valgrind-output.txt" $EXEC_PROGRAM > /dev/null 2>/dev/null
  cat valgrind-output.txt
  rm valgrind-output.txt 2>/dev/null
else
  echo "WARNING: valgrind not available"
fi

echo "====================================================="
echo "7. Tests have full code coverage"
echo "====================================================="

if [ -f "check-code-coverage.sh" ]; then
  ./check-code-coverage.sh
else
  echo "WARNING: check-code-coverage.sh script is missing"
fi


# Remove the executable
rm -rf ./a.out* 2>/dev/null

date

echo "====================================================="
echo "To create an output.txt file with all the output from this script"
echo "Run the below command"
echo "      ./create-output.sh > output.txt 2>&1 "
echo "====================================================="
