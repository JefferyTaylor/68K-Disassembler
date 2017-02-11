*-------------------------------------------------------------
* Title      : Test Program Dissasembler 
* Written by : Jeffery Taylor
* Date       : 09/02/2017
* Description: Test Program that uses all required OP codes.
*-------------------------------------------------------------
    ORG    $1000
START:
**************************************************************
*       THE MOVE COMMANDS                                    *
**************************************************************
        MOVE.B      #1,D2           *143C 0001
        MOVE.W      D2,D3           *3602
        MOVE.L      D3,D4           *2803
        
        MOVEA.W     D4,A1           *3244
        MOVEA.L     A1,A2           *2449
        
        MOVEM.W     A1-A3,0101      *4891 0006
        MOVEM.L     D1-D4,(A1)      *

        MOVEQ.L     #7,D1           *7207
        
**************************************************************
*       THE ADD COMMANDS                                     *
**************************************************************
        ADD.B       D1,D2           *D401
        ADD.W       D2,D3           *D642
        ADD.L       D3,D4           *D883
        
        ADDA.W      D4,A1           *D2C4
        ADDA.L      D5,A2           *D5C5
        
        ADDI.B      #1,D1           *5201
        ADDI.W      #0001,D2        *5242
        ADDI.L      #00000001,D3    *5283
                
        ADDQ.B      #1,D1           *5201
        ADDQ.W      #0001,D2        *5242
        ADDQ.L      #00000001,D3    *5283
        
**************************************************************
*       THE SUB, MUL AND DIV COMMANDS                        *
**************************************************************
        SUB.B       D1,D2           *
        SUB.W       D2,D3           *
        SUB.L       D3,D4           *
        
        MULS.W      D4,D5           *
        
        DIVU.W      D5,D6           *
        
**************************************************************
*       THE COMPARING AND BRANCHING COMMANDS                 *
**************************************************************
        AND.B       D1,D2           *
        AND.W       D2,D3           *
        AND.L       D3,D4           *
        
        OR.B        D1,D2           *
        OR.W        D2,D3           *
        OR.L        D3,D4           *
        
        CMP.B       D1,D2           *
        CMP.W       D2,D3           *
        CMP.L       D3,D4           *
        
        BCC         NEXT            * 
NEXT    BGT         NEXT1           *        
NEXT1   BLE         NEXT2           *

NEXT2   JSR         NEXT3           *
NEXT3   RTS                         *

**************************************************************
*       THE LOGICAL,ARITHMETIC SHIFTS WITH ROTATION COMMANDS *
**************************************************************
        LSL.B       D1,D2           *
        LSL.W       D2,D3           *
        LSL.L       D3,D4           *
        
        LSR.B       D1,D2           *
        LSR.W       D2,D3           *
        LSR.L       D3,D4           *
        
        ASL.B       D1,D2           *
        ASL.W       D2,D3           *
        ASL.L       D3,D4           *
        
        ASR.B       D1,D2           *
        ASR.W       D2,D3           *
        ASR.L       D3,D4           *
        
        ROL.B       D1,D2           *
        ROL.W       D2,D3           *
        ROL.L       D3,D4           *
        
        ROR.B       D1,D2           *
        ROR.W       D2,D3           *
        ROR.L       D3,D4           *

**************************************************************
*       EXTRA COMMANDS                                       *
**************************************************************
        LEA         MESSAGE,A1      *
        
        CLR.B       D1              *
        CLR.W       D2              *
        CLR.L       D3              *
        
        NOP                         *

**************************************************************
*                           FIN                              *
**************************************************************

MESSAGE DC.B 'HELLO',0
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
