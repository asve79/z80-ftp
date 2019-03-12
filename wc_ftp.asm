	DEVICE ZXSPECTRUM128

        DEFINE  WC_PLUGIN 1
;-------

;WLD     EQU #6006
;---------------------------------------
startCode
        ORG     #0000
;WC PLUGIN HEADER:       
        DS 16
        DB "WildCommanderMDL";    Header
        DB #0A;                  Version
        DB 2;                       Type
        DB 2; Pages
        DB 0; Page to #8000
        DB 0,(endCode - startCode) / 512 + 1    ;//page for programm
        DB 1,33 ;//one page for bufer
	DS 2*4
        DS 2*8	;reserved
        DB 'FTP'        ;script extension
        DS 31*3
        DB 0
        DW #6000,#0000; MAX SIZE
        DB "FTP CLIENT      "
        DB "                "
        DB 3
;---------------------------------------
        ALIGN   512
        DISP    #8000
;---------------------------------------
PLUGIN  PUSH    IX
        CALL    main.PROG
        POP     IX
        LD      A,3             ;перечитать каталог после выхода из плагина
        RET
;---------------------------------------
	include "main.asm"
        include "z80-sdk/wc_api/wind.a80"
        include "z80-sdk/wc_api/keys.a80"
        include "z80-sdk/wc_api/mem.a80"
        include "z80-sdk/wc_api/fs.a80"
        include "z80-sdk/math/math.a80"
	ENT
endCode
;---------------------------------------
        SAVEBIN "FTP.WMF", startCode, endCode-startCode