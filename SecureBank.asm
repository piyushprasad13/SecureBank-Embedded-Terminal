ORG 0000H
LJMP MAIN

; =========================================================
; LCD PINS
; =========================================================

RS  BIT P2.5
RW  BIT P2.6
EN  BIT P2.7

; =========================================================
; OUTPUTS + IR SENSOR
; =========================================================

GREEN_LED BIT P2.0
RED_LED   BIT P2.1

IR_SENSOR BIT P2.3

; =========================================================
; RAM VARIABLES
; =========================================================

ID1 EQU 61H
ID2 EQU 62H

PIN1 EQU 63H
PIN2 EQU 64H
PIN3 EQU 65H
PIN4 EQU 66H

BALANCE EQU 67H
AMOUNT  EQU 68H

D1VAL EQU 69H
D2VAL EQU 6AH
D3VAL EQU 6BH

TEMP EQU 6CH

WRONGCNT EQU 76H

; REGISTERED USER

RID1 EQU 70H
RID2 EQU 71H

RP1 EQU 72H
RP2 EQU 73H
RP3 EQU 74H
RP4 EQU 75H

; =========================================================
; MAIN
; =========================================================

MAIN:

    ACALL LCD_INIT

    MOV BALANCE,#00
    MOV WRONGCNT,#00

; =========================================================
; WAIT FOR PERSON
; =========================================================

WAIT_PERSON:

    ACALL LCD_CLEAR

    MOV DPTR,#DETECTMSG
    ACALL PRINT

CHECK_IR:

    ; WAIT UNTIL PERSON DETECTED
    ; IR LOW = PERSON DETECTED

    JB IR_SENSOR,CHECK_IR

    ACALL LCD_CLEAR

    MOV DPTR,#WELCOME
    ACALL PRINT

    SETB GREEN_LED

    ACALL DELAY

    CLR GREEN_LED

START:

    ACALL LCD_CLEAR

    MOV DPTR,#MAINMSG
    ACALL PRINT

WAIT_MAIN:

    ACALL GET_KEY

    CJNE A,#'1',CHK_REG
    LJMP LOGIN

CHK_REG:
    CJNE A,#'2',WAIT_MAIN
    LJMP REGISTER

; =========================================================
; REGISTER
; =========================================================

REGISTER:

    ACALL LCD_CLEAR

    MOV DPTR,#REGMSG
    ACALL PRINT

    ACALL GET_ID

    MOV A,ID1
    MOV RID1,A

    MOV A,ID2
    MOV RID2,A

    ACALL LCD_CLEAR

    MOV DPTR,#PINMSG
    ACALL PRINT

    ACALL GET_PIN

    MOV A,PIN1
    MOV RP1,A

    MOV A,PIN2
    MOV RP2,A

    MOV A,PIN3
    MOV RP3,A

    MOV A,PIN4
    MOV RP4,A

    MOV BALANCE,#00

    ACALL LCD_CLEAR

    MOV DPTR,#DONE
    ACALL PRINT

    ACALL DELAY

    LJMP START

; =========================================================
; LOGIN
; =========================================================

LOGIN:

    ACALL LCD_CLEAR

    MOV DPTR,#IDMSG
    ACALL PRINT

    ACALL GET_ID

    ACALL LCD_CLEAR

    MOV DPTR,#PINMSG
    ACALL PRINT

    ACALL GET_PIN

    MOV A,ID1
    CJNE A,RID1,FAIL

    MOV A,ID2
    CJNE A,RID2,FAIL

    MOV A,PIN1
    CJNE A,RP1,FAIL

    MOV A,PIN2
    CJNE A,RP2,FAIL

    MOV A,PIN3
    CJNE A,RP3,FAIL

    MOV A,PIN4
    CJNE A,RP4,FAIL

SUCCESS:

    SETB GREEN_LED

    MOV WRONGCNT,#00

    ACALL LCD_CLEAR

    MOV DPTR,#OKMSG
    ACALL PRINT

    ACALL DELAY

    CLR GREEN_LED

    LJMP MENU

; =========================================================
; FAIL
; =========================================================

FAIL:

    INC WRONGCNT

    MOV A,WRONGCNT

    CJNE A,#03,SHOW_FAIL

LOCKED:

    SETB RED_LED

    ACALL LCD_CLEAR

    MOV DPTR,#LOCKMSG
    ACALL PRINT

WAIT_UNLOCK:

    ACALL GET_KEY

    CJNE A,#'#',WAIT_UNLOCK

    CLR RED_LED

    MOV WRONGCNT,#00

    ACALL LCD_CLEAR

    MOV DPTR,#UNLOCKMSG
    ACALL PRINT

    ACALL DELAY

    LJMP START

