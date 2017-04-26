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
reg [16:0] c[27:0], d[27:0]; //shift arrays -- made with key
reg [15:0] permutedKey[47:0]; //list of all permuted keys, used to decrypt
reg [31:0] r, l; //left right message permutations
reg [31:0] sOfB;
reg [47:0] l_e_xor_k;
reg [31:0] f;
reg [5:0] decrypt;

reg [55:0] pc1 = {6'd57, 6'd49, 6'd41, 6'd33, 6'd25, 6'd17, 6'd9, 6'd1,
				 6'd58, 6'd50, 6'd42, 6'd34, 6'd26, 6'd18, 6'd10, 6'd2,
				 6'd59, 6'd51, 6'd43, 6'd35, 6'd27, 6'd19, 6'd11, 6'd3,
				 6'd60, 6'd52, 6'd44, 6'd36, 6'd63, 6'd55, 6'd47, 6'd39,
				 6'd31, 6'd23, 6'd15, 6'd7, 6'd62, 6'd54, 6'd46, 6'd38,
				 6'd30, 6'd22, 6'd14, 6'd6, 6'd61, 6'd53, 6'd45, 6'd37,
				 6'd29, 6'd21, 6'd13, 6'd5, 6'd28, 6'd20, 6'd12, 6'd4};

reg [47:0] pc2 = {6'd14, 6'd17, 6'd11, 6'd24, 6'd1, 6'd5,
					6'd3, 6'd28, 6'd15, 6'd6, 6'd21, 6'd10,
					6'd23, 6'd19, 6'd12, 6'd4, 6'd26, 6'd8,
					6'd16, 6'd7, 6'd27, 6'd20, 6'd13, 6'd2,
					6'd41, 6'd52, 6'd31, 6'd37, 6'd47, 6'd55,
					6'd30, 6'd40, 6'd51, 6'd45, 6'd33, 6'd48,
					6'd44, 6'd49, 6'd39, 6'd56, 6'd34, 6'd53,
					6'd46, 6'd42, 6'd50, 6'd36, 6'd29, 6'd32};

reg [15:0] cdShift = {5'd1, 5'd2, 5'd4, 5'd6, 5'd8, 5'd10, 5'd12, 5'd14, 5'd15, 5'd17, 5'd19, 5'd21, 5'd23, 5'd25, 5'd27, 5'd28};

reg [47:0] ebit = {6'd32, 6'd 1, 6'd2, 6'd3, 6'd4, 6'd5,
					6'd4, 6'd 5, 6'd6, 6'd7, 6'd8, 6'd9,
					6'd8, 6'd 9, 6'd10, 6'd11, 6'd12, 6'd13,
					6'd12, 6'd13, 6'd14, 6'd15, 6'd16, 6'd17,
					6'd16, 6'd17, 6'd18, 6'd19, 6'd20, 6'd21,
					6'd20, 6'd21, 6'd22, 6'd23, 6'd24, 6'd25,
					6'd24, 6'd25, 6'd26, 6'd27, 6'd28, 6'd29,
					6'd28, 6'd29, 6'd30, 6'd31, 6'd32, 6'd1};
		
//integer test [0:3][0:1][0:1] = {14,  4,  13,  1,   2, 15,  11,  8,   3, 10,   6, 12,   5,  9,   0,  7};

		/*[0:7][0:3][0:15]*/ 
