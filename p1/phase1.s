;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan

	.requ	wpc, r15
	lea	WARM,r0
	trap	$SysOverlay
	
	mov	$0,wpc
	mov	$0,(rbp)
	mov	$0,1(rbp)
	mov	$0,2(rbp)
	mov	$0,3(rbp)
	mov	$0,4(rbp)
	mov	$0,5(rbp)
	mov	$0,6(rbp)
	mov	$0,7(rbp)
	mov	$0,8(rbp)
	mov	$0,9(rbp)
	mov	$0,10(rbp)
	mov	$0,11(rbp)
	mov	$0,12(rbp)
	mov	$0,13(rbp)
	mov	$0,14(rbp)
	mov	$0,15(rbp)

;;; decode the instruction
	mov	$1, r0
	shr	r0, $26
	and	r0, WARM(wpc)
	be	arith

;;; snag the opcode
arith:	mov	WARM(wpc), r0
	shl	r0, $5
	shr	r0, $28
	mov			;; opcode's in r0


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
WARM:	 
