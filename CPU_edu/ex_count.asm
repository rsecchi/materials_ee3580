; This example counts the number of "1"s in the register R0

		LDI R0, 0x06       ;  R0 is the input 
		LDI R1, 0x00       ;  R1 is the counter 
		LDI R4, 0x01       ;  R4 is a constant (+1)

cycle:
		AND R0, R0         ;  sets the Z flag
		BREQ halt          ;  end if no bit in R0 are "1"
		
		MOV R2, R0         ;  copy R0 in R2
		AND R2, R4         ;  test if the LSB of R0 is "1"

		BREQ out           ;  if it is not "1" do nothing (skip instr)
		ADI R1, 0x01       ;  otherwise add 1 to the counter

out:
		LSR R0             ;  shift R0 one bit to the right
		RJMP cycle


; loops forever
halt:   RJMP halt




