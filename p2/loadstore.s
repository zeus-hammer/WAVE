	.equ	0to13, 0x3FFF
	.equ	0to5, 0x3F
;;; load store

loadstore:
;;; move the base reg into work0
	mov	ci, work0
	shl	$13, work0
	shr	$28, work0
	mov	REGS(work0), work0 ;value in that register is now base
;;; now jump based on mode (bit 14), put 14 in 2 and je
	;; can we do this or do we need to make it 4 bits before moving to ccr?
	mov	ci, ccr
	shr	$12, ccr
	je	indexingMode
;;; here we are in immediate displacement
	mov	ci, work1
	mul	$0to13, work1 	;now we have the displacement in work1
	mov	work0(work1), REGS(dst) ;can we do this?
	jmp	fetch
indexingMode:
	mov	ci, work1
	shl	$22, work1
	shr	$28, work1 	; work1 now contains the index reg
	mov	REGS(work1), work1
	mov	ci, work3
	mul	$0to5, work3	; get the shift
	shl	$20, ci
	shr	$30, ci
	mov	SHOPind(ci) 	; jump table to the correct shift mode, copy and paste from Arithmetic