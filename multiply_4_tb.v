`timescale 1ns / 1ps

module multiply_4_tb;
reg [3:0] multiplicand, multiplier;
reg [6:0] opcode;	//? maybe FS?

wire [7:0] product;

multiply_4 uut(
	.multiplicand(multiplicand), .multiplier(multiplier),
	.opcode(opcode),
	// IO
	.product(product)
	);

initial begin
	{multiplicand,multiplier,opcode} = 0;
	#100;
	multiplicand = 4'b1111;
	#50;
	multiplier = 4'b0101;
	// should do this:
	// 			1111
	//		   1111
	//		  1111
	// rest 0!
end


endmodule