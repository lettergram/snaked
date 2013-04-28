###
###
### This file holds the current matrix solver
### To date as of 04/21/2013 by Austin Walters
### Currently not working properly
###	
###

.text

###
### This function finds the first row/column listrow1 = v0, listrow2 = v1
### int fisrt_row_column(HexMatrix * matrix, HexList* list);
###
.globl first_row_column
first_row_column:
	
	lw		$t0, 0($a0)			# matrix->size
	lw 		$t2, 0($a1)			# list->size
	add		$v0, $0, 0			# stores 0 into $v0 represents row

loop1:

	lw      	$t3, 4($a1)    			# $t3 = list->data
    	mul     	$t4, $v0, 4     		# $t4 = 4 * row
   	add    		$t3, $t3, $t4   		# $t3 = &list->data[row]
   	lw      	$t3, 0($t3)     		# $t3 = list->data[row], I belive this is [0] as well
	lb		$t3, 0($t3)			# loading first letter/number

	add		$v1, $v0, 1			# $v1 is the next row, so row = row + 1

loop2:
	
	lw      	$t5, 4($a1)    		 	# $t5 = list->data
   	mul     	$t6, $v1, 4     		# $t4 = 4 * row
   	add     	$t5, $t5, $t6   		# $t5 = &list->data[row]
    	lw      	$t5, 0($t5)     		# $t5 = list->data[row], I belive this is [0] as well
	lb		$t5, 0($t5)			# loading first letter/number

	beq		$t3, $t5, exit_found

	add		$v1, $v1, 1			# adds 1 to start searching next row for match O(log(n))
	
	bge		$v1, $t2, loop2
	bge		$v0, $t2, loop1

exit_found:

	# This part will place list[v0] into matrix[0]

	add		$t4, $0, 0

first_loop:

	lw		$t5, 4($a0)			# loading address of matrix->data
	lw		$t6, 4($a1)			# loading address of list->data

	lw 		$t5, 0($t5)			# loading address of matrix->data[0][]
	add 		$t5, $t5, $t4			# obtaining address of matrix->data[0][j]

	mul		$t8, $v0, 4			# $t8 stores i * 4

	add 		$t6, $t6, $t8			# obtaining address of list->data[i][]
	lw 		$t6, 0($t6)			# loading address of list->data[i][]
	add 		$t6, $t6, $t4			# obtaining address of list->data[i][j]
	lb		$t6, 0($t6)			# loading address of list->data[i][j]
	
	sb		$t6, 0($t5)			# sets matrix->data[0][j] = list->data[v0][j] (I think)

	add		$t4, $t4, 1			# j++

	bne 	$t4, $t0, first_loop	# j < matrix->size

	# This part will place list[v1] into matrix[i][0]

	add		$t4, $0, 0

second_loop:

	lw		$t5, 4($a0)			# loading address of matrix->data
	lw		$t6, 4($a1)			# loading address of list->data

	add 		$t8, $t4, 4			# $t8 stores j * 4

	add 		$t5, $t5, $t8			# obtaining address of matrix->data[j][]
	lw 		$t5, 0($t5)			# loading address of matrix->data[j][]
			#add 	$t5, $t5, $t4		# obtaining address of matrix->data[j][0]

	mul		$t8, $v1, 4			# $t8 stores i * 4

	add 		$t6, $t6, $t8			# obtaining address of list->data[i][]
	lw 		$t6, 0($t6)			# loading address of list->data[i][]
	add 		$t6, $t6, $t4			# obtaining address of list->data[i][j]
	lb		$t6, 0($t6)			# loading address of list->data[i][j]
	
	sb		$t6, 0($t5)			# sets matrix->data[j][0] = list->data[v1][j] (I think)

	add		$t4, $t4, 1			# j++

	bne 		$t4, $t0, second_loop	# j < matrix->size

	jr		$ra					# exit with first row/column set up


###
###	This function finds the next row of the matrix by searching for the first letter in each list
### int next_row(HexMatrix * matrix, HexList* list);
###
.globl next_rows
next_rows:
	
	lw			$t1, 0($a0)			# matrix->size
	lw 			$t2, 0($a1)			# list->size
	add			$t0, $0, 0			# stores 0 into $t1 represents row
	add			$t8, $0, 0			# stores 0 into $t1 for iteration

loopa:

	lw      	$t3, 4($a0)    			# $t3 = matrix->data
  	mul	     	$t4, $t0, 4     		# $t4 = 4 * row
  	add    		$t3, $t3, $t4   		# $t3 = &matrix->data[row]
 	lw      	$t3, 0($t3)     		# $t3 = matrix->data[row], I belive this is [0] as well

	add			$t8, $0, 0				# stores 0 into $t1 for iteration

loopb:
	
	lw      	$t5, 4($a1)    		 	# $t5 = list->data
    mul	    	$t6, $t8, 4     		# $t6 = 4 * row
    add 	    $t5, $t5, $t6   		# $t5 = &list->data[row]
    lw      	$t5, 0($t5)     		# $t5 = list->data[row], I belive this is [0] as well

	beq			$t3, $t5, exit_loop

	add			$t8, $t8, 1
	
	bne			$t8, $t2, loopb

exit_loop:

# This part will place list[row] into matrix[$t0*4]

	add		$t4, $0, 0				# j = 0
	

loop_2:

	add		$t6, $t3, $t4			# obtaining address of matrix->data[row][j]

	add 	$t7, $t5, $t4			# obtaining address of list->data[i][j]
	lb		$t7, 0($t7)				# loading address of list->data[i][j]
	
	sb		$t7, 0($t6)				# sets matrix->data[depth][j] = list->data[i][j] (I think)

	add		$t4, $t4, 1				# j++

	bge 	$t4, $t1, loop_2		# j < matrix->size


# return to loop1 if it has not reached the full size of the matrix

	add		$t0, $t0, 1				# i++

	bne		$t0, $t2, loopa			# loop if($t0 < matrix->size)

	jr		$ra						# return home
