;;; A documented clone.
;;; (c) 2010 duane a. bailey
	.equ	OPCB,  0b11000
	.equ	OPCCMP,0b00011
	.equ	OPCTST,0b00111
	.equ	OPCSWI,0b01101
	.equ	OPCMOV,0b01011
	.equ	OPCLDR,0b10000
start:	adr	r0,headstr1
	bl	putcmt
	adr	r0,headstr2
	bl	putcmt
	adr	r2,data
	adr	r1,start
loop:	cmp	r1,r2
	bge	codedone
	ldr	r3,[r1]		; r3 holds the current instruction
	mov	r0,r1
	bl	putlabel
	mov	r0,#':
	swi	#SysPutChar
	
	bl	tab
	;; grab opcode
	mov	r4,r3,lsr#23	; grab opcode bits
	and	r4,r4,#0x1f	;    into r4
	bl	putopcode
	bl	tab
	
	cmp	r4,#OPCB
	blt	_over2
	mvn	r0,#0xff000000	; compute displacement
	and	r0,r3,r0
	mov	r0,r0,lsl#8
	add	r0,r1,r0,asr#8	; add displacement to pc
	bl	putlabel	; print the label
	b	_eoln
	
_over2:	cmp	r4,#OPCCMP
	beq	_skipdest
	cmp	r4,#OPCTST
	beq	_skipdest
	cmp	r4,#OPCSWI
	beq	_skipdest
	mov	r0,r3,lsr#19	; get destination register
	and	r0,r0,#0xf
	bl	putreg
	bl	comma
_skipdest: cmp	r4,#OPCMOV
	bge	_skiplhs
	mov	r0,r3,lsr#15
	and	r0,r0,#0xf
	bl	putreg
	bl	comma
_skiplhs: cmp	r4,#OPCLDR
	bge	_ldst
	ands	r0,r3,#0x4000
	bne	_regrhs
	mov	r0,#'\#
	swi	#SysPutChar
	and	r0,r3,#0x1ff
	mov	r5,r3,lsr#9
	and	r5,r5,#0x3f
	mov	r0,r0,lsl r5
	bl	putshx
	b	_eoln
