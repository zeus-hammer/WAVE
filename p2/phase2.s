;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	lea	WARM,r0
	lea	REGS,reg
	trap	$SysOverlay
	lea 	add,r4
;;; snag the opcode
	mov	WARM(wpc),ci
	mov 	ci,r2
	shl	$5,r2
	shr	$26,r2	
;;; lets jump straight to the address
	.origin	200
add:				;op 0	00000
	.origin 300	
adc:				;op 1	00001
	.origin 400	
sub:				;op 2	00010
	.origin 500	
cmp:				;op 3	00011
	.origin 600	
eor:				;op 4	00100
	.origin 700	
orr:				;op 5	00101
	.origin 800	
and:				;op 6	00110
	.origin 900	
tst:				;op 7	00111
	.origin 1000	
mul:				;op 8	01000
	.origin 1100	
mla:				;op 9	01001
	.origin 1200	
div:				;op 10	01010
	.origin 1300
mov:				;op 11	01011
	.origin 1400
mvn:				;op 12	01100
	.origin 1500
swi:				;op 13	01101
	.origin 1600
ldm:				;op 14	01110
	.origin 1700
stm:				;op 15	01111
	.origin 1800
ldr:				;op 16  10000
	.origin 1900
str:				;op 17	10001
	.origin 2000
ldu:				;op 18	10010
	.origin 2100
stu:				;op 19	10011
	.origin 2200
adr:				;op 20	10100
	.origin 2300
bf:				;op 24	11000
	.origin 2400
bb:				;op 25	11001
	.origin 2500
blf:				;op 26	11010
	.origin 2600
blb:				;op 27	11011

loop:	mov	WARM(r10),r0
	cmp	$0x06800000,r0
	je	found
	add	$1,r10
	jmp	loop
found:	mov	r10, r0
	trap	$SysPutNum
	mov	$'\n, r0
	trap	$SysPutChar
	trap	$SysHalt
REGS:
	.data	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
INSTR:
	.data   200,300,400
WARM:	 
