	module main

	include "main.mac"
	include "z80-sdk/strings/strings.mac"

 	IFDEF	WC_PLUGIN
	 include "z80-sdk/common/common.mac"
         include "z80-sdk/wc_api/wind.mac"
         include "z80-sdk/wc_api/keys.mac"
        ELSE 
	 include "z80-sdk/windows_bmw/wind.mac"
 	 include "debug.mac"
	ENDIF

	include "z80-sdk/sockets/sockets.mac"

;- MAIN PROCEDURE -
PROG	DI
	CALL	init
	IFDEF	WC_PLUGIN
	_init_txtmode
	ENDIF
	_printw wnd_main
	_prints	msg_keys
	IFDEF	WC_PLUGIN
	_waitkeyoff
	ENDIF
	_cur_on

mloop   
	IFDEF	WC_PLUGIN
	EI:HALT
	;_waitkey
	_is_escape_key
	JNZ	exit
	_is_enter_key
	JNZ	enterkeytermmode
	_is_backspace_key
	JNZ	delsymtermmode
	_getkey
	JR	NZ, ml1
	JR	mloop
	ELSE
	CALL    spkeyb.CONINW	;main loop entry
	JRZ	mloop		;wait a press key
	CP	01Dh
	JZ	exit		;if SS+Q pressed, exit
	CP	#08		;left cursor key pressed
	JZ	mloop
	CP	#19		;right cursor key pressed
	JZ	mloop
	CP	#1A		;up cursor key pressed
	JZ	mloop
	CP	#18		;down cursor key pressed
	JZ	mloop
	CP	#7F		;//delete key pressed
	JZ	delsymtermmode	
	CP	13		;//enter key pressed
	JZ	enterkeytermmode
	ENDIF
ml1	CALL	puttotermbufer	;//put char to command bufer and print
	JP	mloop

puttotermbufer	;put symbol to terminal bufer
	PUSH 	AF
	_findzero input_bufer
puttobufer	;main procedure for put to bufer;TODO make insert mode with shift content
	POP	AF
	LD	(HL),A
	LD	A,(writing_pass)
	OR	A
	JR	Z,ptcb2
	LD	A,'*'		;//if writing password mode, hide symbols
	JR	ptcb3
ptcb2	LD	A,(HL)
ptcb3	_printc		;out character
	RET

delsymtermmode	;delete symbol in terminal mode
	_findzero input_bufer	;//get ptr on last symbol+1 in buffer
	OR	A
	JZ	mloop		;//if nothing in bufer (length=0)
	DEC	HL
	XOR	A
	LD	(HL),A		;//erase symbol
	LD	A,8		;/cusor to left
	_printc
	LD	A,' '		;//space
	_printc
	LD	A,8		;//left again
	_printc
	JP	mloop

enterkeytermmode	;enter key pressed in terminal window
	_cur_off
	_isopencommand  ekcm_nc		;//'open'  command
	_isclosecommand ekcm_nc 	;//'close' command
	_ishelpcommand  ekcm_nc		;//'help' command
	_isaboutcommand ekcm_nc		;//'about' command
	_isexitcommand	ekcm_nc		;//'about' command
	_ifenterusername ekcm_nc	;//if enter username
	_ifenterpassword ekcm_nc	;//if enter password
	_ifenterdir	ekcm_nc		;//if enter dir command
	_ifenterls	ekcm_nc		;//if enter ls commend
	_ifenterquit	ekcm_nc		;//if enter quit command
	_ifenterclose	ekcm_nc		;//if enter close command
	_ifenterbye	ekcm_nc		;//if enter bye command
;	_ifenterget	ekcm_nc		;//if enter get <file> command
;	_ifenterput	ekcm_nc		;//if enter put <file> command
	_ifenterpwd	ekcm_nc		;//if enter pwd command
	_ifentercdup	ekcm_nc		;//if enter cdup command
	_ifentercd	ekcm_nc		;//if enter cd <directory> command
	_ifentercat	ekcm_nc		;//if enter cat <file> command
	_ifenterrmdir	ekcm_nc		;//if enter rmdir <directory> command
	_ifentermkdir	ekcm_nc		;//if enter mkdir <directory> command
	_ifenterrm	ekcm_nc		;//if neter rm <file> command
;	LD	A,13
;	_printc
	_cur_off
	_prints msg_unknown_cmd
