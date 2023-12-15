# Game in MIPS Assembly
# Author: Gines Moratalla || https://github.com/ginesmoratalla


	.data
	
	# Counter "Variables"
	firstCounter:		.word 0		# counter for the general score (initialize to 0)
	secondCounter:		.word 0		# counter (initialized to 0)
	
	# "Variables" used to print the final score in the Game Over screen
	currentUnits:		.byte '0'	# 00(0)
	currentTens:		.word 0x30	# 0(0)0 ASCII for '0'
	currentHundreds:	.word 0x30	# (0)00 ASCII for '0'
	
	# "Variables" to display for the Units Ditits (Either 0 or 5)
	zero:			.byte '0'	# Bytes 0 and 5
	five:			.byte '5'	# for the units in the score 00(0)
	
	.text
	.globl IncrementScore, FinalScore
	
##########################################################################################################
##########################################################################################################

IncrementScore:

	# This function will increment the score, using two counters
	# firstCounter checks for the general count of the points and if the Units 00(0) are even or odd (explained better bellow)
	# secondCounter checks every 2 upgrades in the score to increment the Tens 0(0)0

	lw	$t0, firstCounter		# Load the current score
	
	addi	$t0, $t0, 1			# Add 1 to the current store (1-20)
	beq	$t0, 20, AddHundreds		# If current score == 20 == 100 points, goto ReachedPoints bellow in this file
	
	sw	$t0, firstCounter		# Save score now incremented if we haven't reached the end
	
	# Every 1 reward collected, the score increments by 5
	# This part of the code decodes whether to display either 5 or 0 
	
	# If firstCounter is an even number, it means that the score has 0 in its Units
	# If firstCounter is odd, the score has 5 in its Units
	# {(0;0 Points), (1;5 Points), (2;10 Points)...(20;100 Points)}
	
	li	$t1, 2				# Loads 2 to check for the remainder 
						# firstCounter previously sotred in $t0 above
						
	##################################
	# Lines bellow from (Langer, 2016)
	div	$t0, $t1			# Check if division is even (firstCounter/2)
	mfhi	$t2				# mfhi moves the remainder of the division to $t0
	# Lines above from (Langer, 2016)
	##################################


	beqz 	$t2, PrintZero			# If remainder 0 (even number), goes to printZero
	j	PrintFive			# If else (odd number), goto printFive

##########################################################################################################
##########################################################################################################
PrintZero:	

	# Function that prints/displays 0 in the Units 00(0)
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li 	$t1, 9				# load coords (9, 0) 00(0)
	li 	$t2, 0
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location

loadZero:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadZero			# If ready bit is not set, loop back
	
	lb	$t0, zero			# Load the character in 'zero' into the register
	sb	$t0, currentUnits		# Update the units Digit
	sw	$t0, 0xffff000c			# Print the character into the display
	
	j	TensCounter
	
##########################################################################################################
PrintFive:	

	# Function that prints/displays 5 in the Units 00(5)
	
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li 	$t1, 9				# load coords (9, 0) 00(0)
	li 	$t2, 0
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadFive:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadFive			# If ready bit is not set, loop back
	
	lb	$t0, five			# Load the character in 'five' into the register
	sb	$t0, currentUnits		# Update the units Digit
	sw	$t0, 0xffff000c			# Print the character into the display
	
	j	TensCounter
	
##########################################################################################################
##########################################################################################################

TensCounter:

	# After every 2 rewards collected, the Tens in the score increment 0(0)0
	# secondCounter counts up to 2, and whenever it reaches 2, the Tens are incremented
	
	lw	$t0, secondCounter		# load the current Tens Counter
	addi	$t0, $t0, 1			# add 1 to this counter
	sw	$t0, secondCounter		# Store the new value back in the Counter "Variable"
	beq	$t0, 2, AddTens			# If secondCounter has reached zero, goto AddTens
	
##########################################################################################################

	# Final exit
	
exit_exit:

	jr	$ra
	
