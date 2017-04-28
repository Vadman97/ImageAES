`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:19:54 04/26/2017 
// Design Name: 
// Module Name:    decrypt_dumb 
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
module decrypt_dumb(
	input [63:0] message,
	input [63:0] DESkey,
	output reg [63:0] decrypted,
	output done,
	input clk,
	input reset,
	input enable, 
	input ack
    );
	 
	// 8 of 8 bits
	reg [63:0] rand;
	initial begin
		rand = {8'd238, 8'd107, 8'd12, 8'd79, 8'd36, 8'd116, 8'd4, 8'd112};
	end
	 
	reg [7:0] firstBit, secondBit, thirdBit;
	// 8 of 3 bits
	reg [23:0] randIdx;
	reg [2:0] state;
	
	localparam
	INITIAL = 3'd1,
	DECRYPT = 3'd2,
	DONE = 3'd4;

	always @ (posedge clk, posedge reset)
		begin
			if(reset)
				begin
					state <= INITIAL;
					randIdx = 24'd0;
				end
			else 
				begin
					case (state) 
						INITIAL:
							begin : STATE_INITIAL
								if (enable)
									state <= DECRYPT;
							end
						DECRYPT:
							begin: STATE_DECRYPT 
								integer i;
								for (i = 0; i < 8; i = i + 1) begin
									firstBit[i] = (DESkey[8*i+2 +: 2] ^ DESkey[8*i+6 +: 2]) > 2'd1;
									secondBit[i] = (DESkey[8*i +: 2] ^ DESkey[8*i+4 +: 2]) > 2'd1;
									thirdBit[i] = (DESkey[8*i +: 4] ^ DESkey[8*i+4 +: 4]) > 3'd3;
									
									randIdx[3 * i +: 3] = {firstBit[i], secondBit[i], thirdBit[i]};
									decrypted[8 * i +: 8] <= message[8 * i +: 8] ^ rand[randIdx[3 * i +: 3] +: 8];
								end
								state <= DONE;
							end
						DONE: 
							begin: STATE_DONE
								if (ack)
									state <= INITIAL;
							end
					endcase
				end
		end
		
	assign done = state == DONE;
	
endmodule
