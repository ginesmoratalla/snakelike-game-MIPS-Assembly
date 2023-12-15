# Game in MIPS Assembly
# Author: Gines Moratalla || https://github.com/ginesmoratalla

	
	.data
	# Strings for the board display
	Score:		.asciiz "Score: "		
	FullCol:	.asciiz "###############"
	MidCol:		.asciiz "#             #"
	RowCounter:	.word 0
	
	.globl 	StartBoardPrint
	.text

##########################################################################################################
##########################################################################################################

	# This file contains the elements to print the board.
	# Only accessed once
	
StartBoardPrint:

	# Set starting point of cursor's coordinates to (0, 0)
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 0				# Set coordinates x = 0
	li	$t2, 0				# y = 0
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
##########################################################################################################
##########################################################################################################

PrintScoreText:

	# Function that prints "Score: " into the Display
	la	$a1, Score			# Load the adress of the string GameO
	
IteratorScore:

	lb	$a0, 0($a1)			# Load the current character from the String ($a1 above)
	beqz	$a0, jumpLine2			# If the string is traversed, jump to the next row
	
	jal	loadScoreDisplay		# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string 
	j	IteratorScore			# Loop back to print the next character
	
loadScoreDisplay:
	
	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadScoreDisplay		# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 52)
	
##########################################################################################################
##########################################################################################################

jumpLine2:
	
	# Set the cursor to the next row
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 0				# Load coordinates
	li	$t2, 1				# for the next row in the board
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
##########################################################################################################
##########################################################################################################

PrintTopCol:

	# function that prints "Top Column" into the Display
	la	$a1, FullCol			# Load the adress of the string FullCol
	
IteratorTopCol:
	lb	$a0, 0($a1)			# Load the current character from the String ($a1 above)
	beqz	$a0, Jumpline3			# If the string is traversed, jump to the next row
	
	jal	loadTopColDisplay		# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string
	j	IteratorTopCol			# Loop back to print the next character
	
loadTopColDisplay:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t1, $t1, 1			# Get ready bit value
	beqz	$t1, loadTopColDisplay		# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 97)
	
##########################################################################################################
##########################################################################################################

Jumpline3:

	# Set the cursor to the next row
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 0				# Load coordinates
	li	$t2, 2				# for the next row in the board
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
##########################################################################################################
##########################################################################################################

PrintMiddleCol:

	# function that prints "Middle Cols" into the Display
	la	$a1, MidCol			# Load the adress of the string MidCol
	
IteratorMiddleCol:

	lb	$a0, 0($a1)			# Load the current character from the String ($a1 above)
	beqz	$a0, Jumpline4			# If the string is traversed, jump to the next line
	
	jal	loadMiddleColDisplay		# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string 
	j	IteratorMiddleCol		# Loop back to print the next character
	
loadMiddleColDisplay:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t1, $t1, 1			# Get ready bit value
	beqz	$t1, loadMiddleColDisplay	# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 143)

##########################################################################################################

Jumpline4:

	# Set the cursor to the next row
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 0				# Load coordinates
	li	$t2, 3				# for the next row in the board
	
	lw	$t3, RowCounter			# Load current row
	add	$t2, $t2, $t3			# add counter (3 + n)
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	
	# for loop that checks for 7 board columns
	lw	$t0, RowCounter			# Load current row
	addi 	$t0, $t0, 1			# Add 1 to the counter
	beq 	$t0, 7, PrintBottomCol		# If 7 rows have been printed, goto PrintBottomCol
	sw	$t0, RowCounter
	j	PrintMiddleCol			# If else, print another Middle Row

##########################################################################################################
##########################################################################################################

PrintBottomCol:

	# function that prints "Middle Cols" into the Display
	la	$a1, FullCol
	
IteratorBottomCol:

	lb	$a0, 0($a1)			# Load the current character from the String ($a1 above)
	beqz	$a0, exit			# If the string is traversed, go to exit
	
	jal	loadBottomColDisplay		# Jal to print the current character in the iteration
	
	addi	$a1, $a1, 1			# Increment the pointer to the next character of the string
	j	IteratorBottomCol		# Loop back to print the next character
	
loadBottomColDisplay:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadBottomColDisplay	# If ready bit is not set, loop back
	
	sw	$a0, 0xffff000c			# Print the current character in the iteration of the string
	jr	$ra				# Jump back to increment the pointer (Line 199)
	
##########################################################################################################
##########################################################################################################

exit:
	j	RewardAndPlayer
	
##########################################################################################################
##########################################################################################################

