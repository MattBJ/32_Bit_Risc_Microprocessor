`timescale 1ns/1ps

// MUL UPDATE
// added new output F_mul so that it can be properly latched in top module, then driven to reg file

module Execute(
				input [31:0] A, B, PC_2,	// note: these are busses A and B, not actually a and b (PC_1 and IM)
				// A can be PC_1, B can be IM
				input [4:0] SH, FS,
				input clk, rst, MW,	// all for data block
				// IO
				output [31:0] F, Data_out, BrA, RAA,	// RAA = A
				output [63:0] F_mul,		// MUL UPDATE
				output VxorN, Z, C, N, V	// VxorN to reg, Z to top phase comb. ckt.
				);
// note: clocked (resettable too) reg's all in TOP MODULE

// Module instantiations
Adder A0(
		.B(B), .PC_2(PC_2),
		// IO
		.BrA(BrA)
		);

ALU  A1(
		.A(A), .B(B),
		.SH(SH), .FS(FS),
		// IO
		.Z(Z), .F(F), .V(V),
		.C(C), .N(N), .F_mul(F_mul)		// MUL UPDATE
		);

Data_block D0(  //.instantiated(ThisModule)
				.Address(A), .Data_in(B),
				.clk(clk), .rst(rst), .MW(MW),
				// IO
				.Data_out(Data_out)
				);

assign VxorN = V^N; 	// one of the reg blocks for layer 4
assign RAA = A;


endmodule