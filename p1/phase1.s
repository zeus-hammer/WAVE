;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan

	.requ	wpc, r15
	.requ	reg_a, r14
	lea	WARM,r0
	lea	table,reg_a
	trap	$SysOverlay
	
	mov	$0,wpc
	mov	$0,(wpc)
	mov	$0,1(wpc)
	mov	$0,2(wcp)
	mov	$0,3(wpc)
	mov	$0,4(wpc)
	mov	$0,5(wpc)
	mov	$0,6(wpc)
	mov	$0,7(wpc)
	mov	$0,8(wpc)
	mov	$0,9(wpc)
	mov	$0,10(wpc)
	mov	$0,11(wpc)
	mov	$0,12(wpc)
	mov	$0,13(wpc)
	mov	$0,14(wpc)
	mov	$0,15(wpc)
;;; snag the opcode
	mov	WARM(wpc), r1
	mov	r1, r2
	shl	r2,$5
	shr	r2,$26
;;; we have the opcode in r2, now what do we do with it?
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
	


table:
	.data	1,2,3,4,5,6,7,8,9,10,11,12,13
	
	
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
WARM:	 
