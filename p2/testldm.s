	mov	r0, #100
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r1, #101
	mov	r0, r1
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r2, #102
	mov	r0, r2
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, #100
	stm	r0, #7
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r1, #0
	mov	r0, r1	
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r2, #0
	mov	r0, r2
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, #97
	ldm	r0, #6
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, r1
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	mov	r0, r2
	swi	#SysPutNum
	mov	r0, #'\n
	swi	#SysPutChar
	swi	#SysHalt