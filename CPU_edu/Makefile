
cpu: CPU_edu.c
	gcc CPU_edu.c -o cpu

comp: compiler.c
	gcc compiler.c  -o comp

%.out: %.asm cpu comp 
	./comp $< 
	./cpu 


simu:
	iverilog CPU_edu.v -o out.vvp
	vvp out.vvp


