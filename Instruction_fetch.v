`timescale 1ns/1ps

module Instruction_fetch(
						input [31:0] PC,
						output [31:0] PC_1,
						output [31:0] IR 
						);

assign PC_1 = PC + 1;

// always@(*) begin
//     PC_1 = PC + 1;
// end

Instruction_memory IM0(	// have not made this module yet
						.PC(PC),
						// IO
						.IR(IR)
						);

endmodule