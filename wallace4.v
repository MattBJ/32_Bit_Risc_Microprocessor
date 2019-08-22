    `timescale 1ns / 1ps
     

     // code found from online, 4x4 wallace tree
    module wallace4(input [3:0] A, input [3:0] B, output [7:0] P);
     
    integer i;
    wire s11,s12,s13,s14,s15,   s22,s23,s24,s25,s26,    s32,s34,s35,s36,s37;
    wire c11,c12,c13,c14,c15,   c22,c23,c24,c25,c26,    c32,c34,c35,c36,c37;
    reg [3:0] pp0,pp1,pp2,pp3 ;
     
    //Calculation of Partial Product
    always @(A or B)
    begin
        for(i=0;i<4;i=i+1) begin
      pp0[i] <= A[i] & B[0]; // multiplicand and multiplier
      pp1[i] <= A[i] & B[1];
      pp2[i] <= A[i] & B[2];
      pp3[i] <= A[i] & B[3];
        end     
    end
     
    assign P[0] = pp0[0];
    assign P[1] = s11;
    assign P[2] = s22;
    assign P[3] = s32;
    assign P[4] = s34;
    assign P[5] = s35;
    assign P[6] = s36;
    assign P[7] = s37;
     
    //first stage
    HA ha11 (pp0[1],pp1[0],s11,c11);
    FA fa12 (pp0[2],pp1[1],pp2[0],s12,c12);
    FA fa13 (pp0[3],pp1[2],pp2[1],s13,c13);
    FA fa14 (pp1[3],pp2[2],pp3[1],s14,c14);
    HA ha15 (pp2[3],pp3[2],s15,c15);
     
    //second stage
    HA ha21 (c11,s12,s22,c22);
    FA fa22 (pp3[0],c12,s13,s23,c23);
    FA fa23 (c13,c23,s14,s24,c24); 
    FA fa24 (c14,c24,s15,s25,c25);
    FA fa25 (c15,c25,pp3[3],s26,c26);
     
    //third stage
    HA ha31 (c22,s23,s32,c32);
    HA ha32 (c32,s24,s34,c34);
    HA ha33 (c34,s25,s35,c35);
    HA ha34 (c35,s26,s36,c36);
    HA ha35 (c36,c26,s37,c37);
     
    endmodule