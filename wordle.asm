# CS 2640
# Tyler Carrasco, Tiffany Dinh, Kendan Phan, Angela Salcido
# Final Project
# mips assembly program that replicates the puzzle game "Wordle"

.include "macros.asm"

.data
menu: .asciiz "~~~~~~~~~~~~ MAIN MENU “~~~~~~~~~~~~\n(1) Start Game\n(2)Exit Program\n"

menuChoice: .asciiz "\nEnter (1) or (2) for your selection: "

exitMsg: .asciiz "\nExiting Program. Goodbye!"

word1: .asciiz "piano\n"
word2 : .asciiz "apple\n"
word3: .asciiz "water\n"

wordBank: .word word1, word2, word3

.text
main: 
	#output Main Menu text
	printString(menu)

	#print menu choice
	printString(menuChoice)

	#get user input here
	li $v0, 5	# 5 = read int
	syscall
	move $s0, $v0	  #move user input to $s0

	beq $s0, 1, traverseArray
	beq $s0, 2, exit

	#loop counter
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

	#print string
	li $v0, 4
	move $a0, $s2
	syscall

exit:
	printString(exitMsg)

	#exit program
	li $v0, 10
	syscall
