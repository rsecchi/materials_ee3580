
module alu_test;

	reg clock = 0;
	always #5 clock = ~clock;
	
	reg [7:0] op1 = 8'hAF;
	reg [7:0] op2 = 8'h51;
	reg [3:0] opcode = 4'b1110;

	wire [7:0] result;
	wire zero_flag;

	arith_logic_unit alu(clock, op1, op2, opcode, result, zero_flag);
	
	initial 
	begin

		$dumpfile("alu_test.vcd");
		$dumpvars(0, alu_test);
		
		#52 opcode = 4'b1111;

		#1000 $finish; 
	end

endmodule

