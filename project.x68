*-----------------------------------------------------------
* Title      :  Project 422
* Written by :  Tiana Greisel
* Date       :  02/02/2017
* Description:  
*-----------------------------------------------------------
        ORG    $1000
        
*
*system equates
*
    
stack   EQU     $7000           *stack location
test_op EQU     $103C000E       *test instruction for MOVE.B #14,D0 to disassemble

START:                  ; first instruction of program

        LEA     stack,SP        *initialize the stack pointer
        CLR.L   addrCounter     *clear memory for the counter of the next address location
        MOVEA.L #test_op,A0     *get first word from memory and store in A0 (opcode word)
        MOVE.L  A0,D6           *D6 holds hexidecimal machine code to be disassembled
        JSR     move            *subroutine for MOVE opcode (MOVE calls EA)
        *JMP     exit


****************************************************************
*
*Subroutine move*
*This is the subroutine for the MOVE opcode
*
*****************************************************************
move   *BTST.L  #31,D0              *test first bit of opcode word in D0
        CLR.L   D1                  *clear value in D1
        CLR.L   D3                  *clear D3
        CLR.B   str_length          *initialize string length counter
        LEA     str_opcode1,A2      *pointer to first ascii char in string of opcode word
        MOVE.B  #77,D3              *ascii value for 'M' 
        MOVE.B  D3,(A2)+            *move character to opcode string
        MOVE.B  #1,D4               *counter for string length
       * LSL.L   #8,D3              *move ascii char byte to left
        CLR.L   D3                  *clear D3
        MOVE.B  #79,D3              *ascii value for 'O'
        MOVE.B  D3,(A2)+            *move character to opcode string
        ADD.B   #1,D4               *increment counter 1 byte
        *LSL.L   #8,D3              *move ascii char byte to left
        CLR.L   D3                  *clear D3
        MOVE.B  #86,D3              *ascii value for 'V'

        MOVE.B   D3,(A2)+           *add character to opcode string
        ADD.B   #1,D4               *increment counter 1 byte
        *LSL.L   #8,D3              *move ascii char byte to left
        CLR.L   D3                  *clear D3
        MOVE.B  #69,D3              *ascii value for 'E' 
        MOVE.B  D3,(A2)+            *add char to opcode string
        ADD.B   #1,D4               *increment counter 1 byte
        *LSL.L   #8,D3              *move byte to left
        CLR.L   D3                  *clear D3
        MOVE.B  #46,D3              *ascii valuve for '.'
        ADD.B   #1,D4               *increment counter 1 byte
        MOVE.B  D3,(A2)+            *add char to opcode string
        
        *LEA     str_opcode1,A1      *display opcode word string
        *MOVE.L  D3, (A2)
        *MOVE.B  D4,D1
        *MOVE.B  #0,D0
        *TRAP    #15
    
     
        *LSL.L   D2,D3
        MOVE.L  D6,D1               *make copy of hexidecimal machine code
        LSL.L   #2,D1               *take off first two bits of opcode word
        MOVE.B  #30,D2              *move 30 into D2 to shift right with
        LSR.L   D2,D1               *shift so only size bits left in D1

        CMP.B   #1,D1               *compare size bits with 01 (size is byte)
        BGT     two
        CLR.B   D3
        MOVE.B  #66,D3
        MOVE.B  D3,(A2)+
        ADD.B   #1,D4
        JMP     space
        
two     CMP.B   #2,D1               *if 2 (10) then size is long
        BGT     three
        CLR.B   D3
        MOVE.B  #76,D3
        MOVE.B  D3,(A2)+
        ADD.B   #1,D4
        JMP     space

three   CLR.B    D3                 *if 3 (11) then size is word 
        MOVE.B  #87,D3
        MOVE.B  D3,(A2)+
        ADD.B   #1,D4
                  
space   CLR.B   D3                  
        MOVE.B  #32,D3              *ascii value for a space
        MOVE.B  D3,(A2)+            *add space character to string
        ADD.B   #1,D4               *increment bytes of string counter cause added a byte (char)
        JMP     dest

