; Phase 2 test.                 -*- mode: asm; compile-command: "waa -l phase2.as" -*-
; (c) 2010 duane bailey
; This demonstrates most of instructions and modes needed for phase 2.
; Enjoy :-).

; test 0: check output, and data direct (assume r0 is 0 and conditions are cleared)
zero:   adc	r0,r0,pc    	 
	swi	#SysPutNum
; text 0.5: check char output, and immediate data
	mov	r0,#'\n
	swi	#SysPutChar
; test 1: check immediate data	
one:	mov	r1,#1
	mov	r0,r1
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 2: add instruction
two:	mov	r1,#1
	mov	r2,r1
	add	r0,r1,r2
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 3: lsl immediate, nontrivial
three:	mov	r0,#1
	add	r0,r0,r0,lsl #1
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 4: div instructions, immediate encoding
four:	mov	r1,#4096
	div	r0,r1,#1024
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 5: mul, mvn instructions
five:	mvn	r1,#5		; test of move inverted
	add	r2,r1,#1
	mvn	r3,#0
	mul	r0,r2,r3
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 6: mla instruction
six:	mvn	r1,#4		; r1 has -5
	mvn	r2,#0		; r2 has -1
	mov	r3,#1		; r3 has 1
	mla	r0,r3,r2,r1	; r0 has 6
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 7: shifting instructions
seven:	mov	r1,sp,lsl #12
	mov	r1,r1,asr #12
	mov	r2,#29
	mov	r0,r1,lsr r2
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 8: exercise the registers
eight:	mov	r1,#1
	mvn	r2,#1
	mov	r3,r1,ror #31
	mvn	r4,#2
	mov	r5,#3
	mvn	r6,#3
	mov	r7,#4
	mvn	r8,#4
	mov	r9,#5
	mvn	r10,#5
	mov	r11,#6
	mvn	r12,#6
	add	r0,r1,r2
	add	r0,r0,r3
	add	r0,r0,r4
	add	r0,r0,r5
	add	r0,r0,r6
	add	r0,r1,r7
	add	r0,r0,r8
	add	r0,r0,r9
	add	r0,r0,r10
	add	r0,r0,r11
	add	r0,r0,r12
	mvn	r0,r0
	mov	r0,r0,lsl r5
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
; test 9: Some logic.  Or not.
nine:	mov	r1,sp
	and	r2,r1,#0b1111
	eor	r3,r2,#0b0111
	orr	r0,r3,#1
	swi	#SysPutNum
	mov	r0,#'\n
	swi	#SysPutChar
	mov	r0,#'D
	swi	#SysPutChar
	mov	r0,#'o
	swi	#SysPutChar
	mov	r0,#'n
	swi	#SysPutChar
	mov	r0,#'e
	swi	#SysPutChar
	mov	r0,#'!
	swi	#SysPutChar
	mov	r0,#'\n
	swi	#SysPutChar
heaven:	swi	#SysHalt
