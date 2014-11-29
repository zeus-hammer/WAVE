;;; CCR bits and PC lopping.    -*- mode:asm; compile-command: "waa pc-ccr.as"
;;; (c) 2010 duane a. bailey
	;; test 0
zero:	movs	r0,#1  		; ccr: nzcv
	stm	sp,#0x8000	; save ccr+pc to stack top
	ldm	sp,#0x0001	; grap ccr+pc
	mov	r0,r0,lsr #28	; just ccr
	swi	#SysPutNum	; write 0
	;; test 1
	cmp	r0,#0		; ccr: nZcv
	;;  finish test 0
	mov	r0,#'\n
	swi	#SysPutChar
	;;  continue test 1
one:	stm	sp,#0x8000	; save ccr+pc to stack top
	ldm	sp,#0x0001	; grap ccr+pc
	mov	r0,r0,lsr #30	; just ccr
	swi	#SysPutNum	; write 1
	mov	r0,#'\n
	swi	#SysPutChar
	;; test 2
two:	movs	r1,#0		; ccr: nZcv
	mvns	r0,r1		; ccr: Nzcv
	stm	sp,#0x8000	; save ccr+pc to stack top
	ldm	sp,#0x0001	; grap ccr+pc
	mov	r0,r0,lsr #30	; just ccr
	swi	#SysPutNum	; write 2
	mov	r0,#'\n
	swi	#SysPutChar
three:	mov	r1,#2
	cmp	r1,#1		; ccr: nzCv
	adc	r0,r1,#0
	swi	#SysPutNum	; write 3
	mov	r0,#'\n
	swi	#SysPutChar
four:	mvn	r1,#0x80000000	; wow, that's small
	adds	r0,r1,#1	; ccr: NzcV
	stm	sp,#0x8000	; save ccr+pc to stack top
	ldm	sp,#0x0001	; grap ccr+pc
	mov	r0,r0,lsr #26	; just ccr
	and	r0,r0,#4	; just V
	swi	#SysPutNum	; write 4
	mov	r0,#'\n
	swi	#SysPutChar
five:	mov	r0,#5
	add	pc,pc,#2
	b	_x
	b	_y
	b	_z
_x:	mov	r0,#'!
	b	_common
_y:	mov	r0,#'5
	b	_common
_z:	mov	r0,#'?
_common: swi	#SysPutChar
	mov	r0,#'\n
	swi	#SysPutChar
six:	mov	r0,#2
	add	r0,r0,#0xdb000000
	add	pc,pc,r0
	b	_woops
	mov	r0,#6
	swi	#SysPutNum
_woops:	
_fini:	
	swi	#SysHalt
	
	