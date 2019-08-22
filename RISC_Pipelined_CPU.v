`timescale 1ns / 1ps

// --------------------------------------------------------------------------
// RISC/ASM6 MUL UPDATE

// Added new reg and net F_mul and F_mul_net (gets outputted from EX block)

/*
	For this homework, I must implement the RISC pipline CPU in figure 10-15.
	There are 5 different phases in the pipeline:
		top_phase (Mux C writing to PC)
		Instruction Fetch
		Decoded Operand Fetch
		Execution
		WriteBack

	Each phase will have its own module to work with the instruction bits
		-The phase modules will instantiate any necessary sub modules required

	All phases should be instantiated in one very top verilog module
		-Inputs:
			Instruction bits
			clock
			? TBD (look at figure and come back/edit other modules)
			Data memory
		-outputs:
			Register file
			Data memory
		-Reg's (things that will be inputs/outputs)
			PC (PC-1, PC-2)
			IR (Instruction Read)


UART --> know polarity, speed, start/stop bits
*/

module RISC_Pipelined_CPU	(
							input clk,
							input rst
							);	// probably adding more






// All clocked (blues) come from top module, but certainly the boxes between phases are in top
// these boxes are simply registers

// beginning of reg's: PS,Z,

reg [31:0] PC = 0;
reg [31:0] PC_1 = 0;
reg [31:0] PC_2 = 0;
reg [31:0] IR = 0;	// instr. mem -> IF -> register
reg RW = 0; // Register file
reg [4:0] DA = 0; // Reg File (dest address)
reg [1:0] MD = 0; // MUX_D
reg [1:0] BS = 0; // top phase comb. ckt.
reg PS = 0; // top phase comb. ckt.
reg MW = 0; // Data_block
reg [4:0] FS = 0; // ALU
reg [4:0] SH = 0; // ALU
reg [31:0] A = 0; // reg file to ALU
reg [31:0] B = 0; // reg file to ALU
reg VxorN = 0;	// MUX_D (status input)
reg [31:0] F = 0; // alu to MUX_D
reg [31:0] Data_out; // MUX_D
//reg [31:0] D_DATA = 0; --> just use bus_dnet
reg RW_1 = 0;
reg [31:0] Bus_A = 0;
reg [31:0] Bus_B = 0;
reg [4:0] DA_1 = 0;
reg [1:0] MD_1 = 0;

reg [63:0] F_mul = 0;
// end of reg's 

// beginning of wires
wire [31:0] Bus_Anet, Bus_Bnet, Data_outnet, Fnet, BrAnet, RAAnet;
wire RWnet, PSnet, MWnet, VxorNnet, Znet;
wire [1:0] MDnet, BSnet;
wire [4:0] SHnet, FSnet, AAnet, BAnet, DAnet;	// AA and BA needed since Register file is linked from top
wire [31:0] A_DATA, B_DATA; // output of register files --> DOF --> Mux's
wire [31:0] IRnet, BrA, RAA;
wire [31:0] PC_1net;
wire [31:0] PC_net;


// MUL UPDATE
wire [63:0] F_mul_net;
wire [63:0] Bus_Dnet;

// end of wires




// module instantiation
Register_file RF0(
					.clk(clk), .RW_1(RW_1), .rst(rst),
					.DA_1(DA_1), .AA(AAnet), .BA(BAnet),
					.D_DATA(Bus_Dnet),
					// MUL UPDATE
					.MD_1(MD_1),
					// IO
					.A_DATA(A_DATA), .B_DATA(B_DATA)
					);

Top_phase T0( // missing reg's: PS,Z,
			.BS(BS), .PS(PS), // BS = 2-bit input, PS = 1 bit input. Latched on falling edge clk, PC_2 phase latch
			.Z(Znet), .PC_1(PC_1net),
			.BrA(BrAnet), .RAA(RAAnet),
			// IO
			.PC(PC_net)
			);

Instruction_fetch IF0(
						.PC(PC),
						// IO
						.PC_1(PC_1net), // PC + 1, into a wire, reg'd
						.IR(IRnet) // Program memory, into a wire, reg'd
						);

Decoded_operand_fetch DOF0(
							.IR(IR), .PC_1(PC_1), .A_DATA(A_DATA),
							.B_DATA(B_DATA),
							//IO
							.Bus_A(Bus_Anet), .Bus_B(Bus_Bnet),
							.RW(RWnet), .PS(PSnet), .MW(MWnet),
							.DA(DAnet), .FS(FSnet), .SH(SHnet),
							.MD(MDnet), .BS(BSnet),
							.AAnet(AAnet), .BAnet(BAnet)
							);

Execute E0(	// gets all inputs from reg's
			.A(Bus_A), .B(Bus_B), .PC_2(PC_2),
			.SH(SH), .FS(FS),
			.clk(clk), .rst(rst), .MW(MW),
			// IO --> outs drive on net, ins drive from reg
			.F(Fnet), .Data_out(Data_outnet), .BrA(BrAnet), .RAA(RAAnet),	// bra and raa need to be initialized
			.VxorN(VxorNnet), .Z(Znet),
			.F_mul(F_mul_net) // MUL UPDATE
			);

Write_back WB0(
				.F(F), .Data_out(Data_out),
				.VxorN(VxorN), .MD_1(MD_1), //.RW(RW), --> used in reg file (sep. instantiation)
				.DA(DA),
				// MUL UPDATE
				.F_mul(F_mul),
				// IO
				.Bus_D(Bus_Dnet)
				);
// end of instantiation

// synchronous blocks

// Layer 1: PC
// Layer 2: PC_1, IR
// Layer 3: PC_2, RW, DA, MD, BS, PS, MW, FS, SH, BUS_A, BUS_B
// Layer 4: RW_1, DA_1, MD_1, VxorN, F_data, Data_out (from memory block)

// Synchonous, unlayered reg's: -Data in(memory), falling edge
//								-DA, register RW data (Bus_D), rising edge (done in reg file)
always@(negedge clk) begin
	PC <= PC_net; // pc_net comes from top phase combinational circuit
	PC_1 <= PC_1net; // PC_1net comes from IF phase, +1 combinational circuit
	PC_2 <= PC_1; // PC_1 comes from PC_1, which goes into PC_2
	// ^ = PC d-flip flop latches which keep up with pipelined instructions

	IR <= IRnet;

	{RW,DA,MD,BS,PS,MW,FS,SH} <= {RWnet,DAnet,MDnet,BSnet,PSnet,MWnet,FSnet,SHnet};
	// ^Control words that come from IR

	{RW_1,DA_1,MD_1} <= {RW,DA,MD};
	// ^ d-flip flop latches to keep up with pipelined instructions

	{Bus_A,Bus_B} <= {Bus_Anet, Bus_Bnet};

	{VxorN, F, Data_out} <= {VxorNnet, Fnet, Data_outnet};

	// MUL UPDATE

	F_mul <= F_mul_net;
end

// Bus D from Mux D is not reg'd --> inputted into register file
//always@(posedge clk) begin
//	D_DATA <= Bus_Dnet;
//end
// end of synchonous blocks

// reset condition
always@(posedge rst) begin
	{PC,PC_1,PC_2} = 0;
	IR = 0;
	{RW,DA,MD,BS,PS,MW,FS,SH} = 0;
	{RW_1,DA_1,MD_1} = 0;
	{Bus_A,Bus_B} = 0;
	F_mul = 0;
end


endmodule