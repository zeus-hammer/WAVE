;;; testing the addressing of our wave
;;; (c) drsmith modsoussi

	add	r1, r0, #1		;r1 is 1	
	add	r2, r2, r1, lsl #2	;r2 should be 4
	add	r3, r1, r1, lsl r1	;r3 should be 3
	mul	r4, r3, r2		;r4 should be 12
	mla	r5, r1, r2, r3		;r5 should be 13