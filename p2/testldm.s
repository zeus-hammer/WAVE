	mov	r0, #100
	swi	#SysPutNum
	mov	r0, #'\n
	mov	r1, #101
	mov	r2, #102
	stm	r0, #7
	mov	r1, #0
	mov	r2, #0
	ldm	r0, #7
	swi	#SysHalt