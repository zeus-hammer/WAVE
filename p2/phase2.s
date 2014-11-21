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
add:	mov 	$0,r0		;op 0	00000
	trap	$SysPutNum
	trap	$SysHalt
adc:	mov	$1, r0		;op 1	00001
	trap	$SysPutNum
	trap	$SysHalt		
sub:	mov	$2, r0		;op 2	00010
	trap	$SysPutNum
	trap	$SysHalt	
cmp:	mov	$3, r0		;op 3	00011
	trap	$SysPutNum
	trap	$SysHalt	
eor:	mov	$4, r0		;op 4	00100
	trap	$SysPutNum
	trap	$SysHalt	
orr:	mov	$5, r0		;op 5	00101
	trap	$SysPutNum
	trap	$SysHalt	
and:	mov	$6, r0		;op 6	00110
	trap	$SysPutNum
	trap	$SysHalt	
tst:	mov	$7, r0		;op 7	00111
	trap 	$SysPutNum
	trap	$SysHalt	
mul:	mov	$8, r0		;op 8	01000
	trap	$SysPutNum
	trap	$SysHalt	
mla:	mov	$9, r0		;op 9	01001
	trap	$SysPutNum
	trap	$SysHalt	
div:	mov	$10, r0		;op 10	01010
	trap 	$SysPutNum
	trap	$SysHalt	
mov:	mov	$11, r0		;op 11	01011
	trap	$SysPutNum
	trap	$SysHalt	
mvn:	mov	$12, r0		;op 12	01100
	trap	$SysPutNum
	trap	$SysHalt	
swi:	mov	$13, r0		;op 13	01101
 	trap	$SysPutNum
	trap	$SysHalt	
ldm:	mov	$14, r0		;op 14	01110
	trap	$SysPutNum
	trap	$SysHalt	
stm:	mov	$15, r0		;op 15	01111
	trap	$SysPutNum
	trap	$SysHalt	
ldr:	mov	$16, r0		;op 16  10000
	trap	$SysPutNum
	trap	$SysHalt		
str:	mov	$17, r0		;op 17	10001
	trap	$SysPutNum
	trap	$SysHalt		
ldu:	mov	$18, r0		;op 18	10010
	trap	$SysPutNum
	trap	$SysHalt		
stu:	mov	$19, r0		;op 19	10011
	trap	$SysPutNum
	trap	$SysHalt		
adr:	mov	$20, r0		;op 20	10100
	trap	$SysPutNum
	trap	$SysHalt		
bf:	mov	$21, r0		;op 24	11000
	trap	$SysPutNum
	trap	$SysHalt		
bb:	mov	$22, r0		;op 25	11001
	trap	$SysPutNum
	trap	$SysHalt		
blf:	mov	$23, r0		;op 26	11010
	trap	$SysPutNum
	trap	$SysHalt		
blb:	mov	$24, r0		;op 27	11011
	trap	$SysPutNum
	trap	$SysHalt		
loop:	mov	WARM(r10),r0
	cmp	$0x06800000,r0
	je	found
	add	$1,r10
	jmp	loop
found:	mov	r10, r0
	trap	$SysPutNum
	mov	$'\n', r0
	trap	$SysPutChar
	trap	$SysHalt
REGS:
	.data	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
INSTR:
	.data 	add,adc,sub,cmp,eor,orr,and,tst,mul,mla,div,mov,mvn,swi,ldm,stm,ldr,str,ldu,stu,adr,0,0,0,bf,bb,blf,blb
WARM:	 
