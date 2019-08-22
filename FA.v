`timescale 1ns / 1ps

module FA(
	input A, B, c_in,
	output sum, c_out
	);

assign {c_out, sum} = A + B + c_in;

endmodule