`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    12:59:40 04/12/2011 
// Design Name: EC311 Support Files
// Module Name:    vga_display 
// Project Name: Lab5 / Lab6 / Project
// Target Devices: xc6slx16-3csg324
// Tool versions: XILINX ISE 13.3
// Description: 
//
// Dependencies: vga_controller_640_60
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_display(St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
						HS, VS, R, G, B,  An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
						rst, ClkPort, btnU, btnD);
	input rst;	// global reset
	input ClkPort, btnU, btnD;
		
	// color outputs to show on display (current pixel)
	output [2:0] R, G;
	output [1:0] B;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	
	wire [2:0] R, G;
	wire [1:0] B;
	
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	assign {An0, An1, An2, An3} = {4'b0000};
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {8'hFF};
	
	// Synchronization signals
	output HS;
	output VS;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	wire figure;	// the figure you want to display
	
	// memory interface:
	wire [14:0] addra;
	wire [7:0] douta;
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	initial count = 0;
	always @ (posedge ClkPort) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end

	// End clock division
	/////////////////////////////////////////////////////
	
	parameter [10:0] VGA_WIDTH = 640;
	parameter [10:0] VGA_HEIGHT = 480;
	
	parameter [7:0] IMG_WIDTH = 172;
	parameter [7:0] IMG_HEIGHT = 181;
	
	parameter [3:0] SCALE = 1;
	
	parameter [10:0] START_X = (VGA_WIDTH - (IMG_WIDTH * SCALE)) / 2;
	parameter [10:0] START_Y = (VGA_HEIGHT - (IMG_HEIGHT * SCALE)) / 2;
	
	// parameter [10:0] START_X = 50;
	// parameter [10:0] START_Y = 50;
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank)
	);
	
	vga_bsprite sprites_mem(
		.x0(START_X), 
		.y0(START_Y),
		.x1(IMG_WIDTH+START_X),
		.y1(IMG_HEIGHT+START_Y),
		.hc(hcount), 
		.vc(vcount), 
		.image_width(IMG_WIDTH),
		.scaler(SCALE),
		.mem_value(douta), 
		.rom_addr(addra), 
		.R(R), 
		.G(G), 
		.B(B), 
		.blank(blank)
	);
	
	ben_mem memory_1 (
		.clka(clk_25Mhz), // input clka
		.addra(addra), // input [14 : 0] addra
		.douta(douta) // output [7 : 0] douta
	);
	

endmodule
