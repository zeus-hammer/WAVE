	mov	#5, r0
	add	#10, r0

	mov	r0, #10
	swi	#SysPutChar
	swi	#SysHalt