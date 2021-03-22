.include "linux.s"
.include "record-def.s"

.section .data

record1:
	.ascii "Frederick\0"
	.rept 31 # Padding to 40 bytes
	.byte 0
	.endr

	.ascii "Bartlett\0"
	.rept 31 # Padding to 40 bytes
	.byte 0
	.endr

	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209 # Padding to 240 bytes
	.byte 0
	.endr

	.long 45

record2:
	.ascii "Marilyn\0"
	.rept 32 # Padding to 40 bytes
	.byte 0
	.endr

	.ascii "Taylor\0"
	.rept 33 #Padding to 40 bytes
	.byte 0
	.endr

	.ascii "2224 S Johannan St\nChicago, IL 12345\0"
	.rept 203
	.byte 0
	.endr

	.long 29

record3:
	.ascii "Derrick\0"
	.rept 32
	.byte 0
	.endr

	.ascii "McIntire\0"
	.rept 31 #Padding to 40 bytes
	.byte 0
	.endr

	.ascii "500 W Oakland\nSan Diego, CA 54321\0"
	.rept 206 #Padding to 240 bytes
	.byte 0
	.endr

	.long 36

file_name:
	.ascii "test.dat\0"

	.equ ST_FILE_DESCRIPTOR, -4

.globl _start
_start:
	movl %esp, %ebp
	subl $4, %esp

	movl $SYS_OPEN, %eax
	movl $file_name, %ebx
	movl $0101, %ecx # create if it does not exist and open for writing
	movl $0666, %edx
	int $LINUX_SYSCALL

	movl %eax, ST_FILE_DESCRIPTOR(%ebp)

# Write the first record
	pushl ST_FILE_DESCRIPTOR(%ebp)
	pushl $record1
	call write_record
	addl $8, %esp

# Write the second record
	pushl ST_FILE_DESCRIPTOR(%ebp)
	pushl $record2
	call write_record
	addl $8, %esp

# Write the third record
	pushl ST_FILE_DESCRIPTOR(%ebp)
	pushl $record3
	call write_record
	addl $8, %esp

# Close the file descr
	movl $SYS_CLOSE, %eax
	movl ST_FILE_DESCRIPTOR(%ebp), %ebx
	int $LINUX_SYSCALL

	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL
