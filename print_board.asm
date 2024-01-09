.data
newline:         .asciiz "\n"
dead_cell_repr:  .asciiz "."
cell_a_repr:     .asciiz "A"
cell_b_repr:     .asciiz "B"

.text
print_board:
    # Function prologue
    subu $sp, $sp, 24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)

    # Argument handling
    move $s0, $a0         # $s0 = Address of game_board
    move $s1, $a1         # $s1 = Address of colony A parameter block
    move $s2, $a2         # $s2 = Address of colony B parameter block
    move $t0, $a3         # $t0 = Board size

    li $t1, 0             # Initialize row counter to 0

print_row:
    bge $t1, $t0, exit_print  # If all rows are printed, exit
    li $t2, 0                 # Initialize column counter to 0

print_col:
    bge $t2, $t0, newline_print  # If all columns in row are printed, print newline
    mul $t3, $t1, $t0           # Calculate row offset
    add $t3, $t3, $t2           # Add column to get cell index
    li $t4, 4
    mul $t3, $t3, $t4           # Multiply by 4 (size of word) to get byte offset

    # Determine the state of the cell
    lw $t5, 0($s0)              # Load cell value from game_board
    beqz $t5, print_dead
    lw $t5, 0($s1)              # Load cell value from colony A parameter block
    beqz $t5, print_b
    lw $t5, 0($s2)              # Load cell value from colony B parameter block
    beqz $t5, print_a

print_dead:
    la $a0, dead_cell_repr
    b print_char

print_a:
    la $a0, cell_a_repr
    b print_char

print_b:
    la $a0, cell_b_repr
    b print_char

print_char:
    li $v0, 4
    syscall
    addi $t2, $t2, 1             # Increment column counter
    j print_col

newline_print:
    la $a0, newline
    li $v0, 4
    syscall
    addi $t1, $t1, 1             # Increment row counter
    j print_row

exit_print:
    # Function epilogue
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    addu $sp, $sp, 24
    jr $ra                       # Return from the function
