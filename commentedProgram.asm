# CS 2640
# Tyler Carrasco, Tiffany Dinh, Kendan Phan, Angela Salcido
# Final Project
# mips assembly program that replicates the puzzle game "Wordle"

.include "wordleMacro.asm"

.data
menu: .asciiz "~~ MAIN MENU “~~\n(1) Start Game\n(2) Exit Program\n"

menuChoice: .asciiz "\nEnter (1) or (2) for your selection: "

exitMsg: .asciiz "\nExiting Program. Goodbye!"

word1: .asciiz "piano\n"
word2: .asciiz "apple\n"
word3: .asciiz "water\n" 

youLose: .asciiz "You have reached max attempts, you lose! The answer was "

correct: .asciiz "Congrats!!! You won, the answer was "
existsInWord: .asciiz " however does exist in the word"
doesNotExistInWord: .asciiz " and does not exist in the word"
newLine: .asciiz "\n"
correctPosition: .asciiz " is Correct at Position: "
incorrectPosition: .asciiz " is not Correct at Position "
promptUserInput: .asciiz "\nPlease input a 5-letter word: " 
guessBuffer: .space 16

fiveLetterTrue : .asciiz "\nInput is 5 letters"
fiveLetterFalse : .asciiz"\nInput is not 5 letters"

replayMenu: .asciiz "\n~~Would you like to play again?~~\n(1) Yes\n(2) No\n"

wordBank: .word word1, word2, word3

.text
main: 
    	#output Main Menu text
    	printString(menu)

    	#print menu options
    	printString(menuChoice)

    	#get user input here
    	li $v0, 5    # 5 = read int
    	syscall
    	move $s0, $v0      #move user input to $s0

	#if the user input is 1, jump to traverseArray
	beq $s0, 1, traverseArray

	#if the user input is 2, it jumps to the exit
	beq $s0, 2, exit
    	
    	j main
    	
#randomly picks a word in the array for user to guess
traverseArray:
    	li $v0, 42	# 42 = random int generator in range
    	li $a0, 0    	#load generator ID in $a0 (0 = default generator)
    	li $a1, 3    	#$a1 = upper bound (array size is 3)
    	syscall        	#$a0 holds random index [0,2]

    	#convert index to byte offset so that we can traverse array (2 bits^2 = 4)
    	#sll quickly converts an array index to a byte offset
    	sll $t1, $a0, 2     #index * 4 (4 bytes = word)

    	la $s1, wordBank

    	#move to correct element
    	add $s1, $s1, $t1     #adds offset ($t1) into base address of array ($s1)
    	lw $s2, 0($s1)        #load random word from wordBank to $s2

    	#print random word (USE THIS TO TEST)
    	#li $v0, 4
    	#move $a0, $s2
   	#syscall
   	
    	li $s6, 0	#$s6 is the counter for the amount of guesses the user has
    	li $s5, 5 	#$s5 is the max due to indexing (6 attempts, 0-5 index)
    	
restart:
	#prompt user for a guess
    	printString(promptUserInput)
    
    	#store user's input into guessBuffer
    	li $v0, 8	# 8 = read string
    	la $a0, guessBuffer
    	li $a1, 16	#max number of characters
    	syscall
    
    	la $t0, guessBuffer	#load address of guessBuffer into $t0
    	
    	#declaring register values for the loop below
    	li $t2, 10	#$t2 is declared as \n (10 = \n)
    	li $t4, 0	#$t4 declared as 0 (counter)
    	li $t5, 4	#$t5 declared as max index check (5-letter word, 0-4)

#loop checks for amount of characters in user input
loop: 
    	lb $t3, 0($t0)	#load byte/char from word inside guessBuffer into $t3
    	
    	beq $t3, $t2, restart	#if byte/char is equal to \n, then word is too small and restarts
    	beq $t4, $t5, checkIfLong	#if counter equals max index check (5 letters), jump to check if word is too long
    	
    	addi $t4, $t4, 1	#incrementing the counter for loop
    	addi $t0, $t0, 1	#move to next byte/char in word
    
    	j loop

promptUserToTryAgainIfWrong:  #come back here to work on
    	move $t7, $s2	#$t7 stores address correct word
    	la $t0, guessBuffer
    	li $t9, 0 	#counter for loop to check for perfect answer
    	li $t1, 5	#total letters (5)

#loop through each letter in user guess to compare
LoopToCheckForPerfectAnswer:
    	lb $t5, 0($t7)	#load byte/char of correct word into $t5
    	lb $t6, 0($t0)	#load byte/char of user guess into $t6
    	
    	beq $t9, $t1, correctGuess	#if counter equals 5, all characters have been checked so jump to correctGuess
    	bne $t5, $t6, incorrectGuess	#if byte/char in correct word is not equal to the byte/char in user guess, jump to incorrectGuess
    	
    	#increment counter, correct word, and user guess pointer
    	addi $t9, $t9, 1
    	addi $t0, $t0, 1
    	addi $t7, $t7, 1
    	
    	j LoopToCheckForPerfectAnswer
    
    	li $v0, 10   #for testing purposes only
    	syscall 
    
#protected position
printToUserTooLong:
	printString(fiveLetterFalse)
    	printString(newLine)
    	
    	j restart	#if it is too long, it jumps to restart and prompts again
    
