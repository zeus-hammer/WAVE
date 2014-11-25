;;; testing that our addressing modes are correct
;;; (c) drsmith


	add	r0, r0, #3	;r0 should be 3
	sub	r1, r0, #1	;r1 should be 2
	sub	r2, r1, r1, lsl #2 ;r2 should be -6
	add	r3, r2, r2, lsr r1 ;3ffffff8
	