dest    *JSR     EA                  *call subroutine for EA modes
        *JMP     disply
        MOVE.L  D6,D1               *make copy of hexidecimal machine code
        LSL.L   #7,D1               *get rid of first 7 bits (so just dest mode left)        
        CLR.L   D3
        MOVE.B  #29,D3
        LSR.L   D3,D1               *get rid of all but destination mode 3 bits in D1
        MOVE.L  D6,D5               *copy hexidecimal machine code 
        LSL.L   #4,D5               *get rid of first 4 bits
        MOVE.B  #26,D3              *get rid of all but destination register bits
        LSR.L   D3,D5               *DONT CALL IF IMMEDIATE OR ABSOLUTE
        JSR     regNum              *get ascii value of register number
        
        JSR     EA                  *call subroutine for EA modes
        MOVE.B  D3,(A2)+            *move ascii value EA function stored onto assembly code string
        ADD.B   #1,D4               *added character to string, so add 1 byte on counter
        MOVE.B  D5,(A2)+            *add register # to assembly code instruction string
        ADD.B   #1,D4
        
disply  LEA     str_opcode1,A1      *display opcode word string
        CLR.L   D1
        MOVE.B  D4,D1
        MOVE.B  #0,D0
        TRAP    #15

        RTS
        
        
        
********************************************************************
*
*Subroutine EA
*
*A2 holds the address of the location of the string for the assembly
*language instruction we are printing.  EA figures out the EA mode and stores the
*ascii value of the EA mode in D3 which subroutine opcode that calls EA will
*add to assembly code instruction string.  If addressing mode is absolute or
*immediate, functions put zero into D3 by clearing it.  Opcode subroutine calling EA
*subroutine, will know to get the following register 3 bits so it knows size of data,etc.
*D1 holds the 3 bits that EA operates on to figure out the EA mode.
********************************************************************
EA      CMP.B   #0,D1               *D1 holds 3 bits figuring EA mode of
        BGT     addr_r              *if not zero, not data register direct
        MOVE.B  #68,D3              *Data register so add D to string
        JMP     done

addr_r  CMP.B   #4,D1               *if greater than 4, absolute of immediate addressing mode
        BGT     abs_im
        MOVE.B  #65,D3              *if 1,2,3 or 4 then add A to string since Address register EA mode
        JMP     done
        
abs_im  CLR.L   D3                  *if absolute or immediate addressing, store zero for false flag 
                                    *so opcode subroutine knows it needs to get data
            
done    RTS     

****************************************************************
*
*Subroutine RegNum
*
*Returns ascii value of register number 0 - 7 based on value in D5.
*
*****************************************************************   
regNum  CMP.B   #0,D5               *is number 0
        BGT     one_
        MOVE.B  #48,D5
        JMP     dne

one_    CMP.B   #1,D5               *is number 1
        BGT     two_        
        MOVE.B  #49,D5
        JMP     dne
        
two_    CMP.B   #2,D5               *is number 2
        BGT     three_
        MOVE.B  #50,D5
        JMP     dne
        
three_  CMP.B   #3,D5               *is number 3
        BGT     four_
        MOVE.B  #51,D5
        JMP     dne
        
four_   CMP.B   #4,D5               *is number 4
        BGT     five_
        MOVE.B  #52,D5
        JMP     dne
        
five_   CMP.B   #5,D5               *is number 5
        BGT     six_
        MOVE.B  #53,D5
        JMP     dne
        
six_    CMP.B   #6,D5               *is number 6
        BGT     seven_
        MOVE.B  #54,D5
        JMP     dne
        
seven_  MOVE.B  #55,D5
        JMP     dne
       
dne     RTS
exit        SIMHALT                     ;halt simulator

* Data storage region
start_addr  DS.L        1           *starting address to disassemble in memory
end_addr    DS.L        1           *ending address to disassemble in memory
addrCounter DS.L        1           *counter of current address location 
str_opcode1 DS.B        1           *address of first character in string for opcode word

str_length  DS.B        1           *length of string (number of characters in string of opcode)
dest_reg    DS.B        1           *storage for destination register EA
dest_mode   DS.B        1           *storage for destination mode EA
EA_mode     DS.B        1           *storage of EA mode ascii character



        END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
