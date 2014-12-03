	mov	r0, #100
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	str	r0,[r1, #50]
	mov	r0, #2
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, #5
	ldr	r0,[r1, #50]
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov 	r1, #50
	str	r1, 60
	mov	r0, #2
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	ldr	r0, 60
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	swi	#SysHalt