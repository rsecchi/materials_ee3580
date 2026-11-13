
module rom_test;

	reg clock = 0;
	always #5 clock = ~clock;
	
	reg reset = 1;

	reg [7:0] add_addr = 8'hFF;
	reg jmp = 0;

	wire [13:0] addr;
	wire [15:0] data;

	address_gen_unit agu(clock, reset, add_addr, jmp, addr); 

	instr_memory rom(addr, data);
	
	initial 
	begin

		$dumpfile("agu_test.vcd");
		$dumpvars(0, rom_test);

		$readmemh("rom.mem", rom.ROM);

		#33 reset = 0;
		#52 reset = 1;

		#88 jmp = 1;
		#120 jmp = 0;

		#1000 $finish; 
	end

endmodule

