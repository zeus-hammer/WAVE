	mov	r1,#0
	adr	r2,stop
loop:	cmp	r1,r2
	swige	#SysHalt
	mov	r0,#'\t
	swi	#SysPutChar
	mov	r0,#'.
	swi	#SysPutChar
	mov	r0,#'d
	swi	#SysPutChar
	mov	r0,#'a
	swi	#SysPutChar
	mov	r0,#'t
	swi	#SysPutChar
	mov	r0,#'a
	swi	#SysPutChar
	mov	r0,#'\t
	swi	#SysPutChar
	mov	r0,#'0
	swi	#SysPutChar
	mov	r0,#'b
	swi	#SysPutChar
	ldr	r3,[r1]
	mov	r4,#32
_loop:	cmp	r3,#0
	movge	r0,#'0
	movlt	r0,#'1
	swi	#SysPutChar
	mov	r3,r3,lsl#1
	subs	r4,r4,#1
	bgt	_loop
	mov	r0,#'\n
	swi	#SysPutChar
	add	r1,r1,#1
	b	loop
stop: