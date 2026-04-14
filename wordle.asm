.include "macros.asm"

.data
menu: .asciiz "~~~~~~~~~~~~ MAIN MENU “~~~~~~~~~~~~\n(1) Start Game\n(2)Exit Program\n"

menuChoice: .asciiz "\nEnter (1) or (2) for your selection: "

exitMsg: .asciiz "Exiting Program. Goodbye!"

word1: .asciiz "sunoo\n"
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
	li $v0, 42	#42 does random int generator in range
	la $a0, 0	#generator ID
	li $a1, 3	#upper bound (array size)
	syscall		#$a0 now holds [0,2] 0-3

	#shifting by 2 bits = multiplying by 4 (4 bytes = word) meaning we traverse to the next word
	sll $t1, $a0, 2 	#shifts left by 2 bits, multiply index by 2^2=4 (4 is our offset), $t1 holds the byte offset
	la $s1, wordBank	#loading our array into a base address
	add $s1, $s1, $t1 	#adds offset ($t1) into base address ($s1), (array location) stored in base adrs
	lw $a0, 0($s1)		#load rand word into $a0, load what is at $s1, $a0 contains rand elm

	#print random word at the end so that user knows the correct word
	#print string
	li $v0, 4
	syscall


exit:
	printString(exitMsg)

	#exit program
	li $v0, 10
	syscall


