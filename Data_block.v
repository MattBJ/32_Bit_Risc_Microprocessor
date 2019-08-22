`timescale 1ns / 1ps

// EXECUTE phase of pipeline
// asynchronous (memory write is posedge sync)
// make it 32-bits by 255 (so width is 32 bits, have 255 of them)

// 'clock and reset goes to all registers'

module Data_block(
				input [31:0] Address,	// comes from bus-A
				input [31:0] Data_in,		// comes from bus-B
				input clk, MW, rst,
				output reg [31:0] Data_out	// technically, bus-B bits mapped from bus-A
				);

// need to have a register of all of the data

reg [31:0] DATA [255:0]; // external memory

integer i;

initial begin // initialize all to zero
	for(i = 0; i <256; i = i + 1) begin
		DATA[i] = i;
	end
end


// both blocks work off of data register
always@(*) begin 	// Data_read block, asynchronous
	Data_out = DATA[Address];	// address is 32 bit number, so can only map to 32 bits
end


// moved reset block for conditional reset reasons!!
always@(posedge clk) begin 	// data_write block, rising edge of clock
	if(Address > 255)
		DATA[255] <= (MW)? Data_in : DATA[255];	// if address value is greater than maximum memory allocation
	else
		DATA[Address] <= (MW)? Data_in : DATA[Address];	// dependent on MEMORY WRITE bit, if so writes over, else keeps data
end

always@(posedge rst) begin
	if(rst) begin
		for(i = 0; i < 256; i = i + 1) begin
			DATA[i] <= 0;
		end
	end	
end

endmodule