SHOW_FAIL:

    SETB RED_LED

    ACALL LCD_CLEAR

    MOV DPTR,#FAILMSG
    ACALL PRINT

    ACALL DELAY

    CLR RED_LED

    LJMP START

; =========================================================
; MENU
; =========================================================

MENU:

    ACALL LCD_CLEAR

    MOV DPTR,#MENUMSG
    ACALL PRINT

WAIT_MENU:

    ACALL GET_KEY

    CJNE A,#'1',CHK_DEP
    LJMP BALANCE_SHOW

CHK_DEP:
    CJNE A,#'2',CHK_WD
    LJMP DEPOSIT

CHK_WD:
    CJNE A,#'3',CHK_EXIT
    LJMP WITHDRAW

CHK_EXIT:
    CJNE A,#'0',WAIT_MENU

    ; GO BACK TO IR DETECTION

    LJMP WAIT_PERSON

; =========================================================
; BALANCE
; =========================================================

BALANCE_SHOW:

    ACALL LCD_CLEAR

    MOV DPTR,#BALMSG
    ACALL PRINT

    MOV A,BALANCE
    MOV B,#100
    DIV AB

    MOV D1VAL,A

    MOV A,D1VAL
    ADD A,#30H
    ACALL LCD_DATA

    MOV A,B

    MOV B,#10
    DIV AB

    MOV D2VAL,A

    MOV A,D2VAL
    ADD A,#30H
    ACALL LCD_DATA

    MOV A,B
    ADD A,#30H
    ACALL LCD_DATA

    ACALL DELAY

    LJMP MENU

; =========================================================
; DEPOSIT
; =========================================================

DEPOSIT:

    ACALL LCD_CLEAR

    MOV DPTR,#DEPMSG
    ACALL PRINT

    ACALL GET_3DIGIT

    MOV A,BALANCE
    ADD A,AMOUNT
    MOV BALANCE,A

    ACALL LCD_CLEAR

    MOV DPTR,#SAVEMSG
    ACALL PRINT

    ACALL DELAY

    LJMP MENU

; =========================================================
; WITHDRAW
; =========================================================

WITHDRAW:

    ACALL LCD_CLEAR

    MOV DPTR,#WDMSG
    ACALL PRINT

    ACALL GET_3DIGIT

    MOV A,BALANCE

    CLR C
    SUBB A,AMOUNT

    JC NO_MONEY

    MOV BALANCE,A

    ACALL LCD_CLEAR

    MOV DPTR,#WDOKMSG
    ACALL PRINT

    ACALL DELAY

    LJMP MENU

NO_MONEY:

    ACALL LCD_CLEAR

    MOV DPTR,#NOBALMSG
    ACALL PRINT

    ACALL DELAY

    LJMP MENU

; =========================================================
; GET 3 DIGIT NUMBER
; =========================================================

GET_3DIGIT:

    ACALL WAIT_NO_KEY

G1:
    ACALL GET_KEY
    JZ G1

    MOV D1VAL,A

    ACALL CONFIRM

    MOV A,D1VAL
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

G2:
    ACALL GET_KEY
    JZ G2

    MOV D2VAL,A

    ACALL CONFIRM

    MOV A,D2VAL
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

G3:
    ACALL GET_KEY
    JZ G3

    MOV D3VAL,A

    ACALL CONFIRM

    MOV A,D3VAL
    ACALL LCD_DATA

    MOV A,D1VAL
    CLR C
    SUBB A,#30H

    MOV B,#100
    MUL AB

    MOV TEMP,A

    MOV A,D2VAL
    CLR C
    SUBB A,#30H

    MOV B,#10
    MUL AB

    ADD A,TEMP

    MOV TEMP,A

    MOV A,D3VAL
    CLR C
    SUBB A,#30H

    ADD A,TEMP

    MOV AMOUNT,A

RET

; =========================================================
; GET USER ID
; =========================================================

GET_ID:

    ACALL WAIT_NO_KEY

GID1:
    ACALL GET_KEY
    JZ GID1

    MOV ID1,A

    ACALL CONFIRM

    MOV A,ID1
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

GID2:
    ACALL GET_KEY
    JZ GID2

    MOV ID2,A

    ACALL CONFIRM

    MOV A,ID2
    ACALL LCD_DATA

RET

; =========================================================
; GET PIN
; =========================================================

GET_PIN:

    ACALL WAIT_NO_KEY

GP1:
    ACALL GET_KEY
    JZ GP1

    MOV PIN1,A

    ACALL CONFIRM

    MOV A,#'*'
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

