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
	input [63:0] message,
	input [63:0] DESkey,
	output reg [63:0] decrypted,
	output done,
	input clk,
	input reset,
	input enable, 
	input ack
    );
	 
reg [7:0] result[7:0], msg[7:0], key[7:0];
reg [10:0] state; 
reg [55:0] k; //initial key permutation
reg [15:0] c[27:0], d[27:0]; //shift arrays -- made with key
reg [15:0] permutedKey[47:0]; //list of all permuted keys, used to decrypt
reg [7:0] r[31:0], l[31:0], temp[31:0], sOfB[31:0], f[31:0]; 
//left right message permutations
// reg [31:0] sOfB;
reg [47:0] l_e_xor_k;
// reg [31:0] f;
reg [3:0] decrypt;

/*
	8 bits width
	pc1 56, 55:0
	pc2 48, 103:56
	cdShift 16, 119:104
	ebit 48, 167:120
	s 511, 679:168
	p 32, 711:680
	mp 64, 775:712
	ipl 64, 839:776
*/

reg [9:0] const_addr;
wire [7:0] const_data;
reg [3:0] t_count;

constants_mem constants_mem(
	.clka(clk), 
	.addra(const_addr),
	.douta(const_data)
);

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

//shift array base condition:
//assign c[0] = k[0:27];
//assign d[0] = k[28:55];
 
integer i;
always @* begin
	if (!reset) begin
		for (i = 0; i < 8; i = i+1) begin
			msg[i] = message[8*i +: 8];
			key[i] = DESkey[8*i +: 8];
			decrypted[8*i +: 8] = result[i];
		end
	end
end 

