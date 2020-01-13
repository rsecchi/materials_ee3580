/* CPU educational example - Harvard arch */
/* Raffaello Secchi */
/* University of Aberdeen - 2019 */


/*
	rw = 0   read
	rw = 1   write
*/

module register_file(clk, regname1, regname2, in, rw, out1, out2);
	input wire clk;
	
	input wire [7:0] in;
	input wire rw;
	input wire [3:0] regname1;      // first operand (destination)
	input wire [3:0] regname2;      // second operand (source)
	output reg [7:0] out1;
	output reg [7:0] out2;
	
	reg [15:0] r[15:0];
	
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
	output reg [7:0] outrom;

	reg [7:0] ROM[16'hFFFF:0];    // micro instructions memory (64KB)
	
	always @(posedge clk)
	begin
		outrom <= ROM[addr];
	end

endmodule

module control_unit(clk, op1, op2, rw, operation, value, ip, opcode);

	input wire clk;
	output reg [3:0] op1;
	output wire [3:0] op2;
	output reg rw;
	output wire [7:0] value;
	output reg [15:0] ip; // instruction pointer
	input wire [7:0] opcode;
	output wire [3:0] operation;  // ALU operation;
	
	reg [7:0] state; //internal FSM state
	
	reg [7:0] instr; // temporary instruction register
	assign operation = instr[7:4];
	
	reg imm_reg;
	
	assign code = opcode[7:4];	
	assign op2 = opcode[3:0];
	
		
	always @(posedge clk)
	begin
				
		case(state)
		
			8'h00: begin // START (Reset state)
					ip <= ip + 1;
					rw <= 1'b0;
					state = 8'h01;
				   end
			
			8'h01: begin // first FETCH state
					instr <= opcode;
					rw <= 1'b0;
					ip <= ip + 1;
					if (opcode & 8'h80)
						state <= 8'h02; // two-bytes opcodes
					else 
						// decode one-byte opcodes
						case(code)
							4'b0000: begin 	// NOP
									$display("NOP");
									state <= 8'h01;
									end
									
							4'b0001: begin // COM
									$display("COM");
									state <= 8'h03;
									op1 <= opcode[3:0];
									end
									
							default:
									state <= 8'h00;	
						endcase
					
				   end
				   
			8'h02: begin // second FETCH state
					state <= 8'h01;
				   end
			
			
			8'h03: begin // COM
					state <= 8'h01;
					
				   end
			
			
			default:
				state <= 8'h00;
				
		endcase
		
		
	end


endmodule

module alu(out1, out2);
	
	input wire [7:0] out1;
	output wire [7:0] out2;
	
	assign out2 = out1;
	
endmodule



module test;

	reg ck = 0;
	always #5 ck = ~ck;
	
	wire rw;
	wire [3:0] regname1;      // first operand (destination)
	wire [3:0] regname2;      // second operand (source)
	wire [7:0] myinput;
	
	wire [7:0] myout1;
	wire [7:0] myout2;

	wire [3:0] operation;
	wire [15:0] instr_addr;
	wire [7:0] opcode;
	wire [7:0] val;

	register_file RF(ck, regname1, regname2, myinput, rw, myout1, myout2);
	
	
	instr_memory INSTR_MEM(ck, instr_addr, opcode);
	
//module    control_unit(clk, op1,     op2,      rw, operation, value, ip, opcode);
	control_unit CPU_FSM(ck, regname1, regname2, rw, operation, val, instr_addr, opcode);
		
	initial begin 
		$dumpfile("delay.vcd");
		$dumpvars(0,test);
		$readmemh("rom.mem", INSTR_MEM.ROM);
		
		#0 CPU_FSM.ip <= 16'h0000;
		#0 CPU_FSM.state <= 16'h0000;
		#0 RF.r[0] <= 8'h00;
						
		
		#1000 $finish;
	
	end
	
	
	
endmodule