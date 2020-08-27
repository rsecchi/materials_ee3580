;
; example of a 16 bit sum:
;
;    the source operand is R1:R2 => 0x1345
;    the destination operand is R3:R4 => 0x3A2B

		; load operand in RF registers		
		LDI R1, 0x13
		LDI R2, 0x45
		LDI R3, 0x3A
		LDI R4, 0x2B

		; Add the 16 bit registers 
		; (note the add with carry)
		ADD R2, R4
		ADC R1, R3

		; loop foerver
halt:	RJMP halt

