	module main

	include "main.mac"
	include "debug.mac"
	include "z80-sdk/strings/strings.mac"
	include "z80-sdk/windows_bmw/wind.mac"
	include "z80-sdk/sockets/sockets.mac"

;- MAIN PROCEDURE -
PROG	
	CALL	init
	_printw wnd_main
	_prints	msg_keys
	CALL	showstatus
	_cur_on

mloop   LD	A,(wait_data)	
	OR	A
	JR	Z,mloop_s	;if we no wait responce to command or receve any data
	CALL	cangetdata
	JR	NZ,mloop_s
	CALL	get_rcv		;get data from main stream
	CALL	proc_status	;analyse incoming data from status commands
	CALL	get_data	;get data from data stream
mloop_s	CALL    spkeyb.CONINW	;main loop entry
	JZ	mloop		;wait a press key
	PUSH 	AF
	_iscmdmode		;if comman mode on go to cmdmodeproc
	JZ	cmdmodeproc
	;process terminal mode
	POP	AF
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
	CP	01Ch		;if Ss+W pressed - terminal command
	JZ	opencmdmode	
	CP	#7F		;//delete key pressed
	JZ	delsymtermmode	
	CP	13		;//enter key pressed
	JZ	enterkeytermmode
	CALL	puttotermbufer	;//put char to command bufer and print
	JP	mloop
cmdmodeproc ;process command mode
	POP	AF
	CP	#08		;left cursor key pressed
	JZ	mloop
	CP	#19		;right cursor key pressed
	JZ	mloop
	CP	#1A		;up cursor key pressed
	JZ	mloop
	CP	#18		;down cursor key pressed
	JZ	mloop
	CP	01Dh
	JZ	closecmdmode	;if SS+Q pressed, exit
	CP	01Ch		;if Ss+W pressed - terminal command
	JZ	closecmdmode
	CP	#7F		;//delete key pressed
	JZ	delsymcmdmode	
	CP	13		;//enter key pressed
	JZ	enterkeycmdmode
	CALL	puttocmdbufer	;//put char to terminal bufer and print
	JP	mloop

opencmdmode ;open command window
	LD	A,1		;if terminal command mode is off
	LD	(termcmd),A	;turn on termianl mode
	_cur_off
	_printw	wnd_cmd		;print command window
	_prints	cmd_bufer	;print content of command buffer
	_cur_on
	JP	mloop
;----
closecmdmode ;close the commend window
	XOR	A
	LD	(termcmd),A
	_cur_off		
	_endw
	_cur_on
	JP	mloop
;-----
delsymcmdmode	;delete symbol in command bufer
	_findzero cmd_bufer	;//get ptr on last symbol+1 in buffer
	JR	delsymproc	;//get ptr on last symbol+1 in buffer
delsymtermmode	;delete symbol in terminal mode
	_findzero inp_bufer	;//get ptr on last symbol+1 in buffer
delsymproc	;delete symbol main proc
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
;----
enterkeycmdmode	;enter key pressed in command window. execute command if it exists
	_isopencommand  cmd_bufer,eccm1	;//'open'  command
	_isclosecommand cmd_bufer,eccm1 ;//'close' command
	_ishelpcommand  cmd_bufer,eccm1	;//'help' command
	_isaboutcommand cmd_bufer,eccm1	;//'about' command
	_isexitcommand cmd_bufer,eccm1	;//'about' command
	_clearwindow			;// wrong command:  clear window
eccm1	_fillzero cmd_bufer, 100	;clear command buffer
	JP 	mloop
;----
enterkeytermmode	;enter key pressed in terminal window
	_isconnected
	JNZ	ekcm_nc		;//if not connected
	_ifenterusername ekcm_cr	;//if enter username
	_ifenterpassword ekcm_cr	;//if enter password
	_ifenterdir	 ekcm_cr	;//if enter dir command
	_ifenterls	 ekcm_cr	;//if enter ls commend
	_ifenterquit	 ekcm_cr	;//if enter quit command
	_ifenterclose	 ekcm_cr	;//if enter close command
	_ifenterbye	 ekcm_cr	;//if enter bye command
;	_ifenterget	 ekcm_cr	;//if enter get command
;	_ifenterput	 ekcm_cr	;//if enter put command
	_ifenterpwd	 ekcm_cr	;//if enter pwd command
	_ifentercd	 ekcm_cr	;//if enter cd command	
	LD	A,13
	_printc
	_prints msg_unknown_cmd
	JP	ekcm_nc
ekcm_cr	
	_findzero inp_bufer	;//find EOL
	LD	C,A
	LD	A,13		;/add 13 code for <CR><LF> EOL command
	LD	(HL),A
	INC	HL
	LD	A,10		;/add 10 code for <CR><LF> EOL command
	LD	(HL),A
	INC	C
	LD	B,0
	INC	BC
ekcm_snd
	XOR	A		;//reset last status code for we can undestand what new commend arrived
	LD	(ftp_cmd_result_code),A
	LD	A,(conn_descr)
	LD	HL,inp_bufer
	CALL	sockets.send	;//send buffer content
	OR	A
	JZ	ekcm_ok
	_printw wnd_status	;//if error while send data
	LD	A,'E'		
	_printc
	_closew
	_cur_on
	CALL	close_connection
	JP	ekcm_nc
ekcm_ok	_printw wnd_status	;//success status
	LD	A,'#'
	_printc
	_closew
	_cur_on
