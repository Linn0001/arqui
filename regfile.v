`timescale 1ns / 1ps

module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3,
	wd3,
	r15,
	rd1,
	rd2,

	we4,
	wa4,
	wd4
);
	input wire clk;
	input wire we3;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] wa3;
	input wire [31:0] wd3;
	input wire [31:0] r15;
	output wire [31:0] rd1;
	output wire [31:0] rd2;


	input wire we4;
	input wire [3:0] wa4;
	input wire [63:0] wd4;

	reg [31:0] rf [14:0];
	always @(posedge clk) begin
		if (we3) begin
			rf[wa3] <= wd3;
		end
		if (we4) begin
			rf[wa3] <= wd4[31:0];
			rf[wa4] <= wd4[63:32]; 
		end
    end
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule