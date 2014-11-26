;;; emulator for warm - phase 2
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	ci, r14
	.requ	op, r13
	.requ	lhs, r12
	.requ	dst, r11
	.requ 	rhs, r10
	.requ	shiftC, r9
	.requ	wCCR, r8
	.requ	cond, r5
	.requ	work0, r0
 	.requ	work1, r1
		
	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskShift, 0x3F
	.equ	maskLow4, 0xf
	.equ	maskHigh4, 0xf0000000
	.equ	maskValue, 0x1ff
	.equ	maskExp, 0x1f00
	
	lea	WARM,work0
	trap	$SysOverlay

;;; --------------------BEGIN FETCHING THE INSTRUCTION-------------------

;;; we should double up on these. one for after the wCCR has been set for the
;;; first time and one for before. cause if the wCCR never gets set, we can
;;; skip all the cc deciphering cause itll just pretty much be an always
;;; statement

;;; 5 INSTRUCTIONS
fetch:	mov	WARM(wpc),ci
	mov	ci, work0
	shr	$29, work0	;high 3 condition bits in work0
	cmovg	COND(work0,wRRC), rip
;;; to do it or not to do it. that is the question
	
;;; snag the opcode
getop:	mov 	ci,op
	shl	$3,op
	shr	$27,op	
;;; ----------------------END FETCH--------------------------------------

;;; ARITH
;;; 13 INSTRUCTIONS
getLHS:	mov     ci, lhs		;get dst and lhs
	shr     $15, lhs
	and     $maskLow4, lhs
getDST:	mov     ci, dst
	shr     $19, dst
	and     $maskLow4, dst
getRHS:	mov 	$maskA, work0
	and 	ci,work0
	shr	$12, work0	;work 0 holds the addressing mode
	mov	ADDR(work0), rip

ls:	
branch:


;;; -------------------END INSTRUCTION TYPES------------------------------

	
	
;;; -------------------BEGIN ADDRESSING MODES------------------------------
	
;;; Immediate Mode
;;; 7 INSTRUCTIONS
imd:	mov	ci, work0
	and	$maskExp, work0	;exponent
	shr	$9, work0
	mov	ci, rhs
	and	$maskValue, rhs	;value
	shl	work0, rhs	;shifted value in rhs
	mov     INSTR(op), rip
	
;;; Register Shifted by Immediate Mode
;;; 10 INSTRUCTIONS
rim:	mov	ci, rhs
	shl	$22, rhs
	shr	$28, rhs 	;now we have src reg 2 in rhs
	mov	REGS(rhs), rhs	;rhs now has the value that was in register number rhs
	mov	ci, shiftC
	and	$maskShift, shiftC	;shift count has the bits number to shift
	mov	ci, work0
	shl	$20, work0
	shr	$30, work0	;work1 now has the shop
	mov 	SHOP(work0),rip

;;; Register Shifted by Register Mode
;;; 11 INSTRUCTIONS
rsr:	mov	$maskLow4, shiftC	; shiftC := 15
	and 	ci, shiftC	; shiftC := shiftC & ci; to get shift register
	mov	REGS(shiftC), shiftC ; shiftC now has whatever was stored in the 
	mov	ci, rhs	
	shl	$22, rhs
	shr	$28, rhs	; rhs has rhs register
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in rhs (memory)
	mov 	ci, work0
	shl	$20, work0
	shr	$30, work0	; work0 now has the shift op code
	mov	SHOP(work0), rip

;;; --------------------------BEGIN SHIFTING MODES-------------------------
	
;;; logical shift left
;;; 2 INSTRUCTIONS
lsl:	shl	shiftC, rhs
	mov     INSTR(op), rip

;;; logical shift right
;;; 2 INSTRUCTIONS
lsr:	shr	shiftC, rhs
	mov     INSTR(op), rip

;;; arithmetic shift right
;;; 2 INSTRUCTIONS
asr:	sar	shiftC, rhs
	mov     INSTR(op), rip
	
