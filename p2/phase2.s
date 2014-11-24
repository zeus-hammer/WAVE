;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ	src, r10
	.requ	dst, r9
<<<<<<< HEAD
	.requ 	rhs, r8
=======
	.requ	src2, r8
	.requ	shr, r5
>>>>>>> 5f81736c5adb03c7a6ce0e0b17b23de5da257ebd
	
	.requ	work0, r1
	.requ	work1, r2
	.requ	work2, r3
	.requ	work3, r4
		
 	.equ	maskT, 0xc000000 	;27 and 26th bit
	.equ	maskA, 0x7800		;1 in 14,13,12th bits
	.equ	mask4, 0xf
	.equ	maskValue, 0x1ff
	.equ	maskExp, 0x1f00
	
	lea	WARM,r0
	lea	REGS,reg
	lea	INSTR,op
	
	trap	$SysOverlay
;;; decipher type
fetch:	mov	WARM(wpc),ci
 	mov	$maskT, work0
	and	ci, work0
	shr	$31, work0	;work 0 holds the type
 	mov	TYPE(work0), rip
;;; INSTRUCTION TYPES
arith:
	mov 	$maskA, work0
	and 	ci,work0
	shr	$14, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip
;;; ADDRESSING MODES
imd:
	mov	ci, src
	shr	$15, src
	and	$mask4, src
	mov	ci, dst
	shr	$19, dst
	and	$mask4, dst
	mov	ci, work0
<<<<<<< HEAD
	and	$maskExp, work0	;exponent
	shr	$9, work0
	mov	ci, rhs
	and	$maskValue, rhs	;value
	shl	work0, rhs
=======
	shr	
rim:

;;; Register Shifted by Register Mode;;;
rsr:	mov	$0xE, shr	; shr := 15
	and 	ci, shr		; shr := shr & ci; to get shift register
	mov	ci, src2	
	shl	$23, src2
	shr	$28, src2	; src2 has src2 register 
	mov 	ci, work3
	shl	$21, work3
	shr	$30, work3	; work3 now has the shift op code
	mov	SHOP(work3), rip
	
rpm:	
>>>>>>> 5f81736c5adb03c7a6ce0e0b17b23de5da257ebd
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
<<<<<<< HEAD
	mov	ci,work0
rim:

rsr:

rpm:
=======

SHOP:
	.data	lsl, lsr, asr, ror

lsl:	shl	shr, src2
	mov     INSTR(op), rip

lsr:	shr	shr, src2
	mov     INSTR(op), rip

asr:	sar	shr, src2
	mov     INSTR(op), rip

ror:	mov	src2, work1
	mov	$32, work3	
	sub	shr, work3	;work3 := 32-shr
	shl	work3, work1	;work1 is low shr bits shifted (32-shr) to the left
	shr	shr, src2	;work2 is the highest (32-shr) bits shifted shr to the right
	add	work1, src2
	mov     INSTR(op), rip	
	
ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm
>>>>>>> 5f81736c5adb03c7a6ce0e0b17b23de5da257ebd

ls:

branch:	

<<<<<<< HEAD
;;; INSTRUCTIONS
=======
>>>>>>> 5f81736c5adb03c7a6ce0e0b17b23de5da257ebd
add:
	add	REGS(src), rhs
	mov	rhs, REGS(dst)
adc:
	
sub:
	
cmp:
	
eor:
	
orr:
	
and:
	
tst:
	
mul:
	
mla:
	
div:
	
mov:	
	
mvn:
	
swi:
	
ldm:
	
stm:
	
ldr:
	
str:
	
ldu:
	
stu:
	
adr:
	
bf:
	
bb:
	
blf:
	
blb:

REGS:
	.data	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
INSTR:
	.data 	add,adc,sub,cmp,eor,orr,and,tst,mul,mla,div,mov,mvn,swi,ldm,stm,ldr,str,ldu,stu,adr,0,0,0,bf,bb,blf,blb
TYPE:
	.data	arith, arith, ls, branch
ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm

WARM:	 
