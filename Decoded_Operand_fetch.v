`timescale 1ns/1ps

module Decoded_operand_fetch(
							input [31:0] IR,	//32 bit
							input [31:0] PC_1,
							input [31:0] A_DATA, B_DATA,	// driven by wires in top module, outputted from reg files
							// IO
							output [31:0] Bus_A, Bus_B,		// drives the two registered Bus_A and Bus_B variables
							output RW, PS, MW, 
							output [4:0] DA, FS,
							output reg [4:0] SH,
							output [1:0] MD, BS, 	// MD goes to MD_1, BS goes to top phase
							output [4:0] AAnet, BAnet	// nets --> top module --> Reg file
							);

wire MA, MB, CS;
wire [31:0] CONST_DATA;
reg [14:0] IM = 0;

always@(*) begin
    IM = IR[14:0];	// 15 LSB's of IR
    SH = IR[4:0];	// 5 LSB's of IR
end
// reg file will output two data busses (A and B)
	// they will output, which drive wires in top module to this one
	// those wired inputs will exist solely as inputs here
// module instantiation

Constant_unit CU0(
					.IM(IM), .CS(CS),
					// IO
					.CONST_DATA(CONST_DATA)
					);

MUX_A MA0(
			.MA(MA), .PC_1(PC_1),
			.A_DATA(A_DATA),
			// IO
			.Bus_A(Bus_A)
			);

MUX_B MB0(
			.MB(MB), .CONST_DATA(CONST_DATA),
			.B_DATA(B_DATA),
			// IO
			.Bus_B(Bus_B)
			);

Instruction_decoder ID0( 	// not built yet
						.IR(IR),
						// IO
						.RW(RW), .DA(DA), .MD(MD),
						.BS(BS), .PS(PS), .MW(MW),
						.FS(FS), .MA(MA), .MB(MB),
						.AA(AAnet), .BA(BAnet),
						.CS(CS)
						);

endmodule