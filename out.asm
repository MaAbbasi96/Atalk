main:
move $fp, $sp
# adding a number to stack
li $a0, 0
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
# start of if block
lw $a0, 4($sp)
# pop stack
addiu $sp, $sp, 4
# end of pop stack
beq $a0, $zero, LABEL0
# end of if block
# adding a number to stack
li $a0, 5
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
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
j LABEL1
LABEL0: 
# adding a number to stack
li $a0, 0
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
# start of if block
lw $a0, 4($sp)
# pop stack
addiu $sp, $sp, 4
# end of pop stack
beq $a0, $zero, LABEL2
# end of if block
# adding a number to stack
li $a0, 2
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
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
j LABEL1
LABEL2: 
# adding a number to stack
li $a0, 4
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
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
j LABEL1
LABEL1: 
# adding a number to stack
li $a0, 3
sw $a0, 0($sp)
addiu $sp, $sp, -4
# end of adding a number to stack
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
# start syscall 10
li $v0, 10
syscall
# end syscall
