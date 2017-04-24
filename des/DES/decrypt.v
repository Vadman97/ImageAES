`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:05 04/19/2017 
// Design Name: 
// Module Name:    encrypt 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module decrypt(
	message,
	DESkey,
	decrypted,
	done,
	clk,
	reset,
	enable, 
	ack
    );

input [7:0][7:0] message; 
input [7:0][7:0] DESkey;
output [7:0][7:0] decrypted; 
input clk, reset, enable, ack;
output done; 
reg [63:0] msg, key, result; 
reg [5:0] state; 
reg [55:0] k; //initial key permutation
reg [16:0][27:0] c, d; //shift arrays -- made with key
reg [15:0][47:0] permutedKey; //list of all permuted keys, used to decrypt
reg [31:0] r, l; //left right message permutations
reg [31:0] sOfB;
reg [47:0] l_e_xor_k;
reg [31:0] f;
reg [5:0] decrypt;

integer pc1[55:0] = {57,    49,    41,   33,    25,    17,    9,   1,
               58,    50,    42,   34,    26,    18,   10,   2,
               59,    51,    43,   35,    27,    19,   11,   3,
               60,    52,    44,   36,    63,    55,   47,  39,
               31,    23,    15,    7,    62,    54,   46,  38,
               30,    22,    14,    6,    61,    53,   45,  37,
               29,    21,    13,    5,    28,    20,   12,   4};

int pc2[48] = {14,    17,   11,    24,     1,    5,
                3,    28,   15,     6,    21,   10,
               23,    19,   12,     4,    26,    8,
               16,     7,   27,    20,    13,    2,
               41,    52,   31,    37,    47,   55,
               30,    40,   51,    45,    33,   48,
               44,    49,   39,    56,    34,   53,
               46,    42,   50,    36,    29,   32};

integer cdShift[15:0] = {1, 2, 4, 6, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 28};

int ebit[48] = { 32,     1,    2,     3,     4,    5,
                  4,     5,    6,     7,     8,    9,
                  8,     9,   10,    11,    12,   13,
                 12,    13,   14,    15,    16,   17,
                 16,    17,   18,    19,    20,   21,
                 20,    21,   22,    23,    24,   25,
                 24,    25,   26,    27,    28,   29,
                 28,    29,   30,    31,    32,    1};

int s[8][4][16] = {
                  {{14,  4,  13,  1,   2, 15,  11,  8,   3, 10,   6, 12,   5,  9,   0,  7},
                  {0, 15,   7,  4,  14,  2,  13,  1,  10,  6,  12, 11,   9,  5,   3,  8},
                  {4,  1,  14,  8,  13,  6,   2, 11,  15, 12,   9,  7,   3, 10,   5,  0},
                 {15, 12,   8,  2,   4,  9,   1,  7,   5, 11,   3, 14,  10,  0,   6, 13}},

                 {{15,  1,   8, 14,   6, 11,   3,  4,   9,  7,   2, 13,  12,  0,   5, 10},
                   {3, 13,   4,  7,  15,  2,   8, 14,  12,  0,   1, 10,   6,  9,  11,  5},
                   {0, 14,   7, 11,  10,  4,  13,  1,   5,  8,  12,  6,   9,  3,   2, 15},
                  {13,  8,  10,  1,   3, 15,   4,  2,  11,  6,   7, 12,   0,  5,  14,  9}},

                  {{10,  0,   9, 14,   6,  3,  15,  5,   1, 13,  12,  7,  11,  4,   2,  8},
                  {13,  7,   0,  9,   3,  4,   6, 10,   2,  8,   5, 14,  12, 11,  15,  1},
                  {13,  6,   4,  9,   8, 15,   3,  0,  11,  1,   2, 12,   5, 10,  14,  7},
                  {1, 10,  13,  0,   6,  9,   8,  7,   4, 15,  14,  3,  11,  5,   2, 12}},

                  {{7, 13,  14,  3,   0,  6,   9, 10,   1,  2,   8,  5,  11, 12,   4, 15},
                  {13,  8,  11,  5,   6, 15,   0,  3,   4,  7,   2, 12,   1, 10,  14,  9},
                  {10,  6,   9,  0,  12, 11,   7, 13,  15,  1,   3, 14,   5,  2,   8,  4},
                  {3, 15,   0,  6,  10,  1,  13,  8,   9,  4,   5, 11,  12,  7,   2, 14}},

                  {{2, 12,   4,  1,   7, 10,  11,  6,   8,  5,   3, 15,  13,  0,  14,  9},
                  {14, 11,   2, 12,   4,  7,  13,  1,   5,  0,  15, 10,   3,  9,   8,  6},
                  {4,  2,   1, 11,  10, 13,   7,  8,  15,  9,  12,  5,   6,  3,   0, 14},
                  {11,  8,  12,  7,   1, 14,   2, 13,   6, 15,   0,  9,  10,  4,   5,  3}},

                  {{12,  1,  10, 15,   9,  2,   6,  8,   0, 13,   3,  4,  14,  7,   5, 11},
                  {10, 15,   4,  2,   7, 12,   9,  5,   6,  1,  13, 14,   0, 11,   3,  8},
                  {9, 14,  15,  5,   2,  8,  12,  3,   7,  0,   4, 10,   1, 13,  11,  6},
                  {4,  3,   2, 12,   9,  5,  15, 10,  11, 14,   1,  7,   6,  0,   8, 13}},

                  {{4, 11,   2, 14,  15,  0,   8, 13,   3, 12,   9,  7,   5, 10,   6,  1},
                  {13,  0,  11,  7,   4,  9,   1, 10,  14,  3,   5, 12,   2, 15,   8,  6},
                  {1,  4,  11, 13,  12,  3,   7, 14,  10, 15,   6,  8,   0,  5,   9,  2},
                  {6, 11,  13,  8,   1,  4,  10,  7,   9,  5,   0, 15,  14,  2,   3, 12}},

                  {{13,  2,   8,  4,   6, 15,  11,  1,  10,  9,   3, 14,   5,  0,  12,  7},
                  {1, 15,  13,  8,  10,  3,   7,  4,  12,  5,   6, 11,   0, 14,   9,  2},
                  {7, 11,   4,  1,   9, 12,  14,  2,   0,  6,  10, 13,  15,  3,   5,  8},
                  {2,  1,  14,  7,   4, 10,   8, 13,  15, 12,   9,  0,   3,  5,   6, 11}}

                  };

integer p[31:0] = {        16,   7,  20,  21,
                         29,  12,  28,  17,
                          1,  15,  23,  26,
                          5,  18,  31,  10,
                          2,   8,  24,  14,
                         32,  27,   3,   9,
                         19,  13,  30,   6,
                         22,  11,   4,  25};

integer mp[63:0] = {58,    50,   42,    34,    26,   18,    10,    2,
							60,    52,   44,    36,    28,   20,    12,    4,
							62,    54,   46,    38,    30,   22,    14,    6,
							64,    56,   48,    40,    32,   24,    16,    8,
							57,    49,   41,    33,    25,   17,     9,    1,
							59,    51,   43,    35,    27,   19,    11,    3,
							61,    53,   45,    37,    29,   21,    13,    5,
							63,    55,   47,    39,    31,   23,    15,    7};

integer ip1[63:0] =  {40,     8,   48,    16,    56,   24,    64,   32,
                 39,     7,   47,    15,    55,   23,    63,   31,
                 38,     6,   46,    14,    54,   22,    62,   30,
                 37,     5,   45,    13,    53,   21,    61,   29,
                 36,     4,   44,    12,    52,   20,    60,   28,
                 35,     3,   43,    11,    51,   19,    59,   27,
                 34,     2,   42,    10,    50,   18,    58,   26,
                 33,     1,   41,     9,    49,   17,    57,   25};

localparam
INITIAL = 10'd1,
FIRSTPERMUTATION_MESSAGE_KEY = 10'd2,
LOADSHIFTARRAYS = 10'd4,
CREATEALLKEYS = 10'd8,
CREATE_LE_XOR_K = 10'd16,
CREATE_F = 10'd32,
S_OF_B_PERMUTE = 10'd64,
F_PERMUTE = 10'd128,
DECRYPT = 10'd256,
DONE = 10'd512;

assign key = DESkey;
assign msg = message; 

//shift array base condition:
assign c[0] = k[0:27];
assign d[0] = k[28:55];


always @ (posedge clk, posedge reset)
	begin
		if(reset)
			begin
				state <= INITIAL;
				msg <= 64'bX;
				key <= 64'bX;
				result <= 64'bX;
				decrypt <= 6'bX;
				r <= 32'bX;
				l <= 32'bX;
				l_e_xor_k <= 48'bX;
			end
		else 
			begin
				case (state) 
					INITIAL:
						begin
							integer i; 
							//state
							state <= FIRSTPERMUTATION_MESSAGE_KEY;
							//rtl
							msg <= message; 
							key <= DESkey;
							result <= 0;
							decrypt <= 0;
							for(i = 0; i < 64; i = i + 1) begin
								if(i < 32) r[i] <= msg[mp[i] - 1];
								else l[i - 32] <= msg[mp[i] - 1];
							end
							l_e_xor_k <= 48'b0;
						end
					FIRSTPERMUTATION_MESSAGE_KEY:
						begin
							integer i;
							//state
							state <= LOADSHIFTARRAYS;
							//rtl
							for(i = 0; i < 56; i = i + 1) 
								begin
									integer index; 
									index = pc1[i];
									k[i] <= key[i / 8][i % 8];
								end
						end
					LOADSHIFTARRAYS:
						begin
							integer i; 
							//state
							state <= CREATEALLKEYS;
							//rtl
							//c[0] <= {k[0:27], c[0]};
							//d[0] <= {k[28:55], d[0]};
							
							for(i = 0; i < 16; i = i + 1) begin
									integer j;
									for(j = 0; j < 28; j = j + 1) begin
											if(j + cdShift[i] > 28) begin
												c[i + 1][j] = c[0][j + cdShift[i] - 28];
												d[i + 1][j] = d[0][j + cdShift[i] - 28];
											end else begin
													c[i + 1][j] = c[0][j + cdShift[i]];
													d[i + 1][j] = d[0][j + cdShift[i]];
											end
									end
							end
						end
					CREATEALLKEYS:
						begin
							integer i, j, index;
							//state
							state <= CREATE_LE_XOR_K;
							//rtl
							for(i = 0; i < 16; i = i + 1) begin
								for(j = 0; j < 48; j = j + 1) begin
									index = pc2[i] - 1;
									if(index > 27)
										permutedKey[i][j] = d[i + 1][index - 28];
									else 
										permutedKey[i][j] = c[i + 1][index];
								end
							end
						end
					CREATE_LE_XOR_K:
						begin
							integer i; 
							reg [47:0] L_e;
							//state
							state <= S_OF_B_PERMUTE;
							//rtl
							for(i = 0; i < 48; i = i + 1) begin
								L_e = l[ebit[i] - 1] ^ permutedKey[15 - decrypt][i];
								
							end
							
							
							l_e_xor_k <= L_e;
							// l(n) = r (n - 1) + f(l (n), k (n))
						end
					S_OF_B_PERMUTE: 
						begin
							integer i;
							//state
							state <= F_PERMUTE;
							//rtl 
							for(i = 0; i < 8; i = i + 1) begin
								reg [1:0] index;
								reg [3:0] val; 
								sOfB[i * 4: i * 4 + 3] <= 
									s[i][l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]][l_e_xor_k[i * 6 + 1:i * 6 + 5]];
							end
						end
					F_PERMUTE:
						begin
							integer i; 
							//state
							if(decrypt == 15)
								state <= DECRYPT;
							else state <= CREATE_LE_XOR_K;
							//rtl
							decrypt <= decrypt + 1; 
							for(i = 0; i < 32; i = i + 1) begin
								f[i] <= sOfB[p[i] - 1];
								l[i] <= r[i] ^ sOfB[p[i] - 1];
							end
							r <= l; 
						end
					DECRYPT: 
						begin
							integer i; 
							//state 
							state <= DONE;
							//rtl
							for(i = 0; i < 64; i = i + 1) begin
								if(ip1[i] - 1 < 32) result[i] <= l[ip1[i] - 1];
								else result[i] <= r[ip1[i] - 33];
							end
						end
					DONE: 
						begin
							if(ack) state <= INITIAL;
						end
				endcase
			end
	end

assign encrypted = result;
assign done = (state == DONE);

endmodule
