`timescale 1ns / 1ps


module arm (
	clk,
	reset,
	MemWrite,
	Adr,
	WriteData,
	ReadData
);
	input wire clk;
	input wire reset;
	output wire MemWrite;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	
	input wire [31:0] ReadData;
	wire [31:0] Instr;
	wire [3:0] ALUFlags;
	wire PCWrite;
	wire RegWrite;
	wire IRWrite;
	wire AdrSrc;
	wire [1:0] RegSrc;
	wire [1:0] ALUSrcA;
	wire [1:0] ALUSrcB;
	wire [1:0] ImmSrc;
	wire [3:0] ALUControl;
	wire [1:0] ResultSrc;
	
	wire is_mul_w;
	wire is_long_mul_w;
	wire [2:0] mul_funct_w;
	wire is_div_w;
	
	controller c(
		.clk(clk),
		.reset(reset),
		.Instr(Instr[31:0]),
		.ALUFlags(ALUFlags),
		.PCWrite(PCWrite),
		.MemWrite(MemWrite),
		.RegWrite(RegWrite),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.RegSrc(RegSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.ImmSrc(ImmSrc),
		.ALUControl(ALUControl),

		.IsMul(is_mul_w),
		.IsLongMul(is_long_mul_w),
		.MulFunct(mul_funct_w),
		.IsDiv(is_div_w)
	);
	datapath dp(
		.clk(clk),
		.reset(reset),
		.Adr(Adr),
		.WriteData(WriteData),
		.ReadData(ReadData),
		.Instr(Instr),
		.ALUFlags(ALUFlags),
		.PCWrite(PCWrite),
		.RegWrite(RegWrite),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.RegSrc(RegSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.ImmSrc(ImmSrc),
		.ALUControl(ALUControl),
		
		.IsMul(is_mul_w),
		.IsLongMul(is_long_mul_w),
		.MulFunct(mul_funct_w),
		.IsDiv(is_div_w)
	);
endmodule
