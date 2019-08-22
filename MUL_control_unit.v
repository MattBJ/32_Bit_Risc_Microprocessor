`timescale 1ns / 1ps

module MUL_control_unit(
	input go, Q0, z, clk,
	output initialize, clear_c, load, shift_dec,
	output reg done	// outputs to go register in MUL_ALU module,
	);

reg [1:0] mul_state, next_mul_state, prev_mul_state;
reg prev_go;
parameter IDLE = 2'b00;
parameter MUL0 = 2'b01;
parameter MUL1 = 2'b10;


initial begin
	{mul_state, next_mul_state, prev_mul_state, prev_go} = 0;
end

// flip-flop design
always@(posedge clk) begin
	prev_go <= go;
	prev_mul_state <= mul_state;
	mul_state <= next_mul_state;
end

always@(*) begin
	case(mul_state)
		IDLE:
		begin
			next_mul_state = (go)? MUL0 : IDLE; 	// actually is go && IDLE, but since we're in IDLE, then only go
			{initialize, clear_c, load, shift_dec} = (go)? 4'b1100; // always initialize and clear_c signals
		end
		MUL0:
		begin
			next_mul_state = MUL1;	// always go to next state
			{initialize, clear_c, load, shift_dec} = (Q0)? 4'b0010 : 4'b0000;
		end
		MUL1:
		begin
			next_mul_state = (z)? IDLE : MUL0;		// if P register is finally 0, then back to idle state until go signal is done
			// NOTE: need to find way to stop go input!
			{initialize, clear_c, load, shift_dec} = 4'b0101; // always shift_dec and clear_c signals
		end
	endcase
	done =  (go && !prev_go)? 0 : // first iteration of go, done is reset to 0
			(prev_mul_state == MUL1 && mul_state == IDLE)? 1 : 0;	// if going from MUL1 to IDLE, then done!
end // outputs are asynchronous, state updates are synchronous


endmodule