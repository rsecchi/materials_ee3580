

	LDI R1 $0
	RJMP out

cycle:
	INC R1
	RJMP cycle

out:
	RJMP cycle

