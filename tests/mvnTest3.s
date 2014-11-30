;;; testing eor in wave
;;; (c) drsmith

	mov	r0, #2
	tst	r0, r0
	movne	r0, #10
	swi	#SysPutNum
	swi	#SysHalt