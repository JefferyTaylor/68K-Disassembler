*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Garrett Singletary, Tiana Greisel, Jeffrey Taylor
* Date       : 23 JAN 2017
* Description: CSS 422 Project
*-----------------------------------------------------------

CR      EQU     $0D
LF      EQU     $0A

START	ORG	$1000                  
		LEA     WELCOME_MSG,A1		* Load welcome message	
		MOVE.B  #13, D0				* Trap task
		TRAP    #15       			* Display intro message

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
		
		BRA		CLOSE

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
	


WELCOME_MSG     DC.B    'Welcome to the Some Disassembly Required 68K Disassembler',CR,LF,0
MEM_START_MSG   DC.B    'Please enter the starting memory address: $',0
MEM_END_MSG     DC.B    'Please enter the ending memory address: $',0
BAD_INPUT_MSSG	DC.B 	'Bad input. Please start again again.',0
CLOSE_MSSG		DC.B 	'Thanks for using our disassembler!',0
START_ADDR		DS.L 	0
END_ADDR		DS.L 	0

CLOSE		LEA 	CLOSE_MSSG,A1
			MOVE.B 	#13,D0
			TRAP 	#15	
			END    $1000        






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
