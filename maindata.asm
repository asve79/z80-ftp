wnd_main
	IFDEF WC_PLUGIN
	DB %01000010	;тип
	DB 0		;маска курсора
        DB 5,2		;  X,Y
        DB 70,26	;  W,H
        DB %01111111	;PAPER+INK
        DB 0		; reserver
        DW #0000	;    BUFFER
        DB 0,0		;    LINES
        DB 1		;позиция курсора в окне (от 1)
        DB 1		;нижний ограничитель
        DB 0		;цвет курсора (накладывается по маске из +1(1))
        DB 0		;цвет окна под курсором
	DW wnd_hdr	;+16¦   2¦адрес строки для верхнего заголовка окна (если = 0 то игнорируем)
   	DW 0		;+18¦   2¦адрес строки для нижнего заголовка окна (если = 0 то игнорируем)
   	DW 0 		;+20¦   2¦адрес строки/абзаца для вывода в окно (если = 0 то игнорируем)
	ELSE
	DB 0,0
	DB 32,24
	DB 00001111B
	DB 00000011B
	DB 0,0
	DB 0
	DB 1,'Ftp client v0.1.5',0
	ENDIF

	IFDEF WC_PLUGIN
wnd_hdr	DB #0E,' FTP client v0.1.5 (WC plugin build) ',0
	ENDIF

;wnd_cmd
;	DB 0,21
;	DB 32,3
;	DB 00110010B
;	DB 00000001B
;	DB 0,0
;	DB 0
;	DB 1,'Command:',0

;wnd_status
;	DB 0,21
;	DB 32,3
;	DB 00001111B
;	DB 00000011B
;	DB 0,0
;	DB 0
;	DB 1,'Status',0

msg_keys
        DB '* Socket server version (ic). *',13,13
        IFDEF	WC_PLUGIN
        DB 'Press ESC for exit.',13        
        ELSE
        DB 'Press SS+Q for exit.',13
        ENDIF
	DB '"help" - for command list',13
	DB '----------------------------',13,13,0

msg_help 
	DB 13,13,'Commands:'
        DB 13,'---------'
	DB 13,'open close ls dir mkdir rmdir cd cdup cat'
	IFDEF	WC_PLUGIN
	DB ' get put lls lrm'
	ENDIF
	DB 13
	DB 13,'Keys:'
	DB 13,'-----'
        IFDEF	WC_PLUGIN
	DB 13,'ESC - Exit to TR-DOS'
	ELSE	
	DB 13,'SS+Q - Exit to TR-DOS'
	ENDIF
	DB 13,13,0

msg_about
	DB 13,'About:'
	DB 13,'------'
	DB 13,'Application by asve (asve@ae-nest.com)'
	DB 13,'Window libs by https://github.com/mborisov1'
	DB 13,'Socket libs by https://github.com/HackerVBI'
	DB 13,13,0

inc_addr 	DB 0

msg_error	DB 'Error',13,0
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
msg_connecting 	DB 13,'Connecting...',0
msg_connectclosed DB 13,'Disconnected',13,0
msg_dataerr	DB 'Data stream connection error',13,10,0
msg_loggedin	DB 'User logged in.',0
msg_closedata	DB 'Data chanel closed.',0
msg_opendata	DB 'Data chanel opened.',0
msg_unknown_cmd DB 13,'Unknown command.',13,0
msg_someerror	DB 13,'Some error',13,0
msg_complete	DB 13,'Complete',13,0
msg_warnonly16k DB 13,'WARINIG: Load only first 16k',13,0
msg_specifydirectory
		DB 'Plese specify directory name',0
		IFDEF WC_PLUGIN
msg_createfile_error
		DB 'Error creating file ',0
msg_openfile_error
		DB 'Error opening file ',0
		ENDIF
msg_specifyfilename
		DB 'Plese specify filename',0
msg_username	DB 'Username (anonymous): ',0
msg_password	DB 'Password: ',0

msg_allfine	DB 'All Fine. Good.',0

txt_anonymous	DB 'anonymous',0
txt_zxpass	DB 'zx-spectrum.ftp.client@ae-nest.com',0

		IFDEF WC_PLUGIN
