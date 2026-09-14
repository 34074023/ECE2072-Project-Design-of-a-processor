/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual the CPU.

Please enter your student ID: 34074023

*/
module simple_proc(clk, rst, din, bus, R0, R1, R2, R3, R4, R5, R6, R7, tick);

    // Note: The skeleton you are provided with includes output ports to output the values of the internal registers R0 - R7, for the purpose of test benching. When instantiating the processor to program your DE10-lite, you can leave these ports unused.

    // TODO: Declare inputs and outputs:
	 input clk;
	 input rst;
	 input [8:0] din;
	 output [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	 output [15:0] bus;
	 output [3:0] tick;

    // TODO: declare wires:
	 wire [15:0] dout;
	 wire [15:0] alu_out;
	 reg [2:0] alu_op;
	 reg [3:0] sel;
	 wire [15:0] mux_out;
	 wire [15:0] Q_R0, Q_R1, Q_R2, Q_R3, Q_R4, Q_R5, Q_R6, Q_R7;
	 wire [15:0] Q_A, Q_G;
	 reg A_in, G_in;
	 reg R0_in, R1_in, R2_in, R3_in, R4_in, R5_in, R6_in, R7_in;
	 reg IR_in;
	 wire [8:0] IR_out;
	 //parameters
	 parameter DISP_OPCODE = 3'b000;
    parameter ADD_OPCODE  = 3'b001;
    parameter ADDI_OPCODE = 3'b010;
    parameter SUB_OPCODE  = 3'b011;
    parameter MUL_OPCODE  = 3'b100;
    parameter SSI_OPCODE  = 3'b101;
    parameter BEZ_OPCODE  = 3'b110;
    parameter MOVI_OPCODE = 3'b111;
	 
	 //sign extend for immediate
    sign_extend inst_ext (.din(din),.dout(dout));
	 
    // TODO: instantiate registers:
    register_n inst_R0 (.data_in(bus),.r_in(R0_in),.clk(clk),.Q(Q_R0),.rst(rst));
	 register_n inst_R1 (.data_in(bus),.r_in(R1_in),.clk(clk),.Q(Q_R1),.rst(rst));
	 register_n inst_R2 (.data_in(bus),.r_in(R2_in),.clk(clk),.Q(Q_R2),.rst(rst));
	 register_n inst_R3 (.data_in(bus),.r_in(R3_in),.clk(clk),.Q(Q_R3),.rst(rst));
	 register_n inst_R4 (.data_in(bus),.r_in(R4_in),.clk(clk),.Q(Q_R4),.rst(rst));
	 register_n inst_R5 (.data_in(bus),.r_in(R5_in),.clk(clk),.Q(Q_R5),.rst(rst));
	 register_n inst_R6 (.data_in(bus),.r_in(R6_in),.clk(clk),.Q(Q_R6),.rst(rst));
	 register_n inst_R7 (.data_in(bus),.r_in(R7_in),.clk(clk),.Q(Q_R7),.rst(rst));
	 register_n inst_A (.data_in(bus),.r_in(A_in),.clk(clk),.Q(Q_A),.rst(rst));
	 register_n inst_G (.data_in(alu_out),.r_in(G_in),.clk(clk),.Q(Q_G),.rst(rst));
	 //instruction register
	 register_n #(.N(9)) inst_IR (.data_in(din),.r_in(IR_in),.clk(clk),.Q(IR_out),.rst(rst));
    
    // TODO: instantiate Multiplexer:
    multiplexer inst_multi (.SignExtDin(dout),.R0(Q_R0),.R1(Q_R1),.R2(Q_R2),.R3(Q_R3),.R4(Q_R4),.R5(Q_R5)
	 ,.R6(Q_R6),.R7(Q_R7),.G(Q_G),.sel(sel),.Bus(mux_out));
    
    // TODO: instantiate ALU:
    ALU inst_alu (.input_a(Q_A),.input_b(bus),.alu_op(alu_op),.result(alu_out));
    
    // TODO: instantiate tick counter:
    tick_FSM inst_tick (.rst(rst),.clk(clk),.enable(1'b1),.tick(tick));
    
    // TODO: define control unit:
    always @(*) begin
        if (rst) begin
            // Reset all control signals
            IR_in = 0;
            R0_in = 0;
            R1_in = 0;
            R2_in = 0;
            R3_in = 0;
            R4_in = 0;
            R5_in = 0;
            R6_in = 0;
            R7_in = 0;
            A_in = 0;
            G_in = 0;
            alu_op = 0;
            sel = 0;
				
        end else begin
		  		// TODO: Turn off all control signals:
			  IR_in = 0;
			  R0_in = 0;
			  R1_in = 0;
			  R2_in = 0;
			  R3_in = 0;
			  R4_in = 0;
			  R5_in = 0;
			  R6_in = 0;
			  R7_in = 0;
			  A_in = 0;
			  G_in = 0;
			  //alu_op = 0;
			  sel = 0;

			  // TODO: Turn on specific control signals based on current tick:
			  case (tick)
					4'b0001: //decode
						 begin
							  IR_in = 1;
							  case (din[8:6])
									DISP_OPCODE: alu_op = 6; //default
									ADD_OPCODE: alu_op = 1;
									ADDI_OPCODE: alu_op = 1;
									SUB_OPCODE: alu_op = 2;
									MUL_OPCODE: alu_op = 0;
									SSI_OPCODE: alu_op = 3;
									BEZ_OPCODE:	alu_op = 6; // default
									MOVI_OPCODE: alu_op = 4;
							  endcase
						 end
					
					4'b0010: //load Rx onto bus
						 begin
							  A_in = 1;
							  sel = IR_out[5:3];
						 end
					
					4'b0100: //Ry on bus, store ALU result via G_in
						 begin
							  // Select Ry for ALU second input
							  //Type 2 ()
							  if (IR_out[8:6] == ADD_OPCODE | IR_out[8:6] == SUB_OPCODE | IR_out[8:6] == MUL_OPCODE) begin
									sel = IR_out[2:0];
								//Type 1 (immediate)
							  end else if (IR_out[8:6] == ADDI_OPCODE | IR_out[8:6] == SSI_OPCODE | IR_out[8:6] == MOVI_OPCODE) begin
									sel = 9;
							  end else begin
									sel = 0;
							  end
							  G_in = 1;
						 end
					
					4'b1000: //Read back
						 begin
							  sel = 8;//G
							  case (IR_out[5:3])
								  3'b000: R0_in = 1'b1;
								  3'b001: R1_in = 1'b1;
								  3'b010: R2_in = 1'b1;
								  3'b011: R3_in = 1'b1;
								  3'b100: R4_in = 1'b1;
								  3'b101: R5_in = 1'b1;
								  3'b110: R6_in = 1'b1;
								  3'b111: R7_in = 1'b1;
							  endcase
						 end
					default: ;
			  endcase
		  end
	 end

	 assign bus = mux_out;
	 assign R0 = Q_R0;
	 assign R1 = Q_R1;
	 assign R2 = Q_R2;
	 assign R3 = Q_R3;
	 assign R4 = Q_R4;
	 assign R5 = Q_R5;
	 assign R6 = Q_R6;
	 assign R7 = Q_R7;
endmodule 