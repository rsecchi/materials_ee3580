

module dpll(clk, rst, in);
input wire clk;
input wire rst;
input wire in;
	
reg [15:0] phase;


	always @(posedge clk) 
	begin

		if (rst == 1'b1)
			phase <= 16'h00;
		else
			phase <= phase + 1;
		end 
		
	end

endmodule


module test;
	
	reg clock;
	always #5000 clock = ~clock;   // 100 kHZ clock

	reg in = 0;
	reg rst;
	dpll xorpll(.clk=clock, .rst=rst, 

	initial
	begin
		$dumpfile("dpll.vcc");
		$dumpvars(0, test);

		#1 rst <= 1'b0;
		#10000 rst <= 1'b1;

		#100000 $finish;
		
	end

endmodule


