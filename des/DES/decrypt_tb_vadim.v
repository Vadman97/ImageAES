`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:01:56 04/23/2017
// Design Name:   decrypt
// Module Name:   C:/Users/vkoro/Final_Project/project/des/DES/decrypt_tb.v
// Project Name:  DES
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: decrypt
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module decrypt_tb;

	// Inputs
	reg [63:0] message;
	reg [63:0] DESkey;
	reg clk;
	reg reset;
	reg enable;
	reg ack;
	
	integer  clk_cnt;
	parameter CLK_PERIOD = 10;

	// Outputs
	wire [63:0] decrypted;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	decrypt uut (
		.message(message), 
		.DESkey(DESkey), 
		.decrypted(decrypted), 
		.done(done), 
		.clk(clk), 
		.reset(reset), 
		.enable(enable), 
		.ack(ack)
	);
	
	initial
	  begin  : CLK_GENERATOR
		 clk = 0;
		 forever
			 begin
				#(CLK_PERIOD/2) clk = ~clk;
			 end 
	  end

	initial
	  begin  : RESET_GENERATOR
		 reset = 1;
		 #(2 * CLK_PERIOD) reset = 0;
	  end

	initial
	  begin  : CLK_COUNTER
		 clk_cnt = 0;
		 forever
			 begin
				#(CLK_PERIOD) clk_cnt = clk_cnt + 1;
			 end 
	  end

	initial begin
		// Initialize Inputs
		message = 0;
		DESkey = 0;
		enable = 0;
		ack = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		message = 64'b1110000010100110111110111111100010010010011001011010011101100101;
		DESkey = 64'h133457799BBCDFF1;
		enable = 1;
		
		wait(done);
		
		ack = 1;
		# 10;

	end
      
endmodule

