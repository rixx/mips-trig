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
    la      $a0, xmin       # load address of "x_min: " into $a0
    li      $v0, 4          # load system code for string output
    syscall                 # print string

    li      $v0, 6          # load system code for float input
    syscall                 # read float into $f0
    mov.s   $f1, $f0        # move x_min to $f1
    
    la      $a0, xmax       # load address of "x_max: " into $a0
    li      $v0, 4          # load system code for string output
    syscall                 # print string

    li      $v0, 6          # load system code for float input
    syscall                 # read float into $f0
    mov.s   $f2, $f0        # move x_max to $f2

    c.lt.s  $f2, $f1        # fail if x_min >= x_max
    bc1t    error0

    la      $a0, steps      # load address of "steps: " into $a0
    li      $v0, 4          # load system code for string output
    syscall                 # print string

    li      $v0, 5          # load system code for float input
    syscall                 # read float into $f0
    move    $t0, $v0        # move steps to $t0

    addi    $t1, $t0, -1    # write n-1 to $t1
    blez    $t1, error1     # fail if steps <= 1

    mtc1    $t1, $f4
    cvt.s.w $f4, $f4        # cast n-1 to float (in $f4)

    sub.s   $f3, $f2, $f1   # write (xmax-xmin) to $f3
    div.s   $f4, $f3, $f4   # intervall = (xmax-xmin)/(n-1) in $f4


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

