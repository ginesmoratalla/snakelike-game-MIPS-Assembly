# Game in MIPS Assembly
# Author: Gines Moratalla || https://github.com/ginesmoratalla
	
	.data
	GameO:	.asciiz "GAME OVER"		# Strings to print
	Score:	.asciiz "Score:"		# in the display
	
	
	.globl	CheckForGameOver
	.text

##########################################################################################################
##########################################################################################################
	
	# File in charge of clearing the board,
	# printing the strings above and
	# retrieving the score from score.asm to print it as final score
	
CheckForGameOver:

	# Clear the board
	li 	$t0, 12 			# Load ASCII 12 into $t0 (clear board)
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
		
##########################################################################################################
##########################################################################################################

PrintScoreText:

	# Function that prints "Score: " into the Display
	la	$a1, Score			# Load the adress of the string Score
	
IteratorScore:
	
	# Iterate through the string printing each character into the display
	lb	$a0, 0($a1)			# Load the current character from the String
	beqz	$a0, IncScore			# If the string is traversed, go to IncScore
	
	jal	loadScoreDisplay		# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string 
	j	IteratorScore			# Loop back to print the next character
	
loadScoreDisplay:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadScoreDisplay		# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 42)

IncScore:

	jal	FinalScore			# Print the current final score. Function found in score.asm	

##########################################################################################################
##########################################################################################################
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 0				# Set cursor coordinates to
	li	$t2, 2				# the middle of the screen
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
##########################################################################################################
##########################################################################################################

PrintGameOv:

	# Function that prints "GAME OVER" into the Display
	la	$a1, GameO			# Load the adress of the string GameO
		
first_loop:

	lb	$a0, 0($a1)			# Load the current character from the String GameO ($a1 above)
	beqz	$a0, end			# If the string is traversed, go to the end
	
	jal	loadGameOv			# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string 
	j	first_loop			# Loop back to print the next character

loadGameOv:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadGameOv			# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 89)
	
##########################################################################################################
##########################################################################################################

end:
	# End program
	li	$v0, 10
	syscall

##########################################################################################################
##########################################################################################################
