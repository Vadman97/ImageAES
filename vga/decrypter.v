`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:19:20 04/17/2017 
// Design Name: 
// Module Name:    decryptor 
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
module decrypter(
    input clk,
	 input reset,
    input [7:0] encrypted_data,
	 input decrypter_active,
	 input [7:0] key,
	 output reg [14:0] read_addr,
    output reg [7:0] decrypted_data,
	 output reg [14:0] write_addr,
	 output reg done
    );
	 	 
	 reg [14:0] counter;
	 
	 always @(posedge clk) begin
		if (reset) begin
			counter <= 0;
		end else begin
			if (decrypter_active) begin
				// decryption algo
				if (encrypted_data[6:3] == 3'b111 | encrypted_data == 3'h1C)
					decrypted_data <= key;
				else
					decrypted_data <= encrypted_data;
				
				write_addr <= counter - 1;
				read_addr <= counter;
				counter <= counter + 1;
				
			end
			
			if (counter > (175 * 175)) begin
				done = 1'b1;
			end else
				done = 1'b0;
		end
	 end
	
endmodule
