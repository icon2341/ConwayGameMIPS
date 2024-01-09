#
# FILE:         $File$
# AUTHOR:       Ashar Rahman, RIT, 2023
#
# DESCRIPTION:
#	This is the implementation for the Final Project Where
#	Conways Game of Life is implemented.
#
# ARGUMENTS:
#	None
#
# INPUT:
# 	User will provide The board size, number of generations to run and
#	initial set of alive cells for each colony.
#
# OUTPUT:
#	Various Error Messages and the board with each generation.
#
#
# REVISION HISTORY:
#

#
# Numeric Constantss
#


PRINT_STRING = 4
READ_INT = 5
PRINT_INT = 1
BOARDSIZE_LEGAL_MIN = 4
BOARDSIZE_LEGAL_MAX = 30
GENERATION_LEGAL_MAX = 20

DEAD_CELL = 0
CELL_A = 1
CELL_B = 2

#
# DATA AREAS
#
	.data
	.align 2  			# word boundaries

colony_A_block:
	.word rowArray_A
	.word colArray_A
	.word 0

colony_B_block:
	.word rowArray_B
	.word colArray_B
	.word 0

rowArray_A:
	.space 120   			# Allocate space for row indices

colArray_A:
	.space 120   			# Allocate space for column indices

colonySize_A:
	.word 0				# counter for the number of live cells

rowArray_B:
	.space 120   			# Allocate space for row indices

colArray_B:
	.space 120   			# Allocate space for column indices

colonySize_B:
	.word 0				# counter for the number of live cells

board_size:
	.word 0				# represents current board size

num_generations:
	.word 0

game_board:
	.space 900			# 30*30 cells, each cell 4 bytes

newline:
	.asciiz	"\n"

double_newline:
	.asciiz	"\n\n"

space:	
	.asciiz	" "

board_size_prompt:
	.asciiz "\nEnter board size: "

generations_prompt:
	.asciiz "\nEnter number of generations to run: "

alive_cells_A_prompt:
	.asciiz "\nEnter number of live cells for colony A: "

alive_cells_B_prompt:
	.asciiz "\nEnter number of live cells for colony B: "

start_locations_prompt:
	.asciiz "\nStart entering locations\n"

illegal_board_size_prompt:
	.asciiz "\nWARNING: illegal board size, try again: "

illegal_generations_prompt:
	.asciiz "\nWARNING: illegal number of generations, try again: "

illegal_alive_cells:
	.asciiz "\nWARNING: illegal number of live cells, try again: "

illegal_point__location:
	.asciiz "\nERROR: illegal point location\n"

program_banner:
	.asciiz "\n**********************\n****    Colony    ****\n**********************\n"

#
# CODE AREAS
#
	.text
	.align 2

	.globl main
	.globl is_location_taken
	.globl print_board

main:
	addi	$sp,$sp,-4		# allocate for the return address
	sw	$ra,($sp)		# store the ra on the stack

	li	$v0,PRINT_STRING
	la	$a0,program_banner
	syscall				# print program

	la	$t0, colony_A_block
	li	$t1, 0
	sw	$t1, 8($t0)
	la	$t0, colony_B_block
	sw	$t1, 8($t0)


get_user_input_board_size:
	li	$v0, PRINT_STRING
	la	$a0, board_size_prompt
	syscall				# print board size prompt

	li	$v0, READ_INT
	syscall				# read board size
	move	$s0, $v0		# store board size in $s0

					# compare passed board size to values

	li	$t3, BOARDSIZE_LEGAL_MIN
	slt 	$t0, $s0, $t3
	li	$t1, 30
	slt	$t2, $t1, $s0

					# check to see if board_size within
					# 5 and 31 (exclusive)

	bne	$t0, $zero, bad_board_size_prompt_user_loop
	bne	$t2, $zero, bad_board_size_prompt_user_loop

	j get_user_input_generations

bad_board_size_prompt_user_loop:
	li	$v0, PRINT_STRING
	la	$a0, illegal_board_size_prompt
	syscall			# print illegal board size prompt

	li	$v0, READ_INT
	syscall				# read board size
	move	$s0, $v0		# store board size in $s0

	slt 	$t0, $s0, $t3
	li	$t1, 30
	slt	$t2, $t1, $s0

					# check to see if board_size within
					# 5 and 31 (exclusive)

	bne	$t0, $zero, bad_board_size_prompt_user_loop
	bne	$t2, $zero, bad_board_size_prompt_user_loop

