`timescale 1ns / 1ps

module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	PCWrite,
	RegWrite,
	MemWrite,
	is_long_mul,
	IsLongMul
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire NextPC;
	input wire RegW;
	input wire MemW;
	output wire PCWrite;
	output wire RegWrite;
	output wire MemWrite;

	input wire is_long_mul;
	output wire IsLongMul; 

	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	wire CondEx;
	
	wire cond_ex;

	flopr #(2) flagwritereg(
		clk,
		reset,
		FlagW & {2 {CondEx}},
		FlagWrite
	);
	
	//wire [1:0] nz_flags;
    flopenr #(2) nz_reg (
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[1]),
        .d(ALUFlags[3:2]),
        .q(Flags[3:2])
    );

    //wire [1:0] cv_flags;
    flopenr #(2) cv_reg (
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[0]),
        .d(ALUFlags[1:0]),
        .q(Flags[1:0])
    );
    
    
    flopr #(1) condexreg(
		.clk(clk),
		.reset(reset),
		.d(CondEx),
		.q(cond_ex)
	);
	
	condcheck cc(
		.Cond(Cond),
		.Flags(Flags),
		.CondEx(CondEx)
	);
	
	assign RegWrite = RegW & cond_ex;
	assign MemWrite = MemW & cond_ex;
	assign PCWrite = NextPC | PCS & cond_ex;

	assign IsLongMul = is_long_mul & cond_ex;
endmodule