;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #1	;1 should be in r0
	add	r1, r0, #3	;4 should be in r1
	add	r2, r1, r1, lsl #1 ;8 + 4 = 12 should be in r2
	add	r3, r2, r2, lsr r0 ;12 + 6 = 18 should be in r3
	