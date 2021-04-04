.section .data
	heap_begin:
		.long 0
	current_break:
		.long 0

	.equ HEADER_SIZE, 8
	.equ HDR_AVAIL_OFFSET, 0
	.equ HDR_SIZE_OFFSET, 4

	.equ UNAVAILABLE, 0
	.equ AVAILABLE, 1
	.equ SYS_BRK, 45
	.equ LINUX_SYSCALL, 0x80

.section .text

.globl allocate_init
.type allocate_init, @function
allocate_init:
	pushl %ebp
	movl %esp, %ebp
	movl $SYS_BRK, %eax
	movl $0, %ebx # 0 returns the last usable valid address
	int $LINUX_SYSCALL

	incl %eax # last valid address: we need the next block
	movl %eax, current_break
	movl %eax, heap_begin

	movl %ebp, %esp
	popl %ebp
	ret

.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8
allocate:
	pushl  %ebp
	movl %esp, %ebp

	movl ST_MEM_SIZE(%ebp), %ecx # it holds the size we're looking for
	movl heap_begin, %eax # eax contains the current search location
	movl current_break, %ebx # ebx contains the current break

	alloc_loop_begin:
		cmpl %ebx, %eax # we need more memory if they are equal
		je move_break

		movl HDR_SIZE_OFFSET(%eax), %edx # get the size of this memory
		cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
		je next_location # try the next one

		cmpl %edx, %ecx # check if the space is available
		jle allocate_here # if it is big enough, we allocate it
	
	next_location:
		addl $HEADER_SIZE, %eax
		addl %edx, %eax # adding %edx (current pos) to $8 and %eax will get the new address
		jmp alloc_loop_begin
	
	allocate_here:
		movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
		addl $HEADER_SIZE, %eax # move it to the usable memory
		movl %ebp, %esp
		popl %ebp
		ret
	
	move_break: # reaching this point means we have exhausted all memory blocks and we need to alloc more
		addl $HEADER_SIZE, %ebx # this is where we want our memory
		addl %ecx, %ebx

		pushl %eax
		pushl %ecx
		pushl %ebx

		movl $SYS_BRK, %eax
		int $LINUX_SYSCALL

		cmpl $0, %eax # check for an error
		je error

		popl %ebx
		popl %ecx
		popl %eax

		movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) # set this memory as unavailable
		movl %ecx, HDR_SIZE_OFFSET(%eax)

		addl $HEADER_SIZE, %eax # eax now holds the return value

		movl %ebx, current_break # save the new break

		movl %ebp, %esp
		popl %ebp
		ret

	error:
		movl $0, %eax
		movl %ebp, %esp
		popl %ebp
		ret
	
.globl deallocate
.type deallocate, @function
.equ ST_MEMORY_SEG, 4
deallocate:
	movl ST_MEMORY_SEG(%esp), %eax # get the address of the memory to free
	subl $HEADER_SIZE, %eax
	movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax) # mark it available
	ret
