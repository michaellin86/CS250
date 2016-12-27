.text
.align 2

main:
	# prompt to enter N
	li 		$v0, 4
	la 		$a0, prompt
	syscall

	# read integer N
	li 		$v0, 5
	syscall

	# store input N to $a0
	addi 	$a0, $v0, 1 		# $a0 stores N+1 (+1 needed for algorithm to work)

	li 		$s1, 3				# $s1 stores the value 3
	move 	$t0, $sp

recurse:
	move	$s0, $a0			# store N at each step into $s0
	beqz 	$s0, base			# test if base case

	addi 	$sp, $sp, -8		# move stack pointer down by 8
	sw 		$ra, 4($sp)			# store return address into memory
	sw 		$s0, 0($sp)			# store $s0 into memory

	addi 	$a0, $s0, -1		# next argument N-1
	
	jal 	recurse				# recurse(N-1)

	addi 	$s2, $s0, 1 		# store (N+1) in $s2
	mul 	$s2, $s1, $s2		# store 3*(N+1) in $s2
	add 	$s2, $v1, $s2		# store 3*(N+1)+recurse(N-1) in $s2
	addi 	$s2, $s2, -1 		# store 3*(N+1)+recurse(N-1)-1 in $s2
	move 	$v1, $s2 			# return value via $v1

clean:
	lw 		$s0, 0($sp) 		# load N from memory to $s0
	lw 		$ra, 4($sp)			# load return address from memory
	addi 	$sp, $sp, 8			# move stack pointer up by 8
	beq 	$t0, $sp, exit		# check if moved back stack point to original position
	jr 		$ra 				# jump register to after "jal recurse"

base:
	li 		$v1, 1				# set return value = 1 for base case
	j 		clean

exit:
	li 		$v0, 1 				# print value
	move 	$a0, $v1
	syscall

	# li		$v0, 10 		# exit program
	# syscall
	jr 		$ra

.data
N: .word 63
prompt: .asciiz "Enter N: "