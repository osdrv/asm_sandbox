.section .data

.section .text

.globl _start
_start:
	pushl $3 # push second arg
	pushl $2 # push first arg
	call power
	addl $8, %esp
	pushl %eax # save the first res before calling the 2nd func

	pushl $2
	pushl $5
	call power
	addl $8, %esp

	popl %ebx # the second res is in %eax

	addl %eax, %ebx

	movl $1, %eax
	int $0x80

.type power, @function
power:
	pushl %ebp # save old base pointer
	movl %esp, %ebp #make stack pointer the base pointer
	subl $4, %esp # get room for a local var

	movl 8(%ebp), %ebx #first arg
	movl 12(%ebp), %ecx #second arg

	movl %ebx, -4(%ebp)

	power_loop_start:
	cmpl $1, %ecx # if the pow is 1, we're done
	je end_power
	movl -4(%ebp), %eax #move the cur res to %eax
	imull %ebx, %eax # mult the curr res to the base num
	movl %eax, -4(%ebp) #store the curr res
	decl %ecx # decrease the pow
	jmp power_loop_start

	end_power:
	movl -4(%ebp), %eax #return val goes to eax
	movl %ebp, %esp #restore the stack prt
	popl %ebp #restore the base ptr
	ret


