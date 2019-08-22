`timescale 1ns / 1ps

module Pipeline_tb();
reg clk;
reg rst;

RISC_Pipelined_CPU uut(
						.clk(clk), .rst(rst)
						);
						
initial begin
    #100;
    {clk,rst} = 0;
    #10 rst = 1;
    #50 rst = 0;
    
end

always
    #5 clk = ~clk;
    
endmodule