.section .data

.section .text

.globl _start
_start:
	pushl $5
	call factorial
	addl $4, %esp
	movl %eax, %ebx
	movl $1, %eax
	int $0x80

.type factorial, @function
factorial:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax
	movl 8(%ebp), %ebx

	start_loop:
		decl %ebx
		cmpl $1, %ebx
		jle end_loop
		imull %ebx, %eax
		jmp start_loop
		
	end_loop:
		movl %ebp, %esp
		popl %ebp
		ret
