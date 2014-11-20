;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan

 	.requ	wpc,r11
	.requ	cur_inst, r1
	mov	$0,wpc
	mov	$1000,r0
	trap	$SysOverlay

	.equ	a1, -4
	.equ	a2, -8
	.equ	a3, -12
	.equ	a4, -16
	.equ	v1, -20
	.equ	v2, -24
	.equ	v3, -28
	.equ	v4, -32
	.equ	v5, -36
	.equ	v6, -40
	.equ	v7, -44
	.equ	v8, -48
	.equ	v9, -52
	

	push 	rbp
	mov	rsp, rbp
	sub	rsp,$64
	
	mov	1000(wpc), r0
	mov	r0, cur_instr
	sar	r0, $26
	be	arith

arith:	mov	$15, r2
	sal	r2, $22
	cmp	r2,r1
	be	add

add:	mov	cur_instr, r0
	sar	r0, $14
	mov	r0, r3		;src register
	mov	cur_instr, r0
	sar 	r0, $18
	mov	r0, r4		;dest register
	
	
	