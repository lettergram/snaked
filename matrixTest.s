.data

#typedef struct HexMatrix {
#    int size;
#    unsigned char** data;
#} HexMatrix;

#typedef struct HexList {
#    int size;
#    unsigned char** data;
#} HexList;

########################## MATRIX 1 ########################## 
M2050: .byte 0x4, 0xf
M2070: .byte 0xd, 0x5
M2030: .word M2050, M2070
matrix1: .word 2, M2030

#################### BLANK/EMPTY MATRIX 1 #################### 
B2050: .byte 0x0, 0x0
B2070: .byte 0x0, 0x0
B2030: .word B2050, B2070
blank1: .word 2, B2030

##########################  LIST 1  ########################## 
L20e0: .byte 0xf, 0x5
L2100: .byte 0xd, 0x5
L2120: .byte 0x4, 0xd
L2140: .byte 0x4, 0xf
L20b0: .word L20e0, L2100, L2120, L2140
list1: .word 4, L20b0


########################## MATRIX 2 ########################## 
M21b0: .byte 0x4, 0xf, 0xd, 0x5
M21d0: .byte 0xa, 0x3, 0x6, 0x9
M21f0: .byte 0xd, 0x1, 0xf, 0xe
M2210: .byte 0x1, 0xc, 0xe, 0xd
M2180: .word M21b0, M21d0, M21f0, M2210
matrix2: .word 4, M2180

#################### BLANK/EMPTY MATRIX 2 #################### 
B21b0: .byte 0x0, 0x0, 0x0, 0x0
B21d0: .byte 0x0, 0x0, 0x0, 0x0
B21f0: .byte 0x0, 0x0, 0x0, 0x0
B2210: .byte 0x0, 0x0, 0x0, 0x0
B2180: .word B21b0, B21d0, B21f0, B2210
blank2: .word 4, B2180


##########################  LIST 2  ########################## 
L22a0: .byte 0x5, 0x9, 0xe, 0xd
L22c0: .byte 0xa, 0x3, 0x6, 0x9
L22e0: .byte 0xd, 0x6, 0xf, 0xe
L2300: .byte 0x1, 0xc, 0xe, 0xd
L2320: .byte 0xf, 0x3, 0x1, 0xc
L2340: .byte 0x4, 0xa, 0xd, 0x1
L2360: .byte 0xd, 0x1, 0xf, 0xe
L2380: .byte 0x4, 0xf, 0xd, 0x5
L2250: .word L22a0, L22c0, L22e0, L2300, L2320, L2340, L2360, L2380
list2: .word 8, L2250

instruction: .asciiz "The output should be the same as the original matrix or its transpose.\n\n"
original: .asciiz "The original matrix is:\n"
student: .asciiz "The matrix returned by your solve is:\n"
newline: .asciiz "\n"


########################### problem4.s testing code ##########################
.text         # Code segment

print_hex:                      # the value to print is already in $a0
  bge  $a0, 10, ph_alpha  # if the value is greater than 9 it is a letter.
        li   $v0, 1             # load the syscall option for printing ints
        syscall                 # print the integer
	jr   $ra		# jump to code to print a space
ph_alpha:
	add  $a0, $a0, 87	# add 'a' - 10, so that 0xa becomes 'a'
        li   $v0, 11            # load the syscall option for printing chars
        syscall                 # print the integer
        jr   $ra                # return to the calling procedure


## void printMatrix(HexMatrix* matrix)
print_matrix:
        li      $t0, 0          # $t0 = i = 0
        lw      $t2, 0($a0)     # $t2 = matrix->size
        move    $t3, $a0        # $t3 = matrix

pm_loop:
        bge     $t0, $t2, pm_loop_end

        li      $t1, 0          # $t1 = j = 0
pm_inner_loop:
        bge     $t1, $t2, pm_inner_end

        lw      $t4, 4($t3)     # $t4 = matrix->data
        mul     $t5, $t0, 4     # $t5 = 4 * i
        add     $t4, $t4, $t5   # $t4 = &matrix->data[i]
        lw      $t4, 0($t4)     # $t2 = matrix->data[i]
        add     $t4, $t4, $t1   # $t2 = &matrix->data[i][j]
        lb      $a0, 0($t4)     # $a0 = matrix->data[i][j]

	bge     $a0, 10, pm_alpha  # if the value is greater than 9 it is a letter.
        li      $v0, 1          # load the syscall option for printing ints
        syscall                 # print the integer
	j       pm_inner_continue	
pm_alpha:
	add  $a0, $a0, 87	# add 'a' - 10, so that 0xa becomes 'a'
        li   $v0, 11            # load the syscall option for printing chars
        syscall                 # print the integer

pm_inner_continue:
        add     $t1, $t1, 1     # ++ j
        j       pm_inner_loop

pm_inner_end:
        la      $a0, newline
        li      $v0, 4
        syscall

        add     $t0, $t0, 1     # ++ i
        j       pm_loop

pm_loop_end:
        jr      $ra




# main function

.globl main
main:
        sub     $sp, $sp 4
        sw      $ra, 0($sp)        # save $ra on stack

        li      $v0, 4
        la      $a0, instruction
        syscall

	# TEST 1: find matrix1 from list1
        li      $v0, 4
        la      $a0, original
        syscall
        la      $a0, matrix1
        jal     print_matrix	  # print out goal matrix
        li      $v0, 4
        la      $a0, newline
        syscall
		       
        la      $a0, blank1		 # matrix
        la      $a1, list1		 # list
		jal		first_row_column
		jal		next_rows
        
        li      $v0, 4
        la      $a0, student
        syscall
        la      $a0, blank1
        jal     print_matrix
        li      $v0, 4
        la      $a0, newline
        syscall


	# TEST 2: find matrix2 from list2
        li      $v0, 4
        la      $a0, original
        syscall
        la      $a0, matrix2
        jal     print_matrix	  # print out goal matrix
        li      $v0, 4
        la      $a0, newline
        syscall
        
        la      $a0, blank2		 # matrix
        la      $a1, list2		 # list
		jal		first_row_column
		#jal		next_rows
        
        li      $v0, 4
        la      $a0, student
        syscall
        la      $a0, blank2
        jal     print_matrix
        li      $v0, 4
        la      $a0, newline
        syscall

        lw   $ra, 0($sp)        # restore $ra
        addi $sp, $sp, 4
        
        jr   $ra
