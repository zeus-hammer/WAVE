	b	main
	
;;; An implementation of greatest common divisor.
;;; When a procedure is called, the link register has the return
;;; address.  We must save this on the stack if we want to make gcd recursive.
gcd:
	stm	sp,#0x4000  	; lr = r14
	cmp	r2,#0
	bne	else1
	mov	r0,r1
	b	return
else1:	cmp	r2,r1
	ble	else2
	mov	r0,r2
	mov	r2,r1
	mov	r1,r0
	bl	gcd
	b	return
else2:	div	r3,r1,r2
	mul	r3,r3,r2
	sub	r3,r1,r3
	mov	r1,r2
	mov	r2,r3
	bl	gcd
return:	
	ldm	sp,#0x4000	; lr = r15
	mov	pc,lr

main:
;;; read in pairs of values and write the gcd's.
;;; stop when first of pair is 0 and 0.
	swi	#SysGetNum
	cmp	r0,#0
	beq	done
	mov	r1,r0
	swi	#SysPutNum
	mov	r0,#32
	swi	#SysPutChar
	swi	#SysGetNum
	cmp	r0,#0
	beq	done
	mov	r2,r0
	swi	#SysPutNum
	mov	r0,#'=
	swi	#SysPutChar
	bl	gcd
	swi	#SysPutNum
	mov	r0,#10
	swi	#SysPutChar
	b	main
done:	swi	#SysHalt
	
	