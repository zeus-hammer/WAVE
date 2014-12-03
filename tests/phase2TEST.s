	.requ	wpc, r15
	.requ	ci, r14
	.requ	op, r13
	.requ	lhs, r12
	.requ	dst, r11
	.requ 	rhs, r10
	.requ	shiftC, r9
	.requ	wCCR, r8
	.requ	cond, r5
	.requ	work0, r0
 	.requ	work1, r1
		
	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskShift, 0x3F
	.equ	maskLow4, 0xf
	.equ	maskHigh4, 0xf0000000
	.equ	maskValue, 0x1ff
	.equ	maskExp, 0x1f00
	
;;; 	lea	WARM,work0
;;; 	trap	$SysOverlay
;;; --------------------BEGIN FETCHING THE INSTRUCTION-------------------

;;; 5 INSTRUCTIONS
;;; 	mov	WARM(wpc),ci
fetch:	;; 	mov	ci, work0
	;; 	shr	$29, work0	;high 3 condition bits in work0
	mov	$0, work0
	mov	$8, wCCR
	mov	COND(work0,wCCR), work1
	mov	$1, work0
	mov	$7, wCCR
	mov	COND(work0,wCCR), work1
	
COND:
	.data
		.data 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
		.data 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
