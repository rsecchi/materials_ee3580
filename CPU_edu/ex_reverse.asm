; Reverse the bits in R0
; for example   R0 = 01001011 (0x4B)  
; converts into R0 = 11010010 (0xD2)

		LDI R0, 0x4B    ; value to convert
		LDI R1, 8       ; counter
		LDI R2, 0       ; will contain of R0 reversed
		LDI R3, 0       ; constant zero

cycle:
		LSR R0          ; shift right R0 , LSB in carry
		ADC R2, R3      ; add the carry to R2
		ADI R1, 0xFF    ; R1 <- R1 - 1

		BREQ end        ; if counter is zero exit
		LSL R2
		RJMP cycle

end:
		MOV R0, R2
halt:   RJMP halt

