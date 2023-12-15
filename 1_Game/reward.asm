# Game in MIPS Assembly
# Author: Gines Moratalla || https://github.com/ginesmoratalla


	.data
	Reward:		.byte 	'X'		 # Symbol for the reward
	
	reward_x:	.word   0		 # x starting position (Player)
	reward_y:	.word	0		 # y starting position (Player)
	
	upperBound_x:	.word	14		 # Upper bound for x not included [0,14) 
	upperBound_y:	.word	9		 # Upper bound for y not included [0,9) 
	
	# "Variable" that stores the current row where the player is
	# Used to avoid the reward to spawn in the same place
	currentPlayer_y:.word	0		 # Current player is in this row
	
	.globl RewardPrint
	.text
	
##########################################################################################################
##########################################################################################################
	
RewardPrint:
	
	lw	$s1, 0($sp)			 # Load the current player's row (saved in the stack) into 
	addi	$sp, $sp, 4			 # Restore the stack
	sw	$s1, currentPlayer_y		 # Load this value into our variable
	
##########################################################################################################

RewardGenerate:

	# Instructions for syscall 42 found in:
	# https://courses.missouristate.edu/KenVollmar/mars/Help/SyscallHelp.html
	
	lw	$t0, currentPlayer_y		# Load column of player again in the new function	
	# Generate a random location (x, inside the board)  
	lw 	$a1, upperBound_x		 # Set the upper bound for the syscall (Stated in the instructions)
	li 	$v0, 42				 # Use 42 as value to randomize integer number [0,14)
	syscall
	
	beqz	$a0, RewardGenerate		 # Set 0 as lower bound of x by beqz (if true, repeat process)			
	sw	$a0, reward_x			 # Update the now correct x coordinate for the reward
	
	# Generate a random location (y, inside the board)
	lw 	$a1, upperBound_y		 # Set the upper bound for the syscall (Stated in the instructions)
	li 	$v0, 42				 # Use 42 as value to randomize integer number [0,9)
	syscall
	
	ble	$a0, 1, RewardGenerate		 # Set 0 and 1 as lower bound of y by beqz (if true, repeat process)	
	sw	$a0, reward_y			 # Update the now correct y coordinate for the reward

	beq	$a0, $t0, RewardGenerate	 # If the row of the new reward == current players row, repeat process
	
##########################################################################################################
	
	# Place the reward in the random location that was just set above
	
	# Set coordinates using the cursor
	li 	$t0, 7 				 # Load ASCII value 7 into $t0 (cursor)
	
	lw	$t1, reward_x			 # Load current reward x coordinate in register $t2
	lw	$t2, reward_y			 # Load current reward y coordinate in register $t1
		
	sll 	$t1, $t1, 20 			 # Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			 # Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			 # Combine x and y positions
	or 	$t0, $t0, $t1 			 # Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			 # Store value in Data Transmitter location (Display)

##########################################################################################################
	
	# Print the reward in the location set by the cursor above
	
loadReward:

	lw	$t1, 0xffff0008			 # Load ready bit adress
	andi	$t2, $t1, 1			 # Get ready bit value
	beqz	$t2, loadReward			 # If ready bit is not set, loop back
	
	lb	$t0, Reward			 # Store the symbol as byte in $t0 register
	sw	$t0, 0xffff000c 		 # Store the symbol in the Data Transmitter location (Display)

StoreRewardCoords:
	
	lw	$a2, reward_x			 # Save the coordinates for the new reward
	lw	$a3, reward_y			 # in $a2 and $a3 (these registers will be exclusive for the reward)
	
	jr	$ra				 # Jump to register adress in keyboard_polling.asm

##########################################################################################################
##########################################################################################################
