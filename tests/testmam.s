;;; what does -512 look like in a register
;;;

	mvn	r1, #0x3f
	mov	r2, #3
	mov	r0, r1, r2, lsl #0
