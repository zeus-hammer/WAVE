;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan

	.requ	wpc, r15
	lea	WARM,r0
	trap	$SysOverlay
	
	mov	$0,r10
	mov	$1,(r10)
loop:	mov	WARM(r10),r0
	cmp	$0x06800000,r0
	je	found
	add	$1,r10
	jmp	loop

found:	mov	r10, r0
	trap	$SysPutNum
	mov	$'\n, r0
	trap	$SysPutChar
	trap	$SysHalt
WARM:	 


	