reg [511:0] s  = {
					5'd14, 5'd4, 5'd13, 5'd1, 5'd2, 5'd15, 5'd11, 5'd8, 5'd3, 5'd10, 5'd6, 5'd12, 5'd5, 5'd9, 5'd0, 5'd7,
					5'd0, 5'd15, 5'd7, 5'd4, 5'd14, 5'd2, 5'd13, 5'd1, 5'd10, 5'd6, 5'd12, 5'd11, 5'd9, 5'd5, 5'd3, 5'd8,
					5'd4, 5'd1, 5'd14, 5'd8, 5'd13, 5'd6, 5'd2, 5'd11, 5'd15, 5'd12, 5'd9, 5'd7, 5'd3, 5'd10, 5'd5, 5'd0,
					5'd15, 5'd12, 5'd8, 5'd2, 5'd4, 5'd9, 5'd1, 5'd7, 5'd5, 5'd11, 5'd3, 5'd14, 5'd10, 5'd0, 5'd6, 5'd13,

					5'd15, 5'd1, 5'd8, 5'd14, 5'd6, 5'd11, 5'd3, 5'd4, 5'd9, 5'd7, 5'd2, 5'd13, 5'd12, 5'd0, 5'd5, 5'd10,
					5'd3, 5'd13, 5'd4, 5'd7, 5'd15, 5'd2, 5'd8, 5'd14, 5'd12, 5'd0, 5'd1, 5'd10, 5'd6, 5'd9, 5'd11, 5'd5,
					5'd0, 5'd14, 5'd7, 5'd11, 5'd10, 5'd4, 5'd13, 5'd1, 5'd5, 5'd8, 5'd12, 5'd6, 5'd9, 5'd3, 5'd2, 5'd15,
					5'd13, 5'd8, 5'd10, 5'd1, 5'd3, 5'd15, 5'd4, 5'd2, 5'd11, 5'd6, 5'd7, 5'd12, 5'd0, 5'd5, 5'd14, 5'd9,

					5'd10, 5'd0, 5'd9, 5'd14, 5'd6, 5'd3, 5'd15, 5'd5, 5'd1, 5'd13, 5'd12, 5'd7, 5'd11, 5'd4, 5'd2, 5'd8,
					5'd13, 5'd7, 5'd0, 5'd9, 5'd3, 5'd4, 5'd6, 5'd10, 5'd2, 5'd8, 5'd5, 5'd14, 5'd12, 5'd11, 5'd15, 5'd1,
					5'd13, 5'd6, 5'd4, 5'd9, 5'd8, 5'd15, 5'd3, 5'd0, 5'd11, 5'd1, 5'd2, 5'd12, 5'd5, 5'd10, 5'd14, 5'd7,
					5'd1, 5'd10, 5'd13, 5'd0, 5'd6, 5'd9, 5'd8, 5'd7, 5'd4, 5'd15, 5'd14, 5'd3, 5'd11, 5'd5, 5'd2, 5'd12,

					5'd7, 5'd13, 5'd14, 5'd3, 5'd0, 5'd6, 5'd9, 5'd10, 5'd1, 5'd2, 5'd8, 5'd5, 5'd11, 5'd12, 5'd4, 5'd15,
					5'd13, 5'd8, 5'd11, 5'd5, 5'd6, 5'd15, 5'd0, 5'd3, 5'd4, 5'd7, 5'd2, 5'd12, 5'd1, 5'd10, 5'd14, 5'd9,
					5'd10, 5'd6, 5'd9, 5'd0, 5'd12, 5'd11, 5'd7, 5'd13, 5'd15, 5'd1, 5'd3, 5'd14, 5'd5, 5'd2, 5'd8, 5'd4,
					5'd3, 5'd15, 5'd0, 5'd6, 5'd10, 5'd1, 5'd13, 5'd8, 5'd9, 5'd4, 5'd5, 5'd11, 5'd12, 5'd7, 5'd2, 5'd14,

					5'd2, 5'd12, 5'd4, 5'd1, 5'd7, 5'd10, 5'd11, 5'd6, 5'd8, 5'd5, 5'd3, 5'd15, 5'd13, 5'd0, 5'd14, 5'd9,
					5'd14, 5'd11, 5'd2, 5'd12, 5'd4, 5'd7, 5'd13, 5'd1, 5'd5, 5'd0, 5'd15, 5'd10, 5'd3, 5'd9, 5'd8, 5'd6,
					5'd4, 5'd2, 5'd1, 5'd11, 5'd10, 5'd13, 5'd7, 5'd8, 5'd15, 5'd9, 5'd12, 5'd5, 5'd6, 5'd3, 5'd0, 5'd14,
					5'd11, 5'd8, 5'd12, 5'd7, 5'd1, 5'd14, 5'd2, 5'd13, 5'd6, 5'd15, 5'd0, 5'd9, 5'd10, 5'd4, 5'd5, 5'd3,

					5'd12, 5'd1, 5'd10, 5'd15, 5'd9, 5'd2, 5'd6, 5'd8, 5'd0, 5'd13, 5'd3, 5'd4, 5'd14, 5'd7, 5'd5, 5'd11,
					5'd10, 5'd15, 5'd4, 5'd2, 5'd7, 5'd12, 5'd9, 5'd5, 5'd6, 5'd1, 5'd13, 5'd14, 5'd0, 5'd11, 5'd3, 5'd8,
					5'd9, 5'd14, 5'd15, 5'd5, 5'd2, 5'd8, 5'd12, 5'd3, 5'd7, 5'd0, 5'd4, 5'd10, 5'd1, 5'd13, 5'd11, 5'd6,
					5'd4, 5'd3, 5'd2, 5'd12, 5'd9, 5'd5, 5'd15, 5'd10, 5'd11, 5'd14, 5'd1, 5'd7, 5'd6, 5'd0, 5'd8, 5'd13,

					5'd4, 5'd11, 5'd2, 5'd14, 5'd15, 5'd0, 5'd8, 5'd13, 5'd3, 5'd12, 5'd9, 5'd7, 5'd5, 5'd10, 5'd6, 5'd1,
					5'd13, 5'd0, 5'd11, 5'd7, 5'd4, 5'd9, 5'd1, 5'd10, 5'd14, 5'd3, 5'd5, 5'd12, 5'd2, 5'd15, 5'd8, 5'd6,
					5'd1, 5'd4, 5'd11, 5'd13, 5'd12, 5'd3, 5'd7, 5'd14, 5'd10, 5'd15, 5'd6, 5'd8, 5'd0, 5'd5, 5'd9, 5'd2,
					5'd6, 5'd11, 5'd13, 5'd8, 5'd1, 5'd4, 5'd10, 5'd7, 5'd9, 5'd5, 5'd0, 5'd15, 5'd14, 5'd2, 5'd3, 5'd12,

					5'd13, 5'd2, 5'd8, 5'd4, 5'd6, 5'd15, 5'd11, 5'd1, 5'd10, 5'd9, 5'd3, 5'd14, 5'd5, 5'd0, 5'd12, 5'd7,
					5'd1, 5'd15, 5'd13, 5'd8, 5'd10, 5'd3, 5'd7, 5'd4, 5'd12, 5'd5, 5'd6, 5'd11, 5'd0, 5'd14, 5'd9, 5'd2,
					5'd7, 5'd11, 5'd4, 5'd1, 5'd9, 5'd12, 5'd14, 5'd2, 5'd0, 5'd6, 5'd10, 5'd13, 5'd15, 5'd3, 5'd5, 5'd8,
					5'd2, 5'd1, 5'd14, 5'd7, 5'd4, 5'd10, 5'd8, 5'd13, 5'd15, 5'd12, 5'd9, 5'd0, 5'd3, 5'd5, 5'd6, 5'd11
                  };

