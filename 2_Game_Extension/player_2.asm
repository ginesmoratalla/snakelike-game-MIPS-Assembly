# Extension for Exercise 1 MIPS Assembly game (2 Player option)
# Author: Gines Moratalla || https://github.com/ginesmoratalla



##########################################################################################################
##########################################################################################################
# NEW CODE (the entire file) FOR THE EXENTION: Print Second Player's new position in the display
##########################################################################################################
##########################################################################################################

	.data
	Player:		.byte '2'		# Symbol for the player
	
	.globl PlayerPrint_2			# PlayerPrint as global to be accessible from other files
	.text	
	
##########################################################################################################
##########################################################################################################

	# This file is in charge of printing the player in the
	# coordinates sent from the keyboard_polling.asm file (main file)
		
PlayerPrint_2:
	
	# Set the cursor's coordinates
	li 	$t0, 7 				# Load ASCII value 7 into $t0
	
	# Move current player's coordinates to $t registers
	move 	$t1, $a0			# Previously stored in $a0 and $a1 in keyboard_polling.asm file
	move 	$t2, $a1			# before making a jump
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadPlayer:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadPlayer			# If ready bit is not set, loop back
	
	lb	$t0, Player			# Store the symbol as byte in $t0 register
	sw	$t0, 0xffff000c 		# Store the symbol in the Data Transmitter location (Display)

	jr	$ra


##########################################################################################################
##########################################################################################################
# NEW CODE (the entire file) FOR THE EXENTION: Print Second Player's new position in the display
##########################################################################################################
##########################################################################################################
