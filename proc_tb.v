`timescale 1ns/1ns
/*
Monash University ECE2072: Assignment 
This file contains a Verilog test bench to test the correctness of the processor.

Please enter your student ID: 34074023

*/
module proc_tb;
	// TODO: Implement the logic of your testbench here
	//inputs and outputs
	reg [0:0] clk;
	reg [0:0] rst;
	reg [8:0] din;
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	wire [15:0] bus;
	wire [3:0] tick;
	reg [2:0] opcode;
	reg [2:0] imme;

	//parameters
	parameter DISP_OPCODE = 3'b000;
	parameter ADD_OPCODE  = 3'b001;
	parameter ADDI_OPCODE = 3'b010;
	parameter SUB_OPCODE  = 3'b011;
	parameter MUL_OPCODE  = 3'b100;
	parameter SSI_OPCODE  = 3'b101;
	parameter BEZ_OPCODE  = 3'b110;
	parameter MOVI_OPCODE = 3'b111;
	
	//instantiate
	simple_proc proc_inst (.clk(clk),.rst(rst),.din(din),.bus(bus),.R0(R0),.R1(R1),.R2(R2),.R3(R3),.R4(R4),.R5(R5),.R6(R6),.R7(R7),.tick(tick));

	always begin
		#5
		clk = ~clk;
	end

	initial begin
		clk = 0;
		rst = 1;
		din = 0;
		#10;
		rst = 0;
		#40;//wait to start a new cycle 
		
		din = 9'b111001000; //move R1
		opcode = din[8:6];
		#10;//after a tick (at tick 2)
		din = 9'b000000101; // immediate number 5
		imme = din[2:0];
		#30;//after 3 ticks
		
		din = 9'b010010000;//addi R2
		opcode = din[8:6];
		#10;
		din = 9'b000000010;// number 2
		imme = din[2:0];
		#30;
		
		din = 9'b001010001;//add R2,R1
		opcode = din[8:6];
		#40;
		
		din = 9'b011100010;//sub R4,R2
		opcode = din[8:6];
		#40;
		
		din = 9'b100010001;//mul R2,R1
		opcode = din[8:6];
		#40;
		
		din = 9'b101001000;//ssi R1
		opcode = din[8:6];
		#10;
		din = 9'b000000010;// number 2
		imme = din[2:0];
		#30;
		
		
	end

	integer error = 0;
	always begin
		#9;
		if (rst == 1) begin
			if (R0 !== 0 | R1 !== 0 | R2 !== 0 | R3 !== 0 | R4 !== 0 | R5 !== 0 | R6 !== 0 | R7 !== 0) begin
				$display("Error: the registers' outputs are not 0.");
				error = error + 1;
			end
		end else begin
			case (opcode)
				ADD_OPCODE:
					begin
						#30;
						if (bus !== R2 + R1) begin
							$display("R1 = %d, $R2 = %d", R1,R2);
							$display("Error: bus output is incorrect. Expected output = %d, current output = %d",R2+R1,bus);
							error = error + 1;
						end
					end
				ADDI_OPCODE:
					begin
						#30;
						if (bus !== R2 + imme) begin
							$display("Error: bus output is incorrect. Expected output = %d, current output = %d",R2+imme,bus);
							error = error + 1;
						end
					end
				SUB_OPCODE:
					begin
						#30;
						if (bus !== R4-R2) begin
							$display("Error: bus output is incorrect. Expected output = %d, current output = %d",R4-R2,bus);
							error = error + 1;
						end
					end
				MUL_OPCODE:
					begin
						#30;
						if (bus !== R2*R1) begin
							$display("Error: bus output is incorrect. Expected output = %d, current output = %d",R2*R1,bus);
							error = error + 1;
						end
					end
				SSI_OPCODE:
					begin
						#30;
						if (bus !== R1<<<imme) begin
							$display("Error: bus output is incorrect. Expected output = %d,current output = %d",R1<<<imme,bus);
							error = error + 1;
						end
					end
				MOVI_OPCODE:
					begin
						#21;
						if (bus !== imme) begin
							$display("Error: bus output is incorrect. Expected value = %d, current value = %d",imme,bus);
							error = error + 1;
						end
					end
				default: ;
			endcase
		end
		#1;
	end
	
	always begin
		#290;
		if (error == 0) begin
			$display("success");
		end else begin
			$display("There are %d errors", error);
		end
		$stop;
	end
endmodule 