;;; Phase 1 of final project
;;; (c) 2014 modsoussi
	.requ	wpc,r11
	mov	$0,wpc
	mov	$1000,r0
	trap	$SysOverlay

loop:	mov	1000(wpc),r0
	cmp	$0x06800000,r0
	je	done
	add	$1, wpc
	jmp 	loop
	
done:	mov	wpc, r0
	trap	$SysPutNum
	mov	$10, r0
	trap	$SysPutChar
	trap	$SysHalt
	