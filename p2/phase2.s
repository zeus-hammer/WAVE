;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ	src1, r10
	.requ	src2, r8
	.requ	dst, r9
	
	.requ	work0, r1
	.requ	work1, r2
	.requ	work2, r3
	.requ	work3, r4
	
		
 	.equ	maskT, 0xc000000 	;27 and 26th bit
	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskSC, $63
	
	lea	WARM,r0
	lea	REGS,reg
	lea	INSTR,op
	
	trap	$SysOverlay
;;; decipher type
fetch:	mov	WARM(wpc),ci
 	mov	$maskT, work0
	and	work0, ci
	shr	$31, work0	;work 0 holds the type
 	mov	TYPE(work0), rip
arith:
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov 	$maskA, work0
	and 	work0, ci
	shr	$14, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip

imd:	
	
rim:	mov	ci, work0
	shl	$22, work0
	shr	$28, work0 	;now we have src reg 2 in work0
	mov	work0, src2
	mov	ci, work0
	and	$maskSC, work0	;work0 now has the shift count

	mov	ci, work1
	shl	$20, work1
	shr	$30, work1	;work1 now has the shop
	mov 	SHOPRIM(work1),rip
rimlsl:	shl	work0, src2
	mov	INSTR(op), rip
rimlsr:	shr	work0, src2
	mov	INSTR(op), rip
rimasr:	sar	work0, src2
	mov	INSTR(op), rip
rimror:	mov	$32, work3
	sub	work0, work3	;work3 contains the ammount to shift to hold the rotated stuff
	mov	src2, work4	
	shl	work3, work4	;work4 has the rotated bits
	shr	work0, src2
	add	work4, src2
	mov	INSTR(op), rip

rsr:	

rpm:	

	
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
	mov	ci,work0



ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm

ls:

branch:	

	


add:

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

SHOPRIM:
	.data rimlsl, rimlsr, rimasr, rimror
WARM:	 
