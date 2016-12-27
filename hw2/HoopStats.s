.text
.align 2

##### MAIN METHOD #####
main:
	# Dynamic allocate space for node
	# after syscall, $v0 = address of the allocated space
	# allocate 112 bytes (100 for string,
	#	4 for JPG (.word), 4 for next pointer (.word), 
	#   4 for anything else)
	li		$a0, 112
	li 		$v0, 9
	syscall

	# Save heap address permanently to $s7
	## HEAD OF LINKED LIST IN $s7 ##
	move 	$s7, $v0

	# Save heap address to $s0
	move 	$s0, $v0

	li 		$s6, 0 				# stores length of linked list in $s6

	j 		loadEntry

##### USER LOAD INPUT METHOD #####
loadEntry:
	## ENTER PLAYER NAME (STRING) ##
	# prompt to enter string
	li 		$v0, 4
	la 		$a0, prompt
	syscall
	# Read in string
	# $a0 = memory address for string input to be stored
	# $a1 = length of string buffer
	move 	$a0, $s0
	li 		$a1, 100
	li 		$v0, 8
	syscall

	## REMOVE NEW LINE ##
	# Store $ra to stack, jump and link to removeNL (remove '\n')
	# $a0 = input to removeNL, contains memory address for string
	move 	$a0, $s0
	addi 	$sp, $sp, -4
	sw 		$ra, 0($sp)

	jal 	removeNL

	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4


	## CHECK IF "DONE" ##
	# Store $ra to stack, jump and link to checkDone (check if "DONE")
	# $a0 = input to checkDone, contains memory address for string
	move 	$a0, $s0
	addi 	$sp, $sp, -4
	sw 		$ra, 0($sp)

	jal 	checkDone

	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	li 		$s4, 1 				# load 1 to $s4 for comparing to output
	beq 	$v0, $s4, endEntry	# test if $v0 == 1, user has finished input, 
								#	go to "endEntry"

	## HERE IF NOT "DONE" ##
	addi 	$s6, $s6, 1 		# add 1 to $s6, count of node in linked list

	## ENTER PLAYER NUMBER (INT) ##
	# prompt to enter 1st number
	li 		$v0, 4
	la 		$a0, promptN1
	syscall
	# Read in integer
	# $v0 = integer output location after syscall
	li 		$v0, 5
	syscall
	move 	$s1, $v0			# move number to $s1

	## ENTER PLAYER SCORE (INT) ##
	# prompt to enter 2nd number
	li 		$v0, 4
	la 		$a0, promptN2
	syscall
	# Read in integer
	# $v0 = integer output location after syscall
	li 		$v0, 5
	syscall
	move 	$s2, $v0 			# move number to $s2

	## STORE PLAYER JPG (INT) ##
	# Store JPG number to memory
	sub 	$s3, $s1, $s2
	sw 		$s3, 100($s0)


	## DYNAMIC ALLOCATION NODE SPACE ON HEAP ##
	# Dynamic allocate space for node
	# after syscall, $v0 = address of the allocated space
	# allocate 112 bytes (100 for string,
	#	4 for JPG (.word), 4 for next pointer (.word), 
	#   4 for anything else)
	li		$a0, 112
	li 		$v0, 9
	syscall

	sw 		$v0, 104($s0)  		# store "next" address to memory
	move 	$s5, $s0 			# temporarily store current node address to $s5
	 							#	to be used while working with next node
	move 	$s0, $v0 			# change $s0 to address of next node

	j 		loadEntry

##### USER FINISHED ENTRY, ENTERED "DONE" #####
endEntry:
	beqz 	$s6, printEnd 		# if nothing in linked list, end program
	sw 		$zero, 104($s5)
	move 	$t0, $s7 			# copy HEAD to $t0, initialize print linked list	
	j 		sort
# go to "prePrintLoop": no sorting
# go to "sort": yes sorting

