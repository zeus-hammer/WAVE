;;; A biorhythm program -*- mode: asm; compile-command: "waa -l bio.as" -*-
;;; (c) 2010 duane a. bailey for the Great Class of 2010
	b main
;;; Change these two dates, if you like:
;;;             month, day, year
birthday:.data	12,   15,   1960 ;your birthday
today:	.data	12,    9,   2010 ;today
	;; chart size
	.equ	lines,21
	
	;; beginning of modern time (stored here 'cause there are 10 bits)
firstYear:	.data	1901
	
	;; header
hello:	.string "                 Here's your biorhythm, starting today:\n                P = Physical       M = Mental      E = Emotional\n"
	
	;; template for biorhythm chart
msg:	.string	"-                                   |                                   +"

monthTab:.data	0,31,59,90,120,151,181,212,243,273,304,334
	
;;; mod age by this (next triple critical point, age 58.22 years)
cycle:	.data	21252
	
;;; cycle times
emot:	.data	28
phys:	.data	23
ment:	.data	33
	
main:
	;; greeting at top
	adr	r0,hello
	bl	puts
	
	;; compute age
back:	adr	r0,birthday
	bl	since
	mov	r1,r0
	adr	r0,today
	bl	since
	sub	r0,r0,r1
	
	;; print the next lines days of biorhythms
	add	r1,r0,#lines
_loop:	bl	bior		; print chart line
	stu	r0,[sp,#-1]
	mov	r0,#'\ 		; space
	swi	#SysPutChar
	ldu	r0,[sp,#1]
	swi	#SysPutNum	; age in days
	bl	nl
	add	r0,r0,#1	; count lines
	cmp	r0,r1
	blt	_loop
	swi	#SysHalt	; fini.
	
;;; The main routine for computing biorhythms.
;;; prints a line for someone whose age is in r0.
;;; No registers altered
bior:	stu	lr,[sp,#-1]
	stm	sp,#0x3f
	mov	r4,r0		; stash age in r4
	mov	r1,r4
	ldr	r0,cycle	; mod the age by 58 years to avoid 16 bit overf
	bl	mod
	mov	r4,r0
	
	adr	r1,msg
	adr	r0,output	; copy a clean line
	bl	strcpy
	bl	strlen		; compute the radius of the line
	sub	r0,r0,#3
	mov	r5,r0,asr#1	; multiplier for sine(x)
	
	;; we now compute the physical cycle
	ldr	r0,phys
	mov	r1,r4
	bl	mod		; age mode physical cycle
	mov	r0,r0,lsl#16	; fractional
	ldr	r1,phys
	div	r0,r0,r1	;   division
	ldr	r1,pi2		; multiply by 2pi
	bl	mul
	bl	sin		; compute sine
	mul	r0,r0,r5	; multiply by radius
	ldr	r1,half		; round
	bl	add
	mov	r1,r0,asr#16	; truncate to integer
	add	r1,r1,r5	; compute charcter offset
	add	r1,r1,#1
	adr	r2,output	; place a P
	mov	r3,#'P
	str	r3,[r2,r1,lsl#0] ; in the chart
	
	;; we now compute the emotional cycle
	mov	r1,r4		; same as above but...
	ldr	r0,emot
	bl	mod
	mov	r0,r0,lsl#16
	ldr	r1,emot
	div	r0,r0,r1
	ldr	r1,pi2
	bl	mul
	bl	sin
	mul	r0,r0,r5
	ldr	r1,half
	bl	add
	mov	r1,r0,asr#16
	add	r1,r1,r5
	add	r1,r1,#1
	adr	r2,output
	ldr	r3,[r2,r1,lsl#0]
	cmp	r3,#'P		; if we find a P
	moveq	r3,#'2		;    indicate crossing
	movne	r3,#'E		;       otherwise place E
	str	r3,[r2,r1,lsl#0] ; in chart
	
	;; we now compute the mental cycle
	mov	r1,r4		; same with mental, but
	ldr	r0,ment
	bl	mod
	mov	r0,r0,lsl#16
	ldr	r1,ment
	div	r0,r0,r1
	ldr	r1,pi2
	bl	mul
	bl	sin
	mul	r0,r0,r5
	ldr	r1,half
	bl	add
	mov	r1,r0,asr#16
	add	r1,r1,r5
	add	r1,r1,#1
	adr	r2,output
	ldr	r3,[r2,r1,lsl#0]
	cmp	r3,#'2		; either space or punct, a 2, or an M
	movlt	r3,#'M		; space/punct, place an M
	movgt	r3,#'2		; previous letter.  Place a 2
	moveq	r3,#'3		; previous 2, place a 3 (wow!)
	str	r3,[r2,r1,lsl#0]

	adr	r0,output
	bl	puts		; print the string
	ldm	sp,#0x3f
	ldu	pc,[sp,#1]	; return
	
;;; Print a newline.  No registers harmed.
nl:	stu	r0,[sp,#-1]
	mov	r0,#'\n
	swi	#SysPutChar
	ldu	r0,[sp,#1]
	mov	pc,lr
	
;;; compute the length of the string pointed to by r0
;;; result in r0
strlen:	stm	sp,#0x6
	mov	r1,r0
	mov	r0,#0
_loop:	ldus	r2,[r1,#1]
	addne	r0,r0,#1
	bne	_loop
	ldm	sp,#0x6
	mov	pc,lr

;;; copy string pointed to by r1 to area pointed to by r0
strcpy:	stm	sp,#0x7
_loop:	ldu	r2,[r1,#1]
	stus	r2,[r0,#1]
	bne	_loop
_done:	ldm	sp,#0x7
	mov	pc,lr

;;; print a string pointed to by r0
puts:	stu	r1,[sp,#-1]
	mov	r1,r0
_loop:	ldus	r0,[r1,#1]
	beq	_done
	swi	#SysPutChar
	b	_loop
_done:	ldu	r1,[sp,#1]
	mov	pc,lr
	
;;; r0 is a pointer to date array
;;; result is days since 1901
since:	stu	lr,[sp,#-1]
	stm	sp,#0xfe
	ldr	r1,[r0,#2]	; r1 = year
	ldr	r4,firstYear
	sub	r1,r1,r4
	ldr	r2,[r0,#0]	; r2 = month
	sub	r2,r2,#1	;  0..11
	ldr	r3,[r0,#1]	; r3 = day
	sub	r3,r3,#1
	
	;; now compute days since 1901:
	mul	r0,r1,#365	; r0 = running total
	add	r0,r0,r1,asr#2	; add in leap years
	and	r1,r1,#0x3	; 1 if target year is leap year
	moveq	r1,#1
	movne	r1,#0
	adr	r4,monthTab	; julian date lookup
	ldr	r4,[r4,r2,lsr#0]
	add	r0,r0,r4
	cmp	r2,#2
	addgt	r0,r0,r1	; curry in another leap day after leap feb
	add	r0,r0,r3	; add in days
	ldm	sp,#0xfe	
bnd:	ldu	pc,[sp,#1]
	
;;; compute r1 mod r0.  Result in r0
mod:	stm	sp,#0xe
	div	r2,r1,r0
	mul	r2,r2,r0
	sub	r0,r1,r2
	ldm	sp,#0xe
	mov	pc,lr

;;; convert an int in r0 to a float in r0
float:	mov	r0,r0,lsl#16
	mov	pc,lr

;;; given an integer in r3, fraction in r2, join them in r0
join:	ldr	r0,low16
	mov	r0,r0,lsl#1
	add	r0,r0,#1
	and	r0,r0,r2
	add	r0,r0,r3,lsl #16
	mov	pc,lr

;;; given a float in r0, invert it.
fneg:	mvn	r0,r0
	add	r0,r0,#1
	mov	pc,lr
	
;;; given a float in r0, take its absolute value (set bits based on initial)
fabs:	cmp	r0,#0
	mvnlt	r0,r0
	addlt	r0,r0,#0x10000
	addlt	r0,r0,#1
	mov	pc,lr

;;; given value in r0:
;;; split the floating point number into an integer (r3) and fraction (r2)
split:	mov	r3,r0,asr#16
	stu	r1,[sp,#-1]
	ldr	r1,low16
	and	r2,r0,r1
	and	r1,r3,r1,ror #16 
	orr	r2,r2,r1
	ldu	r1,[sp,#1]
	mov	pc,lr

;;; prints floating point value in r0
print:	stu	lr,[sp,#-1]
	stm	sp,#0xf
	cmp	r0,#0
	bllt	fneg
	stult	r0,[sp,#-1]
	movlt	r0,#'-
	swilt	#SysPutChar
	ldult	r0,[sp,#1]
	bl	split
	mov	r0,r3
	swi	#SysPutNum
	mov	r0,#'.
	swi	#SysPutChar
	mov	r1,#6
_loop:	muls	r2,r2,#10
	beq	_done
	mov	r0,r2
	bl	split
	mov	r0,r3
	swi	#SysPutNum
	sub	r1,r1,#1
	bgt	_loop
_done:	ldm	sp,#0xf
	ldu	pc,[sp,#1]
;;;
;;; we implement a fixed point fractional representation:
;;;   integers portion is in top 16 bits, the fractional portion in lower 16
;;; this gives us values between -32767.999984741211 and +32767.999984741211
;;; with an accuracy of 0.000015258789
	
low16:	.data	0x0000ffff
	
;;; constants needed for the computation of sin(x)
pi2:	.data	0x0006487f
pi:	.data	0x0003243f
halfpi:	.data	0x0001921f
half:	.data	0x00008000	;  0.5
s1:	.data	0xffffd556 	; -0.16666
s2:	.data	0x00000222	;  0.00833
s3:	.data	0xfffffff2	; -0.00019841
	
;;;
;;; This algorithm is from www.netlib.org/fdlibm/k_sin.c
;;; Algorithm used by Sun and IBM.  Taylor series expansion.
;;; 
sin:	stu	lr,[sp,#-1]
	stm	sp,#0x3fe
	mov	r2,#0		; sign of sine
	cmp	r0,#0
	eorlt	r2,r2,#1	; sin(-x) = -sin(x)
	bllt	fneg
	ldr	r1,halfpi
	cmp	r0,r1
	ldrge	r1,pi
	subge	r0,r1,r0
	bl	sin0
	cmp	r2,#0
	blne	fneg
	ldm	sp,#0x3fe
	ldu	pc,[sp,#1]
	
sin0:	stu	lr,[sp,#-1]
	stm	sp,#0x3fe
	;; r = x^3*(s2+x^2*s3)
	;; sin = x+(s1*x^3+(x*r))
	;; r2 = x, r3 = x^2, r4= x^3
	mov	r2,r0
	bl	sqr
	mov	r3,r0
	mov	r0,r2
	bl	cube
	mov	r4,r0
	
	;; compute r:
	ldr	r0,s3
	mov	r1,r3
	bl	mul		; r0 = s3*x^2
	ldr	r1,s2
	bl	add		; r0 = s2+s3*x^2
	mov	r1,r4
	bl	mul		; r0 = r = x^3*(s2+x3*x^2)
	mov	r1,r2
	bl	mul		; r0 = r5 = x*r
	mov	r5,r0		
	ldr	r0,s1
	mov	r1,r4
	bl	mul		;s1*x^3
	mov	r1,r5
	bl	add
	mov	r1,r2
	bl	add
	ldm	sp,#0x3fe
	ldu	pc,[sp,#1]
	
;;; given floating point values in r0 and r1, add them together.
add:
	add	r0,r0,r1
	mov	pc,lr


;;; given floating point values in r0 and r1, multiply them together.
;;; approach:
;;;  work with absolute values, add correct sign later
;;;  (a(1)+b) * (c(1)+d) = (ac(1)+(bc+da)(0)+bd(-1)) where (n) is *2^16n
mul:	stu	lr,[sp,#-1]
	stm	sp,#0x3e
	mov	r9,#0
	cmp	r0,#0
	eorlt	r9,r9,#1
	mvnlt	r0,r0
	addlt	r0,r0,#1
	
	cmp	r1,#0
	eorlt	r9,r9,#1
	mvnlt	r1,r1
	addlt	r1,r1,#1
	;; put first value is r7.r6
	bl	split
	mov	r6,r2 ; B
	mov	r7,r3 ; A
	
	;; second is in r5.r4
	mov	r0,r1
	bl	split
	mov	r4,r2 ; D
	mov	r5,r3 ; C
	
	;; compute result
	mul	r8,r7,r5 ; AC
	mul	r0,r4,r6 ; BD
	mov	r0,r0,lsr#16	;we must divide by 2^16
	
	mla	r0,r0,r5,r6    ; CB	;this need not be shifted, but is fractional
	mla	r0,r0,r4,r7    ; DA  ;this need not be shifted, but is fractional
	bl	split
	add	r3,r8,r3
	bl	join
	cmp	r9,#0
	mvnne	r0,r0
	addne	r0,r0,#1
	
	ldm	sp,#0x3e
	ldu	pc,[sp,#1]

;;; compute r0^2
sqr:	stu	lr,[sp,#-1]
	mov	r1,r0
	bl	mul
	ldu	pc,[sp,#1]
	
;;; compute r0^3	
cube:	stu	lr,[sp,#-1]
	mov	r1,r0
	bl	mul
	bl	mul
	ldu	pc,[sp,#1]
	

output:	