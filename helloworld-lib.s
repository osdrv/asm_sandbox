.section .data
	helloworld:
		.ascii "hello world\0"

.section .text
.globl _start
_start:
	pushl $helloworld
	call printf

	pushl $0
	call exit
