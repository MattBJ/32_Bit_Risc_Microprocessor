`timescale 1ns / 1ps

// prototype multiplication module

module MUL_ALU( // only executes when multiply action
	input go, clk,	// clocked to make synchronous
	// go:
	input [31:0] multiplicand, multiplier,
	output reg [63:0] product,	// in final code, will be two registers concatonated together
	output done
	);


// might need to take out some outputs, and make wires instead (Q0 needs to be wired too, no output for it here...)
MUL_control_unit MCU(
	.clk(clk), .go(go), .Q0(Q0), .z(z),
	// IO
	.initialize(initialize), .clear_c(clear_c),
	.load(load), .shift_dec(shift_dec), .done(done)
	);

/*	NOTES

	Name 	Micro ops				Ctrl sig.	Ctrl. expression

	Reg A:  A <= 0					INITIALIZE  IDLE & Go
			A <= A + B 				Load 		MUL0 & Q0
			C||A||Q <= sr C||A||Q 	Shift_dec 	MUL1

	Reg B: 	B <= IN 				Load_B 		MUL1

	C:		C <= 0 					Clear_C 	(IDLE & Go) | MUL1
			C <= Cout 				Load 		MUL0 & Q0

	Reg Q: 	Q <= IN 				Load_Q 		LOADQ
			C||A||Q <= sr C||A||Q 	shift_dec 	MUL1

	Reg P: 	P <= n-1 				Initialize 	IDLE & Go
			P <= P - 1 				shift_dec 	MUL1
	--------------------------------------------------------------

	'Control Unit' determines Control signals (4-bit width)
		-INPUTS
			>Go signal input
			>Z input (from P)
			>Q0 input
		-OUTPUTS
			> initialize
			> clear_c
			> load
			> shift_dec

*/



reg [4:0] P = 0;	// log2(n=32) = 5 bit register (11111 = 31, 00000 = 0)
reg C = 0;	// carry register

reg [31:0] A, B, Q;

wire z;	// from register P

wire initialize, load, clear_c, shift_dec; 	//

assign z = (P == 0)? 1 : 0;

//always@(posedge clk) begin
	// need this block or else optimization might remove?
//end

always@(*) begin
	A = (initialize)? 0 :
		(load)? A + B :
		(shift_dec)? : A;
	
	B = (load)? multiplicand : B;

	P = (initialize)? 5'b11111 :
		(shift_dec)? P - 1 : P;

	{C,A,Q} = (shift_dec)? {C,A,Q} >> 1 : {C,A,Q};

	C = (clear_c)? 0 :
		(load)? Cout : C;

	Q = (initialize)? multiplier :
		(shift_dec)? : Q;

	product = {A,Q};
end

endmodule