#include <stdio.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <cstddef>
#include <vector>

using namespace std;

const static unsigned char rand_arr[] = {(unsigned char)238, (unsigned char)107, (unsigned char)12, (unsigned char)79, 
                                          (unsigned char)36, (unsigned char)116, (unsigned char)4, (unsigned char)112};

void encrypt(unsigned char* message, unsigned char* key, unsigned char* result);

int main(int argc, char ** argv) {
	if (argc < 2) {
		cout << "Please specify input file name without the .coe" << endl;
		cout << "Running dummy test mode" << endl;
		unsigned char key[8] = {0x13, 0x34, 0x57, 0x79, 0x9B, 0xBC, 0xDF, 0xF1};
		unsigned char message[8] = {0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xFF};
		unsigned char* result = new unsigned char[8];
		encrypt(message, key, result);
		for (int i = 0; i < 8; i++)
      printf("%X", result[i]);
		printf("\n");
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
	unsigned char* result = new unsigned char[8];

	vector<unsigned char> output_buf;

	for (size_t i = 0; i < bytes.size(); i++) {
		message[i % 8] = bytes[i];
		if (i != 0 && i % 8 == 0) {
			encrypt(message, key, result);

			/* unsigned char test = 0x3F;

			for (int i = 0; i < 64; i++) {
				result_bin[i] = (test & (1 << (i % 8))) ? 1 : 0;
				--test;
				printf("%X ", result_bin[i]);
			}
			printf("\n"); */

			// convert binary to dec
			/*unsigned long long result = 0;
			for (int j = 0; j < 64; j++) {
				if (result_bin[j])
					result += (1L << (63 - j));
			}*/
			//printf("%llX\n", result);

			//split up binary into bytes
			for (int j = 0; j < 8; j++) {
			  unsigned char row = result[j];
			  output_buf.push_back(row);
				
			}
			/*for (int j = 7; j >= 0; j--) {
				unsigned char row (result[k] & (0xFFL << (8 * j))) >> (8 * j);
				// printf("%X\n", row);
				output_buf.push_back(row);
			}*/
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
  /*
  for (i = 0; i < 8; i = i + 1) begin
    firstBit[i] = (DESkey[8*i+2 +: 2] ^ DESkey[8*+6 +: 2]) > 2'd1;
    secondBit[i] = (DESkey[8*i +: 2] ^ DESkey[8*i+4 +: 2]) > 2'd1;
    thirdBit[i] = (DESkey[8*i +: 4] ^ DESkey[8*i+4 +: 4]) > 3'd3;
    
    randIdx[3 * i +: 3] = {firstBit[i], secondBit[i], thirdBit[i]};
    decrypted[8 * i +: 8] <= message[8 * i +: 8] ^ rand[randIdx[3 * i +: 3] +: 8];
  end
  */
  for (int i = 0; i < 8; i++) {
    unsigned char key_piece = key[i];
    bool firstBit = ((key_piece & 0b00110000) ^ (key_piece & 0b00000011)) > 1;
    bool secondBit = ((key_piece & 0b11000000) ^ (key_piece & 0b00001100)) > 1;
    bool thirdBit = ((key_piece & 0b11110000) ^ (key_piece & 0b00001111)) > 1;
    unsigned short idx = 0;
    if (firstBit) idx += 1;
    if (secondBit) idx += 2;
    if (thirdBit) idx += 4;
    result[i] = message[i] ^ (unsigned char)rand_arr[idx];
    printf("%d - %X ", idx, result[i]);
  }
  printf("\n");
}
