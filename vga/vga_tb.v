`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:15:54 04/12/2017
// Design Name:   vga_display
// Module Name:   D:/Dropbox/2nd Year USC/EE 354/Final_Project/verilog_projects/VGA/vga_sprites/vga_sprites/vga_tb.v
// Project Name:  image
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vga_tb;

	// Inputs
	reg rst;
	reg ClkPort;
	reg btnU;
	reg btnD;

	// Outputs
	wire HS;
	wire VS;
	wire [2:0] R;
	wire [2:0] G;
	wire [1:0] B;

	// Instantiate the Unit Under Test (UUT)
	vga_display uut (
		.HS(HS), 
		.VS(VS), 
		.R(R), 
		.G(G), 
		.B(B), 
		.rst(rst), 
		.ClkPort(ClkPort), 
		.btnU(btnU), 
		.btnD(btnD)
	);
	
	initial begin
	// Initialize Inputs
	rst = 0;
	ClkPort = 0;
	#1 rst = 1;
	#1000 rst = 0;

	// Wait 100 ns for global reset to finish
	#100;
	  
	// Add stimulus here

	end
	
	always #1 ClkPort = ~ClkPort;
      
endmodule

