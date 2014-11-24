;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	.requ	op, r2 
	lea	WARM,r0
	lea	REGS,reg
	lea	INSTR,op
	trap	$SysOverlay
;;; snag the opcode
	mov	WARM(wpc),ci
	mov 	ci,op
	shl	$4,op
	shr	$27,op
	mov	INSTR(op), rip
;;; lets jump straight to the address
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
WARM:	 
