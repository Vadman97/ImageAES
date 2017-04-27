`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:33:57 04/26/2017
// Design Name:   decrypter
// Module Name:   C:/Users/vkoro/Final_Project/project/vga/decrypt_manager_tb.v
// Project Name:  vga
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: decrypter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module decrypt_manager_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] encrypted_data;
	reg decrypter_active;
	reg [63:0] key;

	// Outputs
	wire [14:0] read_addr;
	wire [7:0] decrypted_data;
	wire [14:0] write_addr;
	wire done;
	
	integer  clk_cnt;
	parameter CLK_PERIOD = 10;

	// Instantiate the Unit Under Test (UUT)
	decrypter uut (
		.clk(clk), 
		.reset(reset), 
		.encrypted_data(encrypted_data), 
		.decrypter_active(decrypter_active), 
		.key(key), 
		.read_addr(read_addr), 
		.decrypted_data(decrypted_data), 
		.write_addr(write_addr), 
		.done(done)
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
		 #(10 * CLK_PERIOD) reset = 0;
	  end

	initial
	  begin  : CLK_COUNTER
		 clk_cnt = 0;
		 forever
			 begin
				#(CLK_PERIOD) clk_cnt = clk_cnt + 1;
			 end 
	  end
	  
	parameter [63:0] data = 64'b1110000010100110111110111111100010010010011001011010011101100101;

	integer i;

	initial begin
		// Initialize Inputs
		encrypted_data = 0;
		decrypter_active = 1;
		key = 0; 

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		key = 64'h133457799BBCDFF1; 
		
		#100;
		for (i = 0; i < 8; i = i + 1) begin
			encrypted_data = data[8 * i +: 8];
			#(CLK_PERIOD);
		end
		 
		//ack = 1;
		# 10;


	end
      
endmodule

