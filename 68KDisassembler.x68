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
	MOVE.B  #13, D0				* Load task
	TRAP    #15       			* Display intro message
	LEA     MEM_START_MSG,A1	* Load memory start message	
	MOVE.B  #13, D0				* Load task
	TRAP    #15					* Display memory start message
	LEA		START_ADDR,A1		* Load address for storing starting address
	MOVE.B  #2,D0             	* Load task
	TRAP	#15					* Get user input
	LEA     MEM_END_MSG,A1      * Load memory end message
	MOVE.B  #13, D0				* Load task
	TRAP    #15					* Display memory end message
	LEA		END_ADDR,A1			* Load address for storing ending address
	MOVE.B  #2,D0             	* Load task
	TRAP    #15 				* Get user input


	

WELCOME_MSG     DC.B    'Welcome to the Some Disassembly Required 68K Disassembler',CR,LF,0
MEM_START_MSG   DC.B    'Please enter the starting memory address:'
MEM_END_MSG     DC.B    'Please enter the ending memory address:'
START_ADDR		DC.B 	80
END_ADDR		DC.B 	80
	
	END    $1000        



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
