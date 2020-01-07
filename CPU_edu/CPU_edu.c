#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define INSTR_MEM_IMAGE   "mem.img"

// Machine states
#define FETCH0    0x00
#define FETCH1    0x01
#define FETCH2    0x02

#define EXEC      0x03

// instructions opcodes
#define NOP       0x00 
#define COM       0x01
#define ST        0x02
#define LD        0x03
#define NEG       0x04
#define INC       0x05
#define LSR       0x06
#define LSL       0x07
#define MOV       0x08
#define LDI       0x09
#define ADD       0x0A
#define ADC       0x0B
#define AND       0x0C
#define OR        0x0D
#define BREQ      0x0E
#define RJMP      0x0F


const char* instr_name[] = {
	"NOP", "COM", "ST", "LD", "NEG",  "INC",
	"LSR", "LSL", "MOV", "LDI", "ADD", "ADC", "AND",
	"OR", "BREQ", "RJMP" };

// CPU registers

uint8_t status;
uint8_t reg_file[16];   // Register file 16 registers 
uint8_t Rd, Rr;         // Register names
uint8_t opcode;

uint16_t ip;       // instruction pointer
uint8_t sreg;      // status register


uint8_t instr_temp[2];  // temporary instruction


// instruction memory (64kB)
uint8_t instr_mem[1<<16];

// data memory memory
uint8_t data_mem[1<<16];


void print_cpu()
{
int i;

	printf("IP: %04x    ", ip);
	printf("SREG: Z=%d C=%d\n", (sreg&0x02)==0x02, (sreg&0x01)==0x01);

	for(i=0; i<16; i++)
		printf("R%x=%x ", i, reg_file[i]);

	printf("\n-------\n");
}


void decode()
{
uint16_t res;

	printf("opcode: %s\n", instr_name[opcode]);

	switch(opcode) {

		// one-byte
		case NOP: 
			status = FETCH0;
			break;

		case COM:
			reg_file[Rd] = ~reg_file[Rd];
			if (reg_file[Rd]==0) sreg |= 0x02; else  sreg &= ~0x02;
			status = FETCH0;
			break;

		case ST: 
			data_mem[(uint16_t)(*(&reg_file[14]))] = reg_file[Rd];
			status = FETCH0;
			break;

		case LD:
			reg_file[Rd] = data_mem[(uint16_t)(*(&reg_file[14]))];
			status = FETCH0;
			break;

		case NEG: 
			reg_file[Rd] = -((char)reg_file[Rd]);
			if (reg_file[Rd]==0) sreg |= 0x02; else  sreg &= ~0x02;
			status = FETCH0;
			break;

		case INC: 
			reg_file[Rd]++;
			if (reg_file[Rd]==0) sreg |= 0x02; else  sreg &= ~0x02;
			status = FETCH0;
			break;

		case LSR:
			reg_file[Rd] >>= 1;
			status = FETCH0;
			break;

		case LSL: 
			reg_file[Rd] <<= 1;
			status = FETCH0;
			break;

		// two bytes
		case MOV: 
			reg_file[Rd] = reg_file[Rr&0x0F];
			status = FETCH0;
			break;

		case LDI: 
			reg_file[Rd] = Rr;
			status = FETCH0;
			break;

		case ADD: 
			res = reg_file[Rd] + reg_file[Rr&0x0F];
			reg_file[Rd] = res & 0xFF;
			if (res&0xFF ==0) sreg |= 0x02; else  sreg &= ~0x02;
			if (res>255) sreg |= 0x01; else sreg &= ~0x01;

			status = FETCH0;
			break;

		case ADC: 
			reg_file[Rd] += reg_file[Rr&0x0F];
			status = FETCH0;
			break;

		case AND: 
			reg_file[Rd] &= reg_file[Rr&0x0F];
			status = FETCH0;
			break;

		case OR: 
			reg_file[Rd] |= reg_file[Rr&0x0F];
			status = FETCH0;
			break;

		case BREQ: 
			if (sreg & 0x02) 
				ip = (int16_t)ip + (int8_t)Rr;
			status = FETCH0;
			break;

		case RJMP: 
			ip = (int16_t)ip + (int8_t)Rr;
			status = FETCH0;
			break;
	}
}


void run_cpu()
{

	switch(status)
	{

		case FETCH0:

			instr_temp[0] = instr_mem[ip];  // impl. using memory
			Rd = instr_temp[0] & 0x0F; // impl. using assign
			opcode  = instr_temp[0] >> 4;   // impl. using assign
			
			ip = ip + 1;

			if (instr_temp[0] & 0x80) 
				status = FETCH1;
			else
				status = EXEC;
			break;


		case FETCH1:
			instr_temp[1] = instr_mem[ip];
			Rr = instr_temp[1];    // instr_temp[1] is the operand
			ip = ip + 1;

			status = EXEC;
			break;


		case EXEC:
			decode();
			print_cpu();
			break;

	}


}



void load_mem()
{
	FILE* file_mem;
	unsigned int c;
	uint16_t i=0;

	file_mem = fopen(INSTR_MEM_IMAGE,"r");
	if (!file_mem)
	{
		fprintf(stderr, "Error in opending file\n");
		exit(1);
	}


	while(fscanf(file_mem, "%x", &c)>0){
		instr_mem[i] = c;
		i++;
	}

}


void init_cpu()
{
	ip = 0;
	status = FETCH0;

}


int main()
{
	char c;
	load_mem();

	init_cpu();
	for(;;) {
		scanf("%c", &c);
		run_cpu();
	}
}

