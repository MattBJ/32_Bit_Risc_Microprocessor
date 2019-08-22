`timescale 1ns / 1ps

module MUX_C(
			input [31:0] BrA, RAA, PC_1,	// check the PC +1, comes from IF phase
			input [1:0] MC,	// comes from combinational circuit from top phase, should be inputted into register in TOP_PHASE VERILOG MODULE
			output reg [31:0] PC 	// this straight up drives the PC register in the top top module
			);

// always @ to make case statement instead of ?:'s
always@(*) begin
	case(MC)
		0: PC = PC_1;	// most used case
		1,3: PC = BrA;
		2: PC = RAA;
		default: PC = PC_1;
	endcase // PC's here are always driving (async), on top phase module, its PC is set on negedge
    //PC = PC_1;
end

endmodule