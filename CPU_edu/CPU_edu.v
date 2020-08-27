/*
	Educational CPU simulating Atmel CPU
	University of Aberdeen - 2020
	Raffaello Secchi - r.secchi@abdn.ac.uk
*/

/* Register file */
module reg_file(clk, 
	regname1, regname2, in, rw, 
	out1, out2);

	input wire clk;
	input wire rw;
	input wire [3:0] regname1; // first operand
	input wire [3:0] regname2; // second operand
	input wire [7:0] in;

	output wire [7:0] out1;
	output wire [7:0] out2;

	reg [7:0] r[15:0];		// register file

	assign out1 = r[regname1];
	assign out2 = r[regname2];

	always @(posedge clk)
	begin
		if (rw == 1'b0)
			r[regname1] <= in;	
	end 
	
endmodule


/* CPU decoding block */
module decode_unit(clk, reset,
	instruction, zero_flag,
	reg1, reg2, write, immediate, imm_data, opcode, rel_addr, jump);

	input wire clk;
	input wire reset;              // reset is active low
	input wire [15:0] instruction; // instruction from ROM
	
	/* outputs to RF (Register File) */
	output wire [3:0] reg1;        // operand register index 1
	output wire [3:0] reg2;        // operand register index 2
	output wire write;             // write command to the register file

	/* outputs to ALU (Arithmetic and Logic Unit) */
	output wire immediate;         // indicates an immediate operand
	output wire [7:0] imm_data;    // immediate data
	output wire [3:0] opcode;      // ALU operation
	input wire zero_flag;          // Z flag in SREG from ALU

	/* outputs to AGU (Address Generation Unit) */
	output wire jump;              // indicates a jump (active low)
	output wire [7:0] rel_addr;    // jump relative address

	reg [15:0] instr_reg;


	/* load the instruction at positive clock edge */
	always @(posedge clk)
	begin
		if ( reset == 1'b0 || jump == 1'b0)
			/* flush the register after a jump or reset */
			instr_reg <= 16'b0;
		else
			/* otherwise gets instruction from I.M. */
			instr_reg <= instruction;

	end

	/* Generating signals */

	/* signals to Register File */
	assign reg1 = instr_reg[11:8];
	assign reg2 = instr_reg[3:0];
	assign write = !(instr_reg[15] | instr_reg[14]);
	
	/* signals to Arithmetic and Logic Unit */
	assign immediate = !instr_reg[15];	
	assign imm_data = instr_reg[7:0];
	assign opcode = instr_reg[15:12];

	/* signals to Address Generation Unit */
	assign rel_addr = instr_reg[7:0];
	assign jump = ~((opcode == 4'b0011) || 
	                (opcode == 4'b0010 && zero_flag == 1'b1));

endmodule


module address_gen_unit(clk, reset,
	rel_addr, jump,
	address);

	input wire clk;
	input wire reset;         // active low

	/* inputs from Decode Unit (DU) */
	input wire [7:0] rel_addr;
	input wire jump;

	/* outputs to instruction memory */
	output wire [13:0] address;

	reg [13:0] instr_pointer; // instruction pointer
	
	assign address = instr_pointer;


	always @(posedge clk)
	begin 
		if (reset == 1'b0)
			instr_pointer <= 14'h00; 
		else 
		if (jump == 1'b0)
			instr_pointer <= instr_pointer + 
					{ {6{rel_addr[7]}} , rel_addr};
		else
			instr_pointer <= instr_pointer + 1;
	end

endmodule


module arith_logic_unit(clk,
	op1, op2, opcode,
	result, zero_flag);

	input wire clk;
	input wire [7:0] op1;     // first operand
	input wire [7:0] op2;     // second operand (if present)
	input wire [3:0] opcode;  // ALU operation

	output wire [7:0] result; // ALU results (8 bits)
	output wire zero_flag;    // Z bit from Status Register


	wire carry_flag;          // C bit from Status Register
	wire [8:0] sum;

	reg [1:0] sreg;           // Status Register (Z and C bit only)
	
	assign sum = 
		(opcode == 4'b0101 || opcode == 4'b1100) 
							? {1'b0, op1} + {1'b0, op2}  :  // ADI, ADD
		(opcode == 4'b1101) ? {1'b0, op1} + {1'b0, op2} 
						+ { 8'b0, sreg[0]} :  // ADC
		0;

	assign carry_flag = 
		(opcode == 4'b0101) ? sum[8]  :  // ADI
		(opcode == 4'b0111) ? op1[0]  :  // LSR
		(opcode == 4'b1000) ? op1[7]  :  // LSL
		(opcode == 4'b1100) ? sum[8]  :  // ADD
		(opcode == 4'b1101) ? sum[8]  :  // ADC
		sreg[0]; // default

	assign zero_flag = 
		(opcode == 4'b0101) || // ADI
		(opcode == 4'b0111) || // LSR
		(opcode == 4'b1000) || // LSL
		(opcode == 4'b1001) || // COM
		(opcode == 4'b1010) || // NEG
		(opcode == 4'b1100) || // ADD
		(opcode == 4'b1101) || // ADC
		(opcode == 4'b1110) || // AND
		(opcode == 4'b1111)    // PR
			? (result == 0) :  
				sreg[1]; // default


	assign result = 
		(opcode == 4'b0101) ? sum[7:0]   :  // ADI
		(opcode == 4'b0110) ? op2        :  // LDI
		(opcode == 4'b0111) ? op1 >> 1   :  // LSR
		(opcode == 4'b1000) ? op1 << 1   :  // LSL
		(opcode == 4'b1001) ? ~op1       :  // COM
		(opcode == 4'b1010) ? -op1       :  // NEG
		(opcode == 4'b1011) ? op2        :  // MOV
		(opcode == 4'b1100) ? sum[7:0]   :  // ADD
		(opcode == 4'b1101) ? sum[7:0]   :  // ADC
		(opcode == 4'b1110) ? op1 & op2  :  // AND
		(opcode == 4'b1111) ? op1 | op2  :  // OR
		0; // default

	always @(posedge clk)
	begin
		sreg[0] <= carry_flag;
		sreg[1] <= zero_flag;	
	end

endmodule


/* Flash memory */
module instr_memory(address, data);

	input wire [13:0] address;
	output wire [15:0] data;

	reg [15:0] ROM[14'h3FFF:0];   // micro instruction memory

	assign data = ROM[address];

endmodule



module central_proc_unit(clk, reset);

	input wire clk;
	input wire reset;

	/* internal signals */
	wire [3:0] reg1;
	wire [3:0] reg2;
	wire rw;
	wire imm;
	wire [7:0] imm_data;
	wire [3:0] opcode;
	wire zflag;

	wire [7:0] rf_in;
	wire [7:0] rf_out2;
	wire [7:0] rf_out1;
	wire [7:0] alu_in2;
	wire [7:0] alu_out;

	wire [15:0] instr;
	wire [13:0] addr;
	
	wire [7:0] rel_addr;
	wire jump;

	/* instantiate blocks */	
	assign alu_in2 = (imm == 1) ? imm_data : rf_out2;

	arith_logic_unit ALU(clk,
		rf_out1, alu_in2, opcode,
		rf_in, zflag);

	reg_file RF(clk, 
		reg1, reg2, rf_in, rw, 
		rf_out1, rf_out2);

	decode_unit DU(clk, reset,
		instr, zflag,
		reg1, reg2, rw, imm, imm_data, opcode, rel_addr, jump);

	address_gen_unit AGU(clk, reset,
		rel_addr, jump, 
		addr);

	instr_memory MEM(addr, instr);

endmodule





