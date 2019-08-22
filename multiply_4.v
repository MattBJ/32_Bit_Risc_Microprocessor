`timescale 1ns / 1ps

module multiply_4( // gonna try 4-bit multiplication first
	input [3:0] multiplicand, multiplier,
	input [6:0] opcode,	// might need to be 4:0 FS??
	output [7:0] product
	);

//reg [3:0] pp [0:3];
// trying new partial product register

reg [6:0] pp [0:3]; // width = 2n - 1 = 2*4 - 1 = 7

reg [6:0] pp_1 [0:2]; // row 0 = last row 0

reg [6:0] pp_2 [0:1];
integer i,j; // row, col


// correct syntax for getting specific values
initial begin
    for(i = 0; i < 4; i = i + 1) begin
        pp[i] = 0;
        if(i < 3) begin
            pp_1[i] = 0;
            if(i < 2)
                pp_2[i] = 0;
        end
    end
end

always@(*) begin
	// step 1: load partial product
	for(i = 0; i < 4; i = i + 1) begin
		pp[i] = (multiplicand & {4{multiplier[i]}}) << i;
	end
	// step 2: row reduction until 2 rows left
	// stage 1
	pp_1[0] = pp[0]; // unaffected row
	for(j = 0; j < 7; j = j + 1) begin // column incrementation
		// CARRY ROW, SUM ROW
		// [row][col]		RECALL: TOP 3 ROWS BEING GROUPED (so rows 1-3)
		{pp_1[1][j+1],pp_1[2][j]} = pp[1][j] + pp[2][j] + pp[3][j]; // all 3 rows in column added up from previous partial product
		// don't think I need a row for, unless I'm initializing a bunch of unaffected rows
	end
	// stage 2

	for(j = 0; j < 7; j = j + 1) begin // column incrementation
		{pp_2[0][j+1], pp_2[1][j]} = pp_1[0][j] + pp_1[1][j] + pp_1[2][j]; // all 3 rows in corresponding col add up 
	end
end

// step 3: assign product

assign product = pp_2[0] + pp_2[1];

// STEP 2:
// stage 1 --> top 3 rows --> two rows
//			ignore bottom row
// stage 2 --> all 3 rows --> final two rows

// step 3: top row + bottom row --> Product

endmodule