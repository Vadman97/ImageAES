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
						Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7,
						rst, ClkPort, btnU, btnD);
	input rst;	// global reset
	input ClkPort, btnU, btnD;
	input Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7;
		
	// color outputs to show on display (current pixel)
	output [2:0] R, G;
	output [1:0] B;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	
	reg [2:0] R, G;
	reg [1:0] B;

	wire [2:0] sprite_R, sprite_G;
	wire [1:0] sprite_B;
	
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b00000};//{5'b11111};
	
	assign {An0, An1, An2, An3} = {4'b0000};
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {8'hFF};
	
	wire [7:0] switches;
	assign switches = {Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0};
	
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
	parameter dec_N = 14; //16;	// decryptor clock divider
	
	reg clk_25Mhz;
	reg clk_decrypter;
	reg [dec_N-1:0] count;
	initial count = 0;
	always @ (posedge ClkPort) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
		clk_decrypter <= count[dec_N-1];
	end
	
	assign MEM_READ_CLOCK = clk_25Mhz;
	assign MEM_WRITE_CLOCK = clk_25Mhz;
	
	reg [30:0] icount;
	initial icount = 0;
	reg decrypter_active;
	initial decrypter_active = 0;
	
	reg [14:0] write_addr;
	wire [14:0] write_addr_dec;
	reg [14:0] reset_addr;
	
	wire dec_done;
	
	always @ (posedge MEM_WRITE_CLOCK) begin
		icount <= icount + 1;
		
		if (!dec_done & !rst) begin
			write_addr <= write_addr_dec;
			dec_mem_din <= dec_din;
			reset_addr <= 0;
			if (1'b1 | icount[26]) begin
				dout <= dec_dout;
				ben_read_addr <= decr_read_addr;
				decrypter_active <= 1'b1;
			end else begin
				dout <= ben_dout; 
				ben_read_addr <= sprite_read_addr;
				decrypter_active <= 1'b0;
			end
			R <= sprite_R;
			G <= sprite_G;
			B <= sprite_B;
		end else begin
			// why the f is this - 4 who knows :'(
			/*write_addr <= reset_addr - 4;
			ben_read_addr <= reset_addr;
			dec_mem_din <= ben_dout;
			
			reset_addr <= reset_addr + 1;
			
			R <= 3'd0;
			G <= 3'd0;
			B <= 2'd0;*/
		end
	end


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
		.R(sprite_R), 
		.G(sprite_G), 
		.B(sprite_B), 
		.blank(blank),
		.inside_image(inside_image)
	);
	
	pezhman_mem /*ben_mem*/ ben (
		.clka(clk_25Mhz), // input clka
		.addra(ben_read_addr), // input [14 : 0] read_addr
		.douta(ben_dout) // output [7 : 0] douta
	);
	
	wire write_en;
	wire [7:0] dec_din;
	reg [7:0] dec_mem_din;
	
	assign write_en = 1'b1; //(~blank) & inside_image;
	
	// this will take some thought
	// we want to read some part of the image (some address) and show that
	// switch between ^ and reading some other part of the image that the decryptor is now decrypting and write correspondingly
	
	reg [63:0] button_key;
	always @(posedge ClkPort) begin: KEY_GEN
		integer i;
		for (i = 0; i < 8; i = i + 1) begin
			if (switches[i])
				button_key[8 * i +: 8] = 8'hFF;
			else
				button_key[8 * i +: 8] = 8'h00;
		end
	end
	
	decrypter dec(
		.clk(clk_decrypter),
		.reset(rst),
		.encrypted_data(ben_dout),
		.read_addr(decr_read_addr),
		.write_addr(write_addr_dec),
		.decrypted_data(dec_din),
		.decrypter_active(decrypter_active),
		.done(dec_done),
		.key(switches)
	);
	
	decryption_mem dec_mem (
		.clka(MEM_WRITE_CLOCK),
		.addra(write_addr),
		.dina(dec_mem_din), 
		.wea(write_en),
		
		.clkb(MEM_READ_CLOCK),
		.addrb(sprite_read_addr), 
		.doutb(dec_dout), 
		.rstb(1'b0)
	);
	

endmodule
