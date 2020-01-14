
cpu: CPU_edu.c
	gcc CPU_edu.c -o cpu

comp: compiler.c
	gcc compiler.c  -o comp

comp16: compiler_16b.c
	gcc compiler_16b.c  -o comp16

%.out: %.asm cpu comp 
	./comp $< 
	./cpu 

simu:
	./comp16 ex.asm rom.mem
	iverilog CPU_edu.v -o out.vvp
	vvp out.vvp


