;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan

	.requ	wpc, r15
	lea	WARM,r0
	trap	$SysOverlay
	
	mov	$0,wpc
	mov	$0,(rbp)
	mov	$0,1(rbp)
	mov	$0,2(rbp)
	mov	$0,3(rbp)
	mov	$0,4(rbp)
	mov	$0,5(rbp)
	mov	$0,6(rbp)
	mov	$0,7(rbp)
	mov	$0,8(rbp)
	mov	$0,9(rbp)
	mov	$0,10(rbp)
	mov	$0,11(rbp)
	mov	$0,12(rbp)
	mov	$0,13(rbp)
	mov	$0,14(rbp)
	mov	$0,15(rbp)

;;; lets add
;;; decode the instruction

	mov	$1, r0
	shr	r0, $26
	and	r0, WARM(r0)
	be	arith

arith:	




	
	
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
