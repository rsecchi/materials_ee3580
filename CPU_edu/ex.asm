; Testing Loop

		LDI R1, $4
		LDI R2, $255
loop:
		ADD R1, R2
		BREQ out
		RJMP loop
out:
		NOP
		NOP