msg_err_rmfile	DB 13,'Error remove file',13,0
		ENDIF

cmd_open  	DB 'open',0
cmd_close 	DB 'close',0
cmd_help  	DB 'help',0
cmd_about 	DB 'about',0
cmd_exit  	DB 'exit',0
cmd_quit	DB 'quit',0
cmd_ls		DB 'ls',0
cmd_dir		DB 'dir',0
cmd_pwd		DB 'pwd',0
cmd_bye		DB 'bye',0
cmd_cd		DB 'cd',0
cmd_cdup	DB 'cdup',0
cmd_mkdir	DB 'mkdir',0
cmd_rmdir	DB 'rmdir',0
cmd_rm		DB 'rm',0
cmd_cat		DM 'cat',0
cmd_size	DM 'size',0
		IFDEF WC_PLUGIN
cmd_get		DB 'get',0
cmd_put		DB 'put',0
cmd_lrm		DB 'lrm',0
cmd_lls		DB 'lls',0
		ENDIF

;ftp command
ftp_cmd_user	DB 'USER ',0
ftp_cmd_pass	DB 'PASS ',0
ftp_cmd_pasv	DB 'PASV',13,10,0
ftp_cmd_list	DB 'LIST',13,10,0
ftp_cmd_cwd	DB 'CWD ',13,10,0
ftp_cmd_cdup	DB 'CDUP',13,10,0
ftp_cmd_retr	DB 'RETR ',0
ftp_cmd_mkd	DB 'MKD   ',0
ftp_cmd_rmd	DB 'RMD   ',0
ftp_cmd_dele	DB 'DELE ',0
ftp_cmd_size	DB 'SIZE ',0
ftp_cmd_stor	DB 'STOR ',0
ftp_cmd_typei	DB 'TYPE I',13,10,0

;local command
;local_cmd_ls	DB '!ls',0
;local_cmd_dir	DB '!dir',0
;local_cmd_cd	DB '!cd',0
;----------------------------- VARIABLES ---------------------
		IFDEF WC_PLUGIN
script_pos	DW 0
		ENDIF
im_cntr		DB 0
term_buf	DB 0
conn_descr	DB 0 ;Connection descriptor
data_descr	DB 0 ;Descroptor for data channel (FTP mode)
ftp_cmd_result_code DB 0;status of last ftp code
user_anonymous	DB 0 ;0 - non anonymous 1 - anonymous
writing_pass	DB 0 ;0 - show input symbols 1 - hide input symbols (show *)
;ID of command REQ
; 1 - USER
; 2 - PASS
; 3 - PASW

;last command id
;0 - none
;1 - connect(ed)
;2 - disconnect(eD)
;3 - username ask
;4 - username enter
;5 - password ask
;6 - password enter
;7 - ls/dir request
;8 - passive mode on request
;9 - service ready for new user
;10 - pwd request
;11 - list command requested.
;12 - 'cd' request
;13 - rmdir request
;14 - mkdir request
;15 - rm <file> request
;16 - cat <file> request
;17 - get <file> request
;18 - size <file> request
;19 - put <file> request

last_command	DB 0

wait_data	DB 0 ;0 - no waitm 1 - wait
ftp_cmd_id	DB 0 

type_ret_code	DB 0	;type code - 5 -erroes, 2-ok 3-data
main_ret_code	DB 0	;main result щзукфешщт code - 

host_addr_len	dw 0
host_addr	dw 0
my_addr		db 0,0,0,0:
my_port		dw 0 ;my ip+port
server_addr	db 93,158,134,3
server_port	dw 21
passive_addr	DB 0,0,0,0
passive_port    DW 0

;buffer for intput. MAX 255 bytes
		IFDEF	WC_PLUGIN
filestruct	DS	5,0	;flag(1),length(4),name(1-255),#00
filename	DS	256,0
		ENDIF
input_bufer	DEFS #FF,0
		DB 13
data_bufer	DEFS #FF,0
		IFDEF	WC_PLUGIN
		DEFS #FF,0	;512b for block i/o
		ENDIF