store_board_size:
	la	$t0, board_size		# get board_size address
	sw	$s0, 0($t0)		# store board_size into address

get_user_input_generations:
	li	$v0, PRINT_STRING
	la	$a0, generations_prompt
	syscall				# print generations prompt

	li	$v0, READ_INT
	syscall				# read generations
	move	$s1, $v0		# store generations in $s1

					# compare passed generations to values

	li	$t3, 0
	slt 	$t0, $s1, $t3 
	li	$t1, GENERATION_LEGAL_MAX
	slt	$t2, $t1, $s1

					# check to see if generations within
					# 1 and 21 (exclusive)

	bne	$t0, $zero, bad_generations_prompt_user_loop
	bne	$t2, $zero, bad_generations_prompt_user_loop

	j get_total_number_cells_board



bad_generations_prompt_user_loop:
	li	$v0, PRINT_STRING
	la	$a0, illegal_generations_prompt
	syscall				# print illegal generations prompt

	li	$v0, READ_INT
	syscall				# read generations
	move	$s1, $v0		# store generations in $s1

	slt 	$t0, $s1, $t3
	li	$t1, GENERATION_LEGAL_MAX
	slt	$t2, $t1, $s1

					# check to see if generations within
					# 1 and 21 (exclusive)

	bne	$t0, $zero, bad_generations_prompt_user_loop
	bne	$t2, $zero, bad_generations_prompt_user_loop

store_generations:
	la	$t0, num_generations
	sw	$s1, 0($t0)

get_total_number_cells_board:
					# multiply board size by board size
					# to get total number of cells
	mul	$s2, $s0, $s0

get_user_input_alive_cells_A:
	li	$v0, PRINT_STRING
	la	$a0, alive_cells_A_prompt
	syscall				# print alive cells A prompt

	li	$v0, READ_INT
	syscall				# read alive cells A
	move	$s3, $v0		# store alive cells A in $s3

					# compare passed alive cells A to values

	li	$t3, 0
	slt 	$t0, $s3, $t3
	slt	$t1, $s2, $s3

					# check to see if alive cells A within
					# 0 and total number of cells on board

	bne	$t0, $zero, bad_alive_cells_A_prompt_user_loop
	bne	$t1, $zero, bad_alive_cells_A_prompt_user_loop

	j get_user_input_live_cell_locations_A

bad_alive_cells_A_prompt_user_loop:
	li	$v0, PRINT_STRING
	la	$a0, illegal_alive_cells
	syscall				# print illegal alive cells prompt

	li	$v0, READ_INT
	syscall				# read alive cells A
	move	$s3, $v0		# store alive cells A in $s3

	slt 	$t0, $s3, $t3
	slt	$t1, $s2, $s3

					# check to see if alive cells A within
					# 0 and total number of cells on board

	bne	$t0, $zero, bad_alive_cells_A_prompt_user_loop
	bne	$t1, $zero, bad_alive_cells_A_prompt_user_loop

get_user_input_live_cell_locations_A:
	li	$v0, PRINT_STRING
	la	$a0, start_locations_prompt
	syscall                 	# print start locations prompt

	li	$s4, 0             	# counter for the number of live cells

get_user_input_live_cell_locations_A_loop:
					# check if our collected number of
					# cells is equal to the number of
					# cells we want to collect
	slt	$t1, $s4, $s3
	beq	$t1, $zero, get_user_input_live_cell_locations_A_done

	li	$v0, READ_INT
	syscall				# read row
	move	$t0, $v0		# store row in $t0

	li	$v0, READ_INT
	syscall				# read column
	move	$t1, $v0		# store column in $t1

validate_row_nonnegative_location_A:
	slt	$t2, $t0, $zero		# verify that row is non-negative

					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, check_row_within_board
	j	invalid_location

check_row_within_board:
					# check that row index is less than
					# board length
	slt	$t2, $t0, $s0
					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, invalid_location
	j	validate_column_location_A

validate_column_location_A:
	slt	$t2, $t1, $zero		# verify that col is non-negative

					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, check_column_within_board
	j	invalid_location

