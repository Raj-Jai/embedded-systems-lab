PORTA   EQU 0E800H
PORTB   EQU 0E801H
PORTC   EQU 0E802H
CTRL    EQU 0E803H

CLK_HR  EQU 9000H
CLK_MIN EQU 9001H
CLK_SEC EQU 9002H

SW_HR   EQU 9003H
SW_MIN  EQU 9004H
SW_SEC  EQU 9005H

MODE_BIT EQU 20H.0
RUN_BIT  EQU 20H.1

ORG 0FFF0H
    LJMP TIMER0_ISR

ORG 8100H
INIT:
    MOV DPTR, #CTRL
    MOV A, #89H
    MOVX @DPTR, A

    MOV A, #05H
    MOV DPTR, #CLK_HR
    MOVX @DPTR, A
	MOV A, #00H
    MOV DPTR, #CLK_MIN
    MOVX @DPTR, A
	MOV A, #00H
    MOV DPTR, #CLK_SEC
    MOVX @DPTR, A
	
	MOV A, #00H
    MOV DPTR, #SW_HR
    MOVX @DPTR, A
    MOV DPTR, #SW_MIN
    MOVX @DPTR, A
    MOV DPTR, #SW_SEC
    MOVX @DPTR, A

    CLR MODE_BIT
    CLR RUN_BIT

    MOV TMOD, #01H
    MOV TH0, #4BH
    MOV TL0, #27H
    MOV R2, #20

    SETB ET0
    SETB EA
    SETB TR0

MAIN_LOOP:
    MOV DPTR, #PORTC
    MOVX A, @DPTR
    MOV R5, A
    
    ; --- ACTIVE LOW: Trigger when wire touches Ground ---
    JNB ACC.0, TOGGLE_MODE
    SJMP CHK_START
TOGGLE_MODE:
    CPL MODE_BIT
    ACALL DEBOUNCE
    
CHK_START:
    MOV A, R5
    JNB ACC.1, START_SW
    SJMP CHK_STOP
START_SW:
    JNB MODE_BIT, CHK_STOP  ; Ignore Start if looking at the Clock
    SETB RUN_BIT
    MOV A, #00H
    MOV DPTR, #SW_HR
    MOVX @DPTR, A
    MOV DPTR, #SW_MIN
    MOVX @DPTR, A
    MOV DPTR, #SW_SEC
    MOVX @DPTR, A
    ACALL DEBOUNCE

CHK_STOP:
    MOV A, R5
    JNB ACC.2, STOP_SW
    SJMP DISP_ROUTINE
STOP_SW:
    JNB MODE_BIT, DISP_ROUTINE ; Ignore Stop if looking at the Clock
    CLR RUN_BIT
    ACALL DEBOUNCE

DISP_ROUTINE:
    JNB MODE_BIT, DISP_CLOCK
    MOV R0, #90H
    MOV R1, #03H
    SJMP MULTIPLEX_OUT
DISP_CLOCK:
    MOV R0, #90H
    MOV R1, #00H

MULTIPLEX_OUT:
    ACALL MULTIPLEX_DISPLAY
    SJMP MAIN_LOOP

TIMER0_ISR:
    PUSH ACC
    PUSH PSW                ; Protect Carry Flag
    PUSH DPH
    PUSH DPL

    MOV TH0, #3CH
    MOV TL0, #0B0H

    DJNZ R2, ISR_END
    MOV R2, #20

    ACALL UPDATE_CLOCK

    JNB RUN_BIT, ISR_END
    ACALL UPDATE_SW

ISR_END:
    POP DPL
    POP DPH
    POP PSW
    POP ACC
    RETI

UPDATE_CLOCK:
    MOV DPTR, #CLK_SEC
    MOVX A, @DPTR
    CLR C                   ; Clear carry before math
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #60H, CLK_RET
    MOV A, #00H
    MOVX @DPTR, A

    MOV DPTR, #CLK_MIN
    MOVX A, @DPTR
    CLR C
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #60H, CLK_RET 
    MOV A, #00H
    MOVX @DPTR, A

    MOV DPTR, #CLK_HR
    MOVX A, @DPTR
    CLR C
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #24H, CLK_RET
    MOV A, #00H
    MOVX @DPTR, A

CLK_RET:
    RET

UPDATE_SW:
    MOV DPTR, #SW_SEC
    MOVX A, @DPTR
    CLR C
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #60H, SW_RET
    MOV A, #00H
    MOVX @DPTR, A

    MOV DPTR, #SW_MIN
    MOVX A, @DPTR
    CLR C
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #60H, SW_RET
    MOV A, #00H
    MOVX @DPTR, A

    MOV DPTR, #SW_HR
    MOVX A, @DPTR
    CLR C
    ADD A, #01H
    DA A
    MOVX @DPTR, A
    CJNE A, #24H, SW_RET
    MOV A, #00H
    MOVX @DPTR, A

SW_RET:
    RET

MULTIPLEX_DISPLAY:
    MOV DPH, R0
    MOV DPL, R1
    MOVX A, @DPTR
    MOV R5, A
    
    SWAP A
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0DFH
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A
    
    MOV A, R5
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0EFH
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A
    
    INC R1
    MOV DPH, R0
    MOV DPL, R1
    MOVX A, @DPTR
    MOV R5, A
    
    SWAP A
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0F7H
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A
    
    MOV A, R5
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0FBH
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A

    INC R1
    MOV DPH, R0
    MOV DPL, R1
    MOVX A, @DPTR
    MOV R5, A
    
    SWAP A
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0FDH
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A
    
    MOV A, R5
    ANL A, #0FH
    ACALL GET_LUT
    MOV DPTR, #PORTA
    MOVX @DPTR, A
    MOV DPTR, #PORTB
    MOV A, #0FEH
    MOVX @DPTR, A
    ACALL SHORT_DELAY
    MOV A, #0FFH
    MOVX @DPTR, A
    
    RET

GET_LUT:
    MOV DPTR, #LUT
    MOVC A, @A+DPTR
    RET

SHORT_DELAY:
    MOV R3, #5
SD_OUTER: 
    MOV R4, #200
SD_INNER: 
    DJNZ R4, SD_INNER
    DJNZ R3, SD_OUTER
    RET

DEBOUNCE:
    MOV R6, #255
DB1: 
    DJNZ R6, DB1
    RET

LUT:
    DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH

END