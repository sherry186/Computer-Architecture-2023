.globl __start

.text
__start:
    # Read n
    li a0, 5
    ecall
    jal ra, rec
    addi s3, a0, 0
    j output

rec:
    addi sp, sp, -12
    sw a0, 8(sp)
    sw ra, 4(sp)
    li s1, 1
    ble a0,s1,L1
    addi a0, a0, -1
    jal ra, rec
    slli a0, a0, 1
    sw a0, 0(sp)
    lw a0, 8(sp)
    addi a0, a0, -2
    jal ra, rec
    lw t0, 0(sp)
    add a0, a0, t0
    lw ra, 4(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)
    
    
L1:
    addi sp, sp, 12
    jalr x0 0(ra)  
       

output:
    # Output the result
    li a0, 1
    mv a1, s3
    ecall

exit:
    # Exit program(necessary)
    li a0, 10
    ecall
