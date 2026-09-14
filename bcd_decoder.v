/*
BCD DECODER MODULES 
- signed_to_bcd: Convert signed 16-bit to 5 BCD digits + sign
- bcd_decoder_digit: Convert 4-bit BCD to 7-segment display pattern
- tick_decoder: Decode tick count to 7-segment (HEX5)
- bcd_decoder: Wrapper with sign indicator on HEX4 decimal point
*/

module signed_to_bcd (
    input  signed [15:0] value,
    output reg [3:0] digit4,
    output reg [3:0] digit3,
    output reg [3:0] digit2,
    output reg [3:0] digit1,
    output reg [3:0] digit0,
    output reg sign
);
    reg [15:0] abs_val;

    always @(*) begin
        // Detect sign and take absolute value
        if (value < 0) begin
            sign = 1;
            abs_val = -value;
        end else begin
            sign = 0;
            abs_val = value;
        end

        // Convert to BCD (5 digits)
        digit0 = abs_val % 10;
        digit1 = (abs_val / 10) % 10;
        digit2 = (abs_val / 100) % 10;
        digit3 = (abs_val / 1000) % 10;
        digit4 = (abs_val / 10000) % 10;
    end
endmodule


// Convert a single BCD digit (0–9) to 7-segment pattern
module bcd_decoder_digit (
    input  [3:0] bcd,
    output reg [6:0] seg
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule


// Tick display decoder (HEX5) — fixed to show 1,2,3,4
module tick_decoder (
    input  [3:0] tick,
    output reg [6:0] seg
);
    reg [3:0] tick_num;  // convert one-hot → 1..4

    always @(*) begin
        // Map one-hot tick to sequential number
        case(tick)
            4'b0001: tick_num = 4'd1;
            4'b0010: tick_num = 4'd2;
            4'b0100: tick_num = 4'd3;
            4'b1000: tick_num = 4'd4;
            default: tick_num = 4'd0;
        endcase

        // Decode as normal BCD digit
        case (tick_num)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule


// Top-level BCD decoder wrapper
module bcd_decoder (
    input  signed [15:0] value,
    input  [3:0] tick,
    output [6:0] seg_tick,
    output [6:0] seg4,
    output [6:0] seg3,
    output [6:0] seg2,
    output [6:0] seg1,
    output [6:0] seg0,
    output       dp4,
    output       dp3,
    output       dp2,
    output       dp1,
    output       dp0
);
    wire [3:0] d4, d3, d2, d1, d0;
    wire sign;

    // Convert number to BCD and detect sign
    signed_to_bcd u_conv (
        .value(value),
        .digit4(d4),
        .digit3(d3),
        .digit2(d2),
        .digit1(d1),
        .digit0(d0),
        .sign(sign)
    );

    // Decode digits
    bcd_decoder_digit u4 (.bcd(d4), .seg(seg4));
    bcd_decoder_digit u3 (.bcd(d3), .seg(seg3));
    bcd_decoder_digit u2 (.bcd(d2), .seg(seg2));
    bcd_decoder_digit u1 (.bcd(d1), .seg(seg1));
    bcd_decoder_digit u0 (.bcd(d0), .seg(seg0));

    // Tick decoder
    tick_decoder u_tick (.tick(tick), .seg(seg_tick));

	 // Decimal point sign indicator (active low on ALL HEX displays if negative)
	 assign dp4 = ~sign ? 1'b1 : 1'b0;
	 assign dp3 = ~sign ? 1'b1 : 1'b0;
	 assign dp2 = ~sign ? 1'b1 : 1'b0;
	 assign dp1 = ~sign ? 1'b1 : 1'b0;
	 assign dp0 = ~sign ? 1'b1 : 1'b0; 

endmodule