check_column_within_board:
					# check that col index is less than
					# board length
	slt	$t2, $t1, $s0
					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, invalid_location

check_if_location_used:
    addi    $sp, $sp, -8      		# Allocate stack space for 2 registers
    sw      $t0, 0($sp)       		# Save $t0 on the stack
    sw      $t1, 4($sp)       		# Save $t1 on the stack

    move    $a0, $t0          		# Row to check
    move    $a1, $t1          		# Column to check
    la      $a2, colony_A_block   	# Address of colony_A_block
    la      $a3, colony_B_block   	# Address of colony_B_block

    jal     is_location_taken

    lw      $t0, 0($sp)       		# Restore $t0
    lw      $t1, 4($sp)       		# Restore $t1
    addi    $sp, $sp, 8       		# Deallocate stack space

    bne     $v0, $zero, invalid_location

store_location_A:
	la	$t4, colony_A_block
	lw	$t5, 0($t4)		# Load address of rowArray_A
	lw	$t6, 4($t4)		# Load address of colArray_A

	mul	$t2, $s4, 4		# multiply $s4 by 4 to get the offset
	add	$t3, $t5, $t2		# add the offset to the base address
	add	$t7, $t6, $t2		# add the offset to the base address
	sw	$t0, 0($t3)		# store the row
	sw	$t1, 0($t7)		# store the column

	addi	$s4, $s4, 1		# increment the number of cells
	sw	$s4, 8($t4)		# store the number of cells

	j	get_user_input_live_cell_locations_A_loop

get_user_input_live_cell_locations_A_done:

get_user_input_alive_cells_B:
	li	$v0, PRINT_STRING
	la	$a0, alive_cells_B_prompt
	syscall				# print alive cells B prompt

	li	$v0, READ_INT
	syscall				# read alive cells B
	move	$s3, $v0		# store alive cells B in $s3

					# compare passed alive cells B to values

	li	$t3, 0
	slt 	$t0, $s3, $t3
	slt	$t1, $s2, $s3

					# check to see if alive cells B within
					# 0 and total number of cells on board

	bne	$t0, $zero, bad_alive_cells_B_prompt_user_loop
	bne	$t1, $zero, bad_alive_cells_B_prompt_user_loop

	j get_user_input_live_cell_locations_B

bad_alive_cells_B_prompt_user_loop:
	li	$v0, PRINT_STRING
	la	$a0, illegal_alive_cells
	syscall				# print illegal alive cells prompt

	li	$v0, READ_INT
	syscall				# read alive cells B
	move	$s3, $v0		# store alive cells B in $s3

	slt 	$t0, $s3, $t3
	slt	$t1, $s2, $s3

					# check to see if alive cells B within
					# 0 and total number of cells on board

	bne	$t0, $zero, bad_alive_cells_B_prompt_user_loop
	bne	$t1, $zero, bad_alive_cells_B_prompt_user_loop

get_user_input_live_cell_locations_B:
	li	$v0, PRINT_STRING
	la	$a0, start_locations_prompt
	syscall                 	# print start locations prompt

	li	$s4, 0             	# counter for the number of live cells

get_user_input_live_cell_locations_B_loop:
					# check if our collected number of
					# cells is equal to the number of
					# cells we want to collect
	slt	$t1, $s4, $s3
	beq	$t1, $zero, get_user_input_live_cell_locations_B_done

	li	$v0, READ_INT
	syscall				# read row
	move	$t0, $v0		# store row in $t0

	li	$v0, READ_INT
	syscall				# read column
	move	$t1, $v0		# store column in $t1

validate_row_nonnegative_location_B:
	slt	$t2, $t0, $zero		# verify that row is non-negative

					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, check_row_within_board_B
	j	invalid_location

check_row_within_board_B:
					# check that row index is less than
					# board length
	slt	$t2, $t0, $s0
					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, invalid_location
	j	validate_column_location_B

validate_column_location_B:
	slt	$t2, $t1, $zero		# verify that col is non-negative

					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, check_column_within_board_B
	j	invalid_location

check_column_within_board_B:
					# check that col index is less than
					# board length
	slt	$t2, $t1, $s0
					# if so, continue checks, else
					# terminate
	beq	$t2, $zero, invalid_location