reg [31:0] p = {6'd16, 6'd7, 6'd20, 6'd21,
				6'd29, 6'd12, 6'd28, 6'd17,
				6'd1, 6'd15, 6'd23, 6'd26,
				6'd5, 6'd18, 6'd31, 6'd10,
				6'd2, 6'd8, 6'd24, 6'd14,
				6'd32, 6'd27, 6'd3, 6'd9,
				6'd19, 6'd13, 6'd30, 6'd6,
				6'd22, 6'd11, 6'd4, 6'd25};

reg [63:0] mp = {7'd58, 7'd50, 7'd42, 7'd34, 7'd26, 7'd18, 7'd10, 7'd2,
				7'd60, 7'd52, 7'd44, 7'd36, 7'd28, 7'd20, 7'd12, 7'd4,
				7'd62, 7'd54, 7'd46, 7'd38, 7'd30, 7'd22, 7'd14, 7'd6,
				7'd64, 7'd56, 7'd48, 7'd40, 7'd32, 7'd24, 7'd16, 7'd8,
				7'd57, 7'd49, 7'd41, 7'd33, 7'd25, 7'd17, 7'd 9, 7'd1,
				7'd59, 7'd51, 7'd43, 7'd35, 7'd27, 7'd19, 7'd11, 7'd3,
				7'd61, 7'd53, 7'd45, 7'd37, 7'd29, 7'd21, 7'd13, 7'd5,
				7'd63, 7'd55, 7'd47, 7'd39, 7'd31, 7'd23, 7'd15, 7'd7};

