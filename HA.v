`timescale 1ns / 1ps

module HA(
	input A, B,
	output sum, c_out
	);

assign sum = A ^ B;
assign c_out = A & B;

endmodule