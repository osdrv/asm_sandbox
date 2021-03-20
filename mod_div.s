.section .data

.section .text

.globl _start
_start:
	pushl $4
	pushl $47
	call mod_div
	addl $8, %esi
	movl %eax, %ebx
	movl $1, %eax
	int $0x80

.type mod_div, @function
mod_div:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	
	start_loop:
		cmpl %ebx, %eax
		jl end_loop
		subl %ebx, %eax
		jmp start_loop
	
	end_loop:
		movl %ebp, %esp
		popl %ebp
		ret
