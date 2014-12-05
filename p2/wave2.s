;;; emulator for warm - phase2p
;;; (c) d.r.smith modsoussi bijan
	.requ	ci, r14
	.requ	rhs, r14
	.requ	op, r13
	.requ	dst, r11
	.requ	lhs, r10	
	.requ	shiftC, r9
	.requ	wCCR, r8
	.requ	temp, r3
	.requ	work0, r0
 	.requ	work1, r1
	.requ	next, r2

	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskShift, 0x3F
	.equ	maskLow4, 0xf
	.equ	maskValue, 0x1ff
	.equ	maskExp, 0x3e00
	.equ	flip, 0xffffffff
	.equ	mask23to0, 0xffffff
	.equ	maskLow13, 0x3fff
	.equ	opMask, 0x1F800000
	.equ	shopMask, 0xc00

	lea	WARM, work0
	trap	$SysOverlay

	jmp	fetch
;;; --------------------BEGIN FETCHING THE INSTRUCTION-------------------
;;; 5 INSTRUCTIONS
fetch4:	mov	ccr,wCCR
	jmp	fetch
fetch3:	mov	ccr,wCCR	;--------------------TOP-------------------;
fetch2:	add	$1, wpc
	mov	rhs, REGS(dst)	;--------------------TOP-------------------;
fetch:	and 	$mask23to0, wpc
	mov	wpc, next
	mov	WARM(next),ci
	mov	ci, work0
	shr	$29, work0	;high 3 condition bits in work0
;;; to do it or not to do it. that is the question	
	cmovg	COND(work0), rip
;;; yes, we do it
getop:	mov 	ci,op
	and	$opMask, op
;;; switch on the opcode to get type
	mov	TYPE(op), rip
;;; switch on the condition code to find out 	
never:	mov	NEVER(wCCR),rip
equal:	mov	EQ(wCCR),rip
ne:	mov	NE(wCCR),rip
lesst:	mov	LT(wCCR),rip
lesse:	mov	LE(wCCR),rip
greate:	mov	GE(wCCR),rip
gt:	mov	GT(wCCR),rip
;;; ----------------------------END FETCH---------------------------------




	
;;; --------------BEGIN ARITHMETIC INSTRUCTION DECODING-------------------
noDST:	mov     ci, lhs		
	shr     $15, lhs
	and     $maskLow4, lhs
	jmp 	oRHS
ALL3:	mov     ci, lhs		;get dst and lhs
	shr     $15, lhs
	and     $maskLow4, lhs
oDST:	mov     ci, dst
	shr     $19, dst
	and     $maskLow4, dst
oRHS:	mov 	$maskA, work0
	and 	ci,work0
	shr	$12, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip
;;; --------------------ADDRESSING MODES OF ARITHMETIC--------------------
;;; Immediate Mode
imd:	mov	ci, work0
	and	$maskExp, work0	;exponent
	shr	$9, work0
	and	$maskValue, rhs	;value
	shl	work0, rhs	;shifted value in rhs

	mov     INSTR(op), rip
;;; Register Shifted by Immediate Mode
rim:	mov	ci, shiftC
	and	$maskShift, shiftC	;shift count has the bits number to shift
	mov	ci, work0
	and	$shopMask, work0	;work0 now has the shop
	shl	$22, rhs
	shr	$28, rhs 	;now we have src reg 2 in rhs
	mov	REGS(rhs), rhs	;rhs now has the value that was in register number rhs

	mov 	SHOP(work0), rip
;;; Register Shifted by Register Mode
rsr:	mov	$maskLow4, shiftC	; shiftC := 15
	and 	ci, shiftC	; shiftC := shiftC & ci; to get shift register
	mov	REGS(shiftC), shiftC ; shiftC now has whatever was stored in the 
	mov 	ci, work0
	and	$shopMask, work0	; work0 now has the shift op code
	shl	$22, rhs
	shr	$28, rhs	; rhs has rhs register
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in rhs (memory)

	mov	SHOP(work0), rip
;;; --------------------------BEGIN SHIFTING MODES-------------------------
;;; logical shift left
lsl:	shl	shiftC, rhs
	mov     INSTR(op), rip
;;; logical shift right
lsr:	shr	shiftC, rhs
	mov     INSTR(op), rip
