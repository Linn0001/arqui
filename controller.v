`timescale 1ns / 1ps

module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	PCWrite,
	MemWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	
	IsMul,
	IsLongMul,
	MulFunct,
	IsDiv
);
	input wire clk;
	input wire reset;
	input wire [31:0] Instr;
	input wire [3:0] ALUFlags;
	
	output wire PCWrite;
	output wire MemWrite;
	output wire RegWrite;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] RegSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [2:0] ResultSrc;
	output wire [1:0] ImmSrc;
	output wire [3:0] ALUControl;
	
	output wire IsMul;
	output wire IsLongMul;
	output wire [2:0] MulFunct;

	output wire IsDiv;
	
	wire [1:0] FlagW;
	wire PCS;
	wire NextPC;
	wire RegW;
	wire MemW;

	wire is_long_mul_w;
	decode dec(
		.clk(clk),
		.reset(reset),
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ResultSrc(ResultSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),

		.MulCmd(Instr[7:4]),
		.IsMul(IsMul),
		.IsLongMul(is_long_mul_w),
		.MulFunct(MulFunct),
		.IsDiv(IsDiv)
	);

	//assign IsDiv = IsDiv & (Instr[15:12] == 4'b1111);

	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.PCWrite(PCWrite),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite),

		.is_long_mul(is_long_mul_w),
		.IsLongMul(IsLongMul)
	);
endmodule