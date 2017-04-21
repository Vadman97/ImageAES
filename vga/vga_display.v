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
	
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b00000};//{5'b11111};
	
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
	reg [7:0] dout;
	wire [7:0] ben_dout;
	wire [7:0] dec_dout;
	
	reg [14:0] ben_read_addr;
	wire [14:0] decr_read_addr;
	wire [14:0] sprite_read_addr;
	
	wire inside_image;
	
	// wire [7:0] pezh_dout;
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// VGA clock divider
	parameter dec_N = 16;	// decryptor clock divider
	
	reg clk_25Mhz;
	reg clk_decrypter;
	reg [dec_N-1:0] count;
	initial count = 0;
	always @ (posedge ClkPort) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
		clk_decrypter <= count[dec_N-1];
	end
	
	reg [30:0] icount;
	reg [7:0] inc;
	initial icount = 0;
	initial inc = 1;
	reg decrypter_active;
	initial decrypter_active = 0;
	
	always @ (posedge ClkPort) begin
		icount <= icount + inc;
		if (1'b1 | icount[27]) begin
			dout <= dec_dout;
			ben_read_addr <= decr_read_addr;
			decrypter_active <= 1'b1;
		end else begin
			dout <= ben_dout; 
			ben_read_addr <= sprite_read_addr;
			decrypter_active <= 1'b0;
		end
	end
	
	/*always @ (posedge icount[28]) begin
		inc <= inc + 1'b1;
		
		// skip over 0 to prevent problemos
		if (inc == 8'hFF)
			inc <= 1;
	end*/
	

	// End clock division
	/////////////////////////////////////////////////////
	
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
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(dout), 
		.rom_addr(sprite_read_addr), 
		.R(R), 
		.G(G), 
		.B(B), 
		.blank(blank),
		.inside_image(inside_image)
	);
	
	/*pezhman_mem*/ben_mem ben (
		.clka(clk_25Mhz), // input clka
		.addra(ben_read_addr), // input [14 : 0] read_addr
		.douta(ben_dout) // output [7 : 0] douta
	);
	
	/*pezhman_mem pezh (
		.clka(clk_25Mhz), // input clka
		.read_addr(read_addr), // input [14 : 0] read_addr
		.douta(pezh_dout) // output [7 : 0] douta
	);*/
	
	wire write_en;
	wire [14:0] write_addr;
	wire [7:0] dec_din;
	
	assign write_en = 1'b1; //(~blank) & inside_image;
	
	// this will take some thought
	// we want to read some part of the image (some address) and show that
	// switch between ^ and reading some other part of the image that the decryptor is now decrypting and write correspondingly
	
	decrypter dec(
		.clk(clk_decrypter),
		.encrypted_data(ben_dout),
		.read_addr(decr_read_addr),
		.write_addr(write_addr),
		.decrypted_data(dec_din),
		.decrypter_active(decrypter_active)
	);
	
	decryption_mem dec_mem (
		.clka(clk_25Mhz),
		.addra(write_addr),
		.dina(dec_din), 
		.wea(write_en),
		
		.clkb(clk_25Mhz),
		.addrb(sprite_read_addr), 
		.doutb(dec_dout), 
		.rstb(1'b0)
	);
	

endmodule
