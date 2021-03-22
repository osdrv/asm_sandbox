.type count_chars, @function
.globl count_chars

.equ ST_STRING_START_ADDRESS, 8

count_chars:
	pushl %ebp
	movl %esp, %ebp

	movl $0, %ecx # reset the counter to 0
	movl ST_STRING_START_ADDRESS(%ebp), %edx

	count_loop_begin:
		movb (%edx), %al
		cmpb $0, %al # is it null?
		je count_loop_end
		incl %ecx # increment the counter
		incl %edx # increment the pointer
        jmp count_loop_begin

    count_loop_end:
        movl %ecx, %eax
        popl %ebp
        ret

