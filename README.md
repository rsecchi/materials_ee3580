# materials_ee3580


CPU registers


R0-R15    8-bit registers (register file)

IP        instruction pointer (16 bits)
SREG      status register


===============================================================================

Formats of Micro instruction:

   1-byte instructions (1 byte is padding):
   
      oooo rrrr 00000000
        
        oooo --> 4-bit opcode
	rrrr --> 4-bit destination operand register
   
   2-byte instructions:  
   
   a)
      oooo dddd   0000ssss
      
      oooo      --> 4-bit opcode
      dddd      --> 4-bit destination register name
      ssss      --> 4-bit source register name
         
   b)
      oooo rrrr   yyyyyyyy
   
        oooo      --> 4-bit opcode
        rrrr      --> 4-bit register name   
        yyyyyyyy  --> 8 bit immediate operand
	
=============================================================================

    one-byte instructions

    0000   NOP       =>   No operation
    0001   COM Rd    =>   One's complement
    0010   ST X,Rr   =>   Store in Memory (X is a pointer register R14:R15)
    0011   LD Rd, X  =>   Load in Memory  (X is a pointer register R14:R15)

    0100   NEG Rd    =>   Two's complement
    0101   INC Rd    =>   Increment Register
    0110   LSR Rd    =>   Logical shift right  
    0111   LSL Rd    =>   Logical shift left

    two-byte instructions

    1000   MOV Rd, Rr  =>  Copy register
    1001   LDI Rd, K   =>  Load immediate
    1010   ADD Rd, Rr  =>  Add register
    1011   ADC Rd, Rd  =>  Add register with carry

    1100   AND Rd, Rr  =>  Logigal AND
    1101   OR  Rd, Rr  =>  Logical OR
    1110   BREQ  K     =>  Relative branch if equal (Z=1)
    1111   RJPM  K     =>  Relative jump
