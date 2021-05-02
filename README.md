# hello-world

`README.md` - This file

`.gitignore` - files that should not be added to GitHub

`.clang-format` - Defines the formatting and indentation style.
See https://clang.llvm.org/docs/ClangFormat.html for additional details.
To fix formatting and modify file, use
`clang-format -i main.cpp`

`main.cpp` - stub file, no changes needed

`factorial.cpp` - Defintion of factorial

`factorial.h` - Header file `factorial.cpp`

`output.txt` - Shows compiling and running program

`create-output.sh` - script to create `output.txt` file. Run it as `./create-output.sh > output.txt 2>&1`


`.github/workflows/buildrun.yml` - GitHub Workflow instructions on how to compile and run the project when it is pushed to GitHub

# Full Check

1. Compiles without warnings with -Wall -Wextra flags
```
    $ g++ -g -Wall -Wextra -Wno-sign-compare *.cpp
 ```
 2. Runs and produces correct output
 ```
    $ ./a.out
 ```
3. clang-tidy warnings are fixed, modify .clang-tidy removing minimum number of tests as needed
```
    $ clang-tidy *.cpp -- -std=c++14
 ```
4. clang-format does not find any formatting issues
```
    $ for f in ./*.cpp; do clang-format $f | diff $f - ; done
```
5. No memory leaks using g++
```
    $ g++ -fsanitize=address -fno-omit-frame-pointer -g *.cpp
    $ ./a.out
 ```
6. No memory leaks using valgrind, look for "in use at exit"
```
    $ g++ -fsanitize=address -fno-omit-frame-pointer -g *.cpp
    $ valgrind ./a.out
 ```
 7. Tests have full code coverage
 ```
    $ ./check-code-coverage.sh
```