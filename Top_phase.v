`timescale 1ns/1ps

module Top_phase(
				input [1:0] BS,
				input PS, Z,
				input [31:0] PC_1, BrA, RAA,
				output [31:0] PC 	// to top top verilog, PC register driven by this output
				);

// below is combinational circuit for the MUX_C
wire top_gate_right, top_gate_middle, top_gate_left;
// look at page 10-34 and look at the top phase for this
assign top_gate_right = Z^PS;
assign top_gate_middle = (BS[1])|top_gate_right;
assign top_gate_left = (BS[0])&top_gate_middle;

// remember, 'MC' is actually BS[1] and the wire driven from top_gate_left
wire [1:0] MC;

assign MC[1] = BS[1];
assign MC[0] = top_gate_left;

MUX_C M0 	(
			.BrA(BrA), .PC_1(PC_1),
			.RAA(RAA), .MC(MC),
			// IO
			.PC(PC) // output reg
			);

endmodule