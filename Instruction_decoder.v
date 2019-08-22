`timescale 1ns / 1ps

module Instruction_decoder(
							//input [1:0] MM,
							//input [2:0] MR,
							input [31:0] IR,	// instructions programmed in
							// IO
							output reg RW, PS, MA, MB, CS, MW,
							output reg [4:0] FS, AA, BA, DA,
							output reg [1:0] MD, BS // 30 bits output, because SH (5 bits) comes straight from IR
							);

localparam NOP = 7'b0000000; 
localparam ADD = 7'b0000010; //1-
localparam SUB = 7'b0000101; //2--
localparam SLT = 7'b1100101; //2--
localparam AND = 7'b0001000; //3---
localparam OR = 7'b0001010;  //4----
localparam XOR = 7'b0001100; //5-----
localparam ST = 7'b0000001;
localparam LD = 7'b0100001;
localparam ADI = 7'b0100010; //1-
localparam SBI = 7'b0100101; //2--
localparam NOT = 7'b0101110;
localparam ANI = 7'b0101000; //3---
localparam ORI = 7'b0101010; //4----
localparam XRI = 7'b0101100; //5-----
localparam AIU = 7'b1100010; //1-
localparam SIU = 7'b1000101; //2--
localparam MOV = 7'b1000000; //6------
localparam LSL = 7'b0110000;
localparam LSR = 7'b0110001;
localparam JMR = 7'b1100001;
localparam BZ = 7'b0100000;  //6------
localparam BNZ = 7'b1100000; //6------
localparam JMP = 7'b1000100;
localparam JML = 7'b0000111;

localparam MUL = 7'b1111110;
localparam MUI = 7'b1111111;

// op code + control words = 22 bits
// op code = 7-bits
// control words = 15-bits

// total output must be 35-bits:
//RW = 1bit,	DA = 5bit,	MD = 2bit,	BS = 2bit,	PS = 1bit,	MW = 1bit, 	FS = 5bit,	SH = 5bit,	MA = 1bit,	MB = 1bit, 	AA = 5bit,	BA = 5bit,	CS = 1bit
//ReadWrite,	DestAddr,	MuxD,		TopPhase,	Polarity,	MemWrite,	ALU code,	Shifter,	MuxA,		MuxB,		AddressA,	AddressB,	Constant Select

always@(*) begin
	FS = IR[29:25];	// won't care about few cases not cared
	DA = IR[24:20];
	BA = IR[14:10];
	AA = IR[19:15];
	case(IR[31:25])	// 7MSB's of instructions
		NOP:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000000000;
		ADD:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		SUB:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		SLT:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1100000000;
		AND:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		OR:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		XOR:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		ST:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000001000;
		LD:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1010000000;
		ADI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
		SBI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000101;
		NOT:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		ANI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
		ORI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
		XRI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
		AIU:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
		SIU:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000100;
		MOV:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		LSL:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		LSR:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1000000000;
		JMR:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001000000;
		BZ:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000100101;
		BNZ:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0000110101;
		JMP:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b0001100101;
		JML:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1001100111;
		MUL:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1110000000; // RW, MD
		MUI:
			{RW, MD, BS, PS, MW, MB, MA, CS} = 10'b1110000101; // CS, MB, MD, RW
	endcase
end

endmodule