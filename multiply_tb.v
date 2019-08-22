`timescale 1ns / 1ps

module multiply_tb;
reg [31:0] multiplicand, multiplier;
reg [6:0] opcode;	//? maybe FS?

wire [63:0] product;

multiply uut(
	.multiplicand(multiplicand), .multiplier(multiplier),
	.opcode(opcode),
	// IO
	.product(product)
	);

initial begin
	{multiplicand,multiplier,opcode} = 0;
	#100;
	multiplicand = 32'd50;
	#50;
	multiplier = 32'd50;
	#100;
	multiplier = 32'd1000;
	#1000;
	multiplier = 32'hffffffff;	//4,294,967,295
	#1000;
	multiplicand = 32'hffffffff;
	// should equal 18,446,744,065,119,617,025 (instead equals 9,223,372,028,264,841,217)
	// in decimal:


	// should do this:
	// 			1111
	//		   1111
	//		  1111
	// rest 0!
end


endmodule