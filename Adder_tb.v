`timescale 1ns / 1ps

module Adder_tb;
reg [31:0] B, PC_2;

wire [31:0] BrA;

Adder uut(
	.B(B), .PC_2(PC_2),
	// IO
	.BrA(BrA)
	);

initial begin
	{B,PC_2} = 0;
	#100;
	// simulate going from PC = 11 to PC = 0
	// --> PC + 1 + seIM = 0
	// --> PC_2 + seIM = 0, therefore seIM == -12 (true)
	// 1100 = +12, so -12 = 0011 + 1 = 0100
	// but IM = 15 bit so: 111111111110100 = -12 (15-bit)
	// so seIM = 1111 1111 1111 1111 1111 1111 1111 0100
	PC_2 = 32'd12;	// 12
	#100;
	B = 32'hfffffff4;
end


endmodule