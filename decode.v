`timescale 1ns / 1ps

module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	ALUControl,
	

	MulCmd,
	IsMul,
	IsLongMul,
	MulFunct,

	IsDiv	
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [3:0] ALUControl;

	input wire [3:0] MulCmd;
	output wire IsMul;
	output wire IsLongMul;
	output wire [2:0] MulFunct;

	output wire IsDiv;

	wire Branch;
	wire ALUOp;

	assign IsDiv = (Op == 2'b01) 
		& (Funct == 6'b110011) 
		& (MulCmd == 4'b0001);

	// Main FSM
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.IsDiv(IsDiv)
	);
	
	assign IsMul = (Op == 2'b00)
          & (Funct[5:4] == 2'b00)
          & (MulCmd == 4'b1001);

	assign IsLongMul = IsMul & (
	                   (Funct[3:1] == 3'b100) ||
	                   (Funct[3:1] == 3'b110)); 
	
	//assign MulFunct = IsLongMul ? 3'b100 : (IsMul ? 3'b000 : 3'bxxx );
    assign MulFunct = IsMul ? Funct[3:1] : 3'bxxx;  
    
    always @(*) begin
        if (ALUOp) begin
            if (IsDiv) begin
                ALUControl = 4'b1000;
                FlagW[1] = Funct[0];
                FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
            end
            else if (IsMul)begin
                case (Funct[3:1])
                    3'b000: begin
                    ALUControl = 4'b0101;
                    FlagW[1] = Funct[0];
                    FlagW[0] = Funct[0];
                    end
                    3'b100: begin
                    ALUControl = 4'b0101;
                    FlagW[1] = Funct[0];
                    FlagW[0] = Funct[0];
                    end
                    3'b110: begin
                    ALUControl = 4'b0101;
                    FlagW[1] = Funct[0];
                    FlagW[0] = Funct[0];
                    end
                    default: ALUControl = 3'bxxx;
                endcase              
              
            end
            else begin
                case (Funct[4:1])
                    4'b0100: ALUControl = 4'b0000;
                    4'b0010: ALUControl = 4'b0001;
                    4'b0000: ALUControl = 4'b0010;
                    4'b1100: ALUControl = 4'b0011;
                    4'b0001: ALUControl = 4'b0110;
                    4'b1101: ALUControl = 4'b0111;
					4'b1111: ALUControl = 4'b1001; 
                    default: ALUControl = 4'bxxx;
                endcase
                FlagW[1] = Funct[0];
                FlagW[0] = Funct[0] & ((ALUControl == 4'b0000) | (ALUControl == 4'b0001));
            end
                      
        end
        else begin
            ALUControl = 4'b0000;
            FlagW = 2'b00;
        end
    end
    
    //assign ALUControl = IsDiv ? 4'b1000 : ALUControl;
    
	assign RegSrc[1] = Op == 2'b01;
	assign RegSrc[0] = Op == 2'b10;
	assign ImmSrc = Op;
	
    assign PCS = ( ((Rd == 4'b1111) & RegW) | Branch ) & ~IsDiv;
endmodule