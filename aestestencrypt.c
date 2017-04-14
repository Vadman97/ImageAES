#include <string>
#include <iostream>
using namespace std;

int keySize = 16;
char* message = "waterbot";
char* key = "hellodar";
char c[16][28];
char d[16][28];
char* encrypted;
void encrypt();
int pc1[56] = {57,   49,    41,   33,    25,    17,    9,
                1,   58,    50,   42,    34,    26,   18,
               10,    2,    59,   51,    43,    35,   27,
               19,   11,     3,   60,    52,    44,   36,
               63,   55,    47,   39,    31,    23,   15,
                7,   62,    54,   46,    38,    30,   22,
               14,    6,    61,   53,    45,    37,   29,
               21,   13,     5,   28,    20,    12,    4};


int main(void) {

  encrypt();

}

void encrypt() {
  char l[keySize / 2];
  char r[keySize / 2];
  copy(key, key + 4, l);
  copy(key + 4, key + 8, r);
  cout << l << " " << r << endl;

  unsigned char k[56];
  //first permuted key
  for(int i = 0; i < 56; i++) {
    int index = pc1[i];
    { // pull out the bit needed & load into k array
      char x = key[index / 8] & (1 << (8 - (index % 8)));
      k[i] = (x & (1 << (8 - (index % 8)))) >> (8 - (index % 8));
    }
    cout << (int)k[i];
  }
  cout << endl;
  //end first permuted key

  //begin Cn and Dn array construction
  for(int i = 0; i < 16; i++) {
    copy(k, k + 28, c[i]);
    copy(k + 28, k + 56, d[i]);
  }

}
