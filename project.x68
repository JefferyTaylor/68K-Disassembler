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
        JSR     move            *subroutine for MOVE opcode


****************************************************************
*
*Subroutine move*
*This is the subroutine for the MOVE opcode
*
*****************************************************************
move    *BTST.L  #31,D0           *test first bit of opcode word in D0
        CLR.L   D1                *clear value in D1
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
        JMP     dest
        
two     CMP.B   #2,D1               *if 2 (10) then size is long
        BGT     three
        CLR.B   D3
        MOVE.B  #76,D3
        MOVE.B  D3,(A2)+
        ADD.B   #1,D4
        JMP     dest

three   CLR.B    D3                 *if 3 (11) then size is word 
        MOVE.B  #87,D3
        MOVE.B  D3,(A2)+
        ADD.B   #1,D4
                  
dest    LEA     str_opcode1,A1      *display opcode word string
        MOVE.B  D4,D1
        MOVE.B  #0,D0
        TRAP    #15

        RTS
        
        SIMHALT                     ;halt simulator

* Data storage region
start_addr  DS.L        1           *starting address to disassemble in memory
end_addr    DS.L        1           *ending address to disassemble in memory
addrCounter DS.L        1           *counter of current address location 
str_opcode1 DS.B        1           *address of first character in string for opcode word

str_length  DS.B        1           *length of string (number of characters in string of opcode)



        END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
