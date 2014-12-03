;;; testing eor in wave
;;; (c) drsmith

	mov	r0, #2
	eor 	r0, r0, #1
	swieq	#SysPutNum
	swine	#SysHalt