_regrhs:
	mov	r0,r3,lsr#6
	and	r0,r0,#0xf
	bl	putreg
	bl	comma
	mov	r5,r3,lsr#12
	ands	r5,r5,#0x3
	cmp	r5,#1
	bgt	_printreg
	mov	r0,r3,lsr#10
	and	r0,r0,#0x3
	ldr	r0,[r0,#shoptab]
	bl	puts
	cmp	r5,#1
	beq	_printreg0
	mov	r0,#'\#
	swi	#SysPutChar
	and	r0,r3,#0x3f
	bl	putdec
	b	_eoln
_printreg0: mov	r0,#'\ 
	swi	#SysPutChar
_printreg:
	ands	r0,r3,#0xf
	bl	putreg
	b	_eoln
_ldst:	mov	r0,#'[
	swi	#SysPutChar
	mov	r5,#15
	and	r0,r5,r3,lsr #15
	bl	putreg
	bl	comma
	ands	r0,r3,#0x4000	; check the shop bit
	bne	_ldstshop
	mov	r0,#'#
	swi	#SysPutChar
	mov	r0,r3,lsl#18	; sign extend displacement
	mov	r0,r0,asr#18
	bl	putshx
	b	_ldstfini
_ldstshop:
	mov	r0,r3,lsr#6
	and	r0,r0,#0xf
	bl	putreg
	bl	comma	
	mov	r0,r3,lsr#10
	and	r0,r0,#3
	ldr	r0,[r0,#shoptab]
	bl	puts
	mov	r0,#'\#
	swi	#SysPutChar
	and	r0,r3,#0x1f
	bl	putdec
_ldstfini:	
	mov	r0,#']
	swi	#SysPutChar
_eoln:	bl	nl
	add	r1,r1,#1
	b	loop
	
codedone:
	adr	r0,torsostr
	bl	putcmt
	adr	r2,strings
dataloop: cmp	r1,r2
	bge	datadone
	mov	r0,r1
	bl	putlabel
	mov	r0,#':
	swi	#SysPutChar
	bl	tab
	adr	r0,datastr
	bl	puts
	bl	tab
	ldu	r0,[r1,#1]
	bl	putlabel
	bl	nl
	b	dataloop
	
datadone:
	adr	r0,kneestr
	bl	putcmt
	adr	r2,end
stringloop:	cmp	r1,r2
	bge	done
	mov	r0,r1
	bl	putlabel
	mov	r0,#':
	swi	#SysPutChar
	bl	tab
	adr	r0,stringstr
	bl	puts
	bl	tab
	mov	r0,#'\"
	swi	#SysPutChar
_loop:	ldus	r0,[r1,#1]
	beq	_over
	swi	#SysPutChar
	b	_loop
_over:	mov	r0,#'\"
	swi	#SysPutChar
	bl	nl
	b	stringloop
done:	adr	r0,finistr
	bl	putcmt
	swi	#SysHalt
	

;;; prints an opcode
putopcode:
	stu	lr,[sp,#-1]
	stm	sp,#0x3		; save registers 0 and 1
	;; grab the instruction
	ldr	r0,[r4,#optab]
	bl	puts		;print base
	mov	r1,r3,lsr #29
	ldr	r0,[r1,#contab]	;grab condition code
	bl	puts		;print
	ands	r1,r3,#0x10000000 ; s bit
	beq	_fini
	mov	r0,#'s		; print s-bit
	swi	#SysPutChar
_fini:
	ldm	sp,#0x3		; restore the registers
	ldu	pc,[sp,#1]	; return
	
;;; prints a label
putlabel:
	stu	lr,[sp,#-1]	; save lr (call puthx)
	stu	r0,[sp,#-1]	; save r0, we're about to trash it
	mov	r0,#'x
	swi	#SysPutChar
	ldu	r0,[sp,#1]	; restore the number
	bl	puthx		; print in hex
	ldu	pc,[sp,#1]	; return
	
;;; prints a register
putreg:
	stu	lr,[sp,#-1]	; save lr (calls putdec)
	ldr	r0,[r0,#regtab]	; get register name
	bl	puts		; print
	ldu	pc,[sp,#1]	; return

;;; print r0 in hex
putshx:	stu	lr,[sp,#-1]	; save return address (recursive)
	cmp	r0,#0		; check for sign
	bge	_pos
	mvn	lr,r0
	mov	r0,#'-		; negative sign
	swi	#SysPutChar
	add	r0,lr,#1	; inverted bits
_pos:		
	cmp	r0,#10
	blt	_dec
	stu	r0,[sp,#-1]
	mov	r0,#'0
	swi	#SysPutChar
	mov	r0,#'x
	swi	#SysPutChar
	ldu	r0,[sp,#1]
	bl	puthx
	b	_fini
_dec:	bl	putdec
_fini:	ldu	pc,[sp,#1]
	
puthx:	stu	lr,[sp,#-1]	; save return address (recursive)
	cmp	r0,#0xf		; is this a big number?
	blt	_print		; no: branch to non-recursive part
	stu	r0,[sp,#-1]	; save r0
	mov	r0,r0,lsr#4	; divide by 16
	bl	puthx		; print leftmost digits recursively
	ldu	r0,[sp,#1]	; restore r0
	and	r0,r0,#0xf	; mod by 16
_print:	cmp	r0,#10		; is this a letter?
	addlt	r0,r0,#'0	; no: add '0'
	addge	r0,r0,#87	; yes: add 'a'-10
	swi	#SysPutChar	; print it!
	ldu	pc,[sp,#1]
	
;;; print r0 in decimal
putdec:	stu	lr,[sp,#-1]	; save lr (recursive)
	cmp	r0,#0		; check for sign
	bge	_pos
	mvn	lr,r0
	mov	r0,#'-		; negative sign
	swi	#SysPutChar
	add	r0,lr,#1	; inverted bits
_pos:	cmp	r0,#10		; a multidigit value?
	blt	_print		; no: just print
	stu	r0,[sp,#-1]	; yes: save r0
	div	r0,r0,#10	; divide by 10
	bl	putdec		;  and print leftmost digits
	ldr	r0,[sp]		; restore r0 copy
	div	lr,r0,#10	; compute r0 mod 10...using lr!
	mul	lr,lr,#10	; this is missing right digit
	ldu	r0,[sp,#1]	; recover r0, again
	sub	r0,r0,lr	; subtract, for rightmost digit
_print:	add	r0,r0,#'0	; offset by '0'
	swi	#SysPutChar	; print it
	ldu	pc,[sp,#1]	; return
	
;;; prints comments pointed to by r0
putcmt:	stu	lr,[sp,#-1]
	stu	r0,[sp,#-1]
	mov	r0,#0x3b
	swi	#SysPutChar
	swi	#SysPutChar
	swi	#SysPutChar
	mov	r0,#'\ 
	swi	#SysPutChar	
	ldu	r0,[sp,#1]
	bl	puts
	bl	nl
	ldu	pc,[sp,#1]
	
;;; prints string pointed to by r0
puts:	stm	sp,#0x4800
	mov	r11,r0
	b	_enter
_loop:	swi	#SysPutChar
_enter:	ldus	r0,[r11,#1]
	bne	_loop
	ldm	sp,#0x8800
	
;;; prints a newline
nl:	mov	r0,#'\n
	swi	#SysPutChar
	mov	pc,lr
	
;;; print a tab
tab:	mov	r0,#'\t
	swi	#SysPutChar
	mov	pc,lr
	
;;; print a tab
comma:	mov	r0,#',
	swi	#SysPutChar
	mov	pc,lr
	
data:	
optab:	.data	addstr,adcstr,substr,cmpstr,eorstr,orrstr,andstr,tststr
	.data	mulstr,mlastr,divstr,movstr,mvnstr,swistr,ldmstr,stmstr
	.data	ldrstr,strstr,ldustr,stustr,adrstr,illstr,illstr,illstr
	.data	bstr,bstr,blstr,blstr,illstr,illstr,illstr,illstr
contab:	.data	alstr,nvstr,eqstr,nestr,ltstr,lestr,gestr,gtstr
shoptab:.data	lslstr,lsrstr,asrstr,rorstr
regtab:	.data	r0str,r1str,r2str,r3str,r4str,r5str,r6str,r7str
	.data	r8str,r9str,r10str,r11str,r12str,spstr,lrstr,pcstr
strings:	
r0str:	.string	"r0"
r1str:	.string	"r1"
r2str:	.string	"r2"
r3str:	.string	"r3"
r4str:	.string	"r4"
r5str:	.string	"r5"
r6str:	.string	"r6"
r7str:	.string	"r7"
r8str:	.string	"r8"
r9str:	.string	"r9"
r10str:	.string	"r10"
r11str:	.string	"r11"
r12str:	.string	"r12"
spstr:	.string	"sp"
lrstr:	.string	"lr"
pcstr:	.string	"pc"
lslstr:	.string	"lsl"
lsrstr:	.string	"lsr"
asrstr:	.string	"asr"
rorstr:	.string	"ror"
alstr:	.string	""
nvstr:	.string	"nv"
eqstr:	.string	"eq"
nestr:	.string	"ne"
ltstr:	.string	"lt"
lestr:	.string	"le"
gestr:	.string	"ge"
gtstr:	.string	"gt"
addstr:	.string	"add"
adcstr:	.string	"adc"
substr:	.string	"sub"
cmpstr:	.string	"cmp"
eorstr:	.string	"eor"
orrstr:	.string	"orr"
andstr:	.string	"and"
tststr:	.string	"tst"
mulstr:	.string "mul"
mlastr:	.string "mla"
divstr:	.string "div"
movstr:	.string	"mov"
mvnstr:	.string	"mvn"
swistr:	.string	"swi"
ldmstr:	.string	"ldm"
stmstr:	.string	"stm"
ldrstr:	.string "ldr"
strstr:	.string "str"
ldustr:	.string	"ldu"
stustr:	.string "stu"
adrstr:	.string "adr"
bstr:	.string "b"
blstr:	.string	"bl"
illstr:	.string	"???"
datastr:.string ".data"
stringstr:.string ".string"
headstr1: .string "A clone program for the Great Class of 2010, by Duane."
headstr2: .string "The output of this program should be the same as the source."
torsostr: .string "Tables of pointers."
kneestr: .string "Strings."
finistr: .string "All told out."
end:	