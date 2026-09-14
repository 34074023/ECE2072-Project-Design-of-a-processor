/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual the CPU.

Please enter your student ID: 34074023

*/
module proc_extension (
    input clk,
    input rst,
    input enable,           //Added for Task 3      
    input [8:0] din,
    output [15:0] R0, R1, R2, R3, R4, R5, R6, R7,
    output [15:0] bus,
    output [15:0] display,  //Added for Task 3
    output [3:0] tick
);

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

    // NEW display register signals
    wire [15:0] Q_DISPLAY;
    reg display_in;

    // parameters (opcodes)
    parameter DISP_OPCODE = 3'b000;
    parameter ADD_OPCODE  = 3'b001;
    parameter ADDI_OPCODE = 3'b010;
    parameter SUB_OPCODE  = 3'b011;
    parameter MUL_OPCODE  = 3'b100;
    parameter SSI_OPCODE  = 3'b101;
    parameter BEZ_OPCODE  = 3'b110;
    parameter MOVI_OPCODE = 3'b111;

    // sign extend for immediate
    sign_extend inst_ext (.din(din),.dout(dout));

    // instantiate registers:
    register_n inst_R0 (.data_in(bus),.r_in(R0_in),.clk(clk),.Q(Q_R0),.rst(rst));
    register_n inst_R1 (.data_in(bus),.r_in(R1_in),.clk(clk),.Q(Q_R1),.rst(rst));
    register_n inst_R2 (.data_in(bus),.r_in(R2_in),.clk(clk),.Q(Q_R2),.rst(rst));
    register_n inst_R3 (.data_in(bus),.r_in(R3_in),.clk(clk),.Q(Q_R3),.rst(rst));
    register_n inst_R4 (.data_in(bus),.r_in(R4_in),.clk(clk),.Q(Q_R4),.rst(rst));
    register_n inst_R5 (.data_in(bus),.r_in(R5_in),.clk(clk),.Q(Q_R5),.rst(rst));
    register_n inst_R6 (.data_in(bus),.r_in(R6_in),.clk(clk),.Q(Q_R6),.rst(rst));
    register_n inst_R7 (.data_in(bus),.r_in(R7_in),.clk(clk),.Q(Q_R7),.rst(rst));
    register_n inst_A  (.data_in(bus),.r_in(A_in), .clk(clk),.Q(Q_A),.rst(rst));
    register_n inst_G  (.data_in(alu_out),.r_in(G_in), .clk(clk),.Q(Q_G),.rst(rst));
    // instruction register
    register_n #(.N(9)) inst_IR (.data_in(din),.r_in(IR_in),.clk(clk),.Q(IR_out),.rst(rst));

    // display register (NEW for Task 3)
    register_n inst_DISPLAY (.data_in(bus), .r_in(display_in), .clk(clk), .Q(Q_DISPLAY), .rst(rst));

    // instantiate Multiplexer:
    multiplexer inst_multi (
        .SignExtDin(dout),
        .R0(Q_R0), .R1(Q_R1), .R2(Q_R2), .R3(Q_R3),
        .R4(Q_R4), .R5(Q_R5), .R6(Q_R6), .R7(Q_R7),
        .G(Q_G),
        .sel(sel),
        .Bus(mux_out)
    );

    // instantiate ALU:
    ALU inst_alu (.input_a(Q_A),.input_b(bus),.alu_op(alu_op),.result(alu_out));

    // instantiate tick counter:
    tick_FSM inst_tick (.rst(rst),.clk(clk),.enable(enable),.tick(tick));

    // control unit:
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
            display_in = 0;   // NEW
            alu_op = 0;
            sel = 0;

        end else begin
            // Turn off all control signals at start
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
            display_in = 0;  // NEW
            // alu_op = 0;   // keep last set in decode if desired
            sel = 0;

            // Turn on specific control signals based on current tick:
            case (tick)
                4'b0001: // decode
                    begin
                        IR_in = 1;
                        case (din[8:6])
                            DISP_OPCODE: alu_op = 6; // not using ALU for disp
                            ADD_OPCODE:  alu_op = 1;
                            ADDI_OPCODE: alu_op = 1;
                            SUB_OPCODE:  alu_op = 2;
                            MUL_OPCODE:  alu_op = 0;
                            SSI_OPCODE:  alu_op = 3;
                            BEZ_OPCODE:  alu_op = 6; // default
                            MOVI_OPCODE: alu_op = 4;
                            default:     alu_op = 6;
                        endcase
                    end

                4'b0010: // load Rx onto bus (or for disp, put Rx on bus and latch to display)
                    begin
                        // For most instructions, we load Rx into A (A_in) and choose selector appropriately
                        // However, for disp we want Rx on the bus then latch into display register.
                        if (IR_out[8:6] == DISP_OPCODE) begin
                            // Put Rx value onto bus and latch directly into display register
                            sel = IR_out[5:3];   // select Rx onto bus (multiplexer uses Rx selection)
                            display_in = 1;      // latch bus into display register this cycle
                        end else begin
                            A_in = 1;
                            sel = IR_out[5:3];   // load Rx into A (for ALU ops)
                        end
                    end

                4'b0100: // Ry on bus, store ALU result via G_in
                    begin
                        // Select Ry for ALU second input
                        // Type 2 (register-register)
                        if (IR_out[8:6] == ADD_OPCODE || IR_out[8:6] == SUB_OPCODE || IR_out[8:6] == MUL_OPCODE) begin
                            sel = IR_out[2:0];
                        // Type 1 (immediate)
                        end else if (IR_out[8:6] == ADDI_OPCODE || IR_out[8:6] == SSI_OPCODE || IR_out[8:6] == MOVI_OPCODE) begin
                            sel = 9; // sign-extended immediate on multiplexer input index 9
                        end else begin
                            sel = 0;
                        end
                        G_in = 1;
                    end

                4'b1000: // Read back / write results to destination register
                    begin
                        // For disp instruction we should NOT do a register file writeback.
                        if (IR_out[8:6] != DISP_OPCODE) begin
                            sel = 8; // G
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
    assign display = Q_DISPLAY;  // NEW output assignment
endmodule
