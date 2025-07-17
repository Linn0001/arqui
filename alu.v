`timescale 1ns / 1ps

module alu(
    input [31:0] a, b,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags,
    
    input wire [2:0] MulFunct,
    output reg [63:0] LongMulResult
    );
    
    wire neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;
    
    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];
    
    reg signed [31:0] sa, sb;
    always @(*) begin
        sa = a;
        sb = b;
        casex (ALUControl[3:0])
            4'b000?: Result = sum;
            4'b0010: Result = a & b;
            4'b0011: Result = a | b;
            4'b0110: Result = a ^ b;
            4'b0111: Result = b;
            4'b1001: Result = ~b;
            4'b0101:  
                case(MulFunct)
                    3'b000: Result = a * b;
                    3'b100: LongMulResult = a * b;
                    3'b110:LongMulResult = sa * sb; 
                    default Result = a * b;         
                endcase
            4'b1000: Result = a / b;
        endcase
    end
    
    
    assign neg = Result[31] || (MulFunct == 3'b110 & LongMulResult[63]);
    
    assign zero = (Result == 32'b0) || LongMulResult == 64'b0;
    
    assign carry = (ALUControl[1] == 1'b0) & (sum[32]);
    
    assign overflow = ((ALUControl[1] == 1'b0) 
        & ~(a[31] ^ b[31] ^ ALUControl[0]) 
        & (a[31] ^ sum[31]));
        
    assign ALUFlags = {neg, zero, carry, overflow};
endmodule
