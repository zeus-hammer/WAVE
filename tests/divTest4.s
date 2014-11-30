;;; testing eor in wave
;;; (c) drsmith

	mov	r0, #2
	div 	r0,r0, #1
	swi	#SysPutNum
	swi	#SysHalt