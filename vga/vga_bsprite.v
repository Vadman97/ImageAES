`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    17:17:19 04/14/2013 
// Design Name: 	VGA sprites controller
// Module Name:    vga_bsprite 
// Project Name:  vga_display
// Target Devices: xc6slx16
// Tool versions: ISE 13.3
// Description: This project calls memory sprites to show on the screen
//
// Dependencies: game_over_mem, vga_controller
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_bsprite(hc, vc, mem_value, rom_addr, R, G, B, blank, inside_image);
	input [10:0] hc, vc;	// Coordinates of the current pixel
	input [7:0] mem_value;	// Memory value at address "rom_addr"
	input blank;
	output reg [14:0] rom_addr;	// ROM address
	output reg [2:0] R, G;
	output reg [1:0] B;	// RGB values outputs;
	output reg inside_image;
	
	parameter [10:0] VGA_WIDTH = 640;
	parameter [10:0] VGA_HEIGHT = 480;
	
	parameter [7:0] IMG_WIDTH = 181;
	parameter [7:0] IMG_HEIGHT = 181;
	
	parameter [3:0] SCALE = 1;
	
	parameter [10:0] START_X = (VGA_WIDTH - (IMG_WIDTH * SCALE)) / 2;
	parameter [10:0] START_Y = (VGA_HEIGHT - (IMG_HEIGHT * SCALE)) / 2;
	parameter [10:0] END_X = START_X + IMG_WIDTH;
	parameter [10:0] END_Y = START_Y + IMG_HEIGHT;
	
	reg [10:0] x, y;
	
	wire [10:0] div_hc, div_vc;
	wire [11:0] mult_x1, mult_y1;
	
	assign div_hc = hc >> (SCALE >> 1);
	assign div_vc = vc >> (SCALE >> 1);
	assign mult_x1 = END_X << (SCALE >> 1);
	assign mult_y1 = END_Y << (SCALE >> 1);
	
	always @ (*) begin
	
		if (hc >= START_X & hc <= mult_x1)		// make sure thath x1-x0 = image_width
			x = div_hc - START_X;	// offset the coordinates
		else
			x = 0;
			
		if (vc >= START_Y & vc <= mult_y1)		// make sure that y1-y0 = image_height
			y = div_vc - START_Y;	//offset the coordinates
		else
			y = 0;
			
		rom_addr = y*IMG_WIDTH + x;
		
		if (x==0 | y==0) begin		// set the color output
			{R,G,B} = 8'd0;
			inside_image <= 1'b0;
		end else begin
			{R,G,B} = mem_value;
			inside_image <= 1'b1;
		end
			
	end
endmodule
