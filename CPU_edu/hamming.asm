; Calculate the Hamming distance between R0 and R1
; Results in R3

		LDI R0, 0x3F
		LDI R1, 0x7E
		LDI R2, 0x00    ; result
		MOV R3, R0      ; copy R0 in R3
		LDI R4, 0x00    ; constant zero

		; compute XOR between R1 and R0
		; result in R0
		AND R0, R1
		COM R0
		OR  R3, R1
		AND R0, R3    ; R0 <= R0 xor R1

loop:
		LSL R0
		ADC R2, R4
		ADD R0, R4     ; is R0==0 ?
		BREQ out
		RJMP loop

out:	
		RJMP out

