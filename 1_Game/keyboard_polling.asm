# Game in MIPS Assembly
# Author: Gines Moratalla || https://github.com/ginesmoratalla

		.data
	# Circular queue that loops around with the data from the buffer
	kb_buf:		.space 25		# Buffer
	kb_buf_size:	.word  0		# Current size of the buffer
	kb_buf_max_size:.word  25		# Max size to wrap around

	x:		.word   3		# x starting position (Player)
	y:		.word	7		# y starting position (Player)
	SpaceBar:	.byte ' '		# Space to print in the previous position

	.text
	.globl poll, main, RewardAndPlayer

##################################################################################
##										  ##
##   GAME INSTRUCTIONS:								  ##
##										  ##
##    	- 1 Player, moves using w,a,s,d keys (only lowercase)			  ##
##    	- Player identified by the symbol 'P'					  ##
##    	- Player collects rewards, identified by 'X'				  ##
##    	- Each reward is worth 5 points (Score above the board)		  ##
##    	- If Player collides with a wall or reaches 100 points, the game is over##
##										  ##
##   BOARD:									  ##
##									          ##
##	- Board size 15x9 enviroment = 135 characters			 	  ##
##	- Playable board 13x7 = 91 jumpable spaces in the board	          ##
##	- Walls in x = 0, x = 14, y = 1, y = 9					  ##
##										  ##
##   SET UP THE DISPLAY:							  ##
##										  ##
##      - To start playing you'll need						  ##			         
##	- Settings > Assemble all files in directory (ON)			  ##
##	- IN THIS FILE (keyboard_polling.asm):		  			  ##
##										  ##
##	    1. Assemble the current file (Wrench icon) 			  ##
##	    2. Open Tools > Keyboard and Display MMIO Simulator		  ##
##	    3. Inside here, press Connect to MIPS				  ##
##	    4. Run current program (Green play button)				  ##
##										  ##
##	- Important to assemble the files and then connect the tool to MIPS     ##
##	- Type inside the keyboard tool in the display				  ##			  
##	- Move the player with the keys above					  ##
##										  ##
##################################################################################

	
##########################################################################################################
##########################################################################################################

# ENTRY POINT (GAME STARTS RUNNING HERE)
	
main:	
	li	$t0, 0xffff0000			# Kb control register
	li	$t1, 0				#
	sw	$t1, ($t0)			# Clear interrupt-enable bit
	
	# Initialize board, player and reward
	j	StartBoardPrint			# Jump to board.asm file
	
RewardAndPlayer:

	# We set the coords for the player to be x and y (x = 3, y = 7; the player always begins here)
	# These will be changing as long as they stay inside the bounds of the board
	lw	$a0, x				# Load initial position of player 			
	lw	$a1, y				# And pass it to PlayerPrint function
	jal	PlayerPrint			# In player.asm
	
	# Save the player's current row to avoid the reward spawning in the same spot as the player
	lw	$s1, y				# Load current player's row
	addi	$sp, $sp, -4			# Reserve space in the stack decrementing the pointer
	sw	$s1, 0($sp)			# Store the value in register $s1
	
	jal	RewardPrint			# Print first reward (reward.asm)
	
loop:
	
	jal	poll				# Check if anything is waiting 
	j 	loop				# Continue waiting
	
	
##########################################################################################################
##########################################################################################################


	# poll for keyboard input
poll:
	###################################
	# Lines bellow from (Stovold, 2023)
	
	li	$t0, 0xffff0000			# Keyboard control register
	lw	$t1, ($t0)			# Read keyboard control register
	andi	$t1, $t1, 1			# Check data bit
	beq	$t1, $zero, exit		# If not ready, exit
	
	# pull data from keyboard and store in buffer
	lw	$a0, 4($t0)			# Load current character from kb data
	la	$a1, kb_buf			# Load address of buffer

	
Queue:
	
	lw	$t3, kb_buf_size		# Current size of buffer
	add	$a1, $a1, $t3			# Move buffer pointer to next free spot (buff adress in $a1
	sb	$a0, 0($a1)			# Store byte (sb in $a0) character into buffer
	
	addi	$t3, $t3, 1			# Increment buffer size
    	sw	$t3, kb_buf_size		# Push new size back to memory
    	
	# Lines above from (Stovold, 2023)
	###################################
	
	
    	lw   	$t2, kb_buf_max_size    	# Load the maximum size of the buffer
    	bne  	$t2, $t3, NewElement	    	# If the current size != max size, keep going (process key)
    	
    	li	$t3, 0				# Set buffer size to 0 again to wrap around
    	sw	$t3, kb_buf_size		# Store size in kb_buf_size
    	j	NewElement			# Check which element was pressed down bellow
    	

NewElement:
	
	# Function to check which key it was pressed (stored in line 108)
	
	beq	$a0, 'w', move_up		# Check keys to move (Move up)
	
	beq	$a0, 's', move_down		# Check keys to move (Move down)
	
	beq	$a0, 'a', move_left		# Check keys to move (Move left)
	
	beq	$a0, 'd', move_right		# Check keys to move (Move right)
	
	# if we reach here, we ignore the key press (none of those keys were pressed)
	j	exit	
	

##########################################################################################################
##########################################################################################################
move_up:
	# Moves the player's coordinates 1 step up (x, y - 1)
