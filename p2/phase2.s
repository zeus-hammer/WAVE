;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	reg, r14
	.requ	ci, r13
	lea	WARM,r0
	lea	REGS,reg
	trap	$SysOverlay
;;; snag the opcode
	mov	WARM(wpc),ci
	mov 	ci,r2
	shl	$5,r2
	shr	$26,r2	
;;; we have the opcode in r2, now what do we do with it?
;;; lets jump straight to the address
add:				;op 0	00000
adc:				;op 1	00001
sub:				;op 2	00010
cmp:				;op 3	00011
eor:				;op 4	00100
orr:				;op 5	00101
and:				;op 6	00110
tst:				;op 7	00111
mul:				;op 8	01000
mla:				;op 9	01001
div:				;op 10	01010
mov:				;op 11	01011
mvn:				;op 12	01100
swi:				;op 13	01101
ldm:				;op 14	01110
stm:				;op 15	01111

ldr:				;op 16  10000
str:				;op 17	10001
ldu:				;op 18	10010
stu:				;op 19	10011
adr:				;op 20	10100

bf:				;op 24	11000
bb:				;op 25	11001
blf:				;op 26	11010
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
WARM:	 