checkIfLong: 
    	addi $t0, $t0, 1	#move to next byte/char in word
    	
    	lb $t3, 0($t0)	#load the byte/char into register $t3 if it is \n (Good size)
    	
    	bne $t3, $t2, printToUserTooLong	#if the next byte/char is not equal to \n, word is too long
    
    
	#-- From here on out, START the game / The word is valid (5 letters) --

     
	#reload registers to adjust for the incrementation of the address we previously did
     	li $t2, 1	#load immediate at position 1
     	la $t0, guessBuffer
     	li $t4, 6	#load ending condition (program only reads up to 5 letters)
     	
     	move $t3, $s2	#move correct word into a safe temp register to not lose our word data in future
     	
#loop to compare each letter in user's guess to correct word
loopForGame:
     	lb $t5, 0($t0)	#load byte/char from user guess into $t5 
     	lb $t6, 0($t3)	#load byte/char from correct randomized word into $t6
     	beq $t2, $t4, promptUserToTryAgainIfWrong	#if byte/char reaches more than 5-letters (6), check if user guess is wrong
     	bne $t5, $t6, wrongCharAtPosition	#if user guess and correct word byte/char are not equal,
     
     	li $v0, 11	# 11 = print character
     	move $a0, $t5	#print user character guess
     	syscall
     
   	printString(correctPosition)
  
  	#print position
   	li $v0, 1
  	move $a0, $t2
   	syscall
   	
    	printString(newLine)
  
  	#increment position, user guess, and correct word pointer
   	addi $t2, $t2, 1
   	addi $t0, $t0, 1
   	addi $t3, $t3, 1
   	
   	j loopForGame
   
wrongCharAtPosition:
	li $v0, 11	# 11 = print character
    	move $a0, $t5	#$t5 = user guess
    	syscall
     
	printString(incorrectPosition)
   
   	#print position
   	li $v0, 1
   	move $a0, $t2
   	syscall
   
	#temp variable to save address of user word again safely
   	move $t7, $s2
   
   	li $t8, 0	#counter
   	li $t9, 4	#max index (5-letters, 0-5)
   
#check if user guess letter exists in correct word at all
checkIfExistsLoop:
   	lb $t1, 0($t7) # CHECK IF t1 REGISTER IS OKAY TO USE HERE TYLER t7 has word address, t5 has letter byte currently
   	beq $t8, $t9, doesNotExist	#if we checked all 5-letters (counter equals max index), there is no match so letter does not exist
   	beq $t5, $t1, printExists	#if guessed wrong letter equals a letter in the correct word, letter exists
   	
   	#increment counter and user word pointer
   	addi $t8, $t8, 1
   	addi $t7, $t7, 1
   	
   	j checkIfExistsLoop

doesNotExist:
   	printString(doesNotExistInWord)
   	printString(newLine)	# input here
   	
   	addi $t2, $t2, 1
   	addi $t0, $t0, 1
   	addi $t3, $t3, 1
   	
   	j loopForGame
   
printExists:
	printString(existsInWord) 
   	printString(newLine)	# input here
   	
   	addi $t2, $t2, 1
   	addi $t0, $t0, 1
   	addi $t3, $t3, 1
   	
   	j loopForGame

correctGuess:
	#play sound when user guesses word correctly
	li $v0, 31
    	li $a0, 60 #pitch
    	li $a1, 500 #time in milliseconds
    	li $a2, 56  # instrument 
    	li $a3, 100 #volume 
    	syscall
    
    	li $v0, 31
    	li $a0, 64
    	syscall
    
    	li $v0, 31
    	li $a0, 67
    	syscall
    
    	li $v0, 31
    	li $a0, 72
    
	printString(correct)
	
	#print the correct randomized word
	li $v0, 4
    	move $a0, $s2
    	syscall
    	
    	#print replay menu
    	printString(replayMenu)
    	printString(menuChoice)
    	
    	#get user input
    	li $v0, 5
    	syscall
    	move $s3, $v0
    	
    	beq $s3, 1, traverseArray	#if user input is 1, restart game
    	beq $s3, 2, exit	#if user input is 2, exit game
    	
    
incorrectGuess:
	beq $s5, $s6, maxAttempts	#if counter reaches 6, go to maxAttempts
	
    	#play lose sound
    	li $v0, 31
    	li $a0, 45 #pitch
    	li $a1, 500 #time in milliseconds
    	li $a2, 58  # instrument 
    	li $a3, 80 #volume MAX
    	syscall
    	
    	addi $s6, $s6, 1
	
	j restart
    
maxAttempts:
	li $v0, 31
	li $a0, 50 #pitch
    	li $a1, 1000 #time in milliseconds
    	li $a2, 58  # instrument 
    	li $a3, 90 #volume MAX
    	syscall
    
    	li $a1, 1300
    	li $v0, 31
   	li $a0, 45
   	syscall
    
    	li $a1, 1500
    	li $v0, 31
    	li $a0, 40
    	li $a3, 127
    	syscall
    
    	printString(youLose)
    	#print correct randomized word
    	li $v0, 4
    	move $a0, $s2
   	syscall
   	
    	#print replay menu
    	printString(replayMenu)
    	printString(menuChoice)
    	
    	#get user input
    	li $v0, 5
    	syscall
    	move $s3, $v0
    	
    	beq $s3, 1, traverseArray	#if user input is 1, restart game
    	beq $s3, 2, exit	#if user input is 2, exit game
    
    	#printing newline below random word, so it shows 5 as string not 6
    	printString(newLine)
    
exit:
	printString(exitMsg)
	
    	#exit program
    	li $v0, 10
    	syscall