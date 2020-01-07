; This is just an example!

	LDI R1 $0
	RJMP out    ;
	LDI R0 $55  ; This line is not executed

cycle:
	INC R1
	RJMP cycle

out:
	RJMP cycle

