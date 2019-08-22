`timescale 1ns / 1ps

//----------------------------------------------------------
// RISC/ASM6 MUL UPDATE
//
// inputs from MUX_D are now ALWAYS 64-BITS WIDE
//
// adding new input MD_1, tells reg file when to write to two registers (64-bit)
//		--> else defaults to one reg write (when RW is true still), and uses lower word (input[31:0])


// (DECODED OPERAND FETCH | WRITEBACK) = phases of the pipeline referenced in

// clock and reset to all regesters
module Register_file(
					input clk, RW_1, rst,
					input [1:0] MD_1, // tells when writing to two destinations
					input [4:0] DA_1, AA, BA,	// destination address (for writing to a register), A_address, B_address (busses used in datapath)
					input [63:0] D_DATA, // UPDATE!!!!!! INCREASED FOR CASE OF F_MUL
					output reg [31:0] A_DATA, B_DATA // corresponds to AA and BA
					);
// REGISTER FILE: 32x32

reg [31:0] REGISTER [31:0];	// R0 always 0, or rather REGISTER[31:0][0] = 0;
// what does 32 by 32 mean? 32--32-bit registers, 5 bits count from 0-31

// UPDATE: changed from [31:0] register [4:0] to [31:0] register [31:0]
//			apparently, although addresses are 5 bit to account for 32 different addresses, the second length needs each own bit

integer i;

initial begin // initialize register block to 0
	for(i = 0; i < 32; i = i + 1) begin
		REGISTER[i] = i;
	end
end
// reading: Potentially reads up to two registers, for bus A and bus B
// DOF phase
always@(*) begin 	// asynchronous parts, reading the registers
	A_DATA = REGISTER[AA];
	B_DATA = REGISTER[BA];
end
// WB phase
always@(posedge clk) begin 	// synchornous parts, writing to register
	if(MD_1 != 2'b11) // normal RW (if RW is true still)
		REGISTER[DA_1] <=	((RW_1) && (DA_1 == 0))? 0 :			// R0 is ALWAYS 0 
							(RW_1)? D_DATA[31:0] : REGISTER[DA_1];	// if Read write bit is true, then alter the specified register, else don't change anything
	else begin // MD == 2'b11 --> completed a multiplication operation
		REGISTER[DA_1] <=	((RW_1) && (DA_1 == 0))? 0 :
							(RW_1)? D_DATA[31:0] : REGISTER[DA_1];

		REGISTER[DA_1 + 1] <= 	(RW_1)? D_DATA[63:32] : REGISTER[DA_1 + 1];
	end
end

// separated rst block because it was resetting all registers even off of posedge!

always@(posedge rst) begin
	if(rst) begin
		for(i = 0; i < 32; i = i +1) begin
	  		REGISTER[i] <= 0;
		end
	end
end

endmodule