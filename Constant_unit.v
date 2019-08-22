`timescale 1ns / 1ps

// in the DECODER AND OPERAND FETCH phase
// extends the IMMEDIATE from 15 bit to 32 bit

// depending on CS bit, extends the sign bit (not sure which, COME BACK AND FIND OUT!!)


module Constant_unit(
					input [14:0] IM,
					input CS,
					output [31:0] CONST_DATA
					);
// updated: changed const_data to a wire and assigned its value
//			corrected the algorithm of REPEATING MSB throughout top 17 bits instead of just MSB


assign CONST_DATA = (CS)? {{17{IM[14]}},IM} : {17'b0,IM}; // if true, copies IM's MSB for top 17 bits (17 + 14:0 = 17 + 15 = 32 = 31:0)	
// MSB, MSB, MSB,...... MSB, IM[14], IM[13], .... IM[0] = CONST_DATA


// always@(*) begin
// 	CONST_DATA = IM;
// 	CONST_DATA[31] = (CS)? IM[14]: 0 ;	// in tables, CS = 1 for sign extended IM
// end

endmodule