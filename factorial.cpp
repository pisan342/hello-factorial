/*
 * factorial definition
 *
 * @author Yusuf Pisan
 * @date 20 Jan 2020
 */

#include "factorial.h"
#include <iostream>

using namespace std;

int fact(int N) {
  int Foo = 200;
  if (N < 30) {
    if (N <= 1)
      return 1;
    return N * fact(N - 1);
  } else {
    cout << "Too large: " << N << endl;
    return -1;
  }
}

int memoryLeakFunction() {
  int X = 10;
  int *Arr = new int[10];
  for (int I = 0; I < 10; I++) {
    Arr[I] = I;
  }
  cout << "Hello World" << endl;
  cout << "Fact 5: " << fact(5) << endl;
  // memory leak if we do not delete it
  // delete(Arr);
  return 0;
}

void unusedFunction() {
  cout << "A cout statement ";
  cout << "that is never called " << endl;
}
