#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#define MEM_SIZE (1<<16)

FILE* file_mem;
FILE* file_asm;
char default_out[] = "mem.img";

uint8_t mem_img[MEM_SIZE];  // 64kB instruction memory

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


char buffer[256];
int bytes;
int	token;

const char* instr_name[] = {
	"NOP", "COM", "ST", "LD", "NEG",  "INC",
	"LSR", "LSL", "MOV", "LDI", "ADD", "ADC", "AND",
	"OR", "BREQ", "RJMP" };


// --- labels and symbols ------
#define MAX_LABS 100
#define MAX_SYMS  100

int labels;
struct {
	uint16_t addr;
	char name[20];
} lab[MAX_LABS];


int syms;
struct {
	uint16_t addr;
	char name[20];

} sym[MAX_SYMS];

// ------------

void out_code(uint8_t bc)
{
	mem_img[bytes] = bc;
	bytes++;

}

uint8_t get_reg()
{
	int res;
	char c;

	if (fscanf(file_asm, " %c%[0-9]", &c, buffer)<=1 || 
		c!='R' || 
		sscanf(buffer, "%d", &res)<=0 || 
		res>15 || res<0 )
	{
		fprintf(stderr, "Unknown register %s at token %d\n", 
			buffer, token);
		exit(1);
	}
		

	return res;

}

uint8_t get_op()
{
	unsigned int res;
	char local_buf[255];
	char c;

	if (sscanf(buffer, " %c%[0-9]", &c, local_buf)<=1 || 
		c!='$' || 
		sscanf(local_buf, "%d", &res)<=0 || 
		res>255 || res<0 )
	{
		fprintf(stderr, "Unknown operand %s at token %d\n", 
			buffer, token);
		exit(1);
	}

	return res;
}

void parse_cmdline(int argc, char* argv[])
{
	char* fn;

	if (argc<2 || argc>3)
	{
		fprintf(stderr, "%s <inputfile> [<outputfile>]\n", argv[0]);
		exit(1);
	}
	
	file_asm = fopen(argv[1], "r");
	if (!file_asm)
	{
		fprintf(stderr, "Error in opening file %s\n", argv[1]);
		exit(1);
	}

	if (argc==3)
		fn = argv[2];
	else
		fn = default_out;

	file_mem = fopen(fn,"w");
	if (!file_mem) {
		fprintf(stderr, "Error in opening file %s\n", fn);
		exit(1);
	}

}

void main(int argc, char* argv[])
{
	uint8_t reg;
	uint8_t opcode;
	int i, k;
	char c;

	parse_cmdline(argc, argv);

	while(fscanf(file_asm, "%s", buffer)>0) {

		// remove comments
		if (buffer[strlen(buffer)-1] == ';') {
			fgets(buffer, sizeof(buffer), file_asm);
			continue;
		}		

		// check for labels
		if (buffer[strlen(buffer)-1] == ':') {

			if (labels==MAX_LABS) {
				fprintf(stderr, "Too many labels\n");
				exit(1);
			}

			buffer[strlen(buffer)-1] = '\0';
			strcpy(lab[labels].name, buffer);
			lab[labels].addr = bytes;
			labels++;

			continue;
		}
	
		token++;

		for(opcode=0; opcode<16; opcode++)
			if (strcmp(buffer, instr_name[opcode])==0)
				break;

		if (opcode==16) {
			fprintf(stderr, "Unknown instruction %s at token %d\n", 
				buffer, token);
			exit(1);
		}
		
		switch(opcode) {
			case NOP:
				out_code(0);
				out_code(0);
				break;

			case COM:
			case ST:
			case LD:
			case NEG:
			case INC:
			case LSR:
			case LSL:

				token++;
				reg = get_reg();
				out_code((opcode<<4) | reg);
				out_code(0);
				break;


			case LDI:
				token++;
				reg = get_reg();
				out_code((opcode<<4) | reg);

				token++;
				fscanf(file_asm, " %c %s", &c, buffer);
				if (c!=',') {
					fprintf(stderr, "missing ',' at token %d\n", token);
					exit(1);
				}
				out_code(get_op());
				break;

			case ADD:
			case ADC:
			case AND:
			case OR:
			case MOV:
				token++;
				reg = get_reg();
				out_code((opcode<<4) | reg);

				token++;
				fscanf(file_asm, " %c", &c);
				if (c!=',') {
					fprintf(stderr, "missing ',' at token %d\n", token);
					exit(1);
				}
				out_code(get_reg());
				break;


			case BREQ:
			case RJMP:
				out_code(opcode<<4);

				token++;
				fscanf(file_asm, "%s", buffer);
		
				// copy symbol for now
				strcpy(sym[syms].name, buffer);
				sym[syms].addr = bytes;
				syms++;

				out_code(0);  
				
				break;

		}
	}			


	// resolve symbols
	for(k=0; k<syms; k++)
	{
		for(i=0; i<labels; i++)
			if (!strcmp(sym[k].name, lab[i].name))
				break;

		if (i<labels) 
			
			mem_img[sym[k].addr] = lab[i].addr - sym[k].addr - 1;
			
		else {
			strcpy(buffer, sym[k].name);		
			mem_img[sym[k].addr] = get_op();
		}

	}

	// copy image to file
	for(k=0; k<bytes;){
		fprintf(file_mem,"%02X", mem_img[k]);
		k++;
		fprintf(file_mem,"%02X", mem_img[k]);
		k++;
		fprintf(file_mem, "\n");
	}
	fprintf(file_mem, "\n");

	exit(0);
}



