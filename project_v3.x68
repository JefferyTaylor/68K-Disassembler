*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Garrett Singletary, Tiana Greisel, Jeffrey Taylor
* Date       : 23 JAN 2017
* Description: CSS 422 Project
*-----------------------------------------------------------

CR      EQU     $0D
LF      EQU     $0A
*test_op EQU     $103C000E       *test instruction for MOVE.B #14,D0 to disassemble
test_op EQU     $100F0000

START	ORG	$1000   


* -------------------------------------------
* 			PARSE OPCODE
* -------------------------------------------
*GET_OPCODE	
			*LEA 	test_op,A5 
			*ADDA.L 	#3,A5
			MOVE.L	#test_op,(A5)
			MOVE.L 	(A5),D1
			BTST.L  #32,D1
			 


* -------------------------------------------
*			MOVE Subroutine 
* -------------------------------------------
MOVE_SUB	LEA 	MOVE_M,A1	* Load 'MOVE'
			MOVE.B 	#14,D0 		* Trap task
			TRAP 	#15 		* Display 'MOVE'

			MOVE.L  (A5),D1     * D1 holds hexidecimal machine code to be disassembled
			ASL.L   #2,D1       * Take off first two bits of opcode word (already determined)
			JSR 	GET_SIZE	*get size of opcode instruction
			
			JSR		ADD_SPACE	*Add space to output string 
			
			MOVE.L  (A5),D1     * D1 holds hexidecimal machine code to be disassembled
			ASL.L   #4,D1       * Get rid of first 4 bits
			LSR.L	#4,D1		*	shift back 4 bits with added trailing zeros (want with destinaiton and source bits)
			
			JSR		OP_WORD		*take off right-most 16 bits of long to be left with opcode instruction word only
			
			MOVE.L 	D1,D2 		* Copy Opcode hex to D2 for source EA determination (DESTINATION AND SOURCE)
			
			MOVE.B 	#26,D4		*D2 holds DESTINATION AND SOURCE REGISTERS AND MODES 6 bits 
			LSL.L 	D4,D1 		*get rid of destination bits 
			LSR.L   D4,D1		*now have source 6 bits only in D2
			MOVE.L 	D1,D3 		*copy for source register 
			LSR.L  	#3,D1 		*SOURCE MODE ONLY
			LEA		EA_mode,A2 	*storage for EA mode bits
			MOVE.B 	D1,(A2)		*EA_mode holds 3 bits of source mode now 
			
			MOVE.B 	#29,D4 		*get rid of all except SOURCE REGISTER bits 
			LSL.L 	D4,D3 
			LSR.L 	D4,D3
			LEA 	reg_num,A2 	*storage for register number bits
			MOVE.B 	D3,(A2)		*reg_num holds 3 bits of register number now 
			
			JSR		GET_EA		*correct register string in reg_str or $ for absolute or # for immediate
			
			CMP.B 	#7,(A2)		*if EA mode is absolute addressing or immediate data 
			BEQ		data
			
*DS			LEA 	reg_str,A1	*display correct register for destination or symbol (absolute or immediate)
DS			MOVE.B 	#14,D0
			TRAP 	#15
			LEA 	COMMA,A1
			MOVE.B 	#14,D0
			TRAP 	#15
			JMP     dest 

data 		JSR 	GET_DATA 
			BRA 	DS

dest
			LSR.L	#6,D2		*get just destination register and mode (DESTINATION ONLY)
			MOVE.B	D2,D3 		*copy D1 into D3 to get destination mode (copy DESTINATION ONLY)
			LSR.L	#3,D2		*get destination register (DESTINATION REGISTER ONLY)
			LEA 	reg_num,A2	*storage for register number bits
			MOVE.B	D2,(A2)		*reg_num holds 3 bits of destination register number now 
			
			MOVE.B 	#29,D4		*shift 29 to left to get just dest mode (DESTINATION MODE ONLY)
			LSL.L 	D4,D3		*get rid of destination register 3 bits 
			LSR.L   D4,D3 		*LEFT WITH DESTINATION MODE ONLY 
			LEA		EA_mode,A2	*storage for EA mode bits 
			MOVE.B	D3,(A2)		*EA_mode holds 3 bits of destination mode now 
			
			JSR		GET_EA		*loads A1 with correct register string or $ for absolute or # for immediate
			
			MOVE.B 	#14,D0
			TRAP 	#15
			
*			BRA		CLOSE 

* -------------------------------------------
*			OP_WORD Subroutine 
*				Takes right-most 16 bits off of 
*				long value passed in D1 and returns that
*				value as a word (in D1).
* -------------------------------------------
OP_WORD		MOVE.B	#16,D2
			LSR.L	D2,D1
			RTS


