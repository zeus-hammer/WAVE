;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #2	;2 should be in r0
	mul	r1, r0, #3	;6 should be in r1
	mla	r2, r1, r1, r0 	;18 should be in r2 (6*2)+6
	mul	r3, r2, r2, lsr r0 ;72 should be in mul
	