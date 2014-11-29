;;; An implementation of a LFSR-based random number generator.
;;; Input is the initial seed.  Prints all value in orbit
;;; (c) 2010 duane a. bailey
	b	main
	.equ	perline,16
ntaps:	.data	4
taps:	.data	7,5,4,3

main:	swi	#SysGetNum
	mov	r1,r0
	mov	r2,#perline
	bl	setSeed
	swi	#SysPutNum
	sub	r2,r2,#1
	mov	r0,#'\ 
	swi	#SysPutChar
_loop:	bl	nextInt
	swi	#SysPutNum
	stu	r0,[sp,#-1]
	subs	r2,r2,#1
	moveq	r2,#perline
	moveq	r0,#'\n
	swieq	#SysPutChar
	movne	r0,#'\ 
	swine	#SysPutChar
	ldu	r0,[sp,#1]
	cmp	r0,r1
	bne	_loop
	cmp	r2,#perline
	movne	r0,#'\n
	swine	#SysPutChar
	swi	#SysHalt

seed:	.data	0
setSeed: stu	r1,[sp,#-1]
	str	r0,seed
	ldu	r1,[sp,#1]
	mov	pc,lr

nextInt:stm	sp,#0x1fe
	ldr	r1,ntaps	; number of taps
	adr	r2,taps		; tap pointer
	mov	r3,#0		; sum of taps
	ldr	r4,seed		; grab seed
_loop:	subs	r1,r1,#1	; look at the next tap
	blt	_done
	ldr	r6,[r2,r1,lsl#0]	; grab the current tap
	mov	r5,#1
	and	r5,r5,r4,lsr r6	; shift seed and mask low bit
	eor	r3,r3,r5	; add into running sum
	b	_loop
_done:	mvn	r8,#0
	mov	r7,#31
	sub	r7,r7,r6	; find the width of the generator
	mov	r8,r8,lsr r7
	mov	r4,r4,lsl #1
	orr	r4,r4,r3
	and	r0,r4,r8
	str	r0,seed
	ldm	sp,#0x1fe
	mov	pc,lr
	