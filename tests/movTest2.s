;;; testing that our addressing modes are correct
;;; (c) drsmith


	mov	r0, #3		;3 in r0
	mov	r0, r0, lsl #3	;24 in r0
	add	r0, r0, #2
	mul	r1, r0, #3	
	mla	r2, r1, r1, r0 	
	div	r3, r2, #2	
	div	r3, r2, r1, lsl #1 
	div	r3, r2, r1, lsr r0 
	