* -------------------------------------------
*			GET_SIZE Subroutine 
* -------------------------------------------
GET_SIZE	LSR.L 	#8,D1
			LSR.L	#8,D1
			LSR.L	#8,D1
			LSR.L	#6,D1
			CMP.B 	#1,D1		* Check if size bits == 01
			BNE		WORD
			LEA 	B_M,A1
			MOVE.B 	#14,D0 		* Trap task
			TRAP 	#15 		* Display '.B'
			RTS
WORD 		CMP.B 	#3,D1		* Check if size bits == 11
			BNE		LONG
			LEA 	W_M,A1
			MOVE.B 	#14,D0 		* Trap task
			TRAP 	#15 		* Display '.W'
			RTS
LONG		LEA 	L_M,A1
			MOVE.B 	#14,D0 		* Trap task
			TRAP 	#15 		* Display '.L'
			RTS
			
* -------------------------------------------
*			GET_EA Subroutine 
*				This subroutine takes register number stored in reg_num and 
*				mode stored in EA_mode and determines the correct EA mode and determines
*				the correct constant to load into A1.  If absolute addressing mode uses '$' 
*				and if immediate data uses '#'.
* -------------------------------------------	
GET_EA		LEA 	reg_num,A2  *REGISTER NUMBER 
			CLR.L 	D3 			*clear D3 
			MOVE.B 	(A2),D3 	*D3 holds register number 3 bits 
			
			LEA 	EA_mode,A3	*MODE 
			CLR.L	D4 			*clear D4 
			MOVE.B	(A3),D4 	*D4 holds EA mode 3 bits 
			
			CMP.B 	#0,D4 		*DATA REGISTER DIRECT 
			BGT		A_reg	
			JSR 	GET_RNUM	*put correct data register constant into reg_str
			RTS
			
A_reg		CMP.B 	#4,D4 		*0 - 4 Address register addressing modes 
			BGT 	abs_immed	*ABSOLUTE OR IMMEDIATE DATA ADDRESSING MODES
			JSR 	GET_ARNUM	*put correct address register constant into reg_str
			RTS

abs_immed	CMP.B 	#4,D3		*look at absolute or immmediate mode bits for if absolute or immediate
			BLT 	abs			*less than 4 absolute EA mode
			
			LEA 	IMMED_M,A1
			
			RTS

abs			LEA 	ABS_M,A1
			
			RTS
			
* -------------------------------------------
*			GET_RNUM Subroutine
*			Gets the correct register number for data register direct and puts constant for it in reg_str. 
*			D3 holds register number 3 bits, D4 holds EA mode 3 bits.
* -------------------------------------------			
GET_RNUM  
		LEA 	reg_str,A3
		
		CMP.B   #0,D3               *is number 0
        BGT     one_
        LEA 	D0_M,A1
        RTS

one_    CMP.B   #1,D3               *is number 1
        BGT     two_        
		LEA 	D1_M,A1
        RTS
        
two_    CMP.B   #2,D3               *is number 2
        BGT     three_
		LEA 	D2_M,A1
        RTS
        
three_  CMP.B   #3,D3               *is number 3
        BGT     four_
		LEA 	D3_M,A1
        RTS
        
four_   CMP.B   #4,D3               *is number 4
        BGT     five_
		LEA 	D4_M,A1
        RTS
        
five_   CMP.B   #5,D3               *is number 5
        BGT     six_
		LEA 	D5_M,A1
        RTS
		
six_    CMP.B   #6,D3               *is number 6
        BGT     seven_
		LEA 	D6_M,A1
        RTS 
        
seven_  LEA 	D7_M,A1
        RTS	
		
* -------------------------------------------
*			GET_ARNUM Subroutine
*			Gets the correct register number for address register  and puts constant for it in reg_str. 
*			D3 holds register number 3 bits, D4 holds EA mode 3 bits.
* -------------------------------------------			
GET_ARNUM
* -------------------------------------------
GET_ARNUM
		LEA 	reg_str,A3
		
		CMP.B   #0,D3               *is number 0
        BGT     one_1
        LEA 	A0_M,A1
        RTS

one_1   CMP.B   #1,D3               *is number 1
        BGT     two_2        
		LEA 	A1_M,A1
        RTS
        
two_2   CMP.B   #2,D3               *is number 2
        BGT     three_3
		LEA 	A2_M,A1
        RTS
        
three_3 CMP.B   #3,D3               *is number 3
        BGT     four_4
		LEA 	A3_M,A1
        RTS
        