##########################################################################################################
	
	# Set cursor to current position
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw 	$t1, x				# Load current player's coorinates
	lw 	$t2, y
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadSpacebar_up:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadSpacebar_up		# If ready bit is not set, loop back
	
	# Print space bar in the current position
	lb	$t0, SpaceBar			# Load SpaceBar character	
	sw	$t0, 0xffff000c 		# Store value in Data Transmitter location

	# Update new position
	lw	$t2, y				# Get current y value
	addi	$t2, $t2, -1			# Increment
	sw	$t2, y				# Push back
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw	$t1, x				# Load current player's coorinates
	lw	$t2, y
	
	# Check for out of bounds
	li 	$t3, 1				# 1 is the row for the Top Column of the board
	beq 	$t2, $t3, CheckForGameOver   	# Jump to GameOver if y == 1
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	# Pass coords to PlayerFunction	
	lw	$a0, x				# Store the new coordinates in $a registers
	lw	$a1, y				# To pass them to PlayerPrint in order to print the new player
	
	jal	PlayerPrint			# In player.asm
	j	exit
	
##########################################################################################################
##########################################################################################################	
move_down:
	# Moves the player's coordinates 1 step up (x, y + 1)
##########################################################################################################
	
	# Set cursor to current position
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw 	$t1, x				# Load current player's coorinates
	lw 	$t2, y
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadSpacebar_down:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadSpacebar_down		# If ready bit is not set, loop back
	
	# Print space bar in the current position
	lb	$t0, SpaceBar			# Load SpaceBar character	
	sw	$t0, 0xffff000c 		# Store value in Data Transmitter location

	# Update new position
	lw	$t2, y				# Get current y value
	addi	$t2, $t2, 1			# Increment
	sw	$t2, y				# Push back
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw	$t1, x				# Load current player's coorinates
	lw	$t2, y
	
	# check for out of bounds
	li 	$t3, 9				# 9 is the row for the Bottom Column of the board
	beq 	$t2, $t3, CheckForGameOver   	# Jump to GameOver if y == 9
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	# pass coords to PlayerFunction	
	lw	$a0, x				# Store the new coordinates in $a registers
	lw	$a1, y				# To pass them to PlayerPrint in order to print the new player
	
	jal	PlayerPrint			# In player.asm
	j	exit
	
##########################################################################################################
##########################################################################################################	
move_left:
	# Moves the player's coordinates 1 step up (x - 1, y)
##########################################################################################################
	
	# Set cursor to current position
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw 	$t1, x				# Load current player's coorinates
	lw 	$t2, y
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadSpacebar_left:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadSpacebar_left		# If ready bit is not set, loop back
	
	# Print space bar in the current position
	lb	$t0, SpaceBar			# Load SpaceBar character	
	sw	$t0, 0xffff000c 		# Store value in Data Transmitter location

	# Update new position
	lw	$t1, x				# Get current y value
	addi	$t1, $t1, -1			# Increment
	sw	$t1, x				# Push back
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw	$t1, x				# Load current player's coorinates
	lw	$t2, y
	
	# check for out of bounds
	li 	$t3, 0				# 0 is the Left Column of the board
	beq 	$t1, $t3, CheckForGameOver   	# Jump to GameOver if x == 0
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	# pass coords to PlayerFunction	
	lw	$a0, x				# Store the new coordinates in $a registers
	lw	$a1, y				# To pass them to PlayerPrint in order to print the new player
	
	jal	PlayerPrint			# In player.asm
	j	exit
	
##########################################################################################################
##########################################################################################################	
move_right:
	# Moves the player's coordinates 1 step up (x + 1, y)
##########################################################################################################
	
	# Set cursor to current position
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw 	$t1, x				# Load current player's coorinates
	lw 	$t2, y
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadSpacebar_right:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadSpacebar_right		# If ready bit is not set, loop back
	
	# Print space bar in the current position
	lb	$t0, SpaceBar			# Load SpaceBar character	
	sw	$t0, 0xffff000c 		# Store value in Data Transmitter location

	# Update new position
	lw	$t1, x				# Get current y value
	addi	$t1, $t1, 1			# Increment
	sw	$t1, x				# Push back
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	lw	$t1, x				# Load current player's coorinates
	lw	$t2, y
	
	# check for out of bounds
	li 	$t3, 14				# 14 is the Right Column of the board
	beq 	$t1, $t3, CheckForGameOver   	# Jump to GameOver if x == 14
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	# pass coords to PlayerFunction	
	lw	$a0, x				# Store the new coordinates in $a registers
	lw	$a1, y				# To pass them to PlayerPrint in order to print the new player
	
	jal	PlayerPrint			# In player.asm
	j	exit
	
##########################################################################################################
##########################################################################################################
exit:

	# The player is currently here
	lw	$t0, x				# Load the current coordinates again
	lw	$t1, y
	
	# $a2 and $a3 registers will always be reserved for the 'x' and 'y' coordinates, respectively
	# Compare the current player's location with the reward's location
	bne	$t1, $a3, hasNotReached			
	bne	$t0, $a2, hasNotReached
	
	# If both are false, the player has reached the spot where the current reward is
	
	# Save current player's row (used in reward.asm file) in the stack
	lw	$s1, y
	addi	$sp, $sp, -4			# Reserve space in the stack decrementing the pointer
	sw	$s1, 0($sp)			# Store the value in register $s1
	
	# Jump to increment the score and print a new randomly placed reward
	jal	IncrementScore
	jal	RewardPrint
    	
hasNotReached:

	j	loop				# Repeat the process for more inputs
	
##########################################################################################################
	
