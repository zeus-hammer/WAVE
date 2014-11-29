;;; A little program to print fortunes. -*- mode: asm -*-
;;; (c) 2010 duane a. bailey
;;; Fortunes are presented on the input, one per line.
;;; Your final fortune is written to the output.
;;; Each has equal probability of being selected.
	b	main
;;; input area
	.equ	fortuneSize,81
fortune:.bss	fortuneSize	; final fortune
main:
	mov	r3,#0		; number of fortunes read
read:	adr	r0,buffer
	bl	gets		; read a fortune
	ldrs	r1,[r0]		; check character read.  -1?
	blt	done
	add	r3,r3,#1	; one more fortune
	;; should we copy it?  if random, mod r3 is zero, yes.
	swis	#SysEntropy
	mvnlt	r0,r0		; absolute value
	div	r1,r0,r3
	mul	r1,r1,r3	; r1 is a multiple of r3
	subs	r0,r0,r1	; r0 mod r3
	bne	read
	adr	r1,buffer
	adr	r0,fortune
	mov	r2,#fortuneSize	; reserved area size
	bl	strncpy		; copy buffer into fortune
	b	read
done:	adr	r0,fortune	; print your fortune
	bl	puts
	swi	#SysHalt

;;; one line of input (nl kept) read to area pointed to by r0
;;; EOF marked by -1
gets:	stu	r0,[sp,#-1]	; to be restored at the end
	mov	r1,r0
_loop:	swis	#SysGetChar
	stu	r0,[r1,#1]
	blt	_done
	cmp	r0,#'\n
	bne	_loop
	mov	r0,#0
	stu	r0,[r1,#1]
_done:	ldu	r0,[sp,#1]
	mov	pc,lr

;;; copy string pointed to by r1 to area pointed to by r0, max r2 chars
strncpy:stm	sp,#0xf
_loop:	subs	r2,r2,#1
	ble	_term
	ldu	r3,[r1,#1]
	stus	r3,[r0,#1]
	bne	_loop
_term:	stu	r2,[r0,#1]	; stores final EOLN
_done:	ldm	sp,#0xf
	mov	pc,lr

;;; print a string pointed to by r0
puts:	stu	r1,[sp,#-1]
	mov	r1,r0
_loop:	ldus	r0,[r1,#1]
	beq	_done
	swi	#SysPutChar
	b	_loop
_done:	ldu	r1,[sp,#1]
	mov	pc,lr
;;; output area
buffer:
