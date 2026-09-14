module proc_memory_top_level (
    input  wire [9:0] SW,
    input  wire [1:0] KEY,
	 input wire CLOCK_50,
    output wire [9:0] LEDR,
    output wire [7:0] HEX0,
    output wire [7:0] HEX1,
    output wire [7:0] HEX2,
    output wire [7:0] HEX3,
    output wire [7:0] HEX4,
    output wire [6:0] HEX5
);

    // Internal signals
    wire clk_10Hz;
    wire rst;
    wire enable;
    wire [8:0] din;
    wire [15:0] bus_net;       
    wire [15:0] display_net;   
    wire [3:0]  tick_net;
	 wire [15:0] pc_address;
	 wire [8:0] rom_output;
	 
	// Decimal point wires for sign
    wire dp0, dp1, dp2, dp3, dp4;
    wire [6:0] seg0, seg1, seg2, seg3, seg4;
    // Control signal mapping
    assign rst    = ~KEY[0];    // KEY[0] active-low reset
    assign enable = SW[9];      // SW[9] is enable control
    //assign din    = SW[8:0];    // Instruction/data input

	 //clock instantiation
	 clock_divider u_clock (
			.clk_in(CLOCK_50),
			.clk_out(clk_10Hz)
	 );
	 
    // Processor Instantiation
    proc_memory u_proc (
        .clk(clk_10Hz),
        .rst(rst),
        .enable(enable),
        .din(rom_output),
        .R0(), .R1(), .R2(), .R3(), .R4(), .R5(), .R6(), .R7(),
        .bus(bus_net),
        .display(display_net),
        .tick(tick_net),
		  .PC(pc_address)
    );
	 
	 rom u_rom (
			.address(pc_address),
			.clock(clk_10Hz),
			.q(rom_output)
	 );
	 
    // LED Output (bus lower 10 bits)
    assign LEDR = bus_net[9:0];

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

module clock_divider (
    input  wire clk_in,   // 50 MHz input (e.g., CLOCK_50)
    output reg  clk_out   // 10 Hz output
);

    // 50,000,000 Hz / 10 Hz = 5,000,000 total cycles per output period
    // Toggle every half-period: 5,000,000 / 2 = 2,500,000
    parameter COUNT_MAX = 2_500_000;

    reg [26:0] count = 0;

    always @(posedge clk_in) begin
        if (count == COUNT_MAX - 1) begin
            count <= 0;
            clk_out <= ~clk_out;  // Toggle output
        end else begin
            count <= count + 1;
        end
    end

endmodule 