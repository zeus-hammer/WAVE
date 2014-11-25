;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ	src1, r10
	.requ	src2, r8
	.requ	dst, r9
	.requ 	rhs, r8
	.requ	src2, r8
	.requ	shr, r5

	.requ	work0, r1
	.requ	work1, r2
	.requ	work2, r3
	.requ	work3, r4
		
 	.equ	maskT, 0xc000000 	;27 and 26th bit
	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskSC, 0x3F
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
;;; instruction types
arith:
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov 	$maskA, work0
	and 	ci,work0
	shr	$14, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip
;;; immediate mode
imd:	
	mov	ci, src
	shr	$15, src
	and	$mask4, src
	mov	ci, dst
	shr	$19, dst
	and	$mask4, dst
	mov	ci, work0
	
	and	$maskExp, work0	;exponent
	shr	$9, work0
	mov	ci, rhs
	and	$maskValue, rhs	;value
	shl	work0, rhs
	shr
	
;;; register shifted immediate mode
rim:	mov	ci, shr
	shl	$23, shr
	shr	$28, shr 	;now we have src reg 2 in shr
	mov	work0, shr2
	mov	ci, shr
	and	$maskSC, shr	;work0 now has the shift count

	mov	ci, work1
	shl	$20, work1
	shr	$30, work1	;work1 now has the shop
	mov 	SHOP(work1),rip
	
;;; Register Shifted by Register Mode;;;
rsr:	mov	$mask4, shr	; shr := 15
	and 	ci, shr		; shr := shr & ci; to get shift register
	mov	ci, src2	
	shl	$23, src2
	shr	$28, src2	; src2 has src2 register 
	mov 	ci, work3
	shl	$21, work3
	shr	$30, work3	; work3 now has the shift op code
	mov	SHOP(work3), rip


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

;;; Register Product Mode
	
rpm:


	
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
	mov	ci,work0

ls:

branch:	

;;; INSTRUCTIONS
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
SHOP:
	.data	lsl, lsr, asr, ror
WARM:	 
