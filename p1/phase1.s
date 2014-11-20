;;; phase 1 of the final project
;;; (c) 2014 d.r.smith
	
	.requ	wpc, r8
	lea	WARM,r0
	trap	$SysOverlay
	
	mov	$0,r10
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