##########################################################################################################

	# Function that increments the Tens 0(0)0 of the score (If secondCounter reaches 2, increment and set it to 0)
AddTens:

	li	$t0, 0			
	sw	$t0, secondCounter		# Reset secondCounter loading 0 into it
	
	# Set cursor's coordinates
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li	$t1, 8				# load coords (8, 0) 0(0)0
	li	$t2, 0
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
	# Cursor set to where the tens are located, we increment and print the new value

loadTensIncremented:

	lw	$t1, 0xffff0008			# Load ready bit adress
	andi	$t2, $t1, 1			# Get ready bit value
	beqz	$t2, loadTensIncremented	# If ready bit is not set, loop back
	
	lw	$t0, currentTens		# Load the previous value in the tens digit
	addi	$t0, $t0, 1			# Increment this by 1
	sw	$t0, currentTens		# Store it back into the variable
	sw	$t0, 0xffff000c			# Print it into the display, overriting the previous
	 
	j	exit_exit			# Jump to final exit (above)
	
##########################################################################################################
##########################################################################################################

FinalScore:	

	# Funtion(s) bellow to load and print the current score into the display
	# Only used when the game is over (collision or when you reach 100 points)
	# This means, game_over.asm file will acess this function 'FinalScore'

##########################################################################################################	
printUnits:	

	# Set cursor's coordinates
	li 	$t0, 7 				# Load ASCII 7 into $t0 (cursor)
	
	li 	$t1, 9				# load coords (9, 0) 00(0)
	li 	$t2, 0
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location
	
loadUnits:
	lw	$t1, 0xffff0008
	andi	$t2, $t1, 1
	beqz	$t2, loadUnits
	
	lb	$t0, currentUnits		# Load current Units Digit into $t0
	sw	$t0, 0xffff000c			# Print the value into the display
	
##########################################################################################################	
printTens:	

	# Set cursor's coordinates
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li 	$t1, 8				# Load coords (8, 0) 0(0)0
	li 	$t2, 0
		
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location

loadTens:
	lw	$t1, 0xffff0008
	andi	$t2, $t1, 1
	beqz	$t2, loadTens
	
	
	lw	$t0, currentTens		# Load current Tens Digit into $t0
	sw	$t0, 0xffff000c			# Print the value into the display
	
##########################################################################################################
printHundreds:	

	# Set cursor's coordinates
	li 	$t0, 7 				# Load ASCII value 7 into $t0 (cursor)
	
	li 	$t1, 7				# load coords (7, 0) for (0)00
	li 	$t2, 0
		
	sll 	$t1, $t1, 20 			# Shift position x left by 20 bits
	sll 	$t2, $t2, 8 			# Shift position y left by 8 bits
	
	or 	$t1, $t1, $t2 			# Combine x and y positions
	or 	$t0, $t0, $t1 			# Combine ASCII value with position
	
	sw 	$t0, 0xffff000c			# Store value in Data Transmitter location

loadHund:
	lw	$t1, 0xffff0008
	andi	$t2, $t1, 1
	beqz	$t2, loadHund
	
	lw	$t0, currentHundreds		# Load current Hundreds Digit into $t0
	sw	$t0, 0xffff000c			# Print the value into the display

	jr	$ra			# Goto final exit (above)
	
##########################################################################################################
##########################################################################################################

	# This function will only be used when the user reaches 100 points, it will set 100 as the score
	# and then it will jump to CheckForGameOver
	# It can only be accessed when firstCounter is 20 (100 points = 20 x 5)
		
AddHundreds:

	li	$t0, 0x31			# ASCII code for 1
	sw	$t0, currentHundreds		# Save 1 in the current digit
	
	
	li	$t0, 0x30			# ASCII code for 0
	sw	$t0, currentTens		# Save 0 in the current digit
	
	lb	$t0, zero			# Zero variable used throught this file
	sw	$t0, currentUnits		# Save 0 in the current digit
	
	j	CheckForGameOver		# Function in file game_over.asm
	
##########################################################################################################
##########################################################################################################