GP2:
    ACALL GET_KEY
    JZ GP2

    MOV PIN2,A

    ACALL CONFIRM

    MOV A,#'*'
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

GP3:
    ACALL GET_KEY
    JZ GP3

    MOV PIN3,A

    ACALL CONFIRM

    MOV A,#'*'
    ACALL LCD_DATA

    ACALL WAIT_NO_KEY

GP4:
    ACALL GET_KEY
    JZ GP4

    MOV PIN4,A

    ACALL CONFIRM

    MOV A,#'*'
    ACALL LCD_DATA

RET

; =========================================================
; WAIT NO KEY
; =========================================================

WAIT_NO_KEY:

    MOV P3,#0FFH

WN:
    JNB P3.4,WN
    JNB P3.5,WN
    JNB P3.6,WN
    JNB P3.7,WN

RET

; =========================================================
; CONFIRM
; =========================================================

CONFIRM:

    ACALL DELAY
    ACALL WAIT_NO_KEY

RET

; =========================================================
; KEYPAD
; =========================================================

GET_KEY:

    MOV P3,#0FFH

    MOV P3,#0FEH
    JNB P3.4,K1
    JNB P3.5,K2
    JNB P3.6,K3
    JNB P3.7,KA

    MOV P3,#0FDH
    JNB P3.4,K4
    JNB P3.5,K5
    JNB P3.6,K6
    JNB P3.7,KB

    MOV P3,#0FBH
    JNB P3.4,K7
    JNB P3.5,K8
    JNB P3.6,K9
    JNB P3.7,KC

    MOV P3,#0F7H
    JNB P3.4,KS
    JNB P3.5,K0
    JNB P3.6,KH
    JNB P3.7,KD

    MOV A,#00H
RET

K1: MOV A,#'1' 
RET
K2: MOV A,#'2' 
RET
K3: MOV A,#'3' 
RET
KA: MOV A,#'A' 
RET
K4: MOV A,#'4' 
RET
K5: MOV A,#'5' 
RET
K6: MOV A,#'6' 
RET
KB: MOV A,#'B' 
RET
K7: MOV A,#'7' 
RET
K8: MOV A,#'8' 
RET
K9: MOV A,#'9' 
RET
KC: MOV A,#'C' 
RET
KS: MOV A,#'*' 
RET
K0: MOV A,#'0' 
RET
KH: MOV A,#'#' 
RET
KD: MOV A,#'D' 
RET

; =========================================================
; LCD
; =========================================================

LCD_INIT:

    MOV A,#38H
    ACALL LCD_CMD

    MOV A,#0CH
    ACALL LCD_CMD

    MOV A,#01H
    ACALL LCD_CMD

    MOV A,#06H
    ACALL LCD_CMD

RET

LCD_CMD:

    MOV P1,A

    CLR RS
    CLR RW

    SETB EN

    ACALL DELAY

    CLR EN

RET

LCD_DATA:

    MOV P1,A

    SETB RS
    CLR RW

    SETB EN

    ACALL DELAY

    CLR EN

RET

LCD_CLEAR:

    MOV A,#01H
    ACALL LCD_CMD

RET

; =========================================================
; PRINT
; =========================================================

PRINT:

    CLR A

PL:
    MOVC A,@A+DPTR

    JZ PDONE

    ACALL LCD_DATA

    INC DPTR

    CLR A

    SJMP PL

PDONE:
RET

; =========================================================
; DELAY
; =========================================================

DELAY:

    MOV R7,#200

D1:
    MOV R6,#255

D2:
    DJNZ R6,D2
    DJNZ R7,D1

RET

; =========================================================
; DATA
; =========================================================

ORG 0300H

MAINMSG:   DB "1:LOG 2:REG",0
REGMSG:    DB "REGISTER",0
IDMSG:     DB "ENTER ID:",0
PINMSG:    DB "ENTER PIN:",0
OKMSG:     DB "LOGIN OK",0
FAILMSG:   DB "LOGIN FAIL",0
MENUMSG:   DB "1B 2D 3W 0E",0
BALMSG:    DB "BAL:",0
DEPMSG:    DB "DEPOSIT:",0
SAVEMSG:   DB "MONEY SAVED",0
WDMSG:     DB "WITHDRAW:",0
WDOKMSG:   DB "TAKE MONEY",0
NOBALMSG:  DB "LOW BALANCE",0
LOCKMSG:   DB "LOCKED ",0
UNLOCKMSG: DB "UNLOCKED",0
DETECTMSG: DB "DETECTING...",0
WELCOME:   DB "WELCOME",0
DONE:      DB "REGISTERED",0

END