check_if_location_used_B:
    addi    $sp, $sp, -8      		# Allocate stack space for 2 registers
    sw      $t0, 0($sp)       		# Save $t0 on the stack
    sw      $t1, 4($sp)       		# Save $t1 on the stack

    move    $a0, $t0          		# Row to check
    move    $a1, $t1          		# Column to check
    la      $a2, colony_A_block   	# Address of colony_A_block
    la      $a3, colony_B_block   	# Address of colony_B_block

    jal     is_location_taken

    lw      $t0, 0($sp)       		# Restore $t0
    lw      $t1, 4($sp)       		# Restore $t1
    addi    $sp, $sp, 8       		# Deallocate stack space

    bne     $v0, $zero, invalid_location

store_location_B:
	la	$t4, colony_B_block
	lw	$t5, 0($t4)		# Load address of rowArray_B
	lw	$t6, 4($t4)		# Load address of colArray_B

	mul	$t2, $s4, 4		# multiply $s4 by 4 to get the offset
	add	$t3, $t5, $t2		# add the offset to the base address
	add	$t7, $t6, $t2		# add the offset to the base address
	sw	$t0, 0($t3)		# store the row
	sw	$t1, 0($t7)		# store the column

	addi	$s4, $s4, 1		# increment the number of cells
	sw	$s4, 8($t4)		# store the number of cells

	j	get_user_input_live_cell_locations_B_loop

get_user_input_live_cell_locations_B_done:
	la	$a1, colony_A_block
	la	$a2, colony_B_block
	move	$a0, $s0
	jal print_board


populate_board:
    la $t1, colony_A_block        # Load address of colony_A_block
    lw $t0, 8($t1)                # Load the number of cells in Colony A
    li $t2, 0                     # Zero constant for comparison
    beq $t0, $t2, populate_B      # If Colony A has no cells, skip to Colony B
    lw $t3, 0($t1)                # Load address of rowArray_A
    lw $t4, 4($t1)                # Load address of colArray_A
    lw $t5, board_size

populate_A_loop:
    beq $t0, $t2, populate_B      # If all cells are populated, go to Colony B
    lw $t6, 0($t3)                # Load a row index from rowArray_A
    lw $t7, 0($t4)                # Load a column index from colArray_A
    mul $t8, $t6, $t5             # Calculate the row offset
    add $t8, $t8, $t7             # Add the column index to get the cell index
    li $t9, 4
    mul $t8, $t8, $t9             # Multiply by 4 (size of word) to get byte offset
    la $t9, game_board
    add $t9, $t9, $t8             # Calculate the address of the cell in game_board
    li $t10, 1                    # CELL_A = 1
    sw $t10, 0($t9)               # Set the cell to CELL_A
    addi $t3, $t3, 4              # Move to the next row index
    addi $t4, $t4, 4              # Move to the next column index
    addi $t0, $t0, -1             # Decrement the cell counter
    j populate_A_loop

populate_B:
    la $t1, colony_B_block        # Load address of colony_B_block
    lw $t0, 8($t1)                # Load the number of cells in Colony B
    li $t2, 0                     # Zero constant for comparison
    beq $t0, $t2, done_populating # If Colony B has no cells, finish population
    lw $t3, 0($t1)                # Load address of rowArray_B
    lw $t4, 4($t1)                # Load address of colArray_B
    lw $t5, board_size

populate_B_loop:
    beq $t0, $t2, done_populating # If all cells are populated, finish population
    lw $t6, 0($t3)                # Load a row index from rowArray_B
    lw $t7, 0($t4)                # Load a column index from colArray_B
    mul $t8, $t6, $t5             # Calculate the row offset
    add $t8, $t8, $t7             # Add the column index to get the cell index
    li $t9, 4
    mul $t8, $t8, $t9             # Multiply by 4 (size of word) to get byte offset
    la $t9, game_board
    add $t9, $t9, $t8             # Calculate the address of the cell in game_board
    li $t10, 2                    # CELL_B = 2
    sw $t10, 0($t9)               # Set the cell to CELL_B
    addi $t3, $t3, 4              # Move to the next row index
    addi $t4, $t4, 4              # Move to the next column index
    addi $t0, $t0, -1             # Decrement the cell counter
    j populate_B_loop





invalid_location:
	li	$v0, PRINT_STRING	# print out illegal point statement
	la	$a0, illegal_point__location
	syscall

main_done:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra			# gracefuly return from program
