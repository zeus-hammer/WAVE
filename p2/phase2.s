;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ	src, r10
	.requ	dst, r9
	
	.requ	work0, r1
	.requ	work1, r2
	.requ	work2, r3
	.requ	work3, r4
	
		
 	.equ	maskT, 0xc000000 	;27 and 26th bit
	.equ	maskA, 0x7800		;1 in 14,13,12th bits
	
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
	mov 	$maskA, work0
	and 	work0, ci
	shr	$14, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip

imd:
	
rim:

rsr:	mov	$0xE, work1
	and 	ci, work1	; work1 now has shreg in it
	mov	ci, work2	; work2 has current instruction in it
	shl	$22, work2
	shr	$26, work2	; work2 now has address of srcreg2 in it
	mov 	ci, work3
	shl	$20, work3
	shr	$30, work3	; work3 now has shop in it
	
	
rpm:	

	
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
	mov	ci,work0


SHOP:
	.data	lsl, lsr, asr, ror

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

WARM:	 
