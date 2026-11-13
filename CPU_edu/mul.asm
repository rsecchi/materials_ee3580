

; Calculate the multiplication between R0 and R1 and 
; write the result in [R2:R3]

		LDI R0, 0x11    ; initalises R0 = 17 
		LDI	R1, 0x03    ; initilises R1 = 3
		LDI R2, 0x00    ; [R2:R3] = [0x00, 0x00]
		LDI R3, 0x00	;	
		LDI R4, 0x00    ; constant zero

loop:
		ADD R3, R0      ;  [R2:R3] + [0: R1]
		ADC R2, R4      ;
		ADI R1, 0xFF    ; decrement R1
		BREQ out
		RJMP loop

out:
		RJMP out        ; halt