#####################################################################
#####################################################################
# only $s6 (count of nodes) and $s7 (HEAD address) are important
# all other S-registers can be used
sort:
	move 	$t0, $s6 			# $t0 = count of nodes
	addi 	$t0, $t0, -1 		# set $t0 = (count - 1)
	beqz 	$t0, prePrintLoop 	# test if only one node

	# # store $ra, $s7 (HEAD address), and $s6 (count of nodes)
	# # to stack memory
	# addi 	$sp, $sp, -12
	# sw 		$ra, 8($sp)
	# sw 		$s7, 4($s7)
	# sw 		$s6, 0($s6)

	j 		forLoop

forLoop:
	beqz 	$t0, exitFor 		# test if looped through N times
	move 	$t1, $s7 			# $t1 = HEAD address
	move 	$t7, $t1 			# $t7 = PREV address
	j 		whileLoop

whileLoop:	# called by "forLoop"
	## $t7 = PREV address (if exist) ##
	lw 		$t2, 104($t1) 		# $t2 = address of "NEXT"
	beqz 	$t2, exitWhile 		# test if at end of linked list
	## NOT AT END OF LINKED LIST (L. 126 IN C CODE) ##
	lw 		$t3, 100($t1) 		# load JPG of "CURR"
	lw 		$t4, 100($t2) 		# load JPG of "NEXT"
	blt 	$t3, $t4, nextNode 	# test if JPG("CURR") <= JPG("NEXT")
	beq 	$t3, $t4, nextNode
	## HERE IF NEED TO SWAP ##
	beq 	$t1, $s7, swapHead	# need to swap with head, go to "swapHead"
	j 		swap 				# regular swap, go to "swap"

swapHead:	# called by "whileLoop"
	lw 		$t3, 104($t2) 		# $t3 = HEAD.NEXT.NEXT address
	# HEAD address stored in: 			$t1, $s7
	# HEAD.NEXT address stored in: 		$t2
	# HEAD.NEXT.NEXT address stored in: $t3

	sw 		$t3, 104($t1) 		# HEAD --> HEAD.NEXT.NEXT
	sw 		$t1, 104($t2) 		# HEAD.NEXT --> HEAD

	move 	$t1, $t2 			# set new HEAD
	move 	$s7, $t1 			# set new HEAD (for global var $s7)
	lw 		$t2, 104($t1) 		# $t2 is the address of the new HEAD.NEXT
	j 		nextNode

swap:		# called by "whileLoop"
	lw 		$t3, 104($t2) 		# $t3 = CURR.NEXT.NEXT address
	# PREV address stored in: 			$t7
	# CURR address stored in: 			$t1
	# CURR.NEXT address stored in: 		$t2
	# CURR.NEXT.NEXT address stored in: $t3

	sw 		$t2, 104($t7) 		# PREV --> CURR.NEXT
	sw 		$t3, 104($t1) 		# CURR --> CURR.NEXT.NEXT
	sw 		$t1, 104($t2) 		# CURR.NEXT --> CURR

	lw 		$t1, 104($t7) 		# set new CURR
	lw 		$t2, 104($t1) 		# set new CURR.NEXT
	# PREV and CURR.NEXT.NEXT did not change
	j 		nextNode

nextNode:
	move 	$t7, $t1 			# $t7 set to address of "CURR", the new "PREV"
	move 	$t1, $t2 			# $t1 set to address of "NEXT", the new "CURR"
	j 		whileLoop

exitWhile:
	addi 	$t0, $t0, -1 		# decrement count of nodes ("N")
	j 		forLoop

exitFor:
	j 		prePrintLoop
#####################################################################
#####################################################################

##### LOOP THAT PRINTS OUT LINKED LIST #####
prePrintLoop:
	move 	$t0, $s7 			# copy HEAD to $t0, initialize print linked list
	j 		printLoop

printLoop:
# node to be printed begin at $t0
	addi 	$sp, $sp, -4
	sw 		$ra, 0($sp) 		# store return address to stack memory

	jal 	printNode

	lw 		$ra, 0($sp) 		# read return address from stack memory
	addi 	$sp, $sp, 4

	lw 		$t1, 104($t0) 		# load address of "NEXT" to $t1
	beqz 	$t1, printEnd 		# test if end of list reached.
								#	"NEXT" address is set to 0 if reached end
	move 	$t0, $t1 			# move address of "NEXT" to $t0
	# addi 	$t0, $t0, 112
	j 		printLoop

