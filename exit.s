.section .data

.section .text

.globl _start
_start:
movl $1, %eax # syscall for exiting the program

movl $0, %ebx # the status number we will return to the os

int $0x80 # wakes up the kernel to exec the command
