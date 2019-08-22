`timescale 1ns/1ps

// MUL UPDATE
// ADDED F_MUL
// BUS_D IS ALWAYS 64 BIT WIDTH NOW

module Write_back(
				 input [31:0] F, Data_out,
				 input [63:0] F_mul,
				 input VxorN,	// gonna be 0 padded (for SLT set less than)
				 input [1:0] MD_1,	// 11 unused?.?
				 //input RW, --> register file is instantiated in top module
				 input [4:0] DA,	// destination address
				 // IO --> NO OUTPUTS!!!
				 output [63:0] Bus_D	// reg file in top verilog module!!, so no clock or reset
				 );	// remember, RW, DA, MD comes from current registered versions --> Two negedge sets
				// ie MD_1, RW_1, DA_1 into these bad boys

wire [31:0] status = 0;	// 0 padded VxorN

assign status = {31'd0,VxorN};	// defaults to LSB, 0 padding

MUX_D MD0(
			.MD_1(MD_1), .F(F),
			.Data_out(Data_out),
			.status(status),
			// MUL UPDATE
			.product(F_mul),
			// IO
			.Bus_D(Bus_D)
			);

// This will output to top module to input into register file

endmodule