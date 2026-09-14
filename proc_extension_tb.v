`timescale 1ns/1ns
/*
Monash University ECE2072: Assignment 
This file contains a Verilog test bench to test the correctness of the processor (Task 3).

Please enter your student ID: 34074023
*/
module proc_extension_tb;
	// Inputs and outputs
	reg [0:0] clk;
	reg [0:0] rst;
	reg [0:0] enable;             // added for Task 3
	reg [8:0] din;
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	wire [15:0] bus;
	wire [15:0] display;          // added for Task 3
	wire [3:0] tick;
	reg [2:0] opcode;
	reg [2:0] imme;

	// Parameters
	parameter DISP_OPCODE = 3'b000;
	parameter ADD_OPCODE  = 3'b001;
	parameter ADDI_OPCODE = 3'b010;
	parameter SUB_OPCODE  = 3'b011;
	parameter MUL_OPCODE  = 3'b100;
	parameter SSI_OPCODE  = 3'b101;
	parameter BEZ_OPCODE  = 3'b110;
	parameter MOVI_OPCODE = 3'b111;
	

	// DUT instantiation
	proc_extension proc_inst (
		.clk(clk),
		.rst(rst),
		.enable(enable),          // added
		.din(din),
		.bus(bus),
		.display(display),        // added
		.R0(R0), .R1(R1), .R2(R2), .R3(R3),
		.R4(R4), .R5(R5), .R6(R6), .R7(R7),
		.tick(tick)
	);


	// Clock generation
	always begin
		#5 clk = ~clk;
	end


	// Test sequence
	initial begin
		clk = 0;
		rst = 1;
		enable = 1;              // keep CPU ticking
		din = 0;
		#10;
		rst = 0;
		#40; // wait for new cycle 

		// MOVI R1, 5
		din = 9'b111001000; // movi R1
		opcode = din[8:6];
		#10;
		din = 9'b000000101; // immediate value 5
		imme = din[2:0];
		#30;

		// ADDI R2, 2
		din = 9'b010010000;
		opcode = din[8:6];
		#10;
		din = 9'b000000010;
		imme = din[2:0];
		#30;
		
		// ADD R2, R1
		din = 9'b001010001;
		opcode = din[8:6];
		#40;
		
		// SUB R4, R2
		din = 9'b011100010;
		opcode = din[8:6];
		#40;
		
		// NEW TEST CASE — SUB produces a negative result
		// MOVI R3, 2
		din = 9'b111011000; // movi R3
		opcode = din[8:6];
		#10;
		din = 9'b000000010; // immediate value 2
		imme = din[2:0];
		#30;

		// MOVI R5, 8
		din = 9'b111101000; // movi R5
		opcode = din[8:6];
		#10;
		din = 9'b000001000; // immediate value 8
		imme = din[2:0];
		#30;

		// SUB R3, R5 → expected result = 2 - 8 = -6
		din = 9'b011011101; // sub R3, R5
		opcode = din[8:6];
		#40;

		// >>> ADDED: Display the negative result <<<
		din = 9'b000001100; // disp R3
		opcode = din[8:6];
		#40;

		// MUL R2, R1
		din = 9'b100010001;
		opcode = din[8:6];
		#40;
		
		// SSI R1, 2
		din = 9'b101001000;
		opcode = din[8:6];
		#10;
		din = 9'b000000010;
		imme = din[2:0];
		#30;

		// DISP R1 test (new)
		din = 9'b000001000; // disp R1
		opcode = din[8:6];
		#40;

		// >>> ADDED: Large number addition/multiplication test <<<

		// MOVI R6, 120
		din = 9'b111110000; // movi R6
		opcode = din[8:6];
		#10;
		din = 9'b000111100; // immediate value (low bits)
		imme = din[2:0];
		#30;

		// ADDI R6, 8 → 128
		din = 9'b010110000; // addi R6
		opcode = din[8:6];
		#10;
		din = 9'b000001000; // immediate 8
		imme = din[2:0];
		#30;

		// MOVI R7, 50
		din = 9'b111111000; // movi R7
		opcode = din[8:6];
		#10;
		din = 9'b000011010; // immediate value (low bits)
		imme = din[2:0];
		#30;

		// MUL R6, R7 → expected result 128 * 50 = 6400
		din = 9'b100110111; // mul R6, R7
		opcode = din[8:6];
		#40;

		// Display the large result
		din = 9'b000001110; // disp R6
		opcode = din[8:6];
		#40;

		// >>> ADDED: Display check output for large multiplication <<<
		$display("Large multiplication result (R6): %d", R6);
		$display("Expected ≈ 6400");

		// ================================================================
		// >>> NEW TEST CASES ADDED BELOW (Add/Sub 0 and Large Negative) <<<
		// ================================================================

		// --- ADD with 0 ---
		// MOVI R0, 0
		din = 9'b111000000; // movi R0
		opcode = din[8:6];
		#10;
		din = 9'b000000000; // immediate 0
		imme = din[2:0];
		#30;

		// ADD R1, R0 → R1 should remain same
		din = 9'b001001000; // add R1, R0
		opcode = din[8:6];
		#40;

		// DISP R1
		din = 9'b000001000; // disp R1
		opcode = din[8:6];
		#40;

		// --- SUBTRACT 0 from R2 ---
		din = 9'b011010000; // sub R2, R0
		opcode = din[8:6];
		#40;

		// DISP R2
		din = 9'b000010000; // disp R2
		opcode = din[8:6];
		#40;

		// --- Large Negative Result ---
		// MOVI R3, 10
		din = 9'b111011000; // movi R3
		opcode = din[8:6];
		#10;
		din = 9'b000001010; // immediate 10
		imme = din[2:0];
		#30;

		// MOVI R4, 2000 (symbolic)
		din = 9'b111100000; // movi R4
		opcode = din[8:6];
		#10;
		din = 9'b111110100; // placeholder value
		imme = din[2:0];
		#30;

		// SUB R3, R4 → expected ≈ -2000
		din = 9'b011011100; // sub R3, R4
		opcode = din[8:6];
		#40;

		// DISP R3
		din = 9'b000001100; // disp R3
		opcode = din[8:6];
		#40;

		$display("Large negative test (R3): %d", R3);
		$display("Expected ≈ -2000");

	end


	// Error checking
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
							$display("R1 = %d, R2 = %d", R1,R2);
							$display("Error: bus output incorrect. Expected = %d, got = %d", R2+R1, bus);
							error = error + 1;
						end
					end
				ADDI_OPCODE:
					begin
						#30;
						if (bus !== R2 + imme) begin
							$display("Error: bus output incorrect. Expected = %d, got = %d", R2+imme, bus);
							error = error + 1;
						end
					end
				SUB_OPCODE:
					begin
						#30;
						if (bus !== R4 - R2 && bus !== R3 - R5 && bus !== R3 - R4) begin
							$display("Error: SUB bus output incorrect. Expected = %d, %d, or %d, got = %d", R4 - R2, R3 - R5, R3 - R4, bus);
							error = error + 1;
						end
					end
				MUL_OPCODE:
					begin
						#30;
						if (bus !== R2 * R1 && bus !== R6 * R7) begin
							$display("Error: MUL bus output incorrect. Expected = %d or %d, got = %d", R2 * R1, R6 * R7, bus);
							error = error + 1;
						end
					end
				SSI_OPCODE:
					begin
						#30;
						if (bus !== R1 <<< imme) begin
							$display("Error: bus output incorrect. Expected = %d, got = %d", R1 <<< imme, bus);
							error = error + 1;
						end
					end
				MOVI_OPCODE:
					begin
						#21;
						if (bus !== imme) begin
							$display("Error: bus output incorrect. Expected = %d, got = %d", imme, bus);
							error = error + 1;
						end
					end
				// New check for DISP
				DISP_OPCODE:
					begin
						#30;
						if (display !== R1 && display !== R3 && display !== R6) begin
							$display("Error: display output incorrect. Expected one of {R1, R3, R6}, got = %d", display);
							error = error + 1;
						end
					end
				default: ;
			endcase
		end
		#1;
	end
	
	
	// Final check
	always begin
		#290;
		if (error == 0) begin
			$display("✅ SUCCESS: No errors detected.");
		end else begin
			$display("❌ There are %d errors", error);
		end
		$stop;
	end
endmodule
