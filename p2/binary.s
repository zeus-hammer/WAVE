;;; A simple solution to the binary.s problem of Computer Science 237.
;;; (c) 2010 duane a. bailey
main:
_loop:	swis	#SysGetNum
	beq	_done
	bl	putbin
	bl	newline
	b	_loop
_done:	swi	#SysHalt
	
;;; First attempt at this program.  The approach is to simply print out
;;; (or not) 32 binary digits of the value in r0.
putbin:	stu	lr,[sp,#-1]
	stm	sp,#0x6
	mov	r2,#32
	movs	r1,r0
	blt	_neg
	beq	_zero
_skipz:	subs	r2,r2,#1
	beq	_done
	movs	r1,r1,lsl#1
	bge	_skipz
_neg:	mov	r0,#'1
_prt:	swi	#SysPutChar
	subs	r2,r2,#1
	beq	_done
	movs	r1,r1,lsl #1
	blt	_neg
	mov	r0,#'0
	b	_prt
_zero:	mov	r0,#'0
	swi	#SysPutChar
_done:
	ldm	sp,#0x6	
	ldu	pc,[sp,#1]

;; write a newline
newline:
	mov	r0,#10
	swi	#SysPutChar
	mov	pc,lr
