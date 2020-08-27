CPU_v= CPU_edu.v


cpu: CPU_edu.c
	gcc $(CPU_v)  cpu

comp16: compiler_16b.c
	gcc compiler_16b.c  -o comp16

%.out: %.asm cpu comp 
	./comp $< 
	./cpu 

simu:
	./comp16 ex.asm rom.mem
	iverilog $(CPU_v) -o out.vvp
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

testcpu: comp16
	./comp16 ex_count.asm rom.mem
	iverilog -o out.vvp $(CPU_v) test_cpu.v
	vvp out.vvp


%.vcd: %.asm
	./comp16 $< rom.mem
	iverilog -o out.vvp $(CPU_v) test_cpu.v
	vvp out.vvp
	mv cpu_test.vcd $@
	


