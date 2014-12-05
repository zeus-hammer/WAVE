;;; A test for the memory instructions of WAVE
;;; it tries to write outside the bounds of the WARM memory
;;; not guaranteed to test all addressing issues
;;; (c) 2010 Antonio Lorenzo
	
main:	mvn	r0,#0
posupdate:
	mvn	r3,#0x3f
	mov	r1,#33
stuPOS:	stu	r1,[r3,#1]
	mov	r0,r1
	swi	#SysPutNum 	; fifth value, 33
	mov	r0,#10
	swi	#SysPutChar

lduPOS:	ldu	r1,[r3,#1]
	mov	r0,r1
	swi	#SysPutNum	; sixth value, 0
	mov	r0,#10
	swi	#SysPutChar
	
	mov	r0,r3		; value 7, highmem 0xffffc2, 16,777,154
	swi	#SysPutNum
	mov	r0,#10
	swi	#SysPutChar

negupdate:
	mov	r2,#1
	mov	r1,#99
stuNEG:	stu	r1,[r2,#-6]
	mov	r0,r2
	swi	#SysPutNum	;value 8, 16777211
	mov	r0,#10
	swi	#SysPutChar
	mov	r0,r1
	swi	#SysPutNum	;value 9, 99
	mov	r0,#10	
	swi	#SysPutChar
	mov	r1,#0
lduNEG:	ldu	r1,[r2,#-6]
	mov	r0,r2
	swi	#SysPutNum	;value 10, 16777205
	mov	r0,#10
	swi	#SysPutChar
	mov	r0,r1
	swi	#SysPutNum	;value 11, 0
	mov	r0,#10
	swi	#SysPutChar

addres:	mvn	r1,#0x3f
	mov	r2,#3
	adr	r0,[r1,r2,lsl #0]
	swi	#SysPutNum
	
	swi	#SysHalt