;;; arithmetic shift right
asr:	sar	shiftC, rhs
	mov     INSTR(op), rip
;;; rotate right shift
ror:	mov	rhs, work0
	mov	$32, work1	
	sub	shiftC, work1	;work0 := 32-shr
	shl	work1, work0	;work0 is low shr bits shifted (32-shr) to the left
	shr	shiftC, rhs	;work1 is the highest (32-shr) bits shifted shr to the right
	add	work0, rhs
	mov     INSTR(op), rip
;;; -------------------------END SHIFTING MODES----------------------
;;; Register Product Mode
rpm:	mov	$maskLow4, work0
	and	ci, work0	;work0 now has src reg 3
	shl	$22, rhs
	shr	$28, rhs	; rhs now has src reg 2
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in the correspondent register
	mov	REGS(work0), work0 ;work0 now has whatever was stored in the correspondent register
	mul	work0, rhs
;;; -------------------------END ADDRESSING MODES-------------------



	
;;; -------------------------BEGIN OPERATIONS------------------------
;;; 2 INSTRUCTION(S)
add:	add	REGS(lhs), rhs
	mov	FETCHT(op), rip
;;; 6 INSTRUCTION(S)
adc:	mov	wCCR, work0
	shr	$2, work0
	shl	$31, work0
	add	REGS(lhs), rhs
	add	work0, rhs
	mov	FETCHT(op), rip
;;; backwards (like div)
;;; 4 INSTRUCTION(S)
sub:	mov	REGS(lhs), work0
	add	$1, wpc
	sub	rhs, work0	
	mov	work0, REGS(dst)
	mov	FETCHT(op), rip
;;; 2 INSTRUCTION(S)
eor:	xor	REGS(lhs), rhs
	mov	FETCHT(op), rip
;;; 2 INSTRUCTION(S)	
orr:	or	REGS(lhs), rhs
	mov	FETCHT(op), rip
;;; 2 INSTRUCTION(S)	
and:	and	REGS(lhs), rhs
	mov	FETCHT(op), rip
;;; 2 INSTRUCTION(S)	
mul:	mul	REGS(lhs), rhs
	mov	FETCHT(op), rip
;;; 4 INSTRUCTION(S)
div:	mov 	REGS(lhs), work0
	div	rhs, work0
	add	$1, wpc
	mov	work0, REGS(dst)
	mov	FETCHT(op), rip
;;; 1 INSTRUCTION(S)
mov:	mov	FETCHT(op), rip
;;; 2 INSTRUCTION(S)	
mvn:	xor	$flip, rhs
	mov	FETCHT(op), rip
;;; 3 INSTRUCTION(S)
swi:	mov	REGS, work0
	trap 	rhs
	add	$1, wpc
	mov	work0, REGS
	and 	REGS, REGS
	mov	FETCHT(op), rip
;;; 12? INSTRUCTION(S)
ldm:	mov	REGS(dst), lhs
	add	$1, wpc
	and	$mask23to0, lhs	;lhs is base register
	mov	$0, work0 	;work0 holds reg number
	test	$1, rhs
	jne	lloading
lshifting:
	add	$1, work0
	shr	$1, rhs
	je	LDMdone
	test	$1, rhs
	jne	lloading
	jmp	lshifting
lloading:
	mov	WARM(lhs), REGS(work0)
	add	$1, lhs
	jmp	lshifting
;;; when LDMdone, if base register popped, do nothing. Otherwise increment.
LDMdone:
	mov	lhs, REGS(dst)
	mov	FETCHT(op), rip
;;; 18? INSTRUCTION(S)
stm:	mov	wCCR, work0
	shl	$24, work0
	or	work0, wpc
	mov	REGS(dst), lhs	;lhs now has the value stored in base register
	and	$mask23to0, lhs	;mask low 24 bits for wraparound
	mov	$15, work0 	;work0 holds register number
	shl	$16, rhs
	jl 	sloading
sshifting:
	sub 	$1, work0	;
	shl	$1, rhs		
	jg 	sshifting	;is the next bit set?
	je	STMdone
sloading:
	sub	$1, lhs				
	mov	REGS(work0), WARM(lhs)
	cmp 	$0, rhs
	jne 	sshifting
STMdone:
	add	$1, wpc
	mov	lhs, REGS(dst)
	mov	FETCHT(op), rip

