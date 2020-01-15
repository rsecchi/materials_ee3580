/* CPU educational example - Harvard arch */
/* Raffaello Secchi */
/* University of Aberdeen - 2019 */


module register_file(clk, regname1, regname2, in, rw, out1, out2);
	input wire clk;
	
	input wire [7:0] in;
	input wire rw;
	input wire [3:0] regname1;      // first operand (destination)
	input wire [3:0] regname2;      // second operand (source)
	output reg [7:0] out1;
	output reg [7:0] out2;
	
	reg [7:0] r[15:0];
	
	always @(posedge clk)
	begin

		out1 <= r[regname1];
		out2 <= r[regname2];
				
		if (rw == 1'b1)
			r[regname1] <= in;
	end
	
endmodule 


module instr_memory(clk, addr, outrom);

	input wire clk;
	input wire [15:0] addr;
	output reg [15:0] outrom;

	reg [15:0] ROM[16'hFFFF:0];    // micro instructions memory (64KB)
	
	always @(posedge clk) 
		outrom <= ROM[addr];

endmodule


module control_unit(clk, op1, op2, rw, operation, 
			imm_op, ip, rom_data, imm_res, alu_flags);

	/* input signals */	
	input wire clk;
	input wire [15:0] rom_data;    // instruction from ROM
	wire [3:0] opcode;             // opcode field in instruction

	/* control registers */
	reg [1:0] state;               // internal FSM state	
	output reg [15:0] ip;          // instruction pointer
	input [7:0] alu_flags;         // flags from ALU
	reg [15:0] instr;              // temporary instruction register

	/* state encodings */
	parameter RESET=2'b00;
	parameter FETCH=2'b01;
	parameter WAIT_INSTR=2'b10;
	
	/* output signals */
	output reg rw;                 // read/write register file
	output wire [7:0] imm_op;      // immediate operand
	output reg imm_res;            // immediate or register
	output wire [3:0] operation;   // ALU operation;
	output wire [3:0] op1;         // first operand (reg)
	output wire [3:0] op2;         // second operand (reg)
		
	/* signal generation (decode) */
	assign opcode    = rom_data[15:12];	
	assign op1       = (state==WAIT_INSTR) ? instr[11:8] : rom_data[11:8];
	assign op2       = rom_data[3:0];
	assign imm_op    = instr[7:0];
	assign operation = instr[15:12];

	/* FSM (generate next state, update ip and rw) */	
	always @(posedge clk)
	begin
				
		case(state)
		
			RESET: begin
					ip <= 16'h0000;
					rw <= 1'b0;
					state <= WAIT_INSTR;
					instr <= 8'h00;
				   end
			
			FETCH: begin
					instr <= rom_data;
					state <= WAIT_INSTR;

					// decode opcode
					case(opcode)
						
						4'b0000: begin // NOP
							ip <= ip + 1;
							rw <= 1'b0;
						end

						4'b0001, 4'b0100, 4'b0101, 4'b0110, 4'b0111,
						4'b1000, 4'b1010, 4'b1011, 4'b1100, 4'b1101
						: begin // COM
							imm_res <= 1'b1;
							ip <= ip + 1;
							rw <= 1'b1;
						end
			
						4'b1001: begin // LDI
							imm_res <= 1'b0;
							ip <= ip + 1;
							rw <= 1'b1;
						end

						4'b1110: begin // BREQ
							rw <= 1'b0;
							if (alu_flags & 8'h02)
								ip <= ip + {{8{rom_data[7]}}, rom_data[7:0]};
							else
								ip <= ip + 1;
						end

						4'b1111: begin // RJMP
							ip <= ip + {{8{rom_data[7]}}, rom_data[7:0]};
							rw <= 1'b0;
						end
						
						default:
							ip <= 16'h0000;
					endcase
					
					end	
				   
			
			
			WAIT_INSTR: begin // wait to load next instruction
					state <= FETCH;
					rw <= 1'b0;
					instr <= 8'h00;
				   end
			
			default:
				state <= RESET;
				
		endcase
	end

endmodule

module arith_logic_unit(clk, in1, in2, op, result, sreg);
	
	input wire [7:0] in1;
	input wire [7:0] in2;
	input wire [3:0] op;
	input wire clk;

	output wire [7:0] result;
	wire [8:0] sum;              // Adder Circuit plus carry 
	output reg  [7:0] sreg;

	wire z_flag;        // Z flag in SREG
	wire c_flag;        // C flag in SREG

	assign sum =
		(op == 4'b0101) ? {1'b0,in1} + 1                    :  // INC
		(op == 4'b1010) ? {1'b0,in1} + {1'b0,in2}           :  // ADD
		(op == 4'b1011) ? {1'b0,in1} + {1'b0,in2} + sreg[0] :  // ADC
		0;  // default 

	assign result = 
		(op == 4'b0001) ? ~in1      :     // COM
		(op == 4'b0100) ? -in1      :     // NEG
		(op == 4'b0101) ? in1 + 1   :     // INC
		(op == 4'b0110) ? in >> 1   :     // LSR
		(op == 4'b0111) ? in << 1   :     // LSL
		(op == 4'b1000) ? in2       :     // MOV
		(op == 4'b1010) ? sum[7:0]  :     // ADD
		(op == 4'b1011) ? sum[7:0]  :     // ADC
		(op == 4'b1100) ? in1 & in2 :     // AND
		(op == 4'b1101) ? in1 | in2 :     // OR
		0;  // default 
	
	assign z_flg = 
		(op == 4'b0100) ? (result == 0) :  // NEG
		(op == 4'b0110) ? (result == 0) :  // LSR
		(op == 4'b0111) ? (result == 0) :  // LSL
		(op == 4'b1010) ? (result == 0) :  // ADD
		(op == 4'b1011) ? (result == 0) :  // ADC
		sreg[1];  // default 
	
	assign c_flg = 
		(op == 4'b0100) ? (in==8'h80) :     // NEG
		(op == 4'b0110) ? in[0]       :     // LSR
		(op == 4'b0111) ? in[7]       :     // LSL
		(op == 4'b1010) ? sum[8]      :     // ADD
		(op == 4'b1011) ? sum[8]      :     // ADC
		sreg[1];  // default 
	
	always @(posedge clk)
		if (op!=4'b0000)
			sreg <= {6'b000000, z_flg, c_flg};
	
endmodule



module processing_unit(clk);

	input clk;

	wire rw;
	wire [3:0] reg1;          // first operand (destination)
	wire [3:0] reg2;          // second operand (source)
	
	wire [7:0] op1;           // ALU operand register 1
	wire [7:0] op2;           // ALU operand register 2

	wire [3:0] operation;
	wire [15:0] instr_addr;
	wire [15:0] opcode;
	
	/* regfile update variables */
	wire imm_res;
	wire [7:0] res;
	wire [7:0] immediate;
	wire [7:0] val;
	wire [7:0] sreg;

	/* wiring the CPU */
	assign val = (imm_res==0) ? immediate : res;
	register_file RF(clk, reg1, reg2, val, rw, op1, op2);

	instr_memory INSTR_MEM(clk, instr_addr, opcode);

	control_unit CPU_FSM(clk, reg1, reg2, rw, 
			operation, immediate, instr_addr, opcode, imm_res, sreg);

	arith_logic_unit ALU(clk, op1, op2, operation, res, sreg);

endmodule


module test;

	reg ck = 0;
	always #5 ck = ~ck;


	processing_unit CPU(ck);

	initial begin 

		$dumpfile("delay.vcd");
		$dumpvars(0,test);

		/* load rom image */
		$readmemh("rom.mem", CPU.INSTR_MEM.ROM);

		#0 CPU.CPU_FSM.state <= 8'h00;   // initialise FSM
		#1000 $finish;
	
	end

	
endmodule
