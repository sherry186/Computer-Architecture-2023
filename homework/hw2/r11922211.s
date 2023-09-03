.globl __start

.rodata
    division_by_zero: .string "division by zero"
    
.data
    SwitchCase: .word O0, O1, O2, O3, O4, O5, O6 

.text
__start:
    # Read first operand
    li a0, 5
    ecall
    mv s0, a0
    # Read operation
    li a0, 5
    ecall
    mv s1, a0
    # Read second operand
    li a0, 5
    ecall
    mv s2, a0

###################################
#  TODO: Develop your calculator  #
#  A, op, B will be stored at register s0, s1, s2 register   
#  Addition(0), subtraction(1), multiplication(2), integer division(3), minimum(4), power(5), and factorial(
###################################
    
    # switch case
    la t3, SwitchCase
    slli t4, s1, 2
    add t5, t3, t4
    lw t6, 0(t5)
    jr t6
    
O0: # add
    add s3, s0, s2
    j output
    
O1: # sub
    sub s3, s0, s2
    j output
    
O2: # multiply
    mul s3, s0, s2
    j output
    
O3: # div
    beq s2, x0, division_by_zero_except
    div s3, s0, s2
    j output
    
O4: # min
    bge s0, s2, O4_greater
    add s3, x0, s0
    j output
    
O4_greater:
    add s3, x0, s2
    j output
   
O5: # power
    addi s3, x0, 1 # set s3 as 1
    addi t0, x0, 0 # set t0 as 0
    j O5_loop

O5_loop:    
    beq t0, s2, output
    mul s3, s3, s0
    addi t0, t0, 1
    j O5_loop

fact:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    addi t0, a0, -1
    bge t0, x0, fact_main
    addi a0, x0, 1
    addi sp, sp, 8
    jalr x0, 0(ra)

fact_main:
    addi a0, a0, -1
    jal x1, fact
    addi t1, a0, 0
    lw a0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    mul a0, a0, t1
    jalr x0, 0(ra)
  
O6: # fact 
    # addi s3, x0, 6 
    addi a0, s0, 0
    jal ra, fact
    addi s3, a0, 0
    j output
    
output:
    # Output the result
    li a0, 1
    mv a1, s3
    ecall

exit:
    # Exit program(necessary)
    li a0, 10
    ecall

division_by_zero_except:
    li a0, 4
    la a1, division_by_zero
    ecall
    jal zero, exit
