.data
xmin: .asciiz "x_min: "
xmax: .asciiz "x_max: "
steps: .asciiz "steps: "

err0: .asciiz "x_max should be greater than x_min."
err1: .asciiz "steps should be greater than 1."

halfpi: .float 1.5707963
mhalfpi: .float -1.5707963
pi: .float 3.141592
mpi: .float -3.141592
twopi: .float 6.283185
fzero: .float 0.0

newline: .asciiz "\n"
space: .asciiz " "
separator: .asciiz " | "
headline: .asciiz "x          | sin        | cos        | tan\n"

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

    la      $a0, headline       # print headline of table
    li      $v0, 4
    syscall

    mov.s   $f20, $f1           # write x_min (steps) to $f20
                                # so it will be saved by other functions

main_loop:
    mov.s   $f12, $f20          # print current x
    li      $v0, 2
    syscall
    la      $a0, separator
    li      $v0, 4
    syscall

    mov.s   $f12, $f20          # move x to $f12
    jal     sin                 # call sin(step)
    
    mov.s   $f12, $f0           # print result of sin(x)
    li      $v0, 2              
    syscall                    
    la      $a0, separator
    li      $v0, 4
    syscall

    mov.s   $f22, $f0           # move sin(step) to $f22
    mov.s   $f12, $f20          # move step to $f12
    jal     cos                 # call cos(step)

    mov.s   $f12, $f0           # print result of cos(x)
    li      $v0, 2              
    syscall                    
    la      $a0, separator
    li      $v0, 4
    syscall

    mov.s   $f23, $f0           # move cos(step) to $f23
    mov.s   $f12, $f20          # move step to $f12
    jal     tan                 # call tan(step)
    mov.s   $f12, $f0
    li      $v0, 2              # load system code for float output
    syscall                     # read int into $v0
    la      $a0, newline
    li      $v0, 4
    syscall
   
    addi    $s0, -1             # n--;
    beqz    $s0, end            # exit if n == 0

    add.s   $f20, $f20, $f21    # step += intervall;
    j       main_loop           # looooop


sin:
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x

    l.s     $f1, mhalfpi        # -pi/2 in $f1
    l.s     $f2, halfpi         # pi/2 in $f2
    l.s     $f3, mpi            # -pi in $f3
    l.s     $f4, pi             # pi in $f4
    l.s     $f5, twopi          # 2*pi in $f5

    c.lt.s  $f12, $f3
    bc1t    sin_norm1           # continue at sin_norm1 if x < -pi
    c.lt.s  $f4, $f12
    bc1t    sin_norm2           # continue at sin_norm2 if x > pi
    j       sin_call            # else continue at sin_call

sin_norm1:
    add.s   $f12, $f12, $f5     # x += 2*pi
    c.lt.s  $f12, $f3           # while (x < -pi)
    bc1t    sin_norm1
    j       sin_call

sin_norm2:
    sub.s   $f12, $f12, $f5     # x -= 2*pi
    c.lt.s  $f4, $f12           # while (x > pi)
    bc1t    sin_norm2
    j       sin_call

sin_call:
    c.lt.s  $f12, $f1           # if x < -pi/2
    bc1t    sin_call1
    c.lt.s  $f2, $f12           # if x > pi/2
    bc1t    sin_call2
    jal     sin0

endsin:
    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 4         # aaaand return
    jr      $ra

sin_call1:
    add.s   $f12, $f12, $f4      # sin0(x + pi)
    jal     sin0
    j       sin_inv 

sin_call2:
    sub.s   $f12, $f12, $f4     # sin0(x - pi)
    jal     sin0
    j       sin_inv

sin_inv:
    l.s     $f5, fzero
    sub.s   $f0, $f5, $f0
    j       endsin


sin0:
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x

    li      $t0, 1              # t0 = 1 (= i)
    li      $t2, 2              # t2 = 2 * i 
    li      $t3, 1              # t3 = 1 (= fac)
    li      $t1, 7              # t1 = maxiter
    mov.s   $f1, $f12           # $f1 = x (= pow)
    mov.s   $f0, $f12           # $f0 = x (= result)
    mul.s   $f2, $f12, $f12     # $f2 = x^2

sin0loop:
    mul.s   $f1, $f1, $f2       # pow *= x * x
    mul     $t3, $t3, $t2       # fac *= 2i
    addi    $t2, $t2, 1
    mul     $t3, $t3, $t2       # fac *= (2i + 1)
    addi    $t2, $t2, 1

    mtc1    $t3, $f3            # cast fac to float
    cvt.s.w $f3, $f3
    div.s   $f3, $f1, $f3       # result -= (pow/fac)
    sub.s   $f0, $f0, $f3

    addi    $t0, $t0, 1
    beq     $t0, $t1, sin0end

    mul.s   $f1, $f1, $f2       # pow *= x * x
    mul     $t3, $t3, $t2       # fac *= 2i
    addi    $t2, $t2, 1
    mul     $t3, $t3, $t2       # fac *= (2i + 1)
    addi    $t2, $t2, 1

    mtc1    $t3, $f3            # cast fac to float
    cvt.s.w $f3, $f3
    div.s   $f3, $f1, $f3       # result += (pow/fac)
    add.s   $f0, $f0, $f3

    addi    $t0, $t0, 1
    bne     $t0, $t1, sin0loop

sin0end:
    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 4         # aaaand return
    jr      $ra


cos:
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x

    l.s     $f1, halfpi
    sub.s   $f12, $f1, $f12
    jal     sin0

    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 4         # aaaand return
    jr      $ra

tan:
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x

    l.s     $f1, mhalfpi
    l.s     $f2, halfpi
    l.s     $f3, pi

    c.lt.s  $f12, $f1
    bc1t    tan_norm1

    c.lt.s  $f2, $f12
    bc1t    tan_norm2

tan_call:
    jal     tan0

tan_end:
    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 4         # aaaand return
    jr      $ra

tan_norm1:
    add.s   $f12, $f12, $f3
    c.lt.s  $f12, $f1
    bc1t    tan_norm1
    j       tan_call

tan_norm2:
    sub.s   $f12, $f12, $f3
    c.lt.s  $f2, $f12
    bc1t    tan_norm2
    j       tan_call


tan0:
    subu    $sp, $sp, 4         # allocate space to save $ra and x
    sw      $ra, 4($sp)         # save $ra
    s.s     $f12, 0($sp)        # save x
    mov.s   $f25, $f12

    jal     sin0
    mov.s   $f26, $f0
    jal     cos

    div.s   $f0, $f26, $f0

    lw      $ra, 4($sp)         # load $ra
    l.s     $f12, 0($sp)        # load x
    addi    $sp, $sp, 4         # aaaand return
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

