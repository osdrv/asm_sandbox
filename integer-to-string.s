.equ ST_VALUE, 8
.equ ST_BUFFER, 12

.globl integer2string
.type integer2string, @function
integer2string:
	pushl %ebp
	movl %esp, %ebp
	movl $0, %ecx # current character count

	movl ST_VALUE(%ebp), %eax
	movl $10, %edi # in order to divide by 10, it needs to be in a register

	conversion_loop:
		movl $0, %edx
		divl %edi # %edx contains the remainder (0-9). 

		addl $'0', %edx # convert it to a char
		pushl %edx # push it onto the stack, 1 by 1, they would be in the right order when we will be popping them
		incl %ecx # increment the digit count

		cmpl $0, %eax
		je end_conversion_loop

		jmp conversion_loop
	
	end_conversion_loop:
		movl ST_BUFFER(%ebp), %edx # get the pointer to the buffer
	
	copy_reversing_loop:
		popl %eax
		movb %al, (%edx)
		decl %ecx
		incl %edx # increase it so it points to the next byte

		cmpl $0, %ecx 
		je end_copy_reversing_loop
		jmp copy_reversing_loop
	
	end_copy_reversing_loop:
		movb $0, (%edx) # write a null-byte
		movl %ebp, %esp
		popl %ebp
		ret
