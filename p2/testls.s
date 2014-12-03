	mov	r1, #69
	stu	r2, [sp, #-1] 	;push
	ldu	r0, [sp, #1]	;pop
	swi	#SysPutNum
	swi	#SysHalt