;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #1	;1 should be in r0
	mul	r1, r0, #3	;r1 should be 3
	mul	r2, r1, r1, lsl #1 ;r2 should be 18
	mul	r3, r2, r2, lsr r0 ;r3 should be 162
	