ekcm_nc	_fillzero inp_bufer,255
	LD	A,13
	_printc
	JP	mloop
;---------------------------
;- routine -
puttocmdbufer	;put symbol in command bufer
	PUSH	AF
	_findzero cmd_bufer
	JR	puttobufer
puttotermbufer	;put symbol to terminal bufer
	PUSH 	AF
	_findzero inp_bufer
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

exit	_cur_off		;TOOD: close connection if needed
	_closew
        LD      HL,conn_descr
        LD      A,(HL)
        CP      0FFh
        RET	Z                     ;if descriptor is bad
	CALL	sockets.close
	RET

fillzero
	_fillzero cmd_bufer, 100
	RET

init	LD HL,connected
	LD (HL),0
	LD HL,termcmd
	LD (HL),0
	LD HL,conn_descr
	LD (HL),#FF
	RET

showstatus
	_printw wnd_status
;	_prints msg_status
	_isconnected
	JNZ	sstat1
	LD	A,'*'
	_printc
;	_prints msg_connected
	JR	sstat_e
sstat1	;_prints msg_disconnected
	LD	A,'x'
	_printc
sstat_e	
;	LD	A,(inc_addr)	;//for debug
;	INC	A
;	LD	(inc_addr),A
;	CALL	wind.A_HEX
	_closew
	RET

;/ inctease counter every interrupt
INCCNTR LD	A,(im_cntr)
	INC	A
	LD	(im_cntr),A
	RET

get_data
;	LD	A,'$'	;//for debugging
;	_printc
	LD	A,(connected)
	OR	A
	RET	Z		;//if not connected
	LD	A,(data_descr)
	CP	#FF		;//check descriptor. FF - bad
	RET	Z
chd1	recv	data_descr,data_bufer,255
	LD	HL,data_bufer
	OR	A
	JZ	chd5
	_printw wnd_status	;//if error, close connection
	LD	A,'!'
	_printc
	_closew
	CALL	close_data_connection
	JR	chd4
chd5	_cur_off
chd2	LD	A,B	;//----------- get info from bufer ------------
	OR	A
	JNZ	chd3
	LD	A,C
	OR	A
	JR	Z,chd4	;//if BC=0 (receve 0 bytes); TODO: check is if 1st 0 bytes, then exit. if it end of block then get new block
chd3	LD	A,(HL)
	_printc		;//print char
	INC	HL
	DEC	BC
	JP	chd2
chd4	_cur_on
	RET

	RET

cangetdata
	LD	A,(im_cntr)
	AND	#F0
	RET	Z		;skip N tick's
	XOR	A
	LD	(im_cntr),A
	LD	A,(termcmd)
	OR	A
	RET

;- RECEVE MAIN -----------------------------------------------------------------------------
get_rcv	;//check receve info from main connection
;	LD	A,'$'	;//for debugging
;	_printc
	LD	A,(connected)
	OR	A
	RET	Z		;//if not connected
	LD	A,(conn_descr)
	CP	#FF		;//check descriptor. FF - bad
	RET	Z
rcv1	recv	conn_descr,rcv_bufer,255
	LD	HL,rcv_bufer
	OR	A
	JZ	rcv5
	_printw wnd_status	;//if error, close connection
	LD	A,'!'
	_printc
	_closew
	CALL	close_connection
	JR	rcv4
rcv5	_cur_off
rcv2	LD	A,B	;//----------- get info from bufer ------------
	OR	A
	JNZ	rcv3
	LD	A,C
	OR	A
	JR	Z,rcv4	;//if BC=0 (receve 0 bytes); TODO: check is if 1st 0 bytes, then exit. if it end of block then get new block
rcv3	LD	A,(HL)
	_printc		;//print char
	INC	HL
	DEC	BC
	JP	rcv2	;//-Пока уберем анализ входящих строк-
rcv4	_cur_on
	RET

close_connection	;routine for close active connection
	LD	A,(conn_descr) ;//main connection descriptor
	CP	#FF	;//check descriptor
	JZ	close_data_connection
	CALL	sockets.close
	LD	A,#FF
	LD	(conn_descr),A
	XOR	A
	LD	(connected),A
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

proc_status
;	LD	A,'>'		;//debug
;	_printc
	LD	HL,rcv_bufer
pstat_l	LD	A,(HL)
	OR	A
	JZ	pstat_k		;//if no data
;	_printc			;//debug
	CALL	parse_rcv_code
	OR	A
	JZ	pstat_k		;//if nothing to parce
	LD	A,E
	PUSH	DE
	PUSH	HL
	_printw wnd_status	;//if error, close connection
	CALL	wind.A_HEX
	_closew
	POP	HL
	POP	DE
	_isstatus220 pstat_e	;//service ready for new user (after connect). turn on login mode
	_isstatus331 pstat_e	;//after USER command. turn on passord mode
	_isstatus230 pstat_e	;//afrer PASS command. just print "seccion open"
	_isstatus227 pstat_e	;//after PASV command. open data connection.
	_isstatus226 pstat_e	;//data chanel is closed. exchange ended
pstat_e	CALL	strings.ptrtonextline
	JZ	pstat_l
pstat_k	XOR	A
	LD	(rcv_bufer),A
	RET

	include "maindata.asm"
	include "z80-sdk/sockets/sockets.a80"
	include "z80-sdk/strings/strings.a80"
	include "debug.asm"

	endmodule