main:
move $fp, $sp
# adding a global variable
li $a0, 0
sw $a0, 0($gp)
# end of adding a global variable
# adding a global variable
li $a0, 0
sw $a0, 4($gp)
# end of adding a global variable
# adding a global variable
li $a0, 0
sw $a0, 12($gp)
# end of adding a global variable
# start of adding global address to stack
addiu $a0, $gp, 12
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding global address to stack
# adding a number to stack
li $a0, 99
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
# start of assign
lw $a0, 4($sp)
# pop stack
addiu $sp, $sp, 4
# end of pop stack
lw $a1, 4($sp)
# pop stack
addiu $sp, $sp, 4
# end of pop stack
sw $a0, 0($a1)
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of assign
# start of adding global variable to stack
lw $a0, 0($gp)
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding global variable to stack
# writing
lw $a0, 4($sp)
# start syscall 1
li $v0, 1
syscall
# end syscall
# pop stack
addiu $sp, $sp, 4
# end of pop stack
addi $a0, $zero, 10
# start syscall 11
li $v0, 11
syscall
# end syscall
# end of writing
# start of adding global variable to stack
lw $a0, 12($gp)
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding global variable to stack
# writing
lw $a0, 4($sp)
# start syscall 11
li $v0, 11
syscall
# end syscall
# pop stack
addiu $sp, $sp, 4
# end of pop stack
addi $a0, $zero, 10
# start syscall 11
li $v0, 11
syscall
# end syscall
# end of writing
# start syscall 10
li $v0, 10
syscall
# end syscall
