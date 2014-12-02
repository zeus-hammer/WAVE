;;; emulator for warm - phase2p
;;; (c) d.r.smith modsoussi bijan
	.requ	wpc, r15
	.requ	ci, r14
	.requ	rhs, r14
	.requ	op, r13
	.requ	lhs, r12
	.requ	dst, r11
	.requ	shiftC, r9
	.requ	wCCR, r8
	.requ	alwaysZ, r5
	.requ	wlr, r4
	.requ	work0, r0
 	.requ	work1, r1
		
	.equ	maskA, 0x7800		;1 in 14,13,12th bit
	.equ	maskShift, 0x3F
	.equ	maskLow4, 0xf
	.equ	maskValue, 0x1ff
	.equ	maskExp, 0x1f00
	.equ	flip, 0xffffffff
	.equ	mask23to0, 0xffffff

	lea	WARM,work0
	trap	$SysOverlay

;;; N.B.
;;; - RHS and CI are the same register, this allows us to cut the
;;; mv ci, rhs      instruction that was common to all addressing
;;; modes. we save an instruction with this, but it's not exactly
;;; clear when you see RHS being manipulated and we didn't put 
;;; anything in it. we are manipulating the CI and then throwing
;;; it away because the next instruction gets its own CI
	
;;; SADS
;;; 
;;; -the wpc being used in instructions
;;; -mov's into the pc
;;; -anding the address of the wpc to make sure we don't
;;; 	wrap out
;;; -linking? how does the lr actually get accessed
;;; -how do we know we're getting back from the last call stack?
	
;;; HAPPIES
;;; 
;;; -we can save multiple instructions by fucking up the ci
;;; 	on it's last go-round. applies in:
;;; 	shifting, dst, src, shopcode etc...
	jmp	fetch

;;; --------------------BEGIN FETCHING THE INSTRUCTION-------------------
;;; 5 INSTRUCTIONS
fetch3:	mov	ccr,wCCR	;----------------------------TOP-------------------;
fetch2:	mov	rhs, REGS(dst)	;----------------------------TOP-------------------;
fetch:	mov	WARM(wpc),ci	;----------------------------TOP-------------------;
	mov	ci, work0
	shr	$29, work0	;high 3 condition bits in work0
;;; to do it or not to do it. that is the question	
	cmovg	COND(work0), rip
;;; yes, we do it
getop:	mov 	ci,op
	shl	$3,op
	shr	$26,op
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
;;; ----------------------END FETCH--------------------------------------
;;; ARITH
;;; 13 INSTRUCTIONS
noDST:	mov     ci, lhs		;get dst and lhs
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
	add	$1, wpc
	mov	ADDR(work0), rip
;;; LOAD STORE
ls:
;;; BRANCHING
branch:	add 	ci, wpc
	and	$mask23to0, wpc
	shr	$22,ci
	mov	ci, ccr	
	jne	fetch
	mov	wpc, wlr
	add	$1, wlr
	jmp	fetch
;;; -------------------END INSTRUCTION TYPES------------------------------
;;; -------------------BEGIN ADDRESSING MODES------------------------------
;;; Immediate Mode
;;; 7 INSTRUCTIONS
imd:	mov	ci, work0
	and	$maskExp, work0	;exponent
	shr	$9, work0
	and	$maskValue, rhs	;value
	shl	work0, rhs	;shifted value in rhs
	mov     INSTR(op), rip
;;; Register Shifted by Immediate Mode
;;; 10 INSTRUCTIONS
rim:	mov	ci, shiftC
	and	$maskShift, shiftC	;shift count has the bits number to shift
	mov	ci, work0
	shl	$20, work0
	shr	$30, work0	;work0 now has the shop
	shl	$22, rhs
	shr	$28, rhs 	;now we have src reg 2 in rhs
	mov	REGS(rhs), rhs	;rhs now has the value that was in register number rhs
	mov 	SHOP(work0), rip
;;; Register Shifted by Register Mode
;;; 11 INSTRUCTIONS
rsr:	mov	$maskLow4, shiftC	; shiftC := 15
	and 	ci, shiftC	; shiftC := shiftC & ci; to get shift register
	mov	REGS(shiftC), shiftC ; shiftC now has whatever was stored in the 
	mov 	ci, work0
	shl	$20, work0
	shr	$30, work0	; work0 now has the shift op code
	shl	$22, rhs
	shr	$28, rhs	; rhs has rhs register
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in rhs (memory)
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
	and	ci, work0	;work0 now has src reg 3
	shl	$22, rhs
	shr	$28, rhs	; rhs now has src reg 2
	mov	REGS(rhs), rhs	; rhs now has whatever was stored in the correspondent register
	mov	REGS(work0), work0 ;work0 now has whatever was stored in the correspondent register
	mul	work0, rhs
;;; -------------------------END ADDRESSING MODES-------------------------------
	
;;; -------------------------BEGIN OPERATIONS------------------------------------
;;; thoughts and improvements for all operations:
;;; 4 INSTRUCTION(S)	
add:	add	REGS(lhs), rhs
	jmp 	fetch2
adc:	mov	wCCR, work0
	shr	$2, work0
	shl	$31, work0
	add	REGS(lhs), rhs
	add	work0, rhs
	jmp	fetch2
;;; 5 INSTRUCTION(S)
;;; backwards (like div)
sub:	mov	REGS(lhs), work0
	sub	rhs, work0
	mov	work0, REGS(dst)
	jmp 	fetch
