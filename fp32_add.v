`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 20:49:27
// Design Name: 
// Module Name: fp_add
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


module fp32_add(
    input wire [31:0] a, b,
  output reg [31:0] y
);
  // Deconstruct inputs
  wire sign_a = a[31];
  wire [7:0] exp_a = a[30:23];
  wire [22:0] mant_a = a[22:0];

  wire sign_b = b[31];
  wire [7:0] exp_b = b[30:23];
  wire [22:0] mant_b = b[22:0];

  // Internal registers for calculation
  reg sign_r;
  reg [7:0] exp_r;
  reg [23:0] mant_r;
  reg [24:0] mant_a_ext, mant_b_ext;
  reg [25:0] mant_sum;
  integer shift;

  always @(*) begin
    // Handle special cases: Zero
    if ((exp_a == 0 && mant_a == 0)) begin
      y = b;
    end else if ((exp_b == 0 && mant_b == 0)) begin
      y = a;
    end else begin
      // Add implicit 1 for normalized numbers
      mant_a_ext = (exp_a == 0) ? {1'b0, mant_a} : {1'b1, mant_a};
      mant_b_ext = (exp_b == 0) ? {1'b0, mant_b} : {1'b1, mant_b};

      // 1. Align exponents
      if (exp_a > exp_b) begin
        shift = exp_a - exp_b;
        mant_b_ext = mant_b_ext >> shift;
        exp_r = exp_a;
      end else begin
        shift = exp_b - exp_a;
        mant_a_ext = mant_a_ext >> shift;
        exp_r = exp_b;
      end

      // 2. Add or subtract mantissas
      if (sign_a == sign_b) begin
        mant_sum = mant_a_ext + mant_b_ext;
        sign_r = sign_a;
      end else begin
        if (mant_a_ext >= mant_b_ext) begin
          mant_sum = mant_a_ext - mant_b_ext;
          sign_r = sign_a;
        end else begin
          mant_sum = mant_b_ext - mant_a_ext;
          sign_r = sign_b;
        end
      end
      
      // 3. Normalize the result
      if (mant_sum[25]) begin // Overflow on mantissa add
        mant_r = mant_sum[25:2];
        exp_r = exp_r + 1;
      end else if (mant_sum[24]) begin // Normal case
        mant_r = mant_sum[24:1];
      end else begin // Needs left shifting
        if(mant_sum != 0) begin
            while(mant_sum[23] == 0) begin
                mant_sum = mant_sum << 1;
                exp_r = exp_r - 1;
            end
        end
        mant_r = mant_sum[23:0];
      end

      // Handle underflow/overflow for exponent
      if (exp_r >= 255) begin
        y = {sign_r, 8'hFF, 23'b0}; // Infinity
      end else if (exp_r == 0) begin
        y = {sign_r, 8'b0, mant_r[22:0]}; // Denormalized or Zero
      end else begin
        y = {sign_r, exp_r, mant_r[22:0]}; // Normalized number
      end
    end
  end
endmodule
