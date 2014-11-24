;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ	src, r10
	.requ	dst, r9
	.requ 	rhs, r8
	
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
	and	$maskExp, work0	;exponent
	shr	$9, work0
	mov	ci, rhs
	and	$maskValue, rhs	;value
	shl	work0, rhs
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
	mov	ci,work0
rim:

rsr:

rpm:

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

WARM:	 
