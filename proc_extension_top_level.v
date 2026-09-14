module proc_extension_top_level (
    input  wire [9:0] SW,
    input  wire [1:0] KEY,
    output wire [9:0] LEDR,
    output wire [7:0] HEX0,
    output wire [7:0] HEX1,
    output wire [7:0] HEX2,
    output wire [7:0] HEX3,
    output wire [7:0] HEX4,
    output wire [6:0] HEX5
);

    // Internal signals
    wire clk;
    wire rst;
    wire enable;
    wire [8:0] din;
    wire [15:0] bus_net;       
    wire [15:0] display_net;   
    wire [3:0]  tick_net;

    // Decimal point wires for sign
    wire dp0, dp1, dp2, dp3, dp4;
    wire [6:0] seg0, seg1, seg2, seg3, seg4;

    // Control signal mapping
    assign clk    = ~KEY[1];    // manual clock
    assign rst    = ~KEY[0];    // active low reset
    assign enable = SW[9];      // enable control
    assign din    = SW[8:0];    // instruction/data

    // Processor Instantiation
    proc_extension u_proc (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .din(din),
        .R0(), .R1(), .R2(), .R3(), .R4(), .R5(), .R6(), .R7(),
        .bus(bus_net),
        .display(display_net),
        .tick(tick_net)
    );

    // LED Output
    assign LEDR = display_net[9:0];

    // BCD Decoder for display + tick
    bcd_decoder u_bcd (
        .value(display_net),
        .tick(tick_net),
        .seg_tick(HEX5),
        .seg4(seg4),
        .seg3(seg3),
        .seg2(seg2),
        .seg1(seg1),
        .seg0(seg0),
        .dp4(dp4),
        .dp3(dp3),
        .dp2(dp2),
        .dp1(dp1),
        .dp0(dp0)
    );

    // Combine segments and decimal points (active low)
    assign HEX0 = {dp0, seg0};
    assign HEX1 = {dp1, seg1};
    assign HEX2 = {dp2, seg2};
    assign HEX3 = {dp3, seg3};
    assign HEX4 = {dp4, seg4};

endmodule 