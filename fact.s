
.section .data

.section .text

.globl _start
.globl factorial

_start:
	pushl $4
	call factorial
	addl $4, %esp
	movl %eax, %ebx

	movl $1, %eax
	int $0x80

.type factorial, @function
factorial:
	pushl %ebp # we will restore %ebp to it's prev state before return
	movl %esp, %ebp # we don't want to modify stack pointer so we use %ebp
	movl 8(%ebp), %eax # move the first arg to %eax
	cmpl $1, %eax # if the number is 1, return
	je end_factorial
	decl %eax
	pushl %eax # push it for the call to factorial
	call factorial
	movl 8(%ebp), %ebx # reload our param into %ebx
	imull %ebx, %eax

end_factorial:
	movl %ebp, %esp # restore %esp
	popl %ebp
	ret
