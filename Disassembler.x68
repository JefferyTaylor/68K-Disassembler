*-----------------------------------------------------------
* Title      : Test Disassembler Input
* Written by : Jeffery Taylor
* Date       : 02/02/2017
* Description: Gets in the input of the user (First Address)
*-----------------------------------------------------------
    ORG    $1000
START
      
*--------CODE FOR INPUT--------
      LEA     MESSAGE,A1
      MOVE.B  #14,D0           READS THE INPUT FROM THE KEYBOARD TO D1 AS A LONG
      TRAP    #15              DISPLAYS THE MESSAGE 
      MOVE.L  #2,D3            TAKES IN THE INPUT AS A STRING
      TRAP    #15              
      
      MOVE.L     D3,D1         loads input into D1
      MOVE.B     #1,D0
      TRAP       #15           DISPLAYS THE number in decimal

MESSAGE DC.B 'HELLO, WHAT IS THE FIRST ADDRESS?',0
      END        START
