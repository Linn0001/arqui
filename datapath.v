`timescale 1ns / 1ps

module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
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
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [3:0] ALUControl;
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [3:0] RA1;
	wire [3:0] RA2;
	
	input wire IsMul;
	input wire IsLongMul;
	input wire [2:0] MulFunct;
	wire [63:0] LongMulResult;

	input wire IsDiv;
	
	
	// Ahora tiene que ser un enable flop ya que 
	// no en todos los ciclos se toma la siguient instruccion
	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.en(PCWrite),
		.d(Result),
		.q(PC)
	);
	
	// PC o PC calculado
	mux2 #(32) address_mux(
		.d0(PC),
		.d1(Result),
		.s(AdrSrc),
		.y(Adr)
	);
	
	// Con enable para solo leer datos 
	// y no instrucciones
	flopenr #(32) instr_mem(
		.clk(clk),
		.reset(reset),
		.en(IRWrite),
		.d(ReadData),
		.q(Instr)
	);

    // Sin enaable porque el libro xd
    flopr #(32) data_mem(
		.clk(clk),
		.reset(reset),
		.d(ReadData),
		.q(Data)
	);
	
	mux2 #(4) ra1_mux(
		.d0(Instr[19:16]),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	
    mux2 #(4) ra2_mux(
        .d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);
	
    regfile rf(
        .clk(clk),
		.we3(RegWrite),
		.ra1((IsMul || IsDiv) ? Instr[3:0] : RA1),
		.ra2((IsMul || IsDiv) ? Instr[11:8]: RA2),
		.wa3((IsMul || IsDiv) ? Instr[19:16] : Instr[15:12]),
		.wd3(Result),
		.r15(Result),
		.rd1(RD1),
		.rd2(RD2),
		
		.we4(IsLongMul),
		.wa4(IsLongMul ? Instr[15:12] : Instr[11:8]),
		.wd4(LongMulResult)
	);
	
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	); 
	
	flopr2 #(32) regfile_mem(
		.clk(clk),
		.reset(reset),
		.d0(RD1),
		.d1(RD2),
		.q0(A),
		.q1(WriteData)
	);	
	
	
	mux3 #(32) srca_mux(
		.d0(A),
		.d1(PC),
		.d2(ALUOut),
		.s(ALUSrcA),
		.y(SrcA)
	);
	
	mux3 #(32) srcb_mux(
		.d0(WriteData),
		.d1(ExtImm),
		.d2(4),
		.s(ALUSrcB),
		.y(SrcB)
	);
	
	wire [3:0] rot4;
	assign rot4 = Instr[11:8];
	
	wire [4:0] rotAmt;
	assign rotAmt = rot4 << 1;
	
	wire [31:0] rotatedB;
	assign rotatedB = (SrcB >> rotAmt) | (SrcB << (32 - rotAmt));
	
	
	alu alu(
		.a(SrcA),
		.b(ALUControl == 4'b0111 ? RotatedB : SrcB),
		.ALUControl(ALUControl),
		.Result(ALUResult),
		.ALUFlags(ALUFlags),
		
		.MulFunct(MulFunct),
		.LongMulResult(LongMulResult)
	);
	
	flopr2 #(32) alu_result_mem(
		.clk(clk),
		.reset(reset),
		.d0(ALUResult),
		.d1(LongMulResult),
		.q0(ALUOut),
		.q1(LongMulOut)
	);
	
	mux3 #(32) res_mux(
		.d0(ALUOut),
		.d1(Data),
		.d2(ALUResult),
		.s(ResultSrc),
		.y(Result)
	);
	
endmodule
