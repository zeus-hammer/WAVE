	.equ	0to13, 0x3FFF
	.equ	0to5, 0x3F
;;; load store

loadstore:
;;; move the base reg into work0
	mov	ci, rhs
	shl	$13, rhs
	shr	$28, rhs
	mov	REGS(rhs), rhs 	;value in that register is now base
;;; now jump based on mode (bit 14), put 14 in 2 and je
	;; can we do this or do we need to make it 4 bits before moving to ccr?
	mov	ci, work1
	shr	$12, work1	
	mov	work1, ccr		;CAN THIS BE OPTIMIZED BY SHIFTING CCR?
	je	indexingMode
;;; here we are in immediate displacement
	mul	$0to13, ci 		;now we have the displacement in ci
	mov	rhs(ci), lhs	;lhs contains a data address, dst has dst from before
	mov	OPind(op), rip 	;jump table, has 25, 24, 23
indexingMode:
	mov	ci, work1
	shl	$22, work1
	shr	$28, work1 		; work1 now contains the index reg
	mov	REGS(work1), work1	; work1 now contains value in index reg
	mov	ci, rhs
	mul	$0to5, shiftC		; get the shift in shiftC
	mov	ci, lhs
	shl	$20, lhs
	shr	$30, lhs
	mov	SHOPindex(lhs) 		; jump table to the correct shift mode, copy and paste from Arithmetic

lslIndex:
	shl	shiftC, work1		;work1 now contains the offset from work0 
	mov	rhs(work1), lhs
	mov	OPind(op), rip
lsrIndex:
	shr	shiftC, work1
	mov	rhs(work1), lhs
	mov	OPind(op), rip
asrIndex:
	sar	shiftC, work1
	mov	rhs(work1), lhs
	mov	OPind(op), rip
rorIndex:			;rotate work1 shiftC
	mov	work1, lhs
	shr	shiftC, lhs	;lhs now has shifted version, now just grab the wrap around
	mov	$32, work0
	sub	shiftC, work0	;work0 now has 32-shiftC
	shl	work0, work1	;work1 has the wrap around
	add	lhs, work1	;put wrap around and shift together
	mov	rhs(work1), lhs
	mov	OPind(op), rip

	
;;; going to take work1, shift by shiftC, add to rhs, put in lhs
;;; go to individual shifting mode, shift work1 by work3, then work0(work1) into lhs and OPind(work), rip for the jump table
OPind:		.data	ldr, str, ldu, stu, adr

SHOPindex:	.data	lslIndex, lsrIndex, asrIndex, rorIndex