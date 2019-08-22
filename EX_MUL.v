`timescale 1ns / 1ps

// in second execute pipeline stage (parallel with other execute stage)

module EX_MUL(
	input go, clk,	// clocked to make synchronous
	input RW, 
	input [4:0] DA,	// MD not needed
	// go:
	input [31:0] multiplicand, multiplier,
	output reg [63:0] product,	// in final code, will be two registers concatonated together
	output reg RW_1, DA_1	// usually done in top module, but since delayed need to keep here
	);

reg [1:0] sign_latch;
reg go_latch, prev_go, start;
reg RW_latch, DA_latch;
reg [31:0] pos_multiplicand, pos_multiplier;
wire done;



MUL_ALU MLU(
	.go(go_latch), .clk(clk),
	.multiplicand(pos_multiplicand),
	.multiplier(pos_multiplier),
	// IO
	.product(product), .done(done);
	);

always@(posedge clk) begin
	prev_go <= go;
end

always@(*) begin
	start = (go && !prev_go)? 1 : 0;
	{RW_latch,DA_latch} = (start)? {RW,DA} : {RW_latch, DA_latch};

	go_latch = (go && (~done));	// when go signal comes in, done should be false, when done signal is true, go latch goes to false
	{RW_1,DA_1} = (!go_latch)? {RW_latch,DA_latch} : {RW_1,DA_1};
	// sign check
	sign_latch = {multiplicand[31],multiplier[31]}; // if 00, both pos, 11, both negative
	// if either sign latch bits, need to make positive by taking two's complement
	pos_multiplicand =  (sign_latch[1])? ((~multiplicand) + 1) : multiplicand;
	pos_multiplier = 	(sign_latch[0])? ((~multiplier) + 1) : multiplier;

	product = (sign_latch[1] == sign_latch[0])? product : (~product) + 1;	// if the sign bits are equal, stays positive, else negative

end

endmodule