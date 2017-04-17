#include <string>
#include <iostream>
using namespace std;

int keySize = 16;
char* message = "waterbot";
char* key = "hellodar";
unsigned char k[56];
char c[17][28], d[17][28], pk[16][48];
char ip[64];
char* encrypted;
void encrypt();
void createFirstPermutedKey();
void loadShiftArrays();
void shift(int);
void createAllKeys();
void initMessagePermute();
//initial subkey permutation table
int pc1[56] = {57,    49,    41,   33,    25,    17,    9,   1,
               58,    50,    42,   34,    26,    18,   10,   2,
               59,    51,    43,   35,    27,    19,   11,   3,
               60,    52,    44,   36,    63,    55,   47,  39,
               31,    23,    15,    7,    62,    54,   46,  38,
               30,    22,    14,    6,    61,    53,   45,  37,
               29,    21,    13,    5,    28,    20,   12,   4};
//subkey permutation table
int pc2[48] = {14,    17,   11,    24,     1,    5,
                3,    28,   15,     6,    21,   10,
               23,    19,   12,     4,    26,    8,
               16,     7,   27,    20,    13,    2,
               41,    52,   31,    37,    47,   55,
               30,    40,   51,    45,    33,   48,
               44,    49,   39,    56,    34,   53,
               46,    42,   50,    36,    29,   32};
//how much to shift c/d arrays by
int cdShift[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};
//message permutation table
int mp[64] = {58,    50,   42,    34,    26,   18,    10,    2,
              60,    52,   44,    36,    28,   20,    12,    4,
              62,    54,   46,    38,    30,   22,    14,    6,
              64,    56,   48,    40,    32,   24,    16,    8,
              57,    49,   41,    33,    25,   17,     9,    1,
              59,    51,   43,    35,    27,   19,    11,    3,
              61,    53,   45,    37,    29,   21,    13,    5,
              63,    55,   47,    39,    31,   23,    15,    7};

int main(void) {

  encrypt();

}

void encrypt() {

  createFirstPermutedKey();
  //load permuted key into tempShift to turn into c/d arrays
  loadShiftArrays();
  //begin Cn and Dn array construction
  for(int i = 0; i < 16; i++) { shift(i); }
  createAllKeys();
  initMessagePermute();

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
  }

}

void createAllKeys() {
  for(int i = 0; i < 16; i++) {
    for(int j = 0; j < 48; j++) {
      int index = pc2[j];
      if(index > 27) {//size of c/d arrays
        pk[i][j] = d[i][pc2[j] - 28];
      }
      else pk[i][j] = c[i][pc2[j]];
      cout << (int)pk[i][j];
    }
    cout << endl;
  }

}

void initMessagePermute() {
    for(int i = 0; i < 64; i++) {
      int index = mp[i];
      {
        //pull out bit needed and load into k array
        char x = message[index / 8] & (1 << (8 - (index % 8)));
        ip[i] = (x & (1 << (8 - (index % 8)))) >> (8 - (index % 8));
      }
      cout << (int)ip[i];
    }
    cout << endl;
}
