`timescale 1ns / 1ps

// part of the EXECUTE phase of the pipeline
// -------------------------------------------
// RISC/ASM6 -- MUL UPDATE
// adding a 64-bit output F_mul == product!!
// instantiating the multiply module in here, works when FS is inputted
// adding extra conditionals for Z and N bit
// -------------------------------------------
module ALU	(
			input [31:0] A, B,
			input [4:0] SH, FS,
			output reg Z, C, N, V,	// Z needs to end up in top phase comb. ckt.
			output reg [31:0] F,
			output [63:0] F_mul
			);

localparam ADD = 5'b00010; //1-
localparam SUB = 5'b00101; //2--
localparam SLT = 5'b00101; //2--
localparam AND = 5'b01000; //3---
localparam OR = 5'b01010;  //4----
localparam XOR = 5'b01100; //5-----
localparam ADI = 5'b00010; //1-
localparam SBI = 5'b00101; //2--
localparam NOT = 5'b01110;
localparam ANI = 5'b01000; //3---
localparam ORI = 5'b01010; //4----
localparam XRI = 5'b01100; //5-----
localparam AIU = 5'b00010; //1-
localparam SIU = 5'b00101; //2--
localparam MOV = 5'b00000; //6------
localparam LSL = 5'b10000;
localparam LSR = 5'b10001;
localparam BZ = 5'b00000;  //6------
localparam BNZ = 5'b00000; //6------
localparam JML = 5'b00111;

localparam MUL = 5'b11110;
localparam MUI = 5'b11111;

// in total, 12 unique cases with MUL UPDATE

wire C_mul;     // MUL UPDATE, REQUIRES NET OUTPUT (C is output reg)

initial begin
    {Z,C,N,V} = 0;
end

always@(*) begin
	case(FS)
		ADD:	// ADI, ADI, AIU
		begin 
			{C,F} = A + B;
			V = (((A[31]) && (B[31])) && (!F[31]))? 1 : // neg + neg --> pos
				(((!A[31]) && (!B[31])) && (F[31]))? 1 : 0; // pos + pos --> neg
		end
		SUB:	// SLT, SBI, SIU
		begin
			F = A - B;	// A + (~B) + 1;
			V = (((A[31]) && (!B[31])) && (!F[31]))? 1 : // neg - pos --> pos
				(((!A[31]) && (B[31])) && (F[31]))? 1 : 0; // pos - (neg) --> neg
		end
		AND:	// ANI
			F = A&B;
		OR:		// ORI
			F = A|B;
		XOR:	// XRI
			F = A^B;
		NOT:
			F = ~A;
		MOV:	// BZ, BNZ
			F = A;
		LSL:
			F = A<<SH;
		LSR:
			F = A>>SH;
		JML:
			F = A;	// PC_1 passes thru from MUX A (MA = 1)
		MUL,MUI:
			F = 0;	// not using F in this instance anyway
		default: F = 0;	//?
	endcase
	// c, z, v, n
	C = (FS == MUL || FS == MUI)? C_mul : C;
	
	V = ((FS == MUL || FS == MUI) && ((A[31] == B[31]) && (F_mul[31])))? 1: V; // doesn't overwrite previous overflow ^
		// if two pos #'s or neg #'s multiply, and end up negative, then overflow!

	Z = ((FS == MUL || FS == MUI) && (F_mul == 0))? 1 :
		(FS == JML)? Z : // removed FS == MOV || FS == JML because need Z bit for BZ (so if branch is zero, put A in F line, and check for zero)
		(F==0)? 1 : 0;

	N = ((FS == MUL || FS == MUI) && (F_mul[63] == 1))? 1 :
		((FS == MOV) || (FS == JML))? N : // Move operation or any branching results in no status bit effects
		(F[31])? 1 : 0;	
end

multiply M_32(
	.multiplicand(A), .multiplier(B),
	.FS(FS),
	//IO
	.product(F_mul), .C(C_mul)		// check for carry as well
	);

endmodule