;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r11
	.requ 	type, r10
	.requ	work0, r1
	.requ	work1, r2
	.requ	work2, r3
	.requ	work3, r4
;;; 	.equ	maskT, 0x00800000
	lea	WARM,r0
	lea	REGS,reg
	lea	INSTR,op
	trap	$SysOverlay
;;; snag the opcode
	mov	WARM(wpc),ci
;;; 	mov	ci,type
;;; 	mov	$maskT, work0
;;; 	and	work0,type
;;; 	mov	TYPE(work0), rip
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
;;; lets jump straight to the address
add:
;;; we need to get 1.) the type of addressing it's supposed to be
;;; 2.) the source and dest registers
;;; 3.) lets just get really big in here
	
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
;;; TYPE:
;;; 	.data	arith, arith, ls, branch
	
WARM:	 


