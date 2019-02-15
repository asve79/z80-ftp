	DEVICE ZXSPECTRUM128

        DEFINE  WC_PLUGIN 1
;-------
WLD     EQU #6006
;---------------------------------------
startCode
        ORG #0000
;WC PLUGIN HEADER:       
        DS 16
        DB "WildCommanderMDL";    Header
        DB #02;                  Version
        DB 0;                       Type
        DB 1; Pages
        DB 0; Page to #8000
;-------
        DB 0,1; CODE
	DS 2*5
;-------
        DS 2*8	;reserved
;-------
        DS 32*3
;-------
        DB 0
;-------
        DW #6000,#0000; MAX SIZE
;-------
        DB "FTP CLIENT      "
        DB "                "
;-------
        DB 3
;---------------------------------------
        ALIGN   512
        DISP    #8000
;-------
LOBU    EQU     #A000
;---------------------------------------
PLUGIN  PUSH    IX
        LD      (DAHL),HL,(DADE),DE

        LD      IX,PLWND        
        CALL PRWOW

        LD      HL,TXT0
        LD      DE,#000B
        LD      BC,12
        CALL    PRSRW
        LD      A,%11110111
        CALL PRIAT

MAIN    EI
        HALT
        CALL    ESC
        JR      Z,MAIN

        LD      IX,PLWND
        CALL    RRESB
        LD      A,(ESTAT)
        POP     IX
        RET
;---------------------------------------
PRWOW   LD      A,1:JP WLD
RRESB   LD      A,2:JP WLD
PRSRW   LD      A,3:JP WLD
PRIAT   EXA
        LD A,4
        JP WLD
;-------
ESC     LD A,23
        JP WLD
;---------------------------------------
PLWND   DB 0,0
        DB 5,5;     X,Y
        DB 32+2,26;  W,H
        DB %01111111;PAPER+INK
        DB 0
        DW #0000;    BUFFER
        DB 0,0;      LINES
;-------
TXT0    DB "FTP CLIENT"
;---------------------------------------
DAHL    DS 2
DADE    DS 2

ESTAT   NOP
        include "main.asm"        
endCode
;---------------------------------------
        SAVEBIN "FTP.WMF", startCode, endCode-startCode