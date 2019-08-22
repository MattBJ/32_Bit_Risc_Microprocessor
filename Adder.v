`timescale 1ns / 1ps

// EXECUTION phase of pipeline
// all variants of PC are taken care of in pipeline_top_module


module Adder(
			input [31:0] B, PC_2,
			output reg [31:0] BrA
			);
reg C = 0;  // disregarded carry bit

always@(*) begin
    {C,BrA} = B + PC_2;	// outputted into top phase of pipeline, MUX C
end


endmodule