`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 20:49:43
// Design Name: 
// Module Name: fp_mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fp32_mul(
    input wire [31:0] a, b,
  output reg [31:0] y
);
  // Deconstruct inputs
  wire sign_a = a[31];
  wire [7:0] exp_a = a[30:23];
  wire [22:0] mant_a_in = a[22:0];

  wire sign_b = b[31];
  wire [7:0] exp_b = b[30:23];
  wire [22:0] mant_b_in = b[22:0];

  // Internal registers for calculation
  reg sign_r;
  reg signed [8:0] exp_r; // Use signed for bias subtraction
  reg [23:0] mant_a, mant_b;
  reg [47:0] mant_mul;

  always @(*) begin
    // Handle special cases: Zero
    if ((exp_a == 0 && mant_a_in == 0) || (exp_b == 0 && mant_b_in == 0)) begin
      y = 32'b0;
    end else begin
      // 1. Add implicit 1 for normalized numbers
      mant_a = (exp_a == 0) ? {1'b0, mant_a_in} : {1'b1, mant_a_in};
      mant_b = (exp_b == 0) ? {1'b0, mant_b_in} : {1'b1, mant_b_in};

      // 2. Multiply mantissas
      mant_mul = mant_a * mant_b;

      // 3. Add exponents and subtract bias (127)
      exp_r = exp_a + exp_b - 127;
      sign_r = sign_a ^ sign_b;

      // 4. Normalize the result
      if (mant_mul[47]) begin // Result has 48 bits, check MSB
        mant_mul = mant_mul >> 1;
        exp_r = exp_r + 1;
      end
      
      // Handle overflow/underflow for exponent
      if (exp_r >= 255) begin
        y = {sign_r, 8'hFF, 23'b0}; // Infinity
      end else if (exp_r <= 0) begin
        y = {sign_r, 8'b0, mant_mul[46:24]}; // Denormalized or Zero
      end else begin
        y = {sign_r, exp_r[7:0], mant_mul[46:24]}; // Normalized number
      end
    end
  end
endmodule
