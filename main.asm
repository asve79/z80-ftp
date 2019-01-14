	module main

	include "main.mac"
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

mloop   CALL	cangetdata
	JR	NZ,mloop_s
	CALL	check_rcv
	CALL	proc_status
	CALL	check_data
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
	_findzero inp_bufer
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
	LD	A,'E'		;//error status TODO: close connection
	_printc
	_closew
	_cur_on
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
	_printc		;out character
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

check_data
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
	CALL	close_connection
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
check_rcv	;//check receve info from main connection
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
	CP	13	;//check for CR
	JNZ	rcv2
	PUSH	HL
;	LD	A,"-"	;// debug
;	_printc
	LD	HL, rcv_bufer
	LD	A,3
	CALL	strings.texttonum_c
	LD	A,E
	LD	(ftp_cmd_result_code),A
	CALL	wind.A_HEX
	LD	A,13
	_printc
	POP	HL	
;	JR	rcv2	;//!!!!!!!!!!!!!!!!!!!!!!!!NOW WE CHECK ONLY FIRST STATUS
rcv4	_cur_on
	RET

close_connection	;routine for close active connection
	LD	A,(conn_descr)
	CP	#FF	;//check descriptor
	RET	Z
	CALL	sockets.close
	LD	A,#FF
	LD	(conn_descr),A
	XOR	A
	LD	(connected),A
	_prints msg_connectclosed
	RET

proc_status
	LD	A,(ftp_cmd_result_code)
	OR	A
	RET	Z	
	_printw wnd_status	;//if error, close connection
	CALL	wind.A_HEX
	_closew
	_isstatus230
	_isstatus227
	XOR 	A
	LD	(ftp_cmd_result_code),A
	RET

wnd_main
	DB 0,0
	DB 32,22
	DB 00001111B
	DB 00000011B
	DB 0,0
	DB 0
	DB 1,'Ftp client v0.0.1',0

wnd_cmd
	DB 0,21
	DB 32,3
	DB 00110010B
	DB 00000001B
	DB 0,0
	DB 0
	DB 1,'Command:',0

wnd_status
	DB 0,21
	DB 32,3
	DB 00001111B
	DB 00000011B
	DB 0,0
	DB 0
	DB 1,'Status',0

msg_keys
        DB 'Socket server version (ic).',13
        DB 'Press SS+Q for exit.',13
        DB 'Press SS+W for commands.',13
	DB 'For help press SS+W + type "help"',13
	DB '---------------------------------',13,13,0

msg_help 
	DB 13,'Commands:'
        DB 13,'---------'
	DB 13,'open hostname port - Open connection to host:port'
	DB 13,'close - Close current connection'
	DB 13,'help  - this help message'
	DB 13,'about - about appication'
	DB 13,'exit  - quit appication',13
	DB 13,'Keys'
	DB 13,'----'
	DB 13,'RShift+Q - Exit'
	DB 13,'RShift+W - Enter command'
	DB 13,13,0

msg_about
	DB 13,'About:'
	DB 13,'------'
	DB 13,'Application by asve (asve@ae-nest.com)'
	DB 13,'Window libs by https://github.com/mborisov1'
	DB 13,'Socket libs by https://github.com/HackerVBI'
	DB 13,13,0

inc_addr 	DB 0

msg_status 	DB 31,'Remote: ',13,0
msg_datastream  DB 'Data stream '
msg_connected 	DB 'connected',0
msg_disconnected DB 'disconnected',0
msg_closeok 	DB 'closed',0
msg_closeerr 	DB 13,'close error',13,0
msg_openerr 	DB 13,'open connection error',13,0
msg_openok  	DB 13,'Connected successfuly',13,0
msg_alredyopen 	DB 13,'Have active connection. Close current first!',13,0
msg_fdproblem 	DB 13,'Connection descriptor problem',13,0
msg_connecting 	DB 'Connecting...',0
msg_connectclosed DB 13,'Disconnected',13,0
msg_dataerr	DB 'Data stream connection error',13,10,0

cmd_open  	DB 'open',0
cmd_close 	DB 'close',0
cmd_help  	DB 'help',0
cmd_about 	DB 'about',0
cmd_exit  	DB 'exit',0

;ftp command
ftp_cmd_user	DB 'user',0
ftp_cmd_pass	DB 'pass',0
ftp_cmd_pasv	DB 'PASV',13,10,0
ftp_cmd_ls	DB 'ls',0
ftp_cmd_get	DB 'get',0
ftp_cmd_put	DB 'put',0

;local command
local_cmd_ls	DB '!ls',0
local_cmd_dir	DB '!dir',0
local_cmd_cd	DB '!cd',0
;----------------------------- VARIABLES ---------------------
im_cntr		DB 0
term_buf	DB 0
conn_descr	DB 0 ;Connection descriptor
data_descr	DB 0 ;Descroptor for data channel (FTP mode)
ftp_cmd_result_code DB 0;status of last ftp code
;ID of command REQ
; 1 - USER
; 2 - PASS
; 3 - PASW
ftp_cmd_id	DB 0 
;connection status
connected	DB 0; 0 - not connected 1 - connected
;terminal command flag
termcmd	DB	0 ;0 - not terminal command 1 - terminal command
;buffer for intput. MAX 255 bytes
cmd_bufer	DEFS 100,0
inp_bufer	DEFS 256,0
rcv_bufer	DEFS 255,0
data_bufer	DEFS 255,0

host_addr_len	dw 0
host_addr	dw 0
my_addr		db 0,0,0,0:
my_port		dw 0 ;my ip+port
server_addr	db 93,158,134,3
server_port	dw 21
passive_addr	DB 0,0,0,0
passive_port    DW 0

	include "z80-sdk/sockets/sockets.a80"
	include "z80-sdk/strings/strings.a80"

	endmodule