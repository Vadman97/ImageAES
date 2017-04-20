#include "encrypt.h"

using namespace std;

int main(void) {
	//unsigned char* message = "waterbot";
	//unsigned char message[8] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
	//unsigned char* key = "hellodar";
	unsigned char key[8] = {0x13, 0x34, 0x57, 0x79, 0x9B, 0xBC, 0xDF, 0xF1};

	ifstream file;
	file.open("benc.coe");
	string line = "";
	
	vector<unsigned char> bytes;
	
	while (getline(file, line)) {
		if (!line.length())
			continue;
		
		if (line[0] == ';' || line[0] == 'm')
			continue;
		
		stringstream ss(line);
		string chunk = "";
		while(getline(ss, chunk, ',')) {
			stringstream ss2;
			ss2 << hex << chunk;
			unsigned short byte = 0;
			ss2 >> byte;
			bytes.push_back(byte);
			//cout << hex << byte << ',';
		}
		//cout << endl;
	}
	
	unsigned char* message = new unsigned char[bytes.size()];
	
	for (size_t i = 0; i < bytes.size(); i++) {
		message[i] = bytes[i];
	}

	encrypt(message, key);
}

void encrypt(unsigned char* message, unsigned char* key) {

  createFirstPermutedKey(key);
  //load permuted key into tempShift to turn into c/d arrays
  loadShiftArrays();
  //begin Cn and Dn array construction
  for(int i = 1; i < 17; i++) { shift(i); }
  createAllKeys();
  initMessagePermute(message);
  createAllMessagePermutations();
  getEncryption();
}

void createFirstPermutedKey(unsigned char* key) {
   printf("k = ");
  for(int i = 0; i < 56; i++) {
    int index = pc1[i];
    {
      // pull out the bit needed & load into k array
      unsigned char x = key[(index - 1) / 8] & (1 << (8 - (index % 8)));
      k[i] = (x >> (8 - (index % 8)));
      printf("%d", k[i]);
    }
  }
  printf("\n");
}

void loadShiftArrays() {
  memcpy(c[0], k, 28);
  printf("c0 = ");
  for(int i = 0; i < 28; i++) {
    printf("%d", c[0][i]);
  }
  printf("\n");
  memcpy(d[0], k + 28, 28);
  printf("d0 = ");
  for(int i = 0; i < 28; i++) {
    printf("%d", d[0][i]);
  }
  printf("\n");
}

void shift(int j) {
  int shiftBy = cdShift[j - 1];
  for(int i = 0; i < 28; i++) {
    c[j][i] = c[j - 1][shiftBy];
    d[j][i] = d[j - 1][shiftBy];
    shiftBy++;
    if(shiftBy == 28) shiftBy = 0;
    printf("%d", d[j][i]);
  }
  printf("\n");

}

void createAllKeys() {
  for(int i = 0; i < 16; i++) {
    printf("pk ");
    for(int j = 0; j < 48; j++) {
      int index = pc2[j] - 1;
      if(index > 27) {//size of c/d arrays
        pk[i][j] = d[i + 1][index - 28];
      }
      else pk[i][j] = c[i + 1][index];
      printf("%d", pk[i][j]);
    }
    printf("\n");
  }

}
//works
void initMessagePermute(unsigned char* message) {
    for(int i = 0; i < 64; i++) {
      int index = mp[i];
      
      if(index % 8 != 0)
      {
        //pull out bit needed and load into k array
        unsigned char x = message[index / 8] & (1 << (8 - (index % 8)));
        ip[i] = (x >> (8 - (index % 8)));
         printf("%d", ip[i]);
      }
      else {
         unsigned char x = message[(index - 1) / 8] & 0x01;
         ip[i] = x;
         printf("%d", ip[i]);
      }
    }
    printf("\n");
}

void createAllMessagePermutations() {
  memcpy(l[0], ip, 32);
  printf("l0 = ");
  for(int i = 0; i < 32; i++) {
    printf("%d", l[0][i]);
  }
  printf("\n");
  memcpy(r[0], ip + 32, 32);
  printf("r0 = ");
  for(int i = 0; i < 32; i++) {
    printf("%d", r[0][i]);
  }
  printf("\n");

  for(int i = 1; i < 17; i++) {
    calculateLn(i);
    calculateRn(i);
  }
}

void calculateLn(int i) {
  memcpy(l[i], r[i - 1], 32);
  printf("l%d = ", i);
  for(int j = 0; j < 32; j++) {
    printf("%d", l[i][j]);
  }
  printf("\n");
}

void calculateRn(int i) {
  char e[48];
  char kXORe[48];
  char f[32], finalf[32];
  for(int j = 0; j < 48; j++) {
    e[j] = r[i - 1][(ebit[j] - 1)];
    kXORe[j] = pk[i - 1][j] ^ e[j];
  }

  for(int m = 0; m < 8; m++) {
    char temp[6];
    memcpy(temp, kXORe + (m * 6), 6);
    int index = (int)(temp[0] << 1) + (int)temp[5];
    int col = (int)((temp[1] << 3) + (temp[2] << 2) + (temp[3] << 1) + temp[4]);
    char load = s[m][index][col];

    for(int k = 0; k < 4; k++) {
      char x = load & (1 << (3 - k));
      x = x >> (3 - k);
      f[m * 4 + k] = x;
      r[i][m * 4 + k] = l[i - 1][m * 4 + k] ^ f[m * 4 + k];
    }
  }
  printf("r%d = ", i);
  for(int j = 0; j < 32; j++) {
    int index = p[j] - 1; 
    finalf[i] = f[index]; 
    r[i][j] = l[i - 1][j] ^ finalf[i];
    printf("%d", r[i][j]);
  }
  printf("\n");

}

void getEncryption() {
  printf("result: ");
  for(int i = 0; i < 64; i++) {
    int index = ip1[i] - 1;
    if(index > 31) {
      result[i] = l[16][index - 32];
    }
    else result[i] = r[16][index];
    printf("%d", (int)result[i]);
  }
  printf("\n");
}