ekcm_nc	_fillzero input_bufer,#FF
;	LD	A,13
;	_printc
	_cur_on
	JP	mloop
;---------------------------
;- routines -
;- exit. close all connections -
exit	_cur_off
	CALL	close_connection
	_closew
	RET
	;JP	eof_module

;- init descriptors whe programs start
init	LD	A,#FF
	LD	(conn_descr),A
	LD	(data_descr),A
	RET

;- inctease counter every interrupt
INCCNTR LD	A,(im_cntr)
	INC	A
	LD	(im_cntr),A
	RET

;-get data from datastream
;OUT: 
;  A: Status. 0 - ok; >0 - error
; BC: length of receved data (#FF max at this time) 
get_data
;	LD	A,'$'	;//for debugging
;	_printc
	LD	A,(data_descr)
	CP	#FF		;//check descriptor. FF - bad
	RET	Z
chd1	recv	data_descr,data_bufer,255
	OR	A
	RET	Z
	CALL	close_data_connection
	RET

;- sleep some ticks. used as data request interval
cangetdata
	LD	A,(im_cntr)
	AND	#F0
	RET	Z		;skip N tick's
	XOR	A
	LD	(im_cntr),A
	RET

;- RECEVE MAIN -----------------------------------------------------------------------------
;receve main stream and print chars
get_rcv	;//check receve info from main connection
;	LD	A,'$'	;//for debugging
;	_printc
	LD	A,(conn_descr)
	CP	#FF		;//check descriptor. FF - bad
	RET	Z
rcv1	recv	conn_descr,data_bufer,#FF
	OR	A
	RET	Z
	CALL	close_connection
	RET

close_connection	;routine for close active connection
	LD	A,(conn_descr) ;//main connection descriptor
	CP	#FF	;//check descriptor
	JZ	close_data_connection
	CALL	sockets.close
	LD	A,#FF
	LD	(conn_descr),A
	LD	(wait_data),A
	LD	A,2
	LD	(last_command),A	;//2 - disconnect(ed)
	_prints msg_connectclosed
close_data_connection		;//entrypoint for close data connection
	LD	A,(data_descr)	;//data descriptor
	CP	#FF		;//check descriptor
	JZ	cc_cl
	CALL	sockets.close
	LD	A,#FF
	LD	(data_descr),A
cc_cl
	RET

;//parce reveve buffer for commands (per one line)
;//IN:
;// HL - bufer
;//OUT:
;// D = first code Xxx
;// E = main code xXX
;// A = 0 if nothing more to parse
;// A = 1 if OK
;// A > 1 if no code in this line
parse_rcv_code
	PUSH	HL
;	LD	HL,recv_bufer
	LD	A,(HL)
	OR	A
	JZ	parr_ex
	LD	A,(HL)
	sub	'0'
	LD	B,A
	INC	HL
	LD	A,2		;//analyse string for code
	PUSH 	BC
	CALL	strings.texttonum_c
	POP	BC
	INC	A		;//A=A+1. If a=1 then OK, else A>1
	PUSH	AF
;	CALL	wind.A_HEX	;//debug
	LD	A,B
	LD	D,A
	POP	AF
parr_ex	POP	HL
	RET	

;PARCE RETURN CODE IN data_bufer
;OUT:
; DE - code
;  A - 0 it nothing to rarce
proc_status
	LD	HL,data_bufer
pstat_l	LD	A,(HL)
	OR	A
	RET	Z
	CALL	parse_rcv_code
	RET

;Send command to conn_descr
;IN:
; input_bufer - command
;OUT:
; data_bufer - responce OR conn_descr=#FF if error
send_command
        _findzero input_bufer
	LD      C,A
	LD      A,13            ;/add 13 code for <CR><LF> EOL command
	LD      (HL),A
	INC     HL
        LD      A,10            ;/add 10 code for <CR><LF> EOL command
        LD      (HL),A
        INC     C
        LD      B,0
        INC     BC
        LD      A,(conn_descr)
        LD      HL,input_bufer
        CALL    sockets.send    ;//send buffer content
        OR      A
        JZ      sco_ok
sco_err 
	CALL	close_connection
        _cur_on
        JP      sco_nc
sco_ok	_fillzero data_bufer,#FF
sco_ok1	CALL	get_rcv		;//receve responce data
	LD	A,(conn_descr)	
	CP	#FF
	JZ	sco_err		;//if connection lost
	LD	A,C
	OR	A
	JZ	sco_ok1		;//wait if no data receved
sco_nc	_fillzero input_bufer,255
        RET

;doned	DB	"done. press a key",0

;Print CRLF, send command and print result
;IN:
; A - last command code
sendandprint
	LD	(last_command),A
	_cur_off
	LD	A,13
	_printc
	CALL	send_command
	_prints	data_bufer
	_cur_on
	RET

;Check receve bufer for message and print it if needed
recevelast
        recv  	conn_descr,data_bufer,#FF
        OR      A
        JNZ     close_connection
	LD	A,C
	OR	A
	RET	Z
	LD	B,A
	LD	HL,data_bufer
rel_l1	LD	A,(HL)
	_printc
	INC	HL
	DJNZ	rel_l1
	JR	recevelast

;Entered to passive mode. open data session
setpassivemode
        LD      A,(conn_descr)
        LD      HL,ftp_cmd_pasv
	LD	BC,6
        CALL    sockets.send    ;//send buffer content
	OR	A
	JZ	spmo_s1		;/if error
	JP	close_connection
;	RET
spmo_s1	CALL	get_rcv		;//receve responce data
	LD	A,(conn_descr)
	CP	#FF
	JZ	spmo_err	;//if connection lost
	LD	A,C
	OR	A
	JZ	spmo_s1		;//wait if no data receved
	CALL	proc_status
	LD	A,D
	CP	2
	RET	NZ
	LD	A,E
	CP	27
	RET	NZ
	LD	HL,data_bufer
spmo_s2 LD	A,(HL)
	OR	A
	RET	Z
	CP	13
	RET	Z
	INC	HL
	CP	'('
	JNZ	spmo_s2
	PUSH	HL
	CALL	strings.texttonum_n
	LD	A,E
	LD	(passive_addr),A
	POP	HL
	CALL	strings.ptrtonextvol
	PUSH	HL
	CALL	strings.texttonum_n
	POP	HL
	LD	A,E
	LD	(passive_addr+1),A
	CALL	strings.ptrtonextvol
	PUSH	HL
	CALL	strings.texttonum_n
	LD	A,E
	LD	(passive_addr+2),A
	POP	HL
	CALL	strings.ptrtonextvol
	PUSH	HL
	CALL	strings.texttonum_n
	LD	A,E
	LD	(passive_addr+3),A
	POP	HL
	CALL	strings.ptrtonextvol
	PUSH	HL
	CALL	strings.texttonum_n
	LD	A,E
	LD	(passive_port+1),A
	POP	HL
	CALL	strings.ptrtonextvol
	CALL	strings.texttonum_n
	LD	A,E
	LD	(passive_port),A

;	_printw wnd_status
	LD	A,13
	_printc
	LD	A,(passive_addr)
	_a_hex
	LD	A,','
	_printc
	LD	A,(passive_addr+1)
	_a_hex
	LD	A,','
	_printc
	LD	A,(passive_addr+2)
	_a_hex
	LD	A,','
	_printc
	LD	A,(passive_addr+3)
	_a_hex
	LD	A,':'
	_printc
	LD	HL,(passive_port)
	_hl_hex

	;create socket			;//create socket
	socket 	AF_INET,SOCK_STREAM,0
	cp 	#FF
	JZ	spmo_err
	LD 	(data_descr),a

;	LD	a,13	;//debug
;	_printc
;	LD	a,'*'
;	_printc
;	LD	A,(data_descr)
;	call	wind.A_HEX

	;bind my socket
	bind 	data_descr,my_addr		;//bind to address ????
	or 	a
	JNZ	spmo_err

        ;connect to host
	connect data_descr,passive_addr	;//create connection
	or 	a
	JNZ	spmo_err
;	_closew
	LD	A,13
	_printc
	_prints msg_opendata
	LD	A,13
	_printc
	RET
spmo_err
;	_closew
	LD	a,13
	_printc
	_prints msg_dataerr
	RET

	include "maindata.asm"
	include "z80-sdk/sockets/sockets.a80"
	include "z80-sdk/strings/strings.a80"

	IFNDEF	WC_PLUGIN
 	 include "debug.asm"
	ENDIF

eof_module

	endmodule
