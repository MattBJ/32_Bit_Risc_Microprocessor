`timescale 1ns / 1ps

module MUL_ALU_tb;
reg go, clk;

reg [31:0] multiplicand, multiplier;

wire [63:0] product;
wire done;

initial begin
	#50;
	{go, clk, multiplicand, multiplier} = 0;
	#50;
	multiplicand = 32'h8fffffff;
	multiplier = 32'hffffffff;
end

always
	#5 ckl = ~clk;

endmodule