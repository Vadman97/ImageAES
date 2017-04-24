#include "encrypt.h"

using namespace std;

int main(int argc, char ** argv) {
	if (argc < 2) {
		cout << "Please specify input file name without the .coe";
		return 0;
	}
	//unsigned char* message = "waterbot";
	//unsigned char message[8] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
	//unsigned char* key = "hellodar";
	unsigned char key[8] = {0x13, 0x34, 0x57, 0x79, 0x9B, 0xBC, 0xDF, 0xF1};

	ifstream file;
	// file.open("benc.coe");

	string in_name = argv[1];
	file.open(in_name + ".coe");

	string line = "";

	vector<unsigned char> bytes;

	string header = "";

	while (getline(file, line)) {
		if (!line.length())
			continue;

		if (line[0] == ';' || line[0] == 'm') {
			header += line + "\n";
			continue;
		}

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

	unsigned char* message = new unsigned char[8];
	unsigned char* result_bin = new unsigned char[64];

	vector<unsigned char> output_buf;

	for (size_t i = 0; i < bytes.size(); i++) {
		message[i % 8] = bytes[i];
		if (i != 0 && i % 8 == 0) {
			encrypt(message, key, result_bin);

			/* unsigned char test = 0x3F;

			for (int i = 0; i < 64; i++) {
				result_bin[i] = (test & (1 << (i % 8))) ? 1 : 0;
				--test;
				printf("%X ", result_bin[i]);
			}
			printf("\n"); */

			// convert binary to dec
			unsigned long long result = 0;
			for (int j = 0; j < 64; j++) {
				if (result_bin[j])
					result += (1L << (63 - j));
			}
			//printf("%llX\n", result);

			//split up binary into bytes
			for (int j = 7; j >= 0; j--) {
				unsigned char row = (result & (0xFFL << (8 * j))) >> (8 * j);
				//printf("%X\n", row);
				output_buf.push_back(row);
			}
		}
	}

	ofstream out;
	out.open(in_name + "_enc.coe");
	out << header;

	char* piece = new char[2];
	for (size_t i = 0; i < output_buf.size(); i++) {
		// to break up the line into more readable chunks, might also be req of coe format
		if (i != 0 && i % 32 == 0)
			out << endl;

		unsigned char row = output_buf[i];

		//first four bits 0
		if (!(row & 0xF0))
			sprintf(piece, "0%X,", row);
		else
			sprintf(piece, "%X,", row);

		out << piece;
	}

	out.close();
}

void encrypt(unsigned char* message, unsigned char* key, unsigned char* result) {

  createFirstPermutedKey(key);
  //load permuted key into tempShift to turn into c/d arrays
  loadShiftArrays();
  //begin Cn and Dn array construction
  for(int i = 1; i < 17; i++) { shift(i); }
  createAllKeys();
  initMessagePermute(message);
  createAllMessagePermutations();
  getEncryption(result);
}

void createFirstPermutedKey(unsigned char* key) {
   //printf("k = ");
  for(int i = 0; i < 56; i++) {
    int index = pc1[i];
    {
      // pull out the bit needed & load into k array
      unsigned char x = key[(index - 1) / 8] & (1 << (8 - (index % 8)));
      k[i] = (x >> (8 - (index % 8)));
      //printf("%d", k[i]);
    }
  }
  //printf("\n");
}

void loadShiftArrays() {
  memcpy(c[0], k, 28);
  memcpy(d[0], k + 28, 28);
}

void shift(int j) {
  int shiftBy = cdShift[j - 1];
  for(int i = 0; i < 28; i++) {
    c[j][i] = c[j - 1][shiftBy];
    d[j][i] = d[j - 1][shiftBy];
    shiftBy++;
    if(shiftBy == 28) shiftBy = 0;
    //printf("%d", d[j][i]);
  }
  //print f("\n");

}

void createAllKeys() {
  for(int i = 0; i < 16; i++) {
    //printf("pk ");
    for(int j = 0; j < 48; j++) {
      int index = pc2[j] - 1;
      if(index > 27) {//size of c/d arrays
        pk[i][j] = d[i + 1][index - 28];
      }
      else pk[i][j] = c[i + 1][index];
      //printf("%d", pk[i][j]);
    }
    //printf("\n");
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
         //printf("%d", ip[i]);
      }
      else {
         unsigned char x = message[(index - 1) / 8] & 0x01;
         ip[i] = x;
         //printf("%d", ip[i]);
      }
    }
    //printf("\n");
}

void createAllMessagePermutations() {
  memcpy(l[0], ip, 32);
  memcpy(r[0], ip + 32, 32);

  for(int i = 1; i < 17; i++) {
    calculateLn(i);
    calculateRn(i);
  }
}

void calculateLn(int i) {
  memcpy(l[i], r[i - 1], 32);
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
  for(int j = 0; j < 32; j++) {
    int index = p[j] - 1;
    finalf[i] = f[index];
    r[i][j] = l[i - 1][j] ^ finalf[i];
  }

}

void getEncryption(unsigned char * result) {
  //printf("result: ");
  for(int i = 0; i < 64; i++) {
    int index = ip1[i] - 1;
    if(index > 31) {
      result[i] = l[16][index - 32];
    }
    else result[i] = r[16][index];
    //printf("%d", (int)result[i]);
  }
  //printf("\n");
}
