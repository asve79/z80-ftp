	module debug

;IN:
; HL - bufer
; B - length
watch_bufer
	PUSH	AF
	PUSH	DE
	PUSH	HL
	PUSH	BC
	_printw wnd_debug
	POP	BC
	POP	HL
	LD	C,1
wb1	LD	A,C
	CP	1
	JNZ	wb1a
	CALL	wind.HL_HEX
	LD	A,' '
	_printc
wb1a	LD	A,(HL)
	CALL	wind.A_HEX
	LD	A,'('
	_printc
	LD	A,(HL)
	CP	' '
	JP	NC,wb2
	LD	A,'#'
wb2	_printc
	LD	A,')'
	_printc
	LD	A,C
	CP	4
	JZ	wb3
	LD	A,' '	
	JR	wb4    
wb3	LD	A,13
	LD	C,0
wb4	_printc
	INC	C
	INC	HL
	DJNZ	wb1	
wb_e	CALL    spkeyb.CONIN
	_closew
	POP	DE
	POP	AF
	RET

watch_registers
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	(vol_a),A
	LD	(vol_bc),BC
	LD	(vol_de),DE
	LD	(vol_hl),HL
	_printw wnd_debug
	_prints msg_af
	LD	a,(vol_a)
	CALL	wind.A_HEX
	_prints msg_bc
	LD	HL,(vol_bc)
	CALL	wind.HL_HEX
	_prints msg_de
	LD	HL,(vol_de)
	CALL	wind.HL_HEX
	_prints msg_hl
	LD	HL,(vol_hl)
	CALL	wind.HL_HEX
wr_e	CALL    spkeyb.CONIN
	_closew
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	ret

wnd_debug
        DB 4,2
        DB 24,18
        DB 00001111B
        DB 00000001B
        DB 0,0
        DB 0
        DB 1,'Debug',0

msg_af	DB 13,'AF ',0
msg_bc	DB 13,'BC ',0
msg_de  DB 13,'DE ',0
msg_hl  DB 13,'HL ',0

vol_a	DB 0
vol_bc	DW 0
vol_de  DW 0
vol_hl  DW 0
	endmodule
