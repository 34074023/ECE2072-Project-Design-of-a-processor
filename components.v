/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual components to be used in 
    the CPU.

Please enter your name and student ID:

*/
module sign_extend(
    input  wire [8:0] din,
    output wire [15:0] dout
);
    // Always zero-extend since all immediates are positive
    assign dout = {7'b0, din};
endmodule

module tick_FSM(rst, clk, enable, tick);
	/* 
	 * This module implements a tick FSM that will be used to
	 * control the actions of the control unit
	 */

	// TODO: Declare inputs and outputs
	input rst;
	input clk;
	input enable;
	output reg [3:0] tick;
	
	always @(posedge clk) begin
	  if (rst) begin
			tick <= 4'b0001;
	  end else if (enable) begin
			case (tick)
				 4'b0001: tick <= 4'b0010; 
				 4'b0010: tick <= 4'b0100; 
				 4'b0100: tick <= 4'b1000; 
				 4'b1000: tick <= 4'b0001; 
				 default: tick <= 4'b0001; 
			endcase
	  end
	end


endmodule

module multiplexer(SignExtDin, R0, R1, R2, R3, R4, R5, R6, R7, G, sel, Bus);
	/* 
	 * This module takes 10 inputs and places the correct input onto the bus.
	 */
	// TODO: Declare inputs and outputs
	input [15:0] SignExtDin;
	input [15:0] R0;
	input [15:0] R1;
	input [15:0] R2;
	input [15:0] R3;
	input [15:0] R4;
	input [15:0] R5;
	input [15:0] R6;
	input [15:0] R7;
	input [15:0] G;
	input [3:0] sel;
	output reg [15:0] Bus;
	// TODO: implement logic
	always @(*) begin
		case (sel)
			0: Bus = R0;
			1: Bus = R1;
			2: Bus = R2;
			3: Bus = R3;
			4: Bus = R4;
			5: Bus = R5;
			6: Bus = R6;
			7: Bus = R7;
			8: Bus = G;
			9: Bus = SignExtDin;
			default: Bus = 0;
		endcase 
	end

endmodule

module ALU (
    input  wire [15:0] input_a,
    input  wire [15:0] input_b,
    input  wire [2:0]  alu_op,
    output reg  [15:0] result
);
    always @(*) begin
        // default to avoid latches
        result = 16'd0;

        case (alu_op)
            3'b000: result = input_a * input_b;              // multiplication
            3'b001: result = input_a + input_b;              // addition
            3'b010: result = input_a - input_b;              // subtraction
            3'b011: result = $signed(input_b) <<< input_a;   // signed shift left
				3'b100: result = input_b;                        // move immediate
            default: result = 16'd0;                         // don't care
        endcase
    end
endmodule



module register_n(data_in, r_in, clk, Q, rst);


	// To set parameter N during instantiation, you can use:
	// register_n #(.N(num_bits)) reg_IR(.....), 
	// where num_bits is how many bits you want to set N to
	// and "..." is your usual input/output signals

	parameter N = 16;

	/* 
	 * This module implements registers that will be used in the processor.
	 */
	// TODO: Declare inputs, outputs, and parameter:
	input [N-1:0] data_in;
	input r_in;
	input clk;
	input rst;
	output reg [N-1:0] Q;
	// TODO: Implement register logic:
	always @(posedge clk) begin
		if (rst) begin
			Q <= 0;
		end else begin
			if (r_in) begin
				Q <= data_in;
			end
		end
	end
endmodule
