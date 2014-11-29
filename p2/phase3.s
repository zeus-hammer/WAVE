	.equ	mask23to0, 0xffffff
;;; working separately, we can copy and paste this in
branch:	mov	ci, work0
	shl	$6, work0
	shr	$31, work0		;this gives us opp code
	mov	BRANCHES(work0), rip			;jmp table
	jmp	fetch


;;; i think this is what we want to do

branch:	add	ci, wpc
	mul	$mask23to0, wpc
	
	shr	$22, ci		;ccr now has a 1 in the z if we are doing a bl
	mov	ci, ccr
	jne	fetch
;;; now we are in the link part
	mov	wpc, wlr
	sub	work0, wlr
	add	$1, wlr 	;i dont think we have a link register right now but we probably want to make one
	jmp	fetch







	
;;; if address is signed
;;; 24 and 23 contain info about where we want to jmp, lets put them in n and z
;;; n is in 3 and z in 2
branch:	mov	ci, work0
	mul	$mask23to0, work0 ;get address
	move	ci, ccr
	shr	$21, ccr
	jl	branchlink	;if there is a 1 here then bl
	je	brn
brp:	add	work0, wpc
	jmp	fetch

brn:	sub	work0, wpc
	jmp	fetch

branchlink:
	jle	bln
blp:	mov	wpc, wlr
	add	$1, wlr
	add	work0, wpc
	jmp 	fetch

bln:	mov	wpc, wlr
	add	$1, wlr
	sub	work0, wpc
	jmp	fetch
	