reg [63:0] ip1 =  {7'd40, 7'd8, 7'd48, 7'd16, 7'd56, 7'd24, 7'd 64, 7'd32,
					7'd39, 7'd7, 7'd47, 7'd15, 7'd55, 7'd23, 7'd 63, 7'd31,
					7'd38, 7'd6, 7'd46, 7'd14, 7'd54, 7'd22, 7'd 62, 7'd30,
					7'd37, 7'd5, 7'd45, 7'd13, 7'd53, 7'd21, 7'd 61, 7'd29,
					7'd36, 7'd4, 7'd44, 7'd12, 7'd52, 7'd20, 7'd 60, 7'd28,
					7'd35, 7'd3, 7'd43, 7'd11, 7'd51, 7'd19, 7'd 59, 7'd27,
					7'd34, 7'd2, 7'd42, 7'd10, 7'd50, 7'd18, 7'd 58, 7'd26,
					7'd33, 7'd1, 7'd41, 7'd9, 7'd49, 7'd17, 7'd 57, 7'd25};

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
	for (i = 0; i < 8; i = i+1) begin
		msg[i] = message[8*i +: 8];
		key[i] = DESkey[8*i +: 8];
		decrypted[8*i +: 8] = result[i];
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
			end
		else 
			begin
				case (state) 
					INITIAL:
						begin : STATE_INITIAL
							integer i, t1, t2; 
							//state
							if(enable) state <= FIRSTPERMUTATION_MESSAGE_KEY;
							//rtl
							
							//result <= 0;
							decrypt <= 0;
							for(i = 0; i < 64; i = i + 1) begin
								if(i < 32) r[i] <= msg[mp[i] - 1];
								else l[i - 32] <= msg[mp[i] - 1];
							end
							l_e_xor_k <= 48'b0;
						end
					FIRSTPERMUTATION_MESSAGE_KEY:
						begin : STATE_FPMK
							integer i;
							//state
							state <= LOADSHIFTARRAYS;
							//rtl
							for(i = 0; i < 56; i = i + 1) 
								begin 
									k[i] <= key[pc1[i] / 8][pc1[i] % 8];
									if(i < 28) c[0][i] <= key[pc1[i] / 8][pc1[i] % 8];
									else d[0][i] <= key[pc1[i - 28] / 8][pc1[i - 28] % 8];
								end
						end
					LOADSHIFTARRAYS:
						begin : STATE_LSA
							integer i; 
							//state
							state <= CREATEALLKEYS;
							//rtl
							//c[0] <= {k[0:27], c[0]};
							//d[0] <= {k[28:55], d[0]};
							
							for(i = 0; i < 16; i = i + 1) begin : FOR
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
						begin : STATE_CAK
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
						begin : STATE_CLEXORK
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
						begin : STATE_SBPERMUTE
							integer i;
							//state
							state <= F_PERMUTE;
							//rtl 
							for(i = 0; i < 8; i = i + 1) begin : FOR
								//sOfB[4 * i +: 3] <= s[i][l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]][l_e_xor_k[i * 6 + 1:i * 6 + 5]];
								//sOfB[4 * i +: 4] <= s[i][l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]][l_e_xor_k[i * 6 + 5 +: 4]];
								sOfB[4 * i +: 4] <= s[8 * i + 4 * (l_e_xor_k[i * 6] << 1 + l_e_xor_k[i * 6 + 5]) + 16 * l_e_xor_k[i * 6 + 5 +: 4]];
								//[0:7][0:3][0:15]
								
							end
						end
					F_PERMUTE:
						begin : STATE_FPERMUTE
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
						begin : STATE_DECRYPT
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
	
assign done = (state == DONE);

endmodule
