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
	 input [63:0] key,
	 output reg [14:0] read_addr,
    output reg [7:0] decrypted_data,
	 output reg [14:0] write_addr,
	 output reg done
    );
	 
	wire [63:0] message;
	wire [63:0] decrypted;
	wire algo_done;
	reg algo_en, ack;
	 
	decrypt_dumb uut (
		.message(message), 
		.DESkey(key), 
		.decrypted(decrypted), 
		.done(algo_done), 
		.clk(clk), 
		.reset(reset), 
		.enable(algo_en), 
		.ack(ack)
	);
	  
	 // parameter [7:0] KEY = 8'b10110011;
	 
	 reg [7:0] pixels [7:0];
	 reg [7:0] dec_pixels [7:0];
	 
	 reg ready_to_write;
	 reg [2:0] read_count;
	 reg [2:0] write_count;
	 reg [14:0] counter;
	 reg [14:0] last_write_count;
	 
	 assign message = {pixels[0], pixels[1], pixels[2], pixels[3], pixels[4], pixels[5], pixels[6], pixels[7]};
	 
	 /*always @(posedge done) begin
		//copy decrypted into mem
		integer i;
		for (int i = 0; i < 8; i = i + 1) begin
			dec_pixels[i] <= decrypted[8 * i +: 8];
		end
		ready_to_write <= 1;
	 end*/
	 
	 always @(posedge clk) begin
		if (reset) begin
			read_count <= 0;
			write_count <= 0;
			counter <= 0;
			last_write_count <= 0;
			algo_en <= 0;
			ready_to_write <= 0;
		end else begin
			if (decrypter_active) begin
				// decryption algo
				// decrypted_data <= encrypted_data ^ KEY;
				pixels[read_count] <= encrypted_data;
				
				if (read_count == 3'd7) begin
					algo_en <= 1;
					ack <= 0;
				end else begin
					algo_en <= 0;
					ack <= 0;
				end
				// end deryption algo
					
				if (ready_to_write) begin
					write_addr <= last_write_count;
					write_count <= write_count + 1;
					last_write_count <= last_write_count + 1;
					
					if (write_count == 3'd7)
						ready_to_write <= 0;
				end
				
				if (algo_done) begin: ALGO_DONE
					//copy decrypted into mem
					integer i;
					for (i = 0; i < 8; i = i + 1) begin
						dec_pixels[i] <= decrypted[8 * i +: 8];
					end
					ack <= 1;
					ready_to_write <= 1;
				end
				
				decrypted_data <= dec_pixels[write_count];
				
				read_addr <= counter;
				
				read_count <= read_count + 1;
				counter <= counter + 1;
				
				if (counter > (175 * 175) & done)
					done = 1'b1;
				else
					done = 1'b0;
			end
		end
	 end
	
endmodule
