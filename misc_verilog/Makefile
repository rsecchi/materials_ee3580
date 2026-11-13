
dpll: dpll.vcd


%.vvp: %.v
	iverilog -o $@ $<

%.vcd: %.vvp
	vvp $<