always @ (posedge clk, posedge reset)
	begin
		if(reset)
			begin
				state <= INITIAL;
				// who cares about this crap we can waste resources if we want to gandhi
				/*msg <= 64'bX;
				key <= 64'bX;
				result <= 64'bX;
				decrypt <= 6'bX;
				r <= 32'bX;
				l <= 32'bX;
				l_e_xor_k <= 48'bX;*/
				const_addr <= 10'd712;
				t_count <= 4'd0;
			end
		else 
			begin
				case (state) 
					INITIAL:
						begin : STATE_INITIAL
							decrypt <= 0;
							
							if (const_addr >= 10'd712) begin
								if(const_addr < 745) r[const_addr - 712] <= msg[const_data - 1];
								else l[const_addr - 712 - 32] <= msg[const_data - 1];
								
								if (const_addr == 10'd775) begin
									if (enable) begin
										state <= FIRSTPERMUTATION_MESSAGE_KEY;
										const_addr <= 10'd0;
									end
								end
							end
							if (const_addr != 10'd775)
								const_addr <= const_addr + 1;
							 
							l_e_xor_k <= 48'b0;
						end
					FIRSTPERMUTATION_MESSAGE_KEY:
						begin : STATE_FPMK
							if (const_addr >= 10'd0) begin
								k[const_addr] <= key[const_data / 8][const_data % 8];
								if(const_addr < 28) c[0][const_addr] <= key[const_data / 8][const_data % 8];
								else d[0][const_addr - 28] <= key[const_data / 8][const_data % 8];
								
								if (const_addr == 10'd55) begin
									state <= LOADSHIFTARRAYS;
									const_addr <= 10'd104;
								end
							end
							
							if (const_addr != 10'd55)
								const_addr <= const_addr + 1;
						end
					LOADSHIFTARRAYS:
						begin : STATE_LSA							
							if (const_addr >= 10'd104) begin: HELLO
								integer j;
								for(j = 0; j < 28; j = j + 1) begin
									if(j + const_data > 28) begin
										c[const_addr - 104 + 1][j] = c[0][j + const_data - 28];
										d[const_addr - 104 + 1][j] = d[0][j + const_data - 28];
									end else begin
											c[const_addr - 104 + 1][j] = c[0][j + const_data];
											d[const_addr - 104 + 1][j] = d[0][j + const_data];
									end
								end
								
								if (const_addr == 10'd119) begin
									state <= CREATEALLKEYS;
									const_addr <= 10'd56;
								end
							end
							
							if (const_addr != 10'd119)
								const_addr <= const_addr + 1;
						end
					CREATEALLKEYS:
						begin : STATE_CAK
							integer j;
							if (const_addr >= 10'd56) begin
								for(j = 0; j < 48; j = j + 1) begin
									if(const_data > 27)
										permutedKey[const_addr - 56][j] = d[const_addr - 56 + 1][const_data - 1 - 28];
									else 
										permutedKey[const_addr - 56][j] = c[const_addr - 56 + 1][const_data - 1];
								end
								
								if (const_addr == 10'd103) begin
									state <= CREATE_LE_XOR_K;
									const_addr <= 120;
								end
							end
							if (const_addr != 10'd103)
								const_addr <= const_addr + 1;
						end
					CREATE_LE_XOR_K:
						begin : STATE_CLEXORK
							reg [47:0] L_e;
							
							if (const_addr >= 10'd120) begin
								L_e = l[const_data - 1] ^ permutedKey[15 - decrypt][const_addr - 120];
								
								if (const_addr == 10'd167) begin
									state <= S_OF_B_PERMUTE;
									// preload the first data to grab
									const_addr <= 4 * (L_e[0] << 1 + L_e[5]) + L_e[1 +: 4] + 168;
								end
								l_e_xor_k <= L_e;
							end
							
							if (const_addr != 10'd167)
								const_addr <= const_addr + 1;
						end
					S_OF_B_PERMUTE: 
						begin : STATE_SBPERMUTE
							// s 511, 679:168
							//sOfB[4 * i +: 3] <= s [i]
							//						[l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]]
							//						[l_e_xor_k[i * 6 + 1:i * 6 + 5]];
							//sOfB[4 * i +: 4] <= s[i][l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]][l_e_xor_k[i * 6 + 5 +: 4]];
							//sOfB[4 * i +: 4] <= s[8 * i + 4 * (l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]) + 16 * l_e_xor_k[i * 6 + 5 +: 4]];
							//[0:7][0:3][0:15]	
							
							// sOfB[4 * t_count +: 4] <= const_data;
							sOfB[4 * t_count] <= const_data;
							
							const_addr <= 8 * t_count + 
										  4 * (l_e_xor_k[t_count * 6] << 1 + l_e_xor_k[t_count * 6 + 5]) + 
										  l_e_xor_k[t_count * 6 + 1 +: 4] + 168;
							if (t_count == 10'd7) begin
								state <= F_PERMUTE;
								t_count <= 4'd0;
							end
							
							if (t_count != 10'd7)
								t_count <= t_count + 1;
						end
					F_PERMUTE:
						begin : STATE_FPERMUTE
							if (const_addr == 10'd680) begin: PRACHI_WAS_HERE
								// temp <= l;
								integer i;
								for (i = 0; i < 32; i = i + 1) begin
									temp[i] <= l[i];
								end
							end
							
							if (const_addr >= 10'd680) begin
								f[const_addr - 680] <= sOfB[const_data - 1];
								l[const_addr - 680] <= r[const_addr - 680] ^ sOfB[const_data - 1];
								
								if (const_addr == 10'd711) begin: PLEASE_VERILOG_WHY
									//r <= temp;
									integer i;
									for (i = 0; i < 32; i = i + 1) begin
										r[i] <= temp[i];
									end
									if(decrypt == 4'd15)
										state <= DECRYPT;
									else state <= CREATE_LE_XOR_K;
									const_addr <= 10'd776;
								end
								decrypt <= decrypt + 1; 
							end
							
							if (const_addr != 10'd711)
								const_addr <= const_addr + 10'd1;
						end
					DECRYPT: 
						begin : STATE_DECRYPT							
							if (const_addr >= 10'd776) begin
								if(const_data - 1 < 32) result[const_addr - 776] <= l[const_data - 1];
								else result[const_addr - 776] <= r[const_data - 33];
								
								if (const_addr == 10'd839) begin
									state <= DONE;
									const_addr <= 0;
								end
							end
							
							if (const_addr != 10'd839)
								const_addr <= const_addr + 1;
						end
					DONE: 
						begin
							if(ack) state <= INITIAL;
						end
				endcase
			end
	end
	
assign done = (state == DONE);

endmodule
