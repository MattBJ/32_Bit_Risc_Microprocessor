`timescale 1ns / 1ps

// in the IF phase of pipeline
// emulates the codes being flashed into ROM part of microprocessor


module Instruction_memory(
							input [31:0] PC,
							output reg [31:0] IR 	// YESSSS!
							);


reg [6:0] opcode = 0;
reg [4:0] DA = 0;
reg [4:0] AA = 0;
reg [4:0] BA = 0;
reg [9:0] junk = 0;
reg [14:0] IM = 0;
reg [14:0] TAR = 0;

localparam NOP = 7'b0000000;
localparam ADD = 7'b0000010;
localparam SUB = 7'b0000101;
localparam SLT = 7'b1100101;
localparam AND = 7'b0001000;
localparam OR  = 7'b0001010;
localparam XOR = 7'b0001100;
localparam ST  = 7'b0000001;
localparam LD  = 7'b0100001;
localparam ADI = 7'b0100010;
localparam SBI = 7'b0100101;
localparam NOT = 7'b0101110;
localparam ANI = 7'b0101000;
localparam ORI = 7'b0101010;
localparam XRI = 7'b0101100;
localparam AIU = 7'b1100010;
localparam SIU = 7'b1000101;
localparam MOV = 7'b1000000;
localparam LSL = 7'b0110000;
localparam LSR = 7'b0110001;
localparam JMR = 7'b1100001;
localparam BZ  = 7'b0100000;
localparam BNZ = 7'b1100000;
localparam JMP = 7'b1000100;
localparam JML = 7'b0000111;

localparam MUL = 7'b1111110;
localparam MUI = 7'b1111111;

localparam R0 = 5'd0;
localparam R1 = 5'd1;
localparam R2 = 5'd2;
localparam R3 = 5'd3;
localparam R4 = 5'd4;
localparam R5 = 5'd5;
localparam R6 = 5'd6;
localparam R7 = 5'd7;
localparam R8 = 5'd8;
localparam R9 = 5'd9;
localparam R10 = 5'd10;
localparam R11 = 5'd11;
localparam R12 = 5'd12;
localparam R13 = 5'd13;
localparam R14 = 5'd14;
localparam R15 = 5'd15;
localparam R16 = 5'd16;
localparam R17 = 5'd17;
localparam R18 = 5'd18;
localparam R19 = 5'd19;
localparam R20 = 5'd20;
localparam R21 = 5'd21;
localparam R22 = 5'd22;
localparam R23 = 5'd23;
localparam R24 = 5'd24;
localparam R25 = 5'd25;
localparam R26 = 5'd26;
localparam R27 = 5'd27;
localparam R28 = 5'd28;
localparam R29 = 5'd29;
localparam R30 = 5'd30;
localparam R31 = 5'd31;

localparam ToZero = 15'b111111111110100;

// NO DATA FORWARDING FOR NOW, SO ADD NO OPS IN BETWEEN
reg [31:0] M [0:1024];
integer i;
initial begin
	//FOR LOOP
    for(i = 0; i < 1024; i = i + 1) begin
    	M[i] = 0;	// NOP
    end
    // opcode,dest,SA,SB,junk OR opcode,dest,SA,IMMEDIATE OR opcode,dest,SA,Target Jump
    // M[1]  = {ADI,R4,R1,15'd27}; // 27 + R1 (0) ---> R4
    // M[3]  = {NOT,R3,R4,15'd0};	// ~R4 (27) --> R3 (immediate unused)
    // M[5]  = {NOT,R2,R0,15'd0}; // ~R0 (0) --> R2 immediate unused
    // M[7]  = {ST,R0,R4,R3,10'd0}; // R[SB] --> M{R[SA]}, 10 bits of junk, destination register is junk
    // M[9]  = {LD,R5,R4,15'd0}; // M{R[SA]} --> R[Dest], 15 bits of junk
    // M[11] = {BZ,R1,R0,ToZero}; // if R[SA] == 0, PC + 1 + seIM --> PC; at this point, pc = 11, so PC + 1 = 12, go back to 0 --> IM = -12

    // prove that multiply is working
    M[1] = {ADI,R1,R0,15'd83}; // put 83 into a register
    M[3] = {MUI,R2,R1,15'd5}; // use mul immediate, 83 * 5
    M[5] = {ADI,R4,R1,15'd117}; // put 209 into a register
    M[7] = {MUL,R5,R1,R4,10'd0}; // 83 * 209 --> two registers
    M[9] = {MUL,R7,R5,R5,10'd0}; // 16600 * 16600
    M[11]= {MUL,R9,R5,R7,10'd0};	// 16600 * 275560000 = over 32'b
    M[13]= {MUI,R11,R1,15'h7fff};	// -1 * 83 = -83
end
//1, add sign IM, dest = R5, AA = 1, IM = 27
//7-bits opcode, 5-bits dest, 5-bits sA, optional: 5-bit sB/10-junk, 15-bit immediate, 15-bit target jump
// block of code to assign
				// 7-bits |5-bit |5-bit| 5-bit + 10-bit |
				// OPCODE | DEST | AA  | TARGET JUMP    | 15-bit
always@(*) begin// OPCODE | DEST | AA  | IMMEDIATE      | 15-bit
	// case(PC)	// OPCODE | DEST | AA  | BA  | JUNK     | 5-bit, 10-bit
	// 	0: IR = NOP;
	// 	1: IR = 32'b0100010_00101_00001_000000000011011; // 27 + R1 (0) --> R4 {ADI,dest,aa,immediate}
	// 	2: IR = NOP;
	// 	3: IR = 32'b0101110_00100_00101_000000000011011; // NOT R4 --> R3 (immediate unused), {NOT,dest,aa,immediate unused}
	// 	4: IR = NOP;
	// 	5: IR = 32'b0101110_00011_00000_000000000011011; // NOT R0 --> R2 {NOT,dest,aa,immediate unused}
	// 	6: IR = NOP;
	// 	7: IR = 32'b0000001_00000_00101_001000000011011; // Store R4 -->M(R5) {} ----> ACTUALLY STORES R5 --> M(R4)
	// 	// store operation: R[SB] --> M{R[SA]}; --> R[4] --> M{R[5]} --> 0 --> M{27}
	// 	8: IR = NOP;
	// 	9: IR = 32'b0100001_00110_00101_000000000011011; 	// load M(R5) --> R6
	// 	10:IR = NOP;
	// 	11:IR =	32'b0100000_00101_00000_100000000001100; // do a jump here BZ (R(A)) = 0 --> PC + 1 +se IM (PC + 1 = 12, + se 12 (MSB = 1, so negative))
	// 		// should have the PC increment, then subtract back to 0
	// 	default: IR = NOP;
	// endcase
	
	IR = M[PC];
end

endmodule