;;; rotate right shift
;;; 7 INSTRUCTIONS
ror:	mov	rhs, work0
	mov	$32, work1	
	sub	shiftC, work1	;work1 := 32-shr
	shl	work1, work0	;work1 is low shr bits shifted (32-shr) to the left
	shr	shiftC, rhs	;work2 is the highest (32-shr) bits shifted shr to the right
	add	work0, rhs
	mov     INSTR(op), rip

;;; -------------------------END SHIFTING MODES----------------------
	
;;; Register Product Mode
;;; 8 INSTRUCTIONS
rpm:	mov	$maskLow4, work0
	and	ci, work0	; work0 now has src reg 3
	mov	ci, rhs
	shl	$22, rhs
	shr	$28, rhs	; rhs now has src reg 2
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in the correspondent register
	mov	REGS(work0), work0 ;work0 now has whatever was stored in the correspondent register
	mul	work0, rhs
;;; -------------------------END ADDRESSING MODES--------------------------


;;; -------------------------BEGIN OPERATIONS------------------------------------
;;; thoughts and improvements for all operations:
;;; the adding one to the wpc is a terrible monkey patch
;;; how can we jump back up with a reloaded wpc in one instruction?

	
;;; 4 INSTRUCTION(S)	
add:	add	REGS(lhs), rhs
	mov	rhs, REGS(dst)
	add	$1, wpc
	jmp 	fetch

adc:

;;; 5 INSTRUCTION(S)
;;; backwards (like div)
sub:	mov	REGS(lhs), work0
	sub	rhs, work0
	mov	work0, REGS(dst)
	add	$1, wpc
	jmp 	fetch
	
;;; 5 INSTRUCTION(S)	
cmp:	mov 	REGS(lhs), work0
	sub 	rhs, work0
	mov	ccr, wCCR
	add	$1, wpc
	jmp 	fetch
	
;;; 5 INSTRUCTION(S)	
eor:	xor	REGS(lhs),rhs
	mov 	rhs, REGS(dst)
	mov 	ccr, wccr
	add	$1, wpc
	jmp 	fetch

;;; 5 INSTRUCTION(S)	
orr:	or	REGS(lhs), rhs
	mov	rhs, REGS(dst)
	mov	ccr, wccr
	add	$1, wpc
	jmp	fetch
	
;;; 4 INSTRUCTION(S)	
and:	and	REGS(lhs), rhs
	mov 	rhs, REGS(dst)
	mov	ccr, wccr
	add	$1, wpc
	jmp 	fetch
	
;;; 4 INSTRUCTION(S)
tst:	test	REGS(lhs), rhs
	mov 	ccr, wccr
	add	$1, wpc
	jmp	fetch
	
;;; 4 INSTRUCTION(S)
mul:	mul	REGS(lhs), rhs
	mov	rhs, REGS(dst)
	add	$1, wpc
	jmp	fetch
	
;;; 5 INSTRUCTION(S)
;;; backwards (like sub)
div:	mov 	REGS(lhs), work0
	div	rhs, work0
	mov	work0, REGS(dst)
	add	$1, wpc
	jmp	fetch	
	
;;; 3 INSTRUCTION(S)
mov:	mov	rhs, REGS(dst)
	add	$1, wpc
	jmp 	fetch

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
	.data 	add,adc,sub,cmp,eor,orr,and,tst,mul,0,div,mov,mvn,swi,ldm,stm,ldr,str,ldu,stu,adr,0,0,0,bf,bb,blf,blb
TYPE:
	.data	ar, ar, ar, ar, ar, ar, ar, ar, ar, ar, ar, ar, ar, ar, ar,ls,ls,ls,ls,ls,0,0,0,b,b,b,b
COND:
	.data	always, never, eq, ne, lt, le, ge, gt
ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm
SHOP:
	.data	lsl, lsr, asr, ror
WARM:	 
