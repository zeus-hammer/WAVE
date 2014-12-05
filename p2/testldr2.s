	mov	r0, #17
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, #17
	str	r0, 100
	mov	r0, #0
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	ldr	r0, 100
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	swi	#SysHalt