.data
xmin: .asciiz "x_min: "
xmax: .asciiz "x_max: "
steps: .asciiz "steps: "
err0: .asciiz "x_max should be greater than x_min."
err1: .asciiz "steps should be greater than 1."
newline: .asciiz "\n"

.globl main

.text

main:
    la      $a0, xmin           # load address of "x_min: " into $a0
    li      $v0, 4              # load system code for string output
    syscall                     # print string

    li      $v0, 6              # load system code for float input
    syscall                     # read float into $f0
    mov.s   $f1, $f0            # move x_min to $f1
    
    la      $a0, xmax           # load address of "x_max: " into $a0
    li      $v0, 4              # load system code for string output
    syscall                     # print string

    li      $v0, 6              # load system code for float input
    syscall                     # read float into $f0
    mov.s   $f2, $f0            # move x_max to $f2

    c.lt.s  $f2, $f1            # fail if x_min >= x_max
    bc1t    error0

    la      $a0, steps          # load address of "steps: " into $a0
    li      $v0, 4              # load system code for string output
    syscall                     # print string

    li      $v0, 5              # load system code for int input
    syscall                     # read int into $v0
    move    $s0, $v0            # move steps to $s0

    addi    $t0, $s0, -1        # write n-1 to $t0
    blez    $t0, error1         # fail if steps <= 1

    mtc1    $t0, $f4
    cvt.s.w $f4, $f4            # cast n-1 to float (in $f4)

    sub.s   $f3, $f2, $f1       # write (xmax-xmin) to $f3
    div.s   $f21, $f3, $f4      # intervall = (xmax-xmin)/(n-1) in $f21

    mov.s   $f20, $f1           # write x_min (steps) to $f20

main_loop:
    mov.s   $f12, $f20          # move step to $f12
    jal     sin                 # call sin(step)

    mov.s   $f22, $f0           # move sin(step) to $f22
    mov.s   $f12, $f20          # move step to $f12
    jal     cos                 # call cos(step)

    mov.s   $f23, $f0           # move cos(step) to $f23
    mov.s   $f12, $f20          # move step to $f12
    jal     tan                 # call tan(step)
   
    addi    $s0, -1             # n--;
    beqz    $s0, end            # exit if n == 0

    add.s   $f20, $f20, $f21    # step += intervall;
    j       main_loop           # looooop


sin
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x

    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 8         # aaaand return
    jr      $ra

cos:
    jr      $ra

tan:
    jr      $ra

end:
    li      $v0, 10
    syscall


error0:
    la      $a0, err0       # load address of error #0
    li      $v0, 4          # load system code for string output
    syscall
    j       end


error1:
    la      $a0, err1       # load address of error #1
    li      $v0, 4          # load system code for string output
    syscall
    j       end

