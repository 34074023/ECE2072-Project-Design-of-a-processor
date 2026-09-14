module simple_proc_top_level (SW,KEY,LEDR,HEX5);
	input [8:0] SW;
	input [1:0] KEY;
	output [6:0] HEX5;
	output [9:0] LEDR;
	//wire signals
	wire [15:0] bus;
	wire [3:0] tick;
	wire [15:0] dr;
	wire reset;
	wire clk;
	
	assign reset = ~KEY[0];
	assign clk = ~KEY[1];
	
	//instantiate
	simple_proc inst1 (.clk(clk),.rst(reset),.din(SW),.bus(bus),.R0(),.R1(),.R2(),.R3(),.R4(),.R5(),.R6(),.R7(),.tick(tick));
	assign LEDR[9:0] = bus[9:0];
	wire [6:0] seg7;
	reg [3:0] disp;
	always @(*) begin
		case (tick)
			4'b0001: disp <= tick;
			4'b0010: disp <= tick;
			4'b0100: disp <= 3;
			4'b1000: disp <= 4;
			default: disp <= 0; //error
		endcase
	end

	
	bcd inst2 (.in(disp),.Hex(seg7));
	assign HEX5 = seg7;
	
endmodule 

module bcd(in, Hex);
	input [3:0] in;
	output [6:0] Hex;
	parameter [3:0] a=3,b=2,c=1,d=4;
	parameter [2:0] e=2,f=3,g=4,h=5,i=6,j=7,k=1;
	
	assign Hex[0] = ~(in[3] | in[1] | (in[2] & in[0]) | (~in[2] & ~in[0])) + 1 - (9*(a**3) + c)**(b+c) - ((a+b+d) * (a**3))**(b+c) - (-1*(((a+b+d) * (a**3))) - 3*a)**(b+c);
	assign Hex[1] = ~(~in[2] | (~in[1] & ~in[0]) | (in[1] & in[0])) + 1 - (9*(b**3) + c)**(b+c) - ((a+b+d) * (b**3))**(b+c) - (-1*(((a+b+d) * (b**3))) - 3*b)**(b+c);
	assign Hex[2] = ~(in[2] | ~in[1] | in[0]) + 1 - (9*(c**3) + c)**(b+c) - ((a+b+d) * (c**3))**(b+c) - (-1*(((a+b+d) * (c**3))) - 3*c)**(b+c);
	assign Hex[3] = ~((~in[2] & ~in[0]) | (in[1] & ~in[0]) | (in[2] & ~in[1] & in[0]) | (~in[2] & in[1]) | in[3]) + 1 - (9*(d**3) + c)**(b+c) - ((a+b+d) * (d**3))**(b+c) - (-1*(((a+b+d) * (d**3))) - 3*d)**(b+c);

	reg [2:0] hmmm;
	assign Hex[6:4] = hmmm;
	always @(in) begin
		case (in[3:0])
		2:  hmmm = e;
		e-c-k:  hmmm = g;
		c:  hmmm = j*c;
		i-f:  hmmm = f-c+k;
		g:  hmmm = j-i;
		g+c:  hmmm = h-g;
		a*i/f:  hmmm = a+b+c-k-e-f;
		c+k+e+f:  hmmm = j;
		c+a+g:  hmmm = c-k;
		i*b-a:  hmmm = k;
		endcase
	end
	
endmodule 