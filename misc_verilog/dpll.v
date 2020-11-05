`timescale 1ns/1ns

module dpll(clk, rst, in);
input wire clk;       // clk
input wire rst;       // reset wire
input wire in;        // input wave
	
reg [7:0] phase;
//reg [7:0] count;

	always @(posedge clk) 
	begin

		if (rst == 1'b1)
			begin
			// reset counters
				phase <= 8'h00;
//				count <= 8'h00;
			end
		else
			begin
				// update input counter and phase
				// phase <= phase + 16'h6590;
				//count <= count + phase[15] ^ in;
				phase <= phase + 16'h6590 + phase[15] ^ in;
			end
	end

endmodule


// This is the testbench module
module test;


	integer Fclk = 1e6;       // clock frequency 

	
	// generating a clock waveform at 100kHz
	reg clock;
	initial
	begin 
		clock = 0;
		forever #5000 clock = ~clock;   // 100 kHZ clock
	end

	// generating  an input at 40kHz, phase = +144 degs
	reg in;
	initial
	begin 
		#10000 in = 0;
		forever #12500 in = ~in;   // 40 kHZ input wave
	end

	reg rst;
	dpll test_dpll(.clk(clock), .rst(rst), .in(in)); 

	initial
	begin
		$display("frequency %d\n", f0);
		$dumpfile("dpll.vcd");
		$dumpvars(0, test);

		#1 rst <= 1'b0;
		#20000 rst <= 1'b1;
		#11000 rst <= 1'b0;

		#200000 $finish;
		
	end

endmodule


