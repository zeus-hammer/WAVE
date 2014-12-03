;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #2	;2 should be in r0
	mul	r1, r0, #3	;6 should be in r1
	mla	r2, r1, r1, r0 	;18 should be in r2 (6*2)+6
	mla	r3, r2, r2, r0	;54 should be in r3 (18*2)+18
	