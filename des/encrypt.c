#include <string>
#include <iostream>
using namespace std;

int keySize = 16;
char* message = "waterbot";
char* key = "hellodar";
unsigned char k[56];
char c[17][28], d[17][28];
char initShiftC[28], initShiftD[28];
char* encrypted;
void encrypt();
void createFirstPermutedKey();
void loadShiftArrays();
void shift(int);
int pc1[56] = {57,    49,    41,   33,    25,    17,    9,   1,
               58,    50,    42,   34,    26,    18,   10,   2,
               59,    51,    43,   35,    27,    19,   11,   3,
               60,    52,    44,   36,    63,    55,   47,  39,
               31,    23,    15,    7,    62,    54,   46,  38,
               30,    22,    14,    6,    61,    53,   45,  37,
               29,    21,    13,    5,    28,    20,   12,   4};
int cdShift[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

int main(void) {

  encrypt();

}

void encrypt() {


  createFirstPermutedKey();

  //load permuted key into tempShift to turn into c/d arrays
  loadShiftArrays();

  //begin Cn and Dn array construction
  for(int i = 0; i < 16; i++) { shift(i); }



}

void createFirstPermutedKey() {
  for(int i = 0; i < 56; i++) {
    int index = pc1[i];
    {
      // pull out the bit needed & load into k array
      char x = key[index / 8] & (1 << (8 - (index % 8)));
      k[i] = (x & (1 << (8 - (index % 8)))) >> (8 - (index % 8));
    }
    cout << (int)k[i];
  }
  cout << endl;
}

void loadShiftArrays() {
  copy(k, k + 28, c[0]);
  copy(k + 28, k + 56, d[0]);
}

void shift(int k) {
  int shiftBy = cdShift[k];
  for(int i = 0; i < 28; i++) {
    c[k + 1][i] = c[k][shiftBy];
    d[k + 1][i] = d[k][shiftBy];
    shiftBy++;
    if(shiftBy == 28) shiftBy = 0;
    cout << (int)c[k + 1][i];
  }
  cout << endl;

}
