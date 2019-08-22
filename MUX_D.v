`timescale 1ns / 1ps
// -------------------------------------------------
// RISC/ASM6 MUL UPDATE
// 
//		changing output to 64-bits!!! cases 0-2 are still 32-bit, and should only write to lower word
//		in case 11 (MD = 3), will be driven by F_mul = 64-bit product

// 		REMEMBER TO ALTER REG FILE --> NEW INPUT: MD (tells reg when normal address writing or special two reg case)
// 		BUS_D IS ALWAYS 64 BITS WIDE NOW


module MUX_D(
			input [1:0] MD_1,
			input [31:0] F, Data_out, status,
			input [63:0] product,
			output reg [63:0] Bus_D
			);

always@(*) begin 	// asynchronous
	case(MD_1)
		0:	Bus_D = F;
		1:	Bus_D = Data_out;
		2:	Bus_D = status;	// 31 bits of 0, LSB is (V^N)
		3:	Bus_D = product; // 64 bits
	endcase
end


endmodule