cmpCC:	mov	REGS(lhs), work0
	add	$1, wpc	
	sub	rhs, work0
	mov	ccr, wCCR
	jmp	fetch

tstCC:	test	REGS(lhs), rhs
	jmp	fetch3
	
movCC:	mov	rhs, REGS(dst)
	add	$1, wpc	
	and	rhs, rhs
	mov	ccr, wCCR
	jmp	fetch
	
;;; LOAD STORE
ls:	mov	ci, lhs 	;get dst and base registers, here base is lhs
	shr	$15, lhs
	and	$maskLow4, lhs 	;lhs now has base register in it
	mov	ci, dst
	shr	$19, dst
	and 	$maskLow4, dst 	;dst now has dst register
	mov	$maskA, work0
	and	ci, work0
	shr	$12, work0 	;work0 now has addressing mode
	mov	lsADDR(work0), rip
;;; ---------------------LOAD STORE INSTRUCTIONS----------------------------
;;; ldr is weird. to get memory reference, it adds offset to the value
;;;	in the program counter.
ldr:	add	REGS(lhs), rhs		;ADDITION, might be able to do this in the preparation so we dont have to type it a bunch of times
	and	$mask23to0, rhs 	;ADDITION: RHS now has the masked address, should only need to do WARM(rhs) now
	mov	WARM(rhs), REGS(dst)
 	add	$1, wpc			;changed WARM(lhs, rhs) to WARM(rhs)
	jmp 	fetch
str:	add	REGS(lhs), rhs		;ADDITION
	and	$mask23to0, rhs 	;ADDITION: RHS now has the masked address, should only need to do WARM(rhs) now
	mov	REGS(dst), WARM(rhs) 	;CHANGE, we had WARM(rhs,dst)
	add 	$1, wpc
	jmp	fetch
ldu:	jge	posldu
	add	REGS(lhs), rhs		;ADDITION
	and	$mask23to0, rhs
	add	$1, wpc			;ADDITION:Masking, rhs now has the modified address
	mov	WARM(rhs), REGS(dst)	;CHANGE
	mov	rhs, REGS(lhs)	
	and	REGS(dst), REGS(dst)
	mov	FETCHT(op), rip
posldu:	mov	REGS(lhs), work0
	and	$mask23to0, work0
	add	REGS(lhs), rhs
	add	$1, wpc
	and	$mask23to0, rhs
	mov	rhs, REGS(lhs)
	mov	WARM(work0),REGS(dst)
	and	REGS(dst),REGS(dst)
	mov	FETCHT(op), rip		;this was fetch2 i dont know why
stu:	jge 	posstu
	add	REGS(lhs), rhs
	and	$mask23to0, rhs
	mov 	REGS(dst), WARM(rhs)
	add	$1, wpc
	mov 	rhs, REGS(lhs)
	and	WARM(rhs),WARM(rhs)
	mov	FETCHT(op), rip
posstu:	mov	REGS(lhs), work0
	and	$mask23to0, work0 ;warm has effective address
	mov 	REGS(dst), WARM(work0)
	add	$1, wpc
	add	work0, rhs
	and	$mask23to0, rhs
	mov	rhs, REGS(lhs)
	and	WARM(rhs),WARM(rhs)
	mov	FETCHT(op), rip	
adr:	add	REGS(lhs), rhs
	and	$mask23to0, rhs	
	add	$1, wpc
	mov	rhs, REGS(dst)
	mov	FETCHT(op), rip
;;; ------------------------------END LOAD STORE--------------------------


;;;  ----------------------------BEGIN BRANCHING--------------------------
bl:	mov	wpc, wlr
	add 	$1, wlr
	and 	$mask23to0, wlr
b:	add 	ci, wpc
	jmp	fetch
;;; Signed offset mode for load store
soff:	shl	$18, rhs
	sar	$18, rhs 	; rhs now has the signed offset from base register
	mov	INSTR(op), rip
;;; no we don't do it
no:	add	$1, wpc
	and	$mask23to0, wpc
	jmp	fetch
REGS:
	.data	0,0,0,0,0,0,0,0,0,0,0,0,0,0x00ffffff,
wlr:
	.data	0
wpc:
	.data	0
