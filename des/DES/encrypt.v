`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:05 04/19/2017 
// Design Name: 
// Module Name:    decrypt 
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
reg [55:0] k;
reg [63:0] ip;

integer pc1[55:0] = {57,    49,    41,   33,    25,    17,    9,   1,
               58,    50,    42,   34,    26,    18,   10,   2,
               59,    51,    43,   35,    27,    19,   11,   3,
               60,    52,    44,   36,    63,    55,   47,  39,
               31,    23,    15,    7,    62,    54,   46,  38,
               30,    22,    14,    6,    61,    53,   45,  37,
               29,    21,    13,    5,    28,    20,   12,   4};

integer mp[63:0] = {58,    50,   42,    34,    26,   18,    10,    2,
              60,    52,   44,    36,    28,   20,    12,    4,
              62,    54,   46,    38,    30,   22,    14,    6,
              64,    56,   48,    40,    32,   24,    16,    8,
              57,    49,   41,    33,    25,   17,     9,    1,
              59,    51,   43,    35,    27,   19,    11,    3,
              61,    53,   45,    37,    29,   21,    13,    5,
              63,    55,   47,    39,    31,   23,    15,    7};

localparam
INITIAL = 6'b0000001,
FIRSTPERMUTATION_MESSAGE_KEY = 6'b0000010,
LOADSHIFTARRAYS = 6'b0000100,
CREATEALLKEYS = 6'b0001000,
CREATEALLMESSAGEPERMUTATIONS = 6'b0010000,
ENCRYPT = 6'b0100000,
DONE = 7'b1000000;


always @ (posedge clk, posedge reset)
	begin
		if(reset)
			begin
				state <= INITIAL;
				msg <= 8'hX;
				key <= 8'hX;
				result <= 8'hX;
			end
		else 
			begin
				case (state) 
					INITIAL:
						begin
							//state
							state <= FIRSTPERMUTATION_MESSAGE_KEY;
							//rtl
							msg <= message; 
							key <= DESkey;
							result <= 0;
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
									k[i] <= key[index];
								end
							/*for(int i = 0; i < 64; i = i + 1) 
								begin
									integer index;
									index = mp[i] - 1;
									ip[i] <= key[index];
								end*/
						end
					LOADSHIFTARRAYS:
						begin
							
						end
					CREATEALLKEYS:
						begin
						end
					CREATEALLMESSAGEPERMUTATIONS:
						begin
						end
					ENCRYPT:
						begin
						end
					DONE: 
						begin
						end
				endcase
			end
	end

assign encrypted = result;
assign done = (state == DONE);

endmodule
