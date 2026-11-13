
module rom_test;

	reg clock = 0;
	always #5 clock = ~clock;
	
	reg reset = 0;

	wire [13:0] addr;
	wire [15:0] data;

	wire [3:0] reg1;
	wire [3:0] reg2;
	wire rw;
	wire [7:0] imm_data;
	wire imm;
	wire [3:0] opcode;
	wire zflag;

	wire [7:0] rel_addr;
	wire jump;

	address_gen_unit agu(clock, reset, rel_addr, jump, addr); 
	instr_memory rom(addr, data);
	decode_unit du(clock,
		data, zflag,
		reg1, reg2, rw, imm, imm_data, opcode, rel_addr, jump);
	
	initial 
	begin

		$dumpfile("du_test.vcd");
		$dumpvars(0, rom_test);

		$readmemh("rom.mem", rom.ROM);

		#33 reset = 1;


		#1000 $finish; 
	end

endmodule

