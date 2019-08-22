`timescale 1ns / 1ps

module MUX_B(
			input MB,
			input [31:0] CONST_DATA, B_DATA,
			output [31:0] Bus_B
			);

assign Bus_B = (!MB)? B_DATA : CONST_DATA;

endmodule