INSTR:
	.data 	add		;0
	.bss    8388607
	.data   adc
	.bss    8388607
	.data   sub
	.bss	16777215
	.data	eor
	.bss    8388607
	.data   orr
	.bss    8388607
	.data   and
	.bss	16777215
	.data	mul
	.bss	16777215
	.data	div
	.bss    8388607		;10
	.data   mov
	.bss    8388607
	.data   mvn
	.bss    8388607
	.data   swi		
	.bss    8388607
	.data   ldm
	.bss    8388607
	.data   stm
	.bss    8388607
	.data   ldr
	.bss    8388607
	.data   str
	.bss    8388607
	.data   ldu
	.bss    8388607
	.data   stu
	.bss    8388607
	.data   adr
	.bss	100663295
	.data	add
	.bss    8388607
	.data   adc
	.bss    8388607
	.data   sub
	.bss    8388607
	.data   cmpCC
	.bss    8388607
	.data   eor
	.bss    8388607
	.data   orr
	.bss    8388607
	.data   and
	.bss    8388607
	.data   tstCC
	.bss    8388607
	.data   mul
	.bss	16777215
	.data	div
	.bss    8388607
	.data   movCC
	.bss    8388607
	.data   mvn
	.bss    8388607
	.data   swi
	.bss    8388607
	.data   ldm
	.bss	16777215
	.data	ldr
	.bss    8388607
	.data   str
	.bss    8388607
	.data   ldu
	.bss    8388607
	.data   stu
FETCHT:
	.data	fetch2
	.bss	8388607
	.data   fetch2
	.bss	8388607
	.data   fetch
	.bss	16777215
	.data	fetch2
	.bss	8388607
	.data   fetch2
	.bss	8388607
	.data   fetch2
	.bss	16777215
	.data	fetch2
	.bss	8388607
	.data   fetch2
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch2
	.bss	8388607
	.data   fetch2
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch
	.bss	100663295
	.data	fetch3
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch4
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch3
	.bss	16777215
	.data	fetch
	.bss	8388607
	.data   fetch
	.bss	8388607
	.data   fetch3
	.bss	8388607
	.data   fetch4
	.bss	8388607
	.data   fetch
	.bss	16777215
	.data	fetch4
	.bss	8388607
	.data   fetch4
	.bss	8388607
	.data   fetch4
	.bss	8388607
	.data   fetch4
TYPE:
	.data	ALL3
	.bss	8388607
	.data	ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   noDST
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   noDST
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   oDST
	.bss	8388607
	.data   oDST
	.bss	8388607
	.data   oRHS
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   oDST
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	33554431
	.data	b
	.bss	8388607
	.data   b
	.bss	8388607
	.data   bl
	.bss	8388607
	.data   bl
	.bss	41943039
	.data	ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   noDST
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   noDST
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ALL3
	.bss	16777215
	.data	ALL3
	.bss	8388607
	.data   oDST
	.bss	8388607
	.data   oDST
	.bss	8388607
	.data   oRHS
	.bss	8388607
	.data   ALL3
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	8388607
	.data   ls
	.bss	33552231
	.data	b
	.bss	8388607
	.data   b
	.bss	8388607
	.data   bl
	.bss	8388607
	.data   bl
COND:
	.data	0,never,equal,ne,lesst,lesse,greate,gt
NEVER:
	.data   no,no,no,no,no,no,no,no,no,no,no,no,no,no,no,no
EQ:
	.data	no,no,no,no,getop,getop,getop,no,no,no,no,no,no,getop,getop,getop
NE:
	.data	getop,getop,getop,getop,no,no,no,getop,getop,getop,getop,getop,getop,no,no,no
LT:
	.data	no,getop,no,getop,no,getop,no,getop,getop,no,getop,getop,no,getop,no,getop
LE:
	.data	no,getop,no,getop,getop,getop,getop,getop,getop,no,getop,getop,no,getop,getop,getop
GE:
	.data	getop,no,getop,no,getop,no,getop,no,no,no,getop,no,getop,no,getop,no
GT:
	.data	getop,no,getop,no,no,no,no,no,no,getop,no,no,getop,no,no,no
ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm
SHOP:
	.data	lsl
	.bss	1023
	.data	lsr
	.bss	1023
	.data	asr
	.bss	1023
	.data	ror
lsADDR:
	.data	soff, soff, soff, soff, rim
WARM:	 
