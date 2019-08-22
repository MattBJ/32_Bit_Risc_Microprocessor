`timescale 1ns/1ps

module Top_phase_tb();
reg [1:0] BS;
reg PS, Z;
reg [31:0] PC_1, BrA, RAA;

wire [31:0] PC;

Top_phase 	uut(
	.BS(BS), .PS(PS), .Z(Z),
	.PC_1(PC_1), .BrA(BrA), .RAA(RAA),
	// IO
	.PC(PC)
	);

initial begin
	{BS,PS,Z,PC_1,BrA,RAA} = 0;
	#50;
	BrA = 50;
	RAA = 100;
	PC_1 = 1;
	#50;
	PC_1 = 10;
	#50;
	PS = 1;
	Z = 1;
	BS[1] = 1;
	#50;
	BS[0] = 1;
end



endmodule