`timescale 1ns / 1ps

module mainfsm (
	clk,
	reset,
	Op,
	Funct,
	IRWrite,
	AdrSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	NextPC,
	RegW,
	MemW,
	Branch,
	ALUOp,

	IsMul,
	IsDiv,
	MulFunct
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	
	input wire IsMul;
	input wire IsDiv;
	input wire [2:0] MulFunct;
	
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire Branch;
	output wire ALUOp;
	
	reg [3:0] state;
	reg [3:0] nextstate;
	reg [12:0] controls;
	localparam [3:0] FETCH = 0;
	localparam [3:0] DECODE = 1;
	localparam [3:0] MEMADR = 2;
	localparam [3:0] MEMRD  = 3;
    localparam [3:0] MEMWB  = 4;
    localparam [3:0] MEMWR  = 5;
	localparam [3:0] EXECUTER = 6;
	localparam [3:0] EXECUTEI = 7;
	localparam [3:0] ALUWB = 8;
	localparam [3:0] BRANCH = 9;
	localparam [3:0] UNKNOWN = 10;
	
	localparam [3:0] MULT_LONG = 11;
	localparam [3:0] STR_RA= 12;
	localparam [3:0] STR_RD = 13;

	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= FETCH;
		else
			state <= nextstate;
	

	// ADD CODE BELOW
  	// Finish entering the next state logic below.  We've completed the 
  	// first two states, FETCH and DECODE, for you.

  	// next state logic
	always @(*)
		casex (state)
			FETCH: nextstate = DECODE;
			DECODE:
				case (Op)
					2'b00:
						if (Funct[5])
							nextstate = EXECUTEI;
						else
							nextstate = EXECUTER;
					2'b01: 
						if (IsDiv) begin
							nextstate = EXECUTER;
						end
						else begin
							nextstate = MEMADR;
						end
					2'b10: nextstate = BRANCH;
					default: nextstate = UNKNOWN;
				endcase
			EXECUTER: nextstate = ALUWB;
			EXECUTEI:    nextstate = ALUWB;
			ALUWB:       nextstate = FETCH;
			MEMADR:      nextstate = (Funct[0]) ? MEMRD : MEMWR;
			MEMRD:       nextstate = MEMWB;
			MEMWB:       nextstate = FETCH;
			MEMWR:       nextstate = FETCH;
			BRANCH:      nextstate = FETCH;
			MULT_LONG:    nextstate = STR_RA;
			STR_RA:      nextstate = STR_RD;
			STR_RD:      nextstate = FETCH;
			default:     nextstate = FETCH;
			
		endcase

	always @(*)
		case (state)
			FETCH: controls =    13'b100010_10_01_10_0;
			DECODE: controls =   13'b000000_10_01_10_0;
			MEMADR: controls =   13'b0000000000010;
			MEMRD: controls =    13'b0000010000000;
			MEMWB: controls =    13'b0001000100000;
			MEMWR: controls =    13'b0010010000000;
			EXECUTER: controls = 13'b000000_00_00_00_1;
			EXECUTEI: controls = 13'b000000_00_00_01_1;
			ALUWB: controls =    13'b0001000000000;
			BRANCH: controls =   13'b0100001010010;
			
			MULT_LONG: controls =    13'b0_0_0_0_0_0_00_00_00_0;         
			
			default: controls =  13'bxxxxxxxxxxxxx;
		endcase
	assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule