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
		$display("r[0]=%2X r[1]=%2X r[2]=%2X r[3]=%2X r[4]=%2X r[5]=%2X r[6]=%2X", 
				r[0], r[1], r[2], r[3], r[4], r[5], r[6]);

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
	
	always @(posedge clk) outrom <= ROM[addr];

endmodule


module control_unit(clk, op1, op2, rw, operation, 
			imm_op, ip, rom_data, imm_res, alu_flags);

	/* input signals */	
	input wire clk;
	input wire [15:0] rom_data;    // instruction from ROM
	wire [3:0] opcode;             // opcode field in instruction

	/* control registers */
	reg [7:0] state;               // internal FSM state	
	output reg [15:0] ip;          // instruction pointer
	input [7:0] alu_flags;         // flags from ALU
	reg [15:0] instr;              // temporary instruction register

	/* state encodings */
	parameter RESET=8'h00;
	parameter FETCH=8'h01;
	parameter EXEC_WRITE=8'h02;
	parameter WAIT_INSTR=8'h03;
	
	/* output signals */
	output reg rw;                 // read/write register file
	output wire [7:0] imm_op;      // immediate operand
	output reg imm_res;            // immediate or register
	output wire [3:0] operation;   // ALU operation;
	output wire [3:0] op1;         // first operand (reg)
	output wire [3:0] op2;         // second operand (reg)
		
	/* signal generation (decode) */
	assign opcode    = rom_data[15:12];	
	assign op1       = (state==EXEC_WRITE) ? instr[11:8] : rom_data[11:8];
	assign op2       = rom_data[3:0];
	assign imm_op    = instr[7:0];
	assign operation = instr[15:12];

	/* FSM (generate next state, update ip and rw) */	
	always @(posedge clk)
	begin
				
		case(state)
		
			RESET: begin
					$display("RESET");
					ip <= 0;
					rw <= 1'b0;
					state <= WAIT_INSTR;
				   end
			
			FETCH: begin
					$display("FETCH: IP=%x rom_data=%x opcode=%x", ip, rom_data, opcode);
					instr <= rom_data;
					rw <= 1'b0;

					// decode opcode
					case(opcode)
						4'b0000: begin 	// NOP
							$display("NOP");
							state <= WAIT_INSTR;
							ip <= ip + 1;
						end
						
						4'b0001, 4'b0100, 4'b0101, 4'b0110, 4'b0111,
						4'b1000, 4'b1010, 4'b1011, 4'b1100, 4'b1101
						: begin // COM
							$display("[%1X]opcode [%02d] [%02d]", 
								opcode, op1, op2);
							imm_res <= 1'b1;
							rw <= 1'b1;
							state <= EXEC_WRITE;
							ip <= ip + 1;
						end
			
						4'b1001: begin // LDI
							$display("LDI R%02d <- %2x",op1, rom_data[7:0]);
							imm_res <= 1'b0;
							rw <= 1'b1;
							state <= EXEC_WRITE;
							ip <= ip + 1;
						end

						4'b1110: begin // BREQ
							$display("BREQ R%02d <- %2x",op1, rom_data[7:0]);
							state <= WAIT_INSTR;
							if (alu_flags & 8'h02)
								ip <= ip + {{8{rom_data[7]}}, rom_data[7:0]};
							else
								ip <= ip + 1;
						end

						4'b1111: begin // RJMP
							$display("RJMP R%02d <- %2x",op1, rom_data[7:0]);
							state <= WAIT_INSTR;
							ip <= ip + {{8{rom_data[7]}}, rom_data[7:0]};
						end
						
						default:
							state <= RESET;	
					endcase
					
					end	
				   
			
			EXEC_WRITE: begin // wait op finish 
					$display("EXEC_WRITE R%02d <- %2x",op1, imm_op);
					state <= FETCH;
					rw <= 1'b0;
					instr <= 8'h00;
				   end
			
			WAIT_INSTR: begin // wait to load next instruction
					$display("WAIT_INSTR");
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
	begin
		if (op!=4'b0000)
			sreg <= {6'b000000, z_flg, c_flg};
		$display("SREG=%2x",sreg);
	end
	
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

	always @(negedge ck)
		$display("\nCLOCK=====================================");


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
