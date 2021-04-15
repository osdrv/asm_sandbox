.include "linux.s"

.section .data
	some_string:
		.ascii "Hello Amazing World!\0"

.section .bss
	.lcomm echo_read_buffer, 1024
	.equ BUFFER_SIZE, 1024

.section .text
	.equ ECHO_ARGC, 0
	.equ ECHO_ARGV_0, 4 # program name
	.equ ECHO_ARGV_1, 8 # echo argument

.globl _start
_start:
	movl %esp, %ebp

	pushl $STDOUT

	movl ECHO_ARGC(%ebp), %eax
	cmpl $1, %eax

	jg echo_read_args
	jmp echo_read_stdin

	echo_read_args:
		movl ECHO_ARGV_1(%ebp), %ecx
		pushl %ecx
		jmp echo_write
	
	echo_read_stdin:
		movl $SYS_READ, %eax
		movl $STDIN, %ebx
		movl $echo_read_buffer, %ecx
		movl $BUFFER_SIZE, %edx
		int $LINUX_SYSCALL
		pushl $echo_read_buffer
		jmp echo_write
	
	echo_write:
		call echo
		addl $8, %esp

		pushl $0
		call exit

.type echo, @function
.globl echo
.equ ECHO_STR_ARG_ADDR, 8
.equ ECHO_FD_OUT_ADDR, 12
echo:
	pushl %ebp
	movl %esp, %ebp

# calculate argument length
	movl ECHO_STR_ARG_ADDR(%ebp), %ecx
	pushl %ecx
	call strlen
	popl %ecx

# write string to the output fd
	movl %eax, %edx # strlen result
	movl $SYS_WRITE, %eax
	movl ECHO_FD_OUT_ADDR(%ebp), %ebx # ouput fd
	movl ECHO_STR_ARG_ADDR(%ebp), %ecx # string argument
	int $LINUX_SYSCALL

	movl %ebp, %esp
	popl %ebp
	ret

.type strlen, @function
.globl strlen
.equ STRLEN_STR_ARG_ADDR, 8
strlen:
	pushl %ebp
	movl %esp, %ebp

	movl $0, %ecx
	movl STRLEN_STR_ARG_ADDR(%ebp), %edx

	strlen_loop_begin:
		movb (%edx), %al
		cmpb $0, %al
		je strlen_loop_end
		incl %ecx
		incl %edx
		jmp strlen_loop_begin
	
	strlen_loop_end:
		movl %ecx, %eax

		movl %ebp, %esp
		popl %ebp
		ret

.type exit, @function
.globl exit
.equ EXIT_CODE_ADDR, 8
exit:
	pushl %ebp
	movl %esp, %ebp
	movl EXIT_CODE_ADDR(%ebp), %ebx
	movl $SYS_EXIT, %eax
	int $LINUX_SYSCALL