;;; 4 INSTRUCTION(S)	
eor:	xor	REGS(lhs), rhs
	jmp 	fetch2
;;; 4 INSTRUCTION(S)	
orr:	or	REGS(lhs), rhs
	jmp	fetch2
;;; 3 INSTRUCTION(S)	
and:	and	REGS(lhs), rhs
	jmp 	fetch2
;;; 4 INSTRUCTION(S)
mul:	mul	REGS(lhs), rhs
	jmp	fetch2
;;; 5 INSTRUCTION(S)
div:	mov 	REGS(lhs), work0
	div	rhs, work0
	mov	work0, REGS(dst)
	jmp	fetch	
;;; 3 INSTRUCTION(S)
mov:	jmp 	fetch2
;;; 5 INSTRUCTION(S)
mvn:	xor	$flip, rhs
	jmp	fetch2
swi:	mov	REGS(alwaysZ), work0
	trap 	rhs
	jmp	fetch
ldm:
stm:
ldr:
str:
ldu:	
stu:
adr:
;;; second set of instrucions. for use when we don't 
addCC:	add	REGS(lhs), rhs
	jmp 	fetch3
adcCC:	mov	wCCR, work0
	shr	$2, work0
	shl	$31, work0
	add	REGS(lhs), rhs
	add	work0, rhs
	jmp	fetch3
;;; 5 INSTRUCTION(S)
;;; backwards (like div)
subCC:	mov	REGS(lhs), work0
	sub	rhs, work0
	mov	ccr,wCCR
	mov	work0, REGS(dst)
	jmp 	fetch
;;; 5 INSTRUCTION(S)	
cmpCC:	mov 	REGS(lhs), work0
	sub 	rhs, work0
	mov	ccr, wCCR
	jmp 	fetch
;;; 5 INSTRUCTION(S)	
eorCC:	xor	REGS(lhs), rhs
	jmp 	fetch3
;;; 5 INSTRUCTION(S)	
orrCC:	or	REGS(lhs), rhs
	jmp	fetch3
;;; 4 INSTRUCTION(S)	
andCC:	and	REGS(lhs), rhs
	jmp 	fetch3
;;; 4 INSTRUCTION(S)
tstCC:	test	REGS(lhs), rhs
	jmp	fetch3
;;; 4 INSTRUCTION(S)
mulCC:	mul	REGS(lhs), rhs
	jmp	fetch3
;;; 6 backwards (like sub)
divCC:	mov 	REGS(lhs), work0
	div	rhs, work0
	mov	ccr,wCCR		
	mov	work0, REGS(dst)
	jmp	fetch
;;; 4 INSTRUCTION(S)
movCC:	mov	rhs, REGS(dst)
;;; 	and	rhs,rhs
	mov	ccr,wCCR			
	jmp	fetch
;;; 4 INSTRUCTIONS
mvnCC:	xor	$flip,rhs
	jmp	fetch3
swiCC:	trap	rhs
	jmp 	fetch3
ldmCC:
ldrCC:
strCC:
lduCC:
stuCC:
	
;;; no we don't do it
next:	add	$1, wpc
	jmp	fetch
REGS:
	.data	0,0,0,0,0,0,0,0,0,0,0,0,0,0x00ffffff,0,0
INSTR:
	.data 	add,adc,sub,0,eor,orr,and,0,mul,0,div,mov,mvn,swi,ldm,stm,ldr,str,ldu,stu,adr,0,0,0,0,0,0,0,0,0,0,0,addCC,adcCC,subCC,cmpCC,eorCC,orrCC,andCC,tstCC,mulCC,0,divCC,movCC,mvnCC,swiCC,ldmCC,0,ldrCC,strCC,lduCC,stuCC
TYPE:
	.data	ALL3,ALL3,ALL3,noDST,ALL3,ALL3,ALL3,noDST,ALL3,ALL3,ALL3,oDST,oDST,oRHS,ALL3,ls,ls,ls,ls,ls,ls,0,0,0,branch,branch,branch,branch,0,0,0,0,ALL3,ALL3,ALL3,noDST,ALL3,ALL3,noDST,ALL3,ALL3,0,ALL3,oDST,oDST,oRHS,ALL3,ls,ls,ls,ls,ls,ls,0,0,0,branch,branch,branch,branch
COND:
	.data	0,never,equal,ne,lesst,lesse,greate,gt
NEVER:
	.data   next,next,next,next,next,next,next,next,next,next,next,next,next,next,next,next
EQ:
	.data	next,next,next,next,getop,getop,getop,next,next,next,next,next,next,getop,getop,getop
NE:
	.data	getop,getop,getop,getop,next,next,next,getop,getop,getop,getop,getop,getop,next,next,next
LT:
	.data	next,getop,next,getop,next,getop,next,getop,getop,next,getop,getop,next,getop,next,getop
LE:
	.data	next,getop,next,getop,getop,getop,getop,getop,getop,next,getop,getop,next,getop,getop,getop
GE:
	.data	getop,next,getop,next,getop,next,getop,next,getop,next,getop,next,getop,next,getop,next
GT:
	.data	getop,next,getop,next,next,next,next,next,next,getop,next,next,getop,next,next,next
ADDR:
	.data 	imd, imd, imd, imd, rim, rsr, rpm
SHOP:
	.data	lsl, lsr, asr, ror
WARM:	 
