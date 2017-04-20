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
    input [7:0] encrypted_data,
	 input decrypter_active,
	 output reg [14:0] read_addr,
    output reg [7:0] decrypted_data,
	 output reg [14:0] write_addr
    );
	  
	 parameter [7:0] KEY = 8'b10110011;
	 
	 reg [14:0] counter;
	 initial counter = 0;
	 always @(posedge clk) begin
		if (decrypter_active) begin
			//decryption algo here
			decrypted_data <= encrypted_data ^ KEY ^ (KEY << 4);
			//end deryption algo
			
			counter <= counter + 1;
			read_addr <= counter;
			write_addr <= counter;
		end
	 end
	
endmodule
