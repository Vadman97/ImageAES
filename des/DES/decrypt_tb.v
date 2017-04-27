`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:55 04/23/2017 
// Design Name: 
// Module Name:    decrypt_tb 
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
module decrypt_tb ;

reg clk_tb, reset_tb, ack_tb, enable_tb;
wire done_tb; 
wire [7:0][7:0] message_tb, DESkey_tb;
wire [7:0][7:0] decrypted_tb; 

parameter CLK_PERIOD = 20; 

decrypt d(
	message_tb,
	DESkey_tb,
	decrypted_tb,
	done_tb,
	clk_tb,
	reset_tb,
	enable_tb, 
	ack_tb
    );
	 
initial 
	begin : CLK_GENERATOR
		clk_tb = 0; 
		forever
			begin 
				#(CLK_PERIOD / 2) clk_tb = ~clk_tb;
			end
	end
	
initial 
	begin : RESET_GENERATOR
		reset_tb = 1; 
			#(2 * CLK_PERIOD) reset_tb = 1; 
	end
	
initial 
	begin : STIMULUS
		message_tb = 8'h0;
		DESkey_tb = 8'h0;
		enable_tb = 0; 
		ack_tb = 0; 
		
		wait(!reset_tb);
		@(posedge clk_tb); 
		
//test 1
		@(posedge clk_tb); 
		#1; 
		message_tb = "waterbot";
		DESkey = "hellodar"; 
		enable_tb = 1; 
		
		@(posedge clk_tb);
		#5; 
			enable_tb = 0; 
		
		wait(done_tb); 
		
	end
	
endmodule
