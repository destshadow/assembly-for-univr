
# Registers in use:
# r13 - holds argc                                          sp
# r14 - holds number of processed command line args         lr
# r15 - holds number of values on the result stack          pc

.section .data
err_msg:
	.asciz "There was an error.\n"

output:
	.space 32, 0x0		# Create an empty buffer, 32 bytes (the result will always fit in this)

.section .text
.global _start
_start:
	mov (%esp), %r13	# The first thing on the stack is argc, save it
	sub $1, %r13		# Don't count argv[0] (the program name)

	push %ebp		# Save rbp, as is convention
	mov %esp, %ebp		# Save rsp for future use, rsp will change as we push/pop

	mov $0, %r14		# Keep track of processed arguments

	mov $0, %r15		# Keep track of the current number of result values on the stack

read_token:
	# If we have processed all arguments, the stack should have the answer
	cmp %r14, %r13
	je result

	# Calculate the next argument's address
	movq $3, %eax		# Skip rbp, argc, argv[0] on the stack
	add %r14, %eax		# Skip processed arguments

	# Move the next argument into rax for evaluation
	mov (%ebp, %eax, 8), %eax

	# Increment since we are processing the argument
	add $1, %r14

	# First, check if it is an operator (+, -, x, /)
	mov %eax, %edi		# In preparation for a possible atoi call
	xor %eax, %eax
	movb (%edi), %al

	cmpb $0x2b, %al
	je addition

	cmpb $0x2d, %al
	je subtract

	cmpb $0x78, %al
	je multiply

	cmpb $0x2f, %al
	je divide

	# Otherwise, assume it is a value so convert to int, push it onto the stack, and start over
	call atoi
	pushq %eax
	add $1, %r15
	jmp read_token

atoi:
	movq $0, %eax		# Will hold the return value
	mov $10, %ecx 		# Will hold the multiplier (10, since we're using decimal)

atoi_loop:
	movb (%edi), %bl	# Move a byte from the string into bl

	cmpb $0x00, %bl		# Check for null byte (end of string)
	je atoi_end		# Return if end of string

	cmpb $0x2d, %bl		# Check for negative number (i.e. -2 must be entered 2-)
	je atoi_isneg

	sub $48, %bl		# Subtract 48 to go from ascii value to decimal
	imul %ecx, %eax		# Multiply previous number by the multiplier
	add %ebx, %eax		# Add new decimal part to previous number
	inc %edi		# Increment the address (move forward one byte in the string)
	jmp atoi_loop

atoi_end:
	ret

atoi_isneg:
	imul $-1, %eax		# Make it negative
	inc %edi		# Prevents a weird bug that prints a comma; not sure why this happens
	ret

addition:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args, convert to int, and do the math with them
	pop %r8
	pop %r9
	add %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

subtract:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %r9
	sub %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

multiply:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %r9
	imul %r8, %r9

	# Push the result, subtract 1 from result stack count
	push %r9
	sub $1, %r15
	jmp read_token

divide:
	# All operators require 2 arguments
	cmp $2, %r15
	jl error

	# Pop the two args and do the math with them
	pop %r8
	pop %eax
	xor %edx, %edx
	idiv %r8		# Take rax, divide by r8, and store the quotient in rax and remainder in rdx

	# Push the result, subtract 1 from result stack count
	push %eax
	sub $1, %r15
	jmp read_token

result:
	# There should only be one value on the stack!
	cmp $1, %r15
	jne error

	pop %edi
	call itoa

	mov %eax, %esi		# rax contains the buffer, this is for the call to write
	mov %eax, %edi		# This is for the call to strlen

	call strlen

	mov %eax, %edx		# rax now contains the length of the buffer
	mov $1, %eax		# Syscall for write (man 2 write)
	mov $1, %edi		# Write to stdout
	#mov $output, %rsi	# Use the buffer
	syscall

# Exit
        movq %ebp, %esp
        popq %ebp		# Restore rbp, as is convention

	mov $60, %eax
	syscall

itoa:
	mov $output, %r8	# Buffer
	add $30, %r8		# Move to almost the end, leaving a null byte
	movb $0x0a, (%r8)	# Write newline
	dec %r8			# Decrement buffer

	mov $10, %r9		# Base (we're usign decimal)
	mov %edi, %eax		# Number to convert -> rax

	# We need to write a '-' when we're done
	mov $0, %r10		# Negative marker
	cmp $0, %eax
	jl itoa_isneg

itoa_loop:
	xor %edx, %edx		# Clear for division
	idiv %r9		# Divide the number by 10
	add $48, %edx		# Add 48 to remainder to convert to ascii
	movb %dl, (%r8)		# Move the converted byte to the buffer
	dec %r8			# Decrement the buffer pointer
	cmp $0, %eax		# If the quotient is 0, we're done
	je itoa_end
	jmp itoa_loop

itoa_isneg:
	mov $1, %r10		# This means later we need to write a '-'
	imul $-1, %eax		# Make the number positive now and convert to ascii
	jmp itoa_loop

itoa_end:
	cmp $0, %r10
	jne itoa_isneg
	mov %r8, %eax		# Return a pointer to the beginning of the string
	ret

itoa_isneg:
	movb $0x2d, (%r8)	# Write a '-' to the buffer
	mov %r8, %eax		# Return a pointer to the beginning of the string
	ret

strlen:
	mov $0, %eax		# Holds the size, to be incremented
	mov %rdi, %r8		# Holds the buffer

strlen_loop:
	cmp $0, (%r8)		# Check for null byte
	je strlen_end
	inc %r8
	inc %eax
	jmp strlen_loop

strlen_end:
	ret

error:
	# Print the error message by calling write (man 2 write)
	mov $1, %eax
	mov $1, %edi
	mov $err_msg, %esi
	mov $20, %edx
	syscall
	mov $60, %eax
	syscall