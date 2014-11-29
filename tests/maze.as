;;; A small program to solve mazes. -*- mode: asm; compile-command: "waa -l maze.as" -*-
;;; Input is a maze, with S marking start, F marking finish, nonspace are walls
;;; Output is solution, with shortest path marked by asterisks.
;;; (c) 2010 duane a. bailey
	bl	main		; do the main routine and quit
	swi	#SysHalt
	
start:	.data	0		; location of start (col in high 16, row low)
finish:	.data	0		; location of finish
queue:	.data	0		; beginning of queue area
queueEnd:	.data	0	; last cell of queue area
head:	.data	0		; head location of the queue
tail:	.data	0		; tail location of queue

lines:	.data	0		; line count
line:	.data	0		; pointer to array of pointers to lines
length:	.data	0		; pointer to array of line lengths
freeMem:.data	maze		; pointer to first unused cell in memory
	
main:	stu	lr,[sp,#-1]
	bl	readMaze	; read in the maze
	bl	solveMaze
	cmp	r0,#1
	bleq	colorMaze
	bl	printSolution	; print out the solution
	ldu	pc,[sp,#1]
	
colorMaze:
	stu	lr,[sp,#-1]
	stm	sp,#0xfe
	ldr	r0,finish
	bl	split
	bl	getDist
	;; r3 is the distance
_loop:	mov	r4,r1
	mov	r5,r2
	sub	r6,r3,#1
	mov	r0,#'*
	bl	put
	cmp	r6,#0
	blt	_done
	;; we now look around for a smaller distance
	;; north
_north:	sub	r1,r4,#1
	mov	r2,r5
	bl	isValid
	cmp	r0,#0
	beq	_east
	bl	isWall
	cmp	r0,#0
	bne	_east
	bl	visited
	cmp	r0,#0
	beq	_east
	bl	getDist
	cmp	r3,r6
	beq	_loop
	;; we now look around for a smaller distance
	;; east
_east:	mov	r1,r4
	add	r2,r5,#1
	bl	isValid
	cmp	r0,#0
	beq	_south
	bl	isWall
	cmp	r0,#0
	bne	_south
	bl	visited
	cmp	r0,#0
	beq	_south
	bl	getDist
	cmp	r3,r6
	beq	_loop
	;; we now look around for a smaller distance
	;; south
_south:	add	r1,r4,#1
	mov	r2,r5
	bl	isValid
	cmp	r0,#0
	beq	_west
	bl	isWall
	cmp	r0,#0
	bne	_west
	bl	visited
	cmp	r0,#0
	beq	_west
	bl	getDist
	cmp	r3,r6
	beq	_loop
	;; we now look around for a smaller distance
	;; west
_west:	mov	r1,r4
	sub	r2,r5,#1
	bl	isValid
	cmp	r0,#0
	beq	_done
	bl	isWall
	cmp	r0,#0
	bne	_done
	bl	visited
	cmp	r0,#0
	beq	_done
	bl	getDist
	cmp	r3,r6
	beq	_loop
_done:	ldm	sp,#0xfe
	ldu	pc,[sp,#1]
	
solveMaze:
	stu	lr,[sp,#-1]
	stm	sp,#0xe
	ldr	r0,start	; add starting location to queue
	bl	split
	mov	r3,#0		; distance zero
	bl	add
_loop:				; main queue removal loop
	bl	remove
	cmp	r0,#0		; if queue runs dry, r0 is zero
	beq	_done
	bl	visited		; if we've already visited this place, loop
	cmp	r0,#0
	bne	_loop
	bl 	visit		; no? visit it, then
	bl	setDist
	bl	pack
	mov	r0,r0,lsl#16
	mov	r0,r0,lsr#16
	ldr	r4,finish
	cmp	r4,r0		; have we finished?
	beq	_madeit		; yes: make solution
	bl	queueNeighbors	;  enqueue all suitable neighbors
	b	_loop
	ldu	pc,[sp,#1]
_madeit:
	mov	r0,#1
	b	_fini
_done:
	mov	r0,#0
_fini:	ldm	sp,#0xe
	ldu	pc,[sp,#1]
	
putCoord:
	stu	r0,[sp,#-1]
	mov	r0,#'[
	swi	#SysPutChar
	mov	r0,r1
	swi	#SysPutNum
	mov	r0,#',
	swi	#SysPutChar
	mov	r0,r2
	swi	#SysPutNum
	mov	r0,#']
	swi	#SysPutChar
	ldu	r0,[sp,#1]
	mov	pc,lr

puts:	stm	sp,#0x3
	mov	r1,r0
_loop:	ldus	r0,[r1,#1]
	beq	_done
	swi	#SysPutChar
	b	_loop
_done:	ldm	sp,#0x3
	mov	pc,lr
	
;;; inputs: (r1,r2) is the current position
;;; outputs: none
;;; This routine simply enqueues all adjacent non-wall locations not previouly
;;; visited
queueNeighbors:
	stu	lr,[sp,#-1]
	stm	sp,#0x1f
	bl	pack
	mov	r4,r1
	mov	r5,r2
	add	r3,r3,#1 	; increase the distance to neighbors
	;; look north
_north:	sub	r1,r4,#1
	mov	r2,r5
	bl	isValid
	cmp	r0,#0
	beq	_east
	bl	isWall
	cmp	r0,#0
	bne	_east
	bl	visited
	cmp	r0,#0
	bne	_east
	bl	add
	;; look east
_east:	add	r2,r5,#1
	mov	r1,r4
	bl	isValid
	cmp	r0,#0
	beq	_south
	bl	isWall
	cmp	r0,#0
	bne	_south
	bl	visited
	cmp	r0,#0
	bne	_south
	bl	add
	;; look south
_south:	add	r1,r4,#1
	mov	r2,r5
	bl	isValid
	cmp	r0,#0
	beq	_west
	bl	isWall
	cmp	r0,#0
	bne	_west
	bl	visited
	cmp	r0,#0
	bne	_west
	bl	add
	;; look west
_west:	sub	r2,r5,#1
	mov	r1,r4
	bl	isValid
	cmp	r0,#0
	beq	_fini
	bl	isWall
	cmp	r0,#0
	bne	_fini
	bl	visited
	cmp	r0,#0
	bne	_fini
	bl	add
_fini:	
	ldm	sp,#0x1f
	ldu	pc,[sp,#1]

split:	mov	r1,r0
	mov	r2,r0
	mov	r3,r0
	mov	r1,r1,lsr#8
	and	r1,r1,#0xff
	and	r2,r2,#0xff
	mov	r3,r3,lsr#16
	mov	pc,lr
	
pack:	orr	r0,r2,r1,lsl#8
	orr	r0,r0,r3,lsl#16
	mov	pc,lr

isWall:	stu	lr,[sp,#-1]
	bl	get
	and	r0,r0,#0xff
	cmp	r0,#'\ 
	beq	_no
	mov	r0,#1
	b	_fini
_no:	mov	r0,#0
_fini:	ldu	pc,[sp,#1]
	
getDist:
	stu	lr,[sp,#-1]
	bl	get
	mov	r3,r0,lsr#17
	ldu	pc,[sp,#1]
	
setDist:stu	lr,[sp,#-1]
	stm	sp,#0x1f
	bl	get
	orr	r0,r0,r3,lsl#17
	bl	put
	ldm	sp,#0x1f
	ldu	pc,[sp,#1]
	
visited:stu	lr,[sp,#-1]
	bl	get
	mov	r0,r0,lsr#16
	and	r0,r0,#1
	ldu	pc,[sp,#1]
	
visit:	stu	lr,[sp,#-1]
	stu	r0,[sp,#-1]
	bl	get
	orr	r0,r0,#0x10000
	bl	put
	ldu	r0,[sp,#1]
	ldu	pc,[sp,#1]
	
nl:	stu	r0,[sp,#-1]
	mov	r0,#'\n
	swi	#SysPutChar
	ldu	r0,[sp,#1]
	mov	pc,lr
	
;;; inputs: r1 row, r2 col
;;; outputs: none
;;; add a row-column to the queue
add:	stu	lr,[sp,#-1]
	stm	sp,#0x7
	bl	pack		; pack values r1 & r2 & r3 into r0
	ldr	r1,tail		; store r0
	stu	r0,[r1,#1]	; at tail
	ldr	r0,queueEnd	; check against end
	cmp	r1,r0		; if
	ldrgt	r1,queue	;  tail >= end: tail = queue
	str	r1,tail		; save tail back
	ldm	sp,#0x7
	ldu	pc,[sp,#1]
	
;;; inputs: none
;;; outputs: r0 is nonzero if pair returned, r1 is row, r2 is column
;;; add a row-column to the queue
remove:
	stu	lr,[sp,#-1]
	ldr	r0,head
	ldr	r1,tail
	cmp	r0,r1
	bne	_fetch
	mov	r0,#0
	b	_fini
_fetch:	ldu	r1,[r0,#1]
	ldr	r2,queueEnd
	cmp	r0,r2
	ldrgt	r0,queue
	str	r0,head
	mov	r0,r1
	bl	split
	mov	r0,#1
_fini:	ldu	pc,[sp,#1]

;;; inputs: r1 row, r2 col
;;; outputs: value of maze at that location
get:	ldr	r0,line
	ldr	r0,[r0,r1,lsl#0]
	ldr	r0,[r0,r2,lsl#0]
	mov	pc,lr
	
;;; inputs: r0 value, r1 row, r2 col
;;; outputs: none
put:	stu	r3,[sp,#-1]
	ldr	r3,line
	ldr	r3,[r3,r1,lsl#0]
	str	r0,[r3,r2,lsl#0]
	ldu	r3,[sp,#1]
	mov	pc,lr
	
;;; inputs: r1 row, r2, col
;;; result: r0 1 iff valid position
isValid:
	stm	sp,#0x18	; save regs
	cmp	r1,#0		; row < 0?
	blt	_no
	ldr	r3,lines
	cmp	r1,r3		; row >= lines in maze?
	bge	_no
	cmp	r2,#0		; column < 0?
	blt	_no
	ldr	r3,length
	ldr	r4,[r3,r1,lsl#0]
	cmp	r2,r4		; column < length[row]?
	bge	_no
_yes:	mov	r0,#1		; return true
	b	_done
_no:	mov	r0,#0
_done:	ldm	sp,#0x18
	mov	pc,lr
	
printSolution:
	stm	sp,#0xf
	adr	r1,maze
_loop:	ldus	r0,[r1,#1]
	blt	_done
	and	r0,r0,#0x7f
	swi	#SysPutChar
	b	_loop
_done:	ldm	sp,#0xf
	mov	pc,lr
	
readMaze:
	stu	lr,[sp,#-1]
	stm	sp,#0xff
	;; first, we read all of the maze data into memory
	ldr	r1,freeMem
	mov	r2,#0		; line counter
_loop:	swi	#SysGetChar
	stus	r0,[r1,#1]
	blt	_done
	cmp	r0,#'\n
	bne 	_loop
	add	r2,r2,#1
	b	_loop
_done:	str	r2,lines
	ldr	r0,freeMem	; compute (for later) size of maze data
	sub	r0,r1,r0
	str	r1,line		; compute the base of line pointer array
	add	r1,r1,r2
	add	r1,r1,#1	; in case of EOF on final line (see below)
	str	r1,length	; compute the base of the length array
	add	r1,r1,r2
	str	r1,queue	; compute the base of the queue
	str	r1,head		; head of queue
	str	r1,tail		; tail of queue (empty when equal to head)
	add	r1,r1,r0	; reserve a visit to every cell
	str	r1,freeMem	; recompute free memory
	sub	r1,r1,#1	; compute end of queue
	str	r1,queueEnd
	;; we now fill out the various pieces of information for each line
phase2:	adr	r1,maze		; r1 will point to maze data
	ldr	r2,lines
	ldr	r3,line
	ldr	r4,length
	mov	r6,#0		; row counter
_lloop:	stu	r1,[r3,#1]	; save memory pointer for current line
	mov	r5,#0		; clear width counter
_loop:	ldus	r0,[r1,#1]	; scan char
	blt	_done
	cmp	r0,#'\n		; check for newline
	beq	_eoln		; end of line mark
	cmp	r0,#'S		; start mark
	beq	_start		; capture location
	cmp	r0,#'F		; finish mark
	bne	_plain		; capture location
_finish:orr	r0,r5,r6,lsl#8	; store in row|col form
	str	r0,finish
	mov	r0,#'\ 
	str	r0,[r1,#-1]
	b	_plain
_start:	orr	r0,r5,r6,lsl#8	; store in row|col form
	str	r0,start
	mov	r0,#'\ 
	str	r0,[r1,#-1]
	b	_plain
_plain:	add	r5,r5,#1	; count non-space
	b	_loop		; loop if not at end
_eoln:	stu	r5,[r4,#1]	; store line length
	add	r6,r6,#1	; increment line number
	b	_lloop		; read next line
_done:	
	ldm	sp,#0xff
	ldu	pc,[sp,#1]
	
maze:			; mark for end of program
