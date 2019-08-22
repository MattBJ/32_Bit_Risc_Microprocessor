`timescale 1ns/1ps

module MUX_C_tb();
reg [31:0] BrA, RAA, PC_1;
reg [1:0] MC;

wire [31:0] PC;

MUX_C uut(.BrA(BrA), .RAA(RAA), .PC_1(PC_1),
			.MC(MC), .PC(PC)
	);


initial begin
	{BrA, RAA, PC_1, MC} = 0;
	#20;
	PC_1 = 1;
	#20;
	PC_1 = 2;
	#20;
	PC_1 = 3;
end


endmodule