`timescale 1ns/1ns
/*
Monash University ECE2072: Assignment 
This file contains a Verilog test bench to test the correctness of the individual 
    components used in the processor.

Please enter your student ID:

*/
module components_tb;
	//for sign_extender
	reg [8:0] DIN;
	wire [15:0] SignExtOut;

	sign_extend test_sign (.din(DIN), .dout(SignExtOut));

	integer error_sign = 0;
	initial begin
    $display("\n--- Testing Sign Extender ---");
		
		// positive case (+85)
		DIN = 9'b010101010; // MSB = 0 → positive number
		#5;
		if (SignExtOut !== 16'b0000001010101010) begin
			$display("Error: Positive sign extension wrong. DIN=%b, OUT=%b", DIN, SignExtOut);
			error_sign = error_sign + 1;
		end

		// negative case (-43)
		DIN = 9'b101010101; // MSB = 1 → negative number
		#5;
		if (SignExtOut !== 16'b1111111101010101) begin
			$display("Error: Negative sign extension wrong. DIN=%b, OUT=%b", DIN, SignExtOut);
			error_sign = error_sign + 1;
		end

		// zero case
		DIN = 9'b000000000;
		#5;
		if (SignExtOut !== 16'b0000000000000000) begin
			$display("Error: Zero case wrong. DIN=%b, OUT=%b", DIN, SignExtOut);
			error_sign = error_sign + 1;
		end

		#5;
		if (error_sign == 0)
			$display("Success for Sign Extender module.");
		else
			$display("Number of errors: %d", error_sign);
	end
	//for tick_FSM
	reg [0:0] rst;
	reg [0:0] clk;
	reg [0:0] enable;
	wire [3:0] tick;
	reg [3:0] tick_check;
	//instantiate
	tick_FSM test_tick (.rst(rst),.clk(clk),.enable(enable),.tick(tick));
	//initial variables
	initial begin
		enable = 1;
		rst = 0;
		clk = 0;
		tick_check = 1;
		#60
		rst = 1;
		#10
		enable = 0;
	end
	//simulate a clock cycle
	always begin
		#5
		clk = ~clk;
	end
	//update Q to check
	always begin
		#10
		if (enable == 1 & tick_check !== 4'b1000 & rst == 0) begin
			tick_check = tick_check << 1;
		end else if ((enable == 1 & tick_check == 4'b1000 & rst == 0) || rst == 1) begin
			tick_check = 1;
		end
	end
	//checking
	integer error_tick = 0;
	
	always begin
		#9
		if (rst == 1) begin
			if (tick !== 4'b0001) begin
				$display("Error: expected 1 after reset.");
				error_tick = error_tick + 1;
			end 
		end else begin
			if (enable == 1) begin
				if (tick != tick_check) begin
					$display("Error: expected tick value = %b, current tick value = %b", tick_check, tick);
					error_tick = error_tick + 1;
				end
			end else begin // enable == 0
				if (tick != tick_check) begin
					$display("Error: expected tick value = %b, current tick value = %b", tick_check, tick);
					error_tick = error_tick + 1;
				end
			end
		end
		#1;
	end
	//display after checking all
	always begin
		#80
		if (error_tick == 0) begin
			$display("Success for tick_FSM.");
		end else begin
			$display("Number of errors: %d", error_tick);
		end
	end
	
	//for multiplexer
	reg [15:0] SignExtDin;
	reg [15:0] R0;
	reg [15:0] R1;
	reg [15:0] R2;
	reg [15:0] R3;
	reg [15:0] R4;
	reg [15:0] R5;
	reg [15:0] R6;
	reg [15:0] R7;
	reg [15:0] G;
	reg [3:0] sel;
	wire [15:0] Bus;
	//instantiate
	multiplexer test_multi (.SignExtDin(SignExtDin),.R0(R0),.R1(R1),.R2(R2),.R3(R3),.R4(R4),.R5(R5),.R6(R6),.R7(R7),.G(G),.sel(sel),.Bus(Bus));
	//initial values
	initial begin
		SignExtDin = 16'd12;
		R0 = 1;
		R1 = 2;
		R2 = 3;
		R3 = 4;
		R4 = 5;
		R5 = 6;
		R6 = 7;
		R7 = 8;
		G = 9;
		sel = 0;
	end
	//update sel
	always begin
		#10
		sel = sel + 1;
	end
	//checking
	integer error_multi = 0;
	always begin
		#9
		case (sel)
			0: begin
				if (Bus != R0) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R0,Bus);
					error_multi = error_multi + 1;
				end
			end
			1: begin
				if (Bus != R1) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R1,Bus);
					error_multi = error_multi + 1;
				end
			end
			2: begin
				if (Bus != R2) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R2,Bus);
					error_multi = error_multi + 1;
				end
			end
			3: begin
				if (Bus != R3) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R3,Bus);
					error_multi = error_multi + 1;
				end
			end
			4: begin
				if (Bus != R4) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R4,Bus);
					error_multi = error_multi + 1;
				end
			end
			5: begin
				if (Bus != R5) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R5,Bus);
					error_multi = error_multi + 1;
				end
			end
			6: begin
				if (Bus != R6) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R6,Bus);
					error_multi = error_multi + 1;
				end
			end
			7: begin
				if (Bus != R7) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",R7,Bus);
					error_multi = error_multi + 1;
				end
			end
			8: begin
				if (Bus != G) begin
					$display("Error: wrong bus. Expected value: %b, current value: %b",G,Bus);
					error_multi = error_multi + 1;
				end
			end
		endcase
		#1;
	end
	//display values after checking all
	always begin
		#80
		if (error_multi == 0) begin
			$display("Success for multiplexer.");
		end else begin
			$display("Number of errors: %d", error_multi);
		end
		$stop;
	end
	
	//for ALU
	reg [15:0] input_a, input_b;
	reg [2:0] alu_op;
	wire [15:0] alu_out;
	integer error_alu = 0;

	ALU test_alu (.input_a(input_a), .input_b(input_b), .alu_op(alu_op), .result(alu_out));

	initial begin
    $display("\n--- Testing ALU ---");
		input_a = 4; input_b = 3;

		// multiplication
		alu_op = 3'b000; #5;
		if (alu_out !== 12) begin
			$display("Error: mult failed. Expected 12, got %d", alu_out);
			error_alu = error_alu + 1;
		end

		// addition
		alu_op = 3'b001; #5;
		if (alu_out !== 7) begin
			$display("Error: add failed. Expected 7, got %d", alu_out);
			error_alu = error_alu + 1;
		end

		// subtraction
		alu_op = 3'b010; #5;
		if (alu_out !== 1) begin
			$display("Error: sub failed. Expected 1, got %d", alu_out);
			error_alu = error_alu + 1;
		end

		// signed shift (3 << 4 = 48)
		alu_op = 3'b011; #5;
		if (alu_out !== 48) begin
			$display("Error: shift failed. Expected 48, got %d", alu_out);
			error_alu = error_alu + 1;
		end

		#5;
		if (error_alu == 0)
			$display("Success for ALU module.");
		else
			$display("Number of errors: %d", error_alu);
	end
	//for register_n
	parameter n = 4;
	reg rst_reg;
	reg r_in;
	reg [n-1:0] data_in;
	wire [n-1:0] Q;
	//instantiate
	register_n #(.N(n)) test_reg (.data_in(data_in),.r_in(r_in),.clk(clk),.Q(Q),.rst(rst_reg));
	
	initial begin
		rst_reg = 0;
		r_in = 1;
		data_in = 4'b1011;//any value to insert
		#10
		r_in = 0;//test when r_in disabled
		#10
		r_in = 1;//test reset
		rst_reg = 1;
		data_in = 4'b1011;
		#10
		rst_reg = 0;//test reassertion of r_in
	end
	//please fix issue here
	reg [n-1:0] old_data;
	always begin
		#10
		if (r_in == 0) begin
			old_data = data_in;
			data_in = 0;
		end
	end
	//checking
	integer error_reg = 0;
	always begin
		#9
		if (rst_reg == 1 & Q !== 0) begin
			$display("Error: expected Q = %b, current Q = %b", 0, Q);
			error_reg = error_reg + 1;
		end else if (rst_reg == 0) begin
			if (r_in == 1 & Q !== data_in) begin
				$display("Error: expected Q = %b, current Q = %b",data_in,Q);
				error_reg = error_reg + 1;
			end else if (r_in == 0 & Q !== old_data) begin
				$display("Error: Q value did not hold. Expected Q = %b, current Q = %b",old_data,Q);
				error_reg = error_reg + 1;
			end
		end
		#1;
	end
	//display result
	always begin
		#40
		if (error_reg == 0) begin
			$display("Success for register_n module.");
		end else begin
			$display("Number of errors: %d", error_reg);
		end
	end
endmodule 