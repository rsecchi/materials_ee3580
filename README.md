# materials_ee3580


CPU registers


R0-R15    8-bit registers (register file)

IP        instruction pointer (15 bits)
SREG      status register

========================================================

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

========================================================

    opcode / instruction

    0000   NOP              =>   No operation
    0001   ST reg           =>   Store in Memory  (at the address pointed by reg R14:R15)
    0010   BREQ  imm        =>   Relative branch if equal (Z=1)
    0011   RJPM  imm        =>   Relative jump
    
    0100   LD reg           =>   Load in Memory (at the address pointed by reg R14:R15)
    0101   ADI reg, imm     =>   Add Immediate
    0110   LDI reg, imm     =>   Load Immediate
    0111   LSR reg          =>   Logical Shift Right
    
    1000   LSL reg          =>   Logical Shift Left
    1001   COM reg          =>   One's complement
    1010   NEG reg          =>   Negate
    1011   MOV reg, reg     =>   Move 

    1010   ADD reg, reg     =>  Add register
    1011   ADC reg, reg     =>  Add register with carry
    1100   AND reg, reg     =>  Logigal AND
    1101   OR  reg, reg     =>  Logical OR