four_4  CMP.B   #4,D3               *is number 4
        BGT     five_5
		LEA 	A4_M,A1
        RTS
        
five_5  CMP.B   #5,D3               *is number 5
        BGT     six_6
		LEA 	A5_M,A1
        RTS
		
six_6   CMP.B   #6,D3               *is number 6
        BGT     seven_7
		LEA 	A6_M,A1
        RTS 
        
seven_7 LEA 	A7_M,A1
        RTS


*			GET_DATA Subroutine 
* -------------------------------------------
GET_DATA	
		
* -------------------------------------------
*			ADD_SPACE Subroutine 
* -------------------------------------------
ADD_SPACE	LEA		SPACE,A1
			MOVE.B	#14,D0
			Trap	#15
			RTS
			

WELCOME_MSG     DC.B    'Welcome to the Some Disassembly Required 68K Disassembler',CR,LF,0
MEM_START_MSG   DC.B    'Please enter the starting memory address: $',0
MEM_END_MSG     DC.B    'Please enter the ending memory address: $',0
BAD_INPUT_MSSG	DC.B 	'Bad input. Please start again again.',0
CLOSE_MSSG		DC.B 	'Thanks for using our disassembler!',0
START_ADDR		DS.L 	0
END_ADDR		DS.L 	0

* -----------------------------------
* 			OPCODE MESSAGES
* -----------------------------------

NOP_M			DC.B 	'NOP',0
MOVE_M 			DC.B    'MOVE',0
MOVEQ_M			DC.B 	'MOVEQ',0
MOVEM_M			DC.B 	'MOVEM',0
MOVEA_M			DC.B 	'MOVEA',0
ADD_M 			DC.B 	'ADD',0
ADDA_M 			DC.B 	'ADDA,0'
ADDI_M			DC.B  	'ADDI',0
SUB_M			DC.B 	'SUB',0
MULS_M			DC.B 	'MULS',0
DIVU_M			DC.B 	'DIVU',0
LEA_M			DC.B 	'LEA',0
CLR_M			DC.B 	'CLR',0
AND_M			DC.B 	'AND',0
OR_M			DC.B 	'OR',0
LSL_M			DC.B 	'LSL',0
LSR_M			DC.B 	'LSR',0
ASR_M			DC.B  	'ASR',0
ASL_M			DC.B 	'ASL',0
ROL_M			DC.B 	'ROL',0
ROR_M			DC.B 	'ROR',0
CMP_M			DC.B 	'CMP',0
BCC_M			DC.B 	'BCC',0
BGT_M			DC.B 	'BGT',0
BLE_M			DC.B 	'BLE',0
JSR_M			DC.B 	'JSR',0
RTS_M			DC.B 	'RTS',0
B_M 			DC.B 	'.B',0
W_M 			DC.B 	'.W',0
L_M 			DC.B 	'.L',0
SPACE			DC.B	' ',0
COMMA			DC.B 	',',0
ABS_M			DC.B   	'$',0
IMMED_M			DC.B	'#',0

**********************************************
*CONSTANT TYPE
*
**********************************************

**********************************************
*DATA REGISTER 
*
**********************************************
D0_M			DC.B	'D0',0
D1_M			DC.B	'D1',0
D2_M			DC.B	'D2',0
D3_M			DC.B	'D3',0
D4_M			DC.B	'D4',0
D5_M			DC.B	'D5',0
D6_M			DC.B	'D6',0
D7_M			DC.B	'D7',0

**********************************************
*ADDRESS REGISTER 
*
**********************************************
A0_M			DC.B	'A0',0
A1_M			DC.B	'A1',0
A2_M			DC.B	'A2',0
A3_M			DC.B	'A3',0
A4_M			DC.B	'A4',0
A5_M			DC.B	'A5',0
A6_M			DC.B	'A6',0
A7_M			DC.B	'A7',0




* Data storage region
addrCounter DS.L        1           *counter of current address location 
str_opcode1 DS.B        1           *address of first character in string for opcode word


dest_reg    DS.B        1           *storage for destination register EA
dest_mode   DS.B        1           *storage for destination mode EA

reg_num		DS.B		1			*storage for register number bits
EA_mode		DS.B		1			*storage for EA mode bits

reg_str		DS.B		1			*register string (register with num)
constAddr	DS.B		1 			*starting address location  of constant type (data registers, address registers, etc.)

abs_data	DS.L 		1
immed_data	DS.L 		1
	
CLOSE		LEA 	CLOSE_MSSG,A1
			MOVE.B 	#13,D0
			TRAP 	#15	
			END    $1000        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
