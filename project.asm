.data

	A:	.word 0 : 10
	totA:	.word 0
	B:	.word 0 : 10
	totB:	.word 0
	C:	.word 0 : 10
	totC:	.word 0
	
	moved:	.asciiz	"Move Disk "
	from:	.asciiz " from Rod "
	to:	.asciiz " to Rod "
	steps:	.asciiz "Amount of step to complete: "
	start:	.asciiz "START"
	nxtLine:.asciiz "\n"
	tabSpce:.asciiz "\t"
	jstSpce:.asciiz " "
	format:	.asciiz "\tA\tB\tC"
	split:	.asciiz "\n---------------------------------\n"
	
.text
	li	$v0, 4
	la	$a0, format		# print a new space in between each element
	syscall
	la	$a0, split		# print a new space in between each element
	syscall
	
	addi 	$a0, $zero, 4		# number of disks, n
	add	$s0, $a0, $zero		# for use in the "printState" routine
	
	la	$s1, A			# from = A
	la	$s2, C			# to = C
	la	$s3, B			# aux = B
	
	add	$a1, $s1, $zero		# from = A
	add	$a2, $s3, $zero		# to = C
	add	$a3, $s2, $zero		# aux = B		
	addi	$t7, $zero, 1
	
	sw	$a0, 40($a1)
	
	jal	setDisks
	jal	printState
	add	$a0, $s0, $zero
	jal	Hanoi
	j	printSteps
#----------------------------------------------------------------------------------------------------	
Hanoi:
	addi	$sp, $sp, -20
	sw 	$ra, 16($sp) 		# save return address
	sw 	$a3, 12($sp) 		# save argument
	sw 	$a2, 8($sp) 		# save argument
	sw 	$a1, 4($sp) 		# save argument
	sw 	$a0, 0($sp) 		# save argument
	
	slti 	$t7, $a0, 2 		# test for n<1
	beq 	$t7, $zero, else1	#branch if n(a0) is > 1	
if1:
	jal	moveDisks
	lw 	$a0, 0($sp) 		# save argument	
	lw	$ra, 16($sp)
	addi 	$sp, $sp, 20 		# pop 2 items from stack
	jr 	$ra 			# and return
else1:
	addi 	$a0, $a0, -1 		# else decrement n
	add	$t0, $a2, $zero		# temp = to
	add	$a2, $a3, $zero		# to = aux
	add	$a3, $t0, $zero		# aux = temp [to]
	jal 	Hanoi 			# recursive call
	
	lw 	$a0, 0($sp) 		# restore original n
	lw 	$a1, 4($sp) 		# save argument
	lw 	$a2, 8($sp) 		# save argument
	lw 	$a3, 12($sp) 		# save argument

	jal	moveDisks
	lw 	$a0, 0($sp) 		# save argument	
	addi 	$a0, $a0, -1 		# else decrement n
	add	$t0, $a1, $zero		# temp = from
	add	$a1, $a3, $zero		# from = aux
	add	$a3, $t0, $zero		# aux = temp [from]
	jal 	Hanoi 			# recursive call
	
	lw	$ra, 16($sp)
	addi 	$sp, $sp, 20 		# pop 2 items from stack
	
	jr	$ra
#----------------------------------------------------------------------------------------------------
moveDisks:
	# Move disk: 'from' <--> 'to' [$a1 <--> $a2]
	lw	$t0, 40($a1)		# Loads value at totA (size of array) into $t0 using memory location specified by $a1 ('from') offset by 40
	addi	$t0, $t0, -1		# The value is then decremented for later to find the proper value in its respective array
	sll	$t2, $t0, 2		# Then the value is shifted left 2 times to create a proper offset to find correct element.
	add	$t2, $t2, $a1		# Lastly, this value is added with the memory location specified by $a1 with offset $t2 into itself
	lw	$t1, 40($a2)		# Same is done here. $t1 = value at mem. loc. specified by $a2 ('to') offset by 40
	sll	$t3, $t1, 2		# $t1 doesn't need to be decremented and is immediately shifted left 2 times to create appropriate offset
	add	$t3, $t3, $a2		# Same as before, a temp. reg.($t3), which has an offset, will add into itself mem. loc. specified by $a2
	lw	$t6, 0($t2)		# Using our new specific reference in the 'from' array ($t2), load value from there into $t6
	sw	$t6, 0($t3)		# Now we move the value to the 'to' array ($t3)
	sw	$zero, 0($t2)		# Element at mem. loc. at $t2 will become zero since the element should have moved out
	addi	$t1, $t1, 1		# Increment $t1 (the size of the 'to' array) since it now has one more 'disk'
	sw	$t0, 40($a1)		# $t0 (size of the 'from' array) is already decrmented and is immediately loaded back to its mem. loc.
	sw	$t1, 40($a2)		# Same is done with the newly incremented value at $t1 (size of the 'from' array)
	addi	$t4, $t4, 1		# Value at $t4 will be incremented. This keeps track of the amount of step required to run this program and must NEVER be used anywhere else.
# If "moveDisks" routine is called it WILL proceed to the "printState" routine since there is currently a new state of the arrays. Will RETURN from "printState"
printState:	
	addi	$t7, $s0, -1		# $t5 = 3 -1 = 2 (amount of disks total - 1 [Necessary for proper offset])
loop2:
	li	$v0, 4
	la	$a0, tabSpce		# print a new space in between each element
	syscall	
	sll	$t5, $t7, 2		# Multiply by 4 for offset value
	add	$t1, $s1, $t5
	add	$t2, $s2, $t5
	add	$t3, $s3, $t5
	lw	$t6, 0($t1)
	li	$v0, 1
	add	$a0, $t6, $zero		# print a new space in between each element	
	syscall
	li	$v0, 4
	la	$a0, tabSpce		# print a new space in between each element	
	syscall
	lw	$t6, 0($t2)
	li	$v0, 1
	add	$a0, $t6, $zero		# print a new space in between each element	
	syscall
	li	$v0, 4
	la	$a0, tabSpce		# print a new space in between each element	
	syscall
	lw	$t6, 0($t3)
	li	$v0, 1
	add	$a0, $t6, $zero		# print a new space in between each element	
	syscall
	li	$v0, 4
	la	$a0, tabSpce		# print a new space in between each element	
	syscall
	li	$v0, 4
	la	$a0, nxtLine		# print a new space in between each element	
	syscall
	addi	$t7, $t7, -1
	slti	$t6, $t7, 0
	beq	$t6, $zero, loop2
	li	$v0, 1
	add	$a0, $t4, $zero		# print a new space in between each element	
	syscall
	li	$v0, 4
	la	$a0, split		# print a new space in between each element	
	syscall
	jr	$ra			# Jumps back (RETURN). Will RETURN for "moveDisks"
	
#----------------------------------------------------------------------------------------------------

setDisks:
	add	$t0, $a0, $zero		# Amount of disk are temporarily set at $t0 to be changed as the values are being set
	add	$t1, $a1, $zero		# Disks start at Rod A ($a1). $a1 (mem. loc. of array 'A') is temporarily set here to be adjusted
loop1:
	sw	$t0, 0($t1)		# Saves current size of disk at $t0 into the mem. loc. specified by $a1
	addi	$t1, $t1, 4		# $t1 (current element is array 'A') is offset by 4 to allow access to the next value in memeory
	addi	$t0, $t0, -1		# Disk size is decremented once and will be loaded into the new mem. loc. specified by $t1 (array 'A')
	slti 	$t2, $t0, 1 		# Checks if $t0 (disk size) is less than one. If true, $t2 = 1; else, $t2 = 0 
	beq 	$t2, $zero, loop1	# If $t2 == 0, then $t0 isn't less than 1. Start back at "for_loop1"
	jr	$ra			# If $t2 != 0, then $t0 is now less than 1. Jump back (RETURN).
	
#----------------------------------------------------------------------------------------------------
	
printSteps:
	li	$v0, 4
	la	$a0, steps		# print a new space in between each element
	syscall
	li	$v0, 1
	add	$a0, $t4, $zero		# print a new space in between each element
	syscall
	
#----------------------------------------------------------------------------------------------------
	
END:
