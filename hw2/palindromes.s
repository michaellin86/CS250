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

	# store input N to $t0
	move	$t0, $v0		# $t0 = number of palindromes to be printed
	li 		$t1, 10 		# $t1 = value to check for whether palindrome
	j 		main_loop

main_loop:
	beqz 	$t0, stop		# test while condition
	addi 	$t1, $t1, 1 	# increment value to be checked by 1
	
	# save $t0, $t1, $ra into stack memory
	addi 	$sp, $sp, -12
	sw 		$t0, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$ra, 0($sp)
	
	jal		palindrome 	 	# call procedure "palindrome"
	
	# load $t0, $t1, $ra from stack memory
	lw 		$ra, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t0, 8($sp)
	addi 	$sp, $sp, 12

main_loop_cont:
	beqz 	$v0, main_loop 	# if $t1 is not palindrome ($v0 = 0)

	li 		$v0, 1
	move 	$a0, $t1
	syscall

	li 		$v0, 4
	la 		$a0, nln
	syscall

	addi 	$t0, $t0, -1 	# if $t1 is palindrome, decrement $t0 by 1
	j 		main_loop

stop:
	jr 		$ra
# $s0 = N, integer in question
# $s1 = 10
# $s2 = begin address of array
# $s3 = end address of array
# $s4 = length of array

palindrome:
	move	$s0, $t1		# $s0 = $t1, value to check for whether palindrome
	li		$s1, 10			# $s1 = 10
	la 		$s2, array 		# $s2 as address of array
	li 		$s4, 1			# initialize length of array as 1
	move	$t2, $s2		# put $s2 into temp
	move 	$t3, $s0  		# put $s0 into temp

loop:
	div		$t3, $s1	
	mflo	$t3				# $t3 = (int) $t3/10
	mfhi	$t1				# $t1 = $t3 mod 10

	sw		$t1, ($t2)		# save least significant digit into mem[$t2]
	addi	$t2, $t2, 4 	# increment $t2 by 4
	addi 	$s4, $s4, 1 	# increment length of array by 1
	blt		$t3, $s1, exit	# if $t3 < 10, go to exit
	j 		loop			# return to beginning of loop

exit:
	sw		$t3, ($t2)		# save last digit left into mem[$t2]
	move 	$s3, $t2		# save end address of array to $s3
	j 		compare_loop

compare_loop:
	lw 		$t0, ($s2) 		# $t0 = array[0]
	lw 		$t1, ($s3) 		# $t1 = array[end]
	bne 	$t0, $t1, ret0 	# if digits not equal, go to ret
	addi 	$s2, $s2, 4		# increment beginning index by 4
	addi 	$s3, $s3, -4	# decrement ending index by 4
	bge 	$s2, $s3, ret1
	j 		compare_loop

ret0:						# if value is not palindrome
	li 		$v0, 0	
	jr		$ra


ret1:						# if value is palindrome
	li 		$v0, 1
	jr		$ra


.data
.align 2
M: .word 100
N: .word 11
array: .space 50
nln: .asciiz "\n"
prompt: .asciiz "Enter N: "