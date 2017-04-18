#include "encrypt.h"

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
  createAllMessagePermutations();
  getEncryption();
}

void createFirstPermutedKey() {
  for(int i = 0; i < 56; i++) {
    int index = pc1[i];
    {
      // pull out the bit needed & load into k array
      char x = key[index / 8] & (1 << (8 - (index % 8)));
      k[i] = (x & (1 << (8 - (index % 8)))) >> (8 - (index % 8));
    }
  }
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
        pk[i][j] = d[i][index - 28];
      }
      else pk[i][j] = c[i][index];
    }
  }

}
//works
void initMessagePermute() {
    for(int i = 0; i < 64; i++) {
      int index = mp[i];
      {
        //pull out bit needed and load into k array
        char x = message[index / 8] & (1 << (8 - (index % 8)));
        ip[i] = (x & (1 << (8 - (index % 8)))) >> (8 - (index % 8));
      }
    }
}

void createAllMessagePermutations() {
  copy(ip, ip + 32, l[0]);
  copy(ip + 32, ip + 64, r[0]);

  for(int i = 1; i < 17; i++) {
    calculateLn(i);
    calculateRn(i);
  }
}

void calculateLn(int i) {
  cout << "hello" << endl;
  copy(r[i - 1], r[i - 1] + 32, l[i]);
  if(i == 3) {
    for(int j = 0; j < 32; j++) {
      cout << (int)l[i][j];
    }
    cout << endl;
  }
}

void calculateRn(int i) {
  char e[48];
  char kXORe[48];
  char f[32];
  // cout << "enter for" << endl;s
  for(int j = 0; j < 48; j++) {
    e[j] = r[i - 1][ebit[j] - 1];
    kXORe[j] = pk[i][j] ^ e[j];
    // if(i == 15) cout << (int)e[j];
  }
  // if(i == 15) cout << endl;
  // for(int j = 0; j < 48; j++) {
  //   if(i == 15) cout << (int)pk[i][j];
  // }
  // if(i == 15) cout << endl;
  // for(int j = 0; j < 48; j++) {
  //   cout << (int)kXORe[j];
  // }
  // cout << endl;

  for(int j = 0; j < 8; j++) {
    char temp[6];
    copy(kXORe + (j * 6), kXORe + (j * 6) + 6, temp);
    int index = (int)(temp[0] << 1) + (int)temp[5];
    int col = (int)((temp[1] << 3) + (temp[2] << 2) + (temp[3] << 1) + temp[4]);
    char load = s[j][index][col];

    for(int k = 0; k < 4; k++) {
      char x = load & (1 << (3 - k));
      x = x >> (3 - k);
      f[j * 4 + k] = x;
      r[i][j * 4 + k] = l[i - 1][j * 4 + k] ^ f[j * 4 + k];
    }
  }

}

void getEncryption() {
  for(int i = 0; i < 64; i++) {
    int index = ip1[i];
    if(index > 31) {
      result[i] = l[16][index - 32];
    }
    else result[i] = r[16][index];
  }
}
