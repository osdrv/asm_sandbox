.section .data

.section .text

.globl _start
_start:
	pushl $42 # as an option, we can use 0 as a stop-cond
	pushl $1
	pushl $4
	pushl $3 # the number of the arguments
	call max
	addl $12, %esp

	movl %eax, %ebx
	movl $1, %eax
	int $0x80

.type max, @function
max:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %edi
	movl 12(%ebp), %eax
	movl 8(%ebp), %ebx # N -> %ebx
	addl $2, %ebx # N + 1 -> %ebx; 2 because 1 var is the # of args
	imull $4, %ebx # 4 * (N + 1) -> %ebx
	addl %ebp, %ebx # %ebp + 4 * (N + 1) -> %ebx
	
	start_loop:
		cmpl $1, %edi
		jle end_loop
		movl (%ebx), %ecx
		decl %edi
		subl $4, %ebx
		cmpl %eax, %ecx
		jle start_loop
		movl %ecx, %eax
		jmp start_loop
		
	end_loop:
		movl %ebp, %esp
		popl %ebp
		ret
