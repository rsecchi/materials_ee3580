
module cpu_test;

	reg clock = 0;
	always #5 clock = ~clock;
	
	reg reset = 1;


	central_proc_unit cpu(clock, reset);	

	initial 
	begin

		$dumpfile("cpu_test.vcd");
		$dumpvars(0, cpu_test);

		$readmemh("rom.mem", cpu.MEM.ROM);

		#3 reset = 0;
		#10 reset = 1;


		#1000 $finish; 
	end

endmodule