##### FINISHED PRINTING LINKED LIST #####
##### WILL EXIT PROGRAM (SYSCALL 10) #####
printEnd:
 	jr 		$ra 				# exit program


##### REMOVE NEW LINE "\n" FROM END OF INPUT STRING #####
removeNL:
	move 	$t0, $a0 			# move $a0 (string address) to $t0
	lb 		$t1, nln 			# load '\n' to $t1
	j 		removeNLLoop

removeNLLoop:
	lb 		$t2, ($t0) 			# load 1 byte from input string
	beq 	$t1, $t2, isNL 		# test if at '\n'
	addi 	$t0, $t0, 1  		# if not at '\n', increment by 1 byte
	j 		removeNLLoop

isNL:
	sb 		$0, ($t0)
	jr 		$ra


##### PRINT OUT STRING AND JPG NUMBER #####
printNode:
	# print string
	li 		$v0, 4
	la 		$a0, ($t0)
	syscall

	li 		$v0, 4
	la 		$a0, onesp
	syscall


	# print JPG number
	li 		$v0, 1
	lw 		$a0, 100($t0)
	syscall

	li 		$v0, 4
	la 		$a0, nln
	syscall


	#### WHERE DO I GO FROM HERE??? #####
	jr 		$ra 				# Go to after "jal printNode" in "printLoop"


##### STRING COMPARE FOR "DONE" #####
checkDone:
	move	$a0, $s0 			# load input string address to $a0
	la 		$a1, DONE 			# load DONE address to $a1

	addi 	$sp, $sp, -4 		# save $ra onto stack
	sw 		$ra, 0($sp)

	jal 	cmpDone 			# jump and link to cmpDone

	lw 		$ra, 0($sp) 		# load $ra address from stack
	addi 	$sp, $sp, 4

	beqz 	$v0, printNo 		# test if strcmp is 0 (strings not same)
	j 		printYes 			# otherwise strcmp is 1 (strings same)
	## ADD CODE ##
	## otherwise go to next node ##

## Determine is the string == DONE ##
cmpDone:
	move 	$t0, $a0 			# move input string address to $t0
	move 	$t1, $a1 			# move DONE address to $t1
	j 		cmpLoop

cmpLoop:
	lb 		$t2, ($t0) 			# load 1 byte of input string to $t2
	lb 		$t3, ($t1)			# load 1 byte of DONE to $t3
	bne 	$t2, $t3, cmpNo 	# test if bytes are not equal
	beqz 	$t2, cmpEnd 		# test if string ends
	addi 	$t0, $t0, 1 		# increment to next byte of address of $t0
	addi 	$t1, $t1, 1 		# increment to next byte of address of $t1
	j 		cmpLoop

## Comes here if string != DONE ##
## $v0 = 0  =>  strings not equal ##
cmpNo:
	li 		$v0, 0
	jr		$ra 				# jumps to after "jal cmpDone" in "checkDone:"

## Comes here if strings == DONE and terminate ##
## $v0 = 1  =>  strings are equal ##
cmpEnd:
	li 		$v0, 1
	jr 		$ra 				# jumps to after "jal cmpDone" in "checkDone:"

## Print "Strings are the same", then exit ##
printNo:
	# li 		$v0, 4
	# la 		$a0, notSame
	# syscall
	li 		$v0, 0 				# return 0 for not being "DONE"
	jr	 	$ra 				# jumps to after "jal checkDone" in "loadEntry:"

## Print "Strings are not the same", then exit ##
printYes:
	# li 		$v0, 4
	# la 		$a0, isSame
	# syscall
	li 		$v0, 1 				# return 1 for being "DONE"
	jr 		$ra 				# jumps to after "jal checkDone" in "loadEntry:"


.data
N: .word 63
prompt: .asciiz "Enter Name or DONE: "
promptN1: .asciiz "Enter Jersey Number: "
promptN2: .asciiz "Enter Points Per Game: "
nln: .asciiz "\n"
DONE: .asciiz "DONE"
isSame: .asciiz "Strings are the same"
notSame: .asciiz "Strings are not the same"
onesp: .asciiz " "