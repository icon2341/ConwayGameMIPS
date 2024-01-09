#
# FILE:         $File$
# AUTHOR:       Ashar Rahman, RIT, 2023
#               
#
# DESCRIPTION:
#	This file contains the is_location_taken function that checks
#	to see if the coordinate is available
#

#-------------------------------

.globl is_location_taken

#
# Name:         is_location_taken
# Description:  checks to see if the coordinate is available by running
#		col and row arrays of both groups of cells to see if there
#		is a match between the provided coordinates.
#
# Arguments:    a0:     index of row
#               a1:     index of col
#               a2:     a parameter block containing 3 values
#			- the address of rowArray_A
#			- the address of colArray_A
#			- the address of the colonySize_A
#               a3:     a parameter block containing 3 values
#			- the address of rowArray_B
#			- the address of colArray_B
#			- the address of the colonySize_B
# Returns:      $v0 - 0 if the location is not taken, 1 if it is
# Destroys:     $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7
#

is_location_taken:
	addi	$sp, $sp, -12		# space on stack for three items
	sw	$ra, 0($sp)		# Save return address
	sw	$s0, 4($sp)		# Save $s0
	sw	$s1, 8($sp)		# Save $s1

	lw	$s0, 8($a2)		# Load colony A value
	lw	$t0, 0($a2)		# Load address of rowArray_A
	lw	$t1, 4($a2)		# Load address of colArray_A

	li	$s1, 0

check_colony_A_loop:
	slt	$t7, $s1, $s0
	beq	$t7, $zero, check_colony_B

	mul	$t2, $s1, 4		# Offset = index * 4
	add	$t5, $t0, $t2		# Address of current row in colony A
	add	$t6, $t1, $t2		# Address of current col in colony A

	lw	$t3, 0($t5)
	lw	$t4, 0($t6)

					# if row matches, check col
	beq	$a0, $t3, check_colony_A_columns_branch
	addi	$s1, $s1, 1
	j	check_colony_A_loop

check_colony_A_columns_branch:
	beq	$a1, $t4, location_taken

check_colony_B:
	lw	$s0, 8($a3)		# Load colony B size
	lw	$t0, 0($a3)		# Load address of rowArray_B
	lw	$t1, 4($a3)		# Load address of colArray_B

	li	$s1, 0

check_colony_B_loop:
	slt	$t7, $s1, $s0
	beq	$t7, $zero, location_not_taken

					# Otherwise, continue

	mul	$t2, $s1, 4		# Offset = index * 4
	add	$t5, $t0, $t2		# Address of current row colony B
	add	$t6, $t1, $t2		# Address of current column colony B

	lw	$t3, 0($t5)
	lw	$t4, 0($t6)

	beq	$a0, $t3, check_colony_B_columns_branch
	addi	$s1, $s1, 1
	j	check_colony_B_loop

check_colony_B_columns_branch:
	beq	$a1, $t4, location_taken

location_not_taken:
	li	$v0, 0
	j	return_from_subroutine

location_taken:
	li	$v0, 1

return_from_subroutine:
	lw	$ra, 0($sp)		# Restore return address
	lw	$s0, 4($sp)		# Restore $s0
	lw	$s1, 8($sp)		# Restore $s1
	addi	$sp, $sp, 12		# Clean up stack
	jr	$ra			# Return to caller
