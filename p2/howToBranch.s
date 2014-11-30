;;; internal wonderings about branch
;;; (c) drsmith

	movs	r0,#0	
loop:	bne	end
	movs	r0, #1
	b	loop
end:	swi	#SysPutNum
	swi	#SysHalt	