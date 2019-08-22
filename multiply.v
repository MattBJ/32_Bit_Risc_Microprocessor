`timescale 1ns / 1ps

module multiply( // gonna try 4-bit multiplication first
	input [31:0] multiplicand, multiplier,
	input [4:0] FS,	// might need to be 4:0 FS??
	output [63:0] product, 
	output C // product's carry
	);

//reg [3:0] pp [0:3];
// trying new partial product register

//  column = 2N - 1
//			 row = from logic/ stage
reg [62:0] pp [0:31]; // width = 2n - 1 = 2*4 - 1 = 7

reg [62:0] pp_1 [0:21]; // row 0 = last row 0

reg [62:0] pp_2 [0:14];

reg [62:0] pp_3 [0:9];

reg [62:0] pp_4 [0:6];

reg [62:0] pp_5 [0:4];

reg [62:0] pp_6 [0:3];

reg [62:0] pp_7 [0:2];

reg [62:0] pp_8 [0:1];

reg multiplicand_sign, multiplier_sign = 0;
reg [31:0] A, B;	// A = multiplicand, B = multiplier






integer i,j; // row, col


// correct syntax for getting specific values
initial begin
	// initialize partial products to 0
	{A,B} = 0;
    for(i = 0; i < 32; i = i + 1) begin
        pp[i] = 0;
        if(i < 22)
        	pp_1[i] = 0;
        if(i < 15)
        	pp_2[i] = 0;
        if(i < 10)
        	pp_3[i] = 0;
        if(i < 7)
        	pp_4[i] = 0;
        if(i < 5)
        	pp_5[i] = 0;
        if(i < 4)
        	pp_6[i] = 0;
        if(i < 3)
        	pp_7[i] = 0;
        if(i < 2)
        	pp_8[i] = 0;
    end
end

always@(*) begin
	if((FS == 5'b11110) || (FS == 5'b11111)) begin // ONLY IN THIS CONDITION WILL WE MULTIPLY
			// FIRST CHECK SIGNS, KEEP TRACK, MAKE NUMBERS POSITIVE
			{multiplicand_sign,multiplier_sign} = {multiplicand[31],multiplier[31]};
			A = (multiplicand_sign)? (~multiplicand) + 1 : multiplicand;
			B = (multiplier_sign)? (~multiplier) + 1 : multiplier;
			// two's complement reverses sign on any binary number


			// step 1: load partial product
			for(i = 0; i < 32; i = i + 1) begin
				pp[i] = (A & {32{B[i]}}) << i;
			end

			// step 2: row reduction until 2 rows left

			// stage 1 notes:
			// 10 groups of 3
			// 2 unaffected rows (taken care of below)
			{pp_1[0],pp_1[1]} = {pp[0],pp[1]}; // unaffected rows
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				// LHS == 2 rows in next pp reg (carry and sum)
				// RHS == 3 consecutive rows in current pp reg
				// CARRY ROW, SUM ROW
				// [row][col]		RECALL: TOP 3 ROWS BEING GROUPED (so rows 1-3)

				// beginning of 10 groups of 3
				{pp_1[2][j+1],pp_1[3][j]} = pp[2][j] + pp[3][j] + pp[4][j]; // all 3 rows in column added up from previous partial product
				{pp_1[4][j+1],pp_1[5][j]} = pp[5][j] + pp[6][j] + pp[7][j]; // all 3 rows in column added up from previous partial product
				{pp_1[6][j+1],pp_1[7][j]} = pp[8][j] + pp[9][j] + pp[10][j]; // all 3 rows in column added up from previous partial product
				{pp_1[8][j+1],pp_1[9][j]} = pp[11][j] + pp[12][j] + pp[13][j]; // all 3 rows in column added up from previous partial product
				{pp_1[10][j+1],pp_1[11][j]} = pp[14][j] + pp[15][j] + pp[16][j]; // all 3 rows in column added up from previous partial product
				{pp_1[12][j+1],pp_1[13][j]} = pp[17][j] + pp[18][j] + pp[19][j]; // all 3 rows in column added up from previous partial product
				{pp_1[14][j+1],pp_1[15][j]} = pp[20][j] + pp[21][j] + pp[22][j]; // all 3 rows in column added up from previous partial product
				{pp_1[16][j+1],pp_1[17][j]} = pp[23][j] + pp[24][j] + pp[25][j]; // all 3 rows in column added up from previous partial product
				{pp_1[18][j+1],pp_1[19][j]} = pp[26][j] + pp[27][j] + pp[28][j]; // all 3 rows in column added up from previous partial product
				{pp_1[20][j+1],pp_1[21][j]} = pp[29][j] + pp[30][j] + pp[31][j]; // all 3 rows in column added up from previous partial product
				//pp_1 is stage 1 reg, pp is step 1 reg
			end

			// stage 2 notes:
			// 7 groups of 3
			// 1 unaffected row
			pp_2[0] = pp_1[0];
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_2[1][j+1], pp_2[2][j]} = pp_1[1][j] + pp_1[2][j] + pp_1[3][j]; // all 3 rows in corresponding col add up 
				{pp_2[3][j+1], pp_2[4][j]} = pp_1[4][j] + pp_1[5][j] + pp_1[6][j]; // all 3 rows in corresponding col add up 
				{pp_2[5][j+1], pp_2[6][j]} = pp_1[7][j] + pp_1[8][j] + pp_1[9][j]; // all 3 rows in corresponding col add up 
				{pp_2[7][j+1], pp_2[8][j]} = pp_1[10][j] + pp_1[11][j] + pp_1[12][j]; // all 3 rows in corresponding col add up 
				{pp_2[9][j+1], pp_2[10][j]} = pp_1[13][j] + pp_1[14][j] + pp_1[15][j]; // all 3 rows in corresponding col add up 
				{pp_2[11][j+1], pp_2[12][j]} = pp_1[16][j] + pp_1[17][j] + pp_1[18][j]; // all 3 rows in corresponding col add up 
				{pp_2[13][j+1], pp_2[14][j]} = pp_1[19][j] + pp_1[20][j] + pp_1[21][j]; // all 3 rows in corresponding col add up 
				//pp_2 is stage 2 reg
			end

			// stage 3 notes:
			// 5 groups of 3
			// 0 unaffected rows
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_3[0][j+1], pp_3[1][j]} = pp_2[0][j] + pp_2[1][j] + pp_2[2][j]; // all 3 rows in corresponding col add up 
				{pp_3[2][j+1], pp_3[3][j]} = pp_2[3][j] + pp_2[4][j] + pp_2[5][j]; // all 3 rows in corresponding col add up 
				{pp_3[4][j+1], pp_3[5][j]} = pp_2[6][j] + pp_2[7][j] + pp_2[8][j]; // all 3 rows in corresponding col add up 
				{pp_3[6][j+1], pp_3[7][j]} = pp_2[9][j] + pp_2[10][j] + pp_2[11][j]; // all 3 rows in corresponding col add up 
				{pp_3[8][j+1], pp_3[9][j]} = pp_2[12][j] + pp_2[13][j] + pp_2[14][j]; // all 3 rows in corresponding col add up 
				//pp_3 is stage 3 reg
			end

			// stage 4 notes:
			// 3 groups of 3
			// 1 unaffected row
			pp_4[0] = pp_3[0];
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_4[1][j+1], pp_4[2][j]} = pp_3[1][j] + pp_3[2][j] + pp_3[3][j]; // all 3 rows in corresponding col add up 
				{pp_4[3][j+1], pp_4[4][j]} = pp_3[4][j] + pp_3[5][j] + pp_3[6][j]; // all 3 rows in corresponding col add up 
				{pp_4[5][j+1], pp_4[6][j]} = pp_3[7][j] + pp_3[8][j] + pp_3[9][j]; // all 3 rows in corresponding col add up
				//pp_4 is stage 4 reg
			end

			// stage 5 notes:
			// 2 groups of 3
			// 1 unaffected row
			pp_5[0] = pp_4[0];
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_5[1][j+1], pp_5[2][j]} = pp_4[1][j] + pp_4[2][j] + pp_4[3][j]; // all 3 rows in corresponding col add up 
				{pp_5[3][j+1], pp_5[4][j]} = pp_4[4][j] + pp_4[5][j] + pp_4[6][j]; // all 3 rows in corresponding col add up
				//pp_5 is stage 5 reg
			end

			// stage 6 notes:
			// 1 group of 3
			// 2 unaffected rows
			{pp_6[0],pp_6[1]} = {pp_5[0],pp_5[1]};
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_6[2][j+1], pp_6[3][j]} = pp_5[2][j] + pp_5[3][j] + pp_5[4][j]; // all 3 rows in corresponding col add up
				//pp_6 is stage 6 reg
			end

			// stage 7 notes:
			// 1 group of 3
			// 1 unaffected row
			pp_7[0] = pp_6[0];
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_7[1][j+1], pp_7[2][j]} = pp_6[1][j] + pp_6[2][j] + pp_6[3][j]; // all 3 rows in corresponding col add up
				//pp_7 is stage 7 reg
			end	

			// stage 8 notes:
			// 1 group of 3
			// 0 unaffected rows
			for(j = 0; j < 63; j = j + 1) begin // column incrementation
				{pp_8[0][j+1], pp_8[1][j]} = pp_7[0][j] + pp_7[1][j] + pp_7[2][j]; // all 3 rows in corresponding col add up
				//pp_8 is stage 8 reg
			end	
		end // END OF CONDITIONAL STATEMENT
end // end of combinational block

// step 3: assign product

assign {C,product} = (((FS == 5'b11110)||(FS == 5'b11111)) && (multiplicand_sign != multiplier_sign))? (~(pp_8[0] + pp_8[1])) + 1 : 
					 ((FS == 5'b11110)||(FS == 5'b11111))? pp_8[0] + pp_8[1] : {C,64'd0}; // keep C as it is/was
					 // NOTE: if the signed registers aren't equal, that means one is pos and one is neg, therefore do final addition then make negative
					 //			ELSE, just do final addition and keep it in positive. And if FS isn't true, then this output means nothing


// STEP 2:
// stage 1 --> top 3 rows --> two rows
//			ignore bottom row
// stage 2 --> all 3 rows --> final two rows

// step 3: top row + bottom row --> Product

endmodule