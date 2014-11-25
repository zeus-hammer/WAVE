;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #1	;1 should be in r0
	mul	r1, r0, #3	;r1 should be 3
	add	r2, r1, r1, lsl #1 ;9 should be in r2
	add	r3, r2, r2, lsr r0 ;13 should be in r3
	