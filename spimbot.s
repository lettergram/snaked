###
###
###     Created 4/22/2013
###     Current 4/22/2013
###     Spimbot contest team name: 
###
###


# spimbot constants
ANGLE = 0xffff0014
ANGLE_CONTROL = 0xffff0018
TIMER = 0xffff001c
HEAD_X = 0xffff0020
HEAD_Y = 0xffff0024
BONK_ACKNOWLEDGE = 0xffff0060
TIMER_ACKNOWLEDGE = 0xffff006c
PUBLIC_APPLE_X = 0xffff0070
PUBLIC_APPLE_Y = 0xffff0074
PRIVATE_APPLE_X = 0xffff00b0
PRIVATE_APPLE_Y = 0xffff00b4

.kdata                # interrupt handler data (separated just for readability)
chunkIH:.space 52      # space for the registers
non_intrpt_str:   .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"


.ktext 0x80000180
interrupt_handler:
.set noat
      move      $k1, $at               # Save $at                               
.set at
      la      $k0, chunkIH                
      sw      $a0, 0($k0)              # Get some free registers                  
      sw      $a1, 4($k0)              # by storing them to a global variable    
      sw      $v0, 8($k0)  	#store $v0
      sw      $t0, 12($k0)		#store $t0
      sw	$t4, 16($k0)
      sw	$t5, 20($k0)
      sw	$t6, 24($k0)
      sw	$t7, 28($k0)
      sw	$a2, 32($k0)
      sw	$a3, 36($k0)
      sw	$t1, 40($k0)
      sw	$t2, 44($k0)
      sw	$t3, 48($k0)	 

      mfc0    $k0, $13                 # Get Cause register                       
      srl     $a0, $k0, 2                
      and     $a0, $a0, 0xf            # ExcCode field                            
      bne     $a0, 0, non_intrpt         

interrupt_dispatch:                    # Interrupt:                             
      mfc0    $k0, $13                 # Get Cause register, again                 
      beq     $k0, $zero, done         # handled all outstanding interrupts     
  
      and     $a0, $k0, 0x1000         # is there a bonk interrupt?                
      bne     $a0, 0, bonk_interrupt   

      and     $a0, $k0, 0x8000         # is there a timer interrupt?
      bne     $a0, 0, timer_interrupt
      
      and     $a0, $k0, 0x4000		#is there a new apple interrupt?
      bne     $a0, 0, new_public_apple_interrupt
      
      and	$a0, $k0, 0x2000	#is there a new private apple created?
      bne	$a0, $0, new_private_apple_interrupt
    


      
      #puzzle interrupt
      #private apple created
      #get other snake's angle interrupt

                         # add dispatch for other interrupt types here.

      li      $v0, 4                   # Unhandled interrupt types

      la      $a0, unhandled_str
      syscall 
      j       done






	#bonk interrupt which makes the snake stop until
	#the obstacle no longer is in the way
	#TO BE MODIFIED ONCE COLLISION IS IMPLEMENTED
bonk_interrupt:
      sw $zero, 0xffff0010($zero) # Forces snake to stop
      sw $a1, 0xffff0060($zero) # acknowledge interrupt

	j interrupt_dispatch









	#interrupt that will be called	
	#when the public apple was eaten
	#or a new public apple has appeared
	#same thing really
new_public_apple_interrupt:
      sw      $a1, 0xffff0064($zero)   # acknowledge interrupt
      #need to save the used registers on the stack
      
      
	lw $t0, HEAD_X

	lw $t1, HEAD_Y
	lw $a2, PUBLIC_APPLE_X
	lw $a3, PUBLIC_APPLE_Y
	
	
	beq $t0, $a2, first_if_public_apple # my_x != apple_x
	bge $t0, $a2, second_if_public_apple # my_x < apple_x
	add $t2, $0, 0
	j public_apple_end # returns 0
	
second_if_public_apple: # second if not true
	add $t2, $0, 180 # inputs 180 for desired angle
	j public_apple_end # returns 180
	
first_if_public_apple:
	bge $t1, $a3, third_if_public_apple # my_y < apple_y
	add $t2, $0, 90 # inputs 90 for v0
	j public_apple_end # returns 90
	
third_if_public_apple:
	add $t2, $0, 270 # inputs 270 into v0
	j public_apple_end # returns 270
	
public_apple_end:
	
	lw $t0, prev_angle
	sub $t0, $t0, $t2
	li $a2, 180
	
	bge $t0, $0, public_apple_less_than_zero
	sub $t0, $0, $t0
	
public_apple_less_than_zero:
	
	bne $t0, $a2, public_apple_not_equal_180
	
	add $t2, $t2, 90
	
	li $t0, 0
	li $a2, 5000
	
public_apple_for_loop:
	add $t0, $t0, 1
	bne $t0, $a2, public_apple_for_loop
	
public_apple_not_equal_180:
	
	bge $t2, $0, public_apple_set_abs_angle # sets abs angle
	add $t2, $0, $t2
	
public_apple_set_abs_angle:
	
        sw $t2, 0xffff0014($zero) # Sets angle to proper angle
	li $t0, 1
        sw $t0, 0xffff0018($zero) # relative to zero
	sw $t2, prev_angle
	
      j interrupt_dispatch # see if other interrupts are waiting      


	
	
	
	
	#interrupt that occurs when
	#a new private apple is available
	#UNDER CONSTRUCTION
	#SEE HOW MATRIX PERFORMS
new_private_apple_interrupt:
      sw      $a1, 0xffff0064($zero)   # acknowledge interrupt
      #need to save the used registers on the stack
      
      
	lw $t0, HEAD_X

	lw $t1, HEAD_Y
	lw $a2, PRIVATE_APPLE_X
	lw $a3, PRIVATE_APPLE_Y
	
	
	beq $t0, $a2, first_if_private_apple # my_x != apple_x
	bge $t0, $a2, second_if_private_apple # my_x < apple_x
	add $t2, $0, 0
	j private_apple_end # returns 0
	
second_if_private_apple: # second if not true
	add $t2, $0, 180 # inputs 180 for desired angle
	j private_apple_end # returns 180
	
first_if_private_apple:
	bge $t1, $a3, third_if_private_apple # my_y < apple_y
	add $t2, $0, 90 # inputs 90 for v0
	j private_apple_end # returns 90
	
third_if_private_apple:
	add $t2, $0, 270 # inputs 270 into v0
	j private_apple_end # returns 270
	
private_apple_end:
	
	lw $t0, prev_angle
	sub $t0, $t0, $t2
	li $a2, 180
	
	bge $t0, $0, private_apple_less_than_zero
	sub $t0, $0, $t0
	
private_apple_less_than_zero:
	
	bne $t0, $a2, private_apple_not_equal_180
	
	add $t2, $t2, 90
	
	li $t0, 0
	li $a2, 5000
	
private_apple_for_loop:
	add $t0, $t0, 1
	bne $t0, $a2, private_apple_for_loop
	
private_apple_not_equal_180:
	
	bge $t2, $0, private_apple_set_abs_angle # sets abs angle
	add $t2, $0, $t2
	
private_apple_set_abs_angle:
	
        sw $t2, 0xffff0014($zero) # Sets angle to proper angle
	li $t0, 1
        sw $t0, 0xffff0018($zero) # relative to zero
	sw $t2, prev_angle
	
      j interrupt_dispatch # see if other interrupts are waiting          
      
	
	
	
	
		
      
	#UNDER CONSTRUCTION      
timer_interrupt:
      sw $a1, 0xffff006c($zero) # acknowledge interrupt
 
	lw $t0, HEAD_X
	lw $t1, HEAD_Y
	lw $a2, PUBLIC_APPLE_X
	lw $a3, PUBLIC_APPLE_Y


	beq $t0, $a2, first_if # my_x != apple_x
	bge $t0, $a2, second_if # my_x < apple_x
	add $t2, $0, 0
	j end # returns 0

second_if: # second if not true
	add $t2, $0, 180 # inputs 180 for desired angle
	j end # returns 180

first_if:
	bge $t1, $a3, third_if # my_y < apple_y
	add $t2, $0, 90 # inputs 90 for v0
	j end # returns 90

third_if:
	add $t2, $0, 270 # inputs 270 into v0
	j end # returns 270

end:

	lw $t0, prev_angle
	sub $t0, $t0, $t2
	li $a2, 180

	bge $t0, $0, less_than_zero
	sub $t0, $0, $t0

less_than_zero:

	bne $t0, $a2, not_equal_180

	add $t2, $t2, 90

	li $t0, 0
	li $a2, 5000

for_loop:
	add $t0, $t0, 1
	bne $t0, $a2, for_loop

not_equal_180:

	bge $t2, $0, set_abs_angle # sets abs angle
	add $t2, $0, $t2

set_abs_angle:

        sw $t2, 0xffff0014($zero) # Sets angle to proper angle
	li $t0, 1
        sw $t0, 0xffff0018($zero) # relative to zero
	sw $t2, prev_angle

      lw $v0, 0xffff001c($0) # current time
      add $v0, $v0, 500
      sw $v0, 0xffff001c($0) # request timer in 500

      j interrupt_dispatch # see if other interrupts are waiting
      
done:
      la      $k0, chunkIH                
      lw      $a0, 0($k0)              # Get some free registers                  
      lw      $a1, 4($k0)              # by storing them to a global variable    
      lw      $v0, 8($k0)		#store $v0
      lw      $t0, 12($k0)		#store $t0
      lw	$t4, 16($k0)
      lw	$t5, 20($k0)
      lw	$t6, 24($k0)
      lw	$t7, 28($k0)
      lw	$a2, 32($k0)
      lw	$a3, 36($k0)
      lw	$t1, 40($k0)
      lw	$t2, 44($k0)
      lw	$t3, 48($k0)	       	 
.set noat
      move    $at, $k1                 # Restore $at
.set at 
      eret
