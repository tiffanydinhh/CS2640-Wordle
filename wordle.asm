# CS 2640
# Tyler Carrasco, Tiffany Dinh, Kendan Phan, Angela Salcido
# Final Project
# mips assembly program that replicates the puzzle game "Wordle"

.include "wordleMacro.asm"

.data

#Menu UI
menu: .asciiz "~~~~~~~~~~~~ MAIN MENU “~~~~~~~~~~~~\n(1) Start Game\n(2)Exit Program\n"
menuChoice: .asciiz "\nEnter (1) or (2) for your selection: "
exitMsg: .asciiz "\nExiting Program. Goodbye!"

#Word bank for randomized solutions
word1: .asciiz "piano\n"
word2: .asciiz "apple\n"
word3: .asciiz "water\n" 
wordBank: .word word1, word2, word3

newLine: .asciiz "\n"

#Prompting the user for a 5-letter word input
promptUserInput: .asciiz "Please input a 5-letter word: "

#TBD
guessBuffer: .space 16

#Setting up data for if the words are 5 letters and match
fiveLetterTrue: .asciiz "\nInput is 5 letters"
fiveLetterFalse: .asciiz "\nInput is not 5 letters"

#inputAccept: .asciiz "Words match"
#inputDenied: .asciiz "Words do not match"


.text
main: 
	#output Main Menu text
	printString(menu)

	#print menu options
	printString(menuChoice)

	#get user input here
	li $v0, 5	# 5 = read int
	syscall
	move $s0, $v0	  #move user input to $s0

	#if the user input is 1, jump to traverseArray
	beq $s0, 1, traverseArray
	
	#If the user input is 2, jump to exit
	beq $s0, 2, exit

	#loop counter, NOT BEING USED YET
	li $t0, 3

traverseArray:
	li $v0, 42	#42 = random int generator in range
	li $a0, 0	#load generator ID in $a0 (0 = default generator)
	li $a1, 3	#$a1 = upper bound (array size is 3)
	syscall		#$a0 holds random index [0,2]

	#convert index to byte offset so that we can traverse array (2 bits^2 = 4)
	#sll quickly converts an array index to a byte offset
	sll $t1, $a0, 2 	#index * 4 (4 bytes = word)

	la $s1, wordBank	#loading our array into a base address ($s1)

	#move to correct element
	add $s1, $s1, $t1 	#adds offset ($t1) into base address of array ($s1)
	lw $s2, 0($s1)		#load random word stored in base address ($s1) to $s2

	#print random word (USE THIS TO TEST)
	li $v0, 4
	move $a0, $s2
	syscall
	
restart:
	#prompt user for a guess
	printString(promptUserInput)

	#store user's input into guessBuffer
	li $v0, 8	# 8 = read string
	la $a0, guessBuffer
	li $a1, 16
	syscall
	
	#count letters in user input
	la $t0, guessBuffer	#$t0 points to first letter in word stored in guessBuffer
	
	#declaring register values for the loop below
	li $t2, 10	#if the input is at \n (10 = \n)
	li $t4, 0	#$t4 declared as 0 (counter)
	li $t5, 4	#$t5 declared as max index check (5-letter word, 0-4)

#loop checks for amount of characters in user input
loop:
	lb $t3, 0($t0)	#load byte/char from user input string into $t3
		
	beq $t3, $t2, restart #if byte is equal to \n, then it is too small and restarts
	beq $t4, $t5, checkIfLong #if counter equals max index check (5 letters), jump to check if word is too long
		
	add $t0, $t0, 1	#move to next byte/char in word
	add $t4, $t4, 1	#incrementing the counter for the loop
	
	j loop
	
printUserTooLong:
	printString(fiveLetterFalse)
	printString(newLine)
	
	j restart	#if it is too long, it jumps to restart and prompts again

checkIfLong:
	add $t0, $t0, 1	#move to next byte/char in word
	#Loading the byte into the address $t3 if it is \n (Good size)
	lb $t3, 0($t0)	#load next byte/char from user input string into $t3
	bne $t3, $t2, printUserTooLong	#if the next byte/char is not equal to \n, word is too long
	
#-- From here on out, START the game / The word is 5 letters --

exit:
	printString(exitMsg)

	#exit program
	li $v0, 10
	syscall