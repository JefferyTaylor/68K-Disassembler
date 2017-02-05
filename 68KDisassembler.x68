*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Garrett Singletary, Tiana Greisel, Jeffrey Taylor
* Date       : 23 JAN 2017
* Description: CSS 422 Project
*-----------------------------------------------------------

CR      EQU     $0D
LF      EQU     $0A

START	ORG	$1000   

* ----------------------------------------------------------------
		MOVE.L 	#1,D6				* Test command for disassembly 
* ----------------------------------------------------------------

		LEA     WELCOME_MSG,A1		* Load welcome message	
		MOVE.B  #13, D0				* Trap task
		TRAP    #15       			* Display intro message

* -------------------------------------------
* 			GET ADDRESSES FROM USER
* -------------------------------------------
MS		LEA     MEM_START_MSG,A1	* Load memory start message	
		MOVE.B  #14, D0				* Trap task
		TRAP    #15					* Display memory start message

		MOVE.B  #2,D0             	* Trap task
		TRAP	#15					* Get starting addr from user
		JSR		ADDR_PARSE			* Parse address from user's string input
		MOVE.L 	D1,A5				* Move the parsed addr to A1
		
ME		LEA     MEM_END_MSG,A1      * Load memory end message
		MOVE.B  #14, D0				* Load task
		TRAP    #15					* Display memory end message
		
		MOVE.B  #2,D0             	* Load task
		TRAP    #15 				* Get user input
		JSR		ADDR_PARSE			* Parse address from user's string input
		MOVE.L 	D1,A6				* Move the parsed addr to A1


		BRA		MOVE_SUB
		
		BRA		CLOSE

* -------------------------------------------
* 			PARSE ADDRESS
* -------------------------------------------
ADDR_PARSE	CMP.B 	#0,D1		* Check for empty input
			BEQ		BAD_INPUT	* Handle bad input
			CMP.B 	#8,D1		* Check for too many values
			BGT		BAD_INPUT
			CLR		D1			* Clear D1 to hold addr value
			MOVE.B 	#0,D2		* For checking nulls
CHAR_PARSE	MOVE.B 	(A1)+,D3	* Get char
			CMP.B 	D2,D3		* Check for null
			BEQ		PARSE_DONE	* Done parsing
			CMP.B 	#$30,D3		* Check if less than 0's ascii value
			BLT		BAD_INPUT
			CMP.B 	#$39,D3		* Check if an integer
			BLE		INTEGER
			CMP.B 	#$40,D3
			BLE		BAD_INPUT
			CMP.B 	#$46,D3
			BLE		UPPER_CHAR
			CMP.B 	#$60,D3
			BLE		BAD_INPUT
			CMP.W 	#$66,D3
			BLE		LOWER_CHAR
			BRA		BAD_INPUT

INTEGER 	SUB.B 	#$30,D3
			BRA		STORE_HEX
UPPER_CHAR	SUB.B 	#55,D3
			BRA		STORE_HEX
LOWER_CHAR	SUB.B 	#87,D3
			BRA		STORE_HEX

BAD_INPUT	LEA 	BAD_INPUT_MSSG,A1
			MOVE.B 	#13,D0
			TRAP 	#15
			BRA		MS

STORE_HEX	ASL.L 	#4,D1
			ADD.B 	D3,D1
			BRA 	CHAR_PARSE

PARSE_DONE	RTS	

* -------------------------------------------
* 			PARSE OPCODE
* -------------------------------------------
GET_OPCODE	MOVE.L 	(A5),D1
			BTST.L  #32,D1
			 


* -------------------------------------------
*			MOVE Subroutine 
* -------------------------------------------
MOVE_SUB	LEA 	MOVE_M,A1	* Load 'MOVE'
			MOVE.B 	#14,D0 		* Trap task
			TRAP 	#15 		* Display 'MOVE'

			MOVE.L  (A5),D1     * D1 holds hexidecimal machine code to be disassembled
			ASL.L   #2,D1       * Take off first two bits of opcode word

			MOVE.L 	D1,D2 		* Copy Opcode hex to D2 for further processing
								                    * Size will be found using D1
			JSR 	GET_SIZE
			BRA		CLOSE 

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
ADDA_M 			DC.B 	'ADDA',0
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


CLOSE		LEA 	CLOSE_MSSG,A1
			MOVE.B 	#13,D0
			TRAP 	#15	
			END    $1000        









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
