
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

testagu:
	iverilog -o out.vvp CPU.v test_agu.v
	vvp out.vvp

testrom:
	iverilog -o out.vvp CPU.v test_rom.v
	vvp out.vvp

testdu:
	iverilog -o out.vvp CPU.v test_du.v
	vvp out.vvp

testalu:
	iverilog -o out.vvp CPU.v test_alu.v
	vvp out.vvp

testcpu:
	iverilog -o out.vvp CPU.v test_cpu.v
	vvp out.vvp



