.include "macros.asm"

.data
menu: .asciiz "~~ MAIN MENU “~~\n(1) Start Game\n(2)Exit Program\n"

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
promptUserInput: .asciiz "Please input a 5-letter word: " 
guessBuffer: .space 16

fiveLetterTrue : .asciiz "\nInput is 5 letters"
fiveLetterFalse : .asciiz"\nInput is not 5 letters"

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

    beq $s0, 1, traverseArray
    #If the userinput is 1, it jumps to traverseArray

    beq $s0, 2, exit
    
    j main
    #If the userinput is 2, it jumps to the exit

   

traverseArray:
    li $v0, 42    #42 = random int generator in range
    li $a0, 0    #load generator ID in $a0 (0 = default generator)
    li $a1, 3    #$a1 = upper bound (array size is 3)
    syscall        #$a0 holds random index [0,2]

    #convert index to byte offset so that we can traverse array (2 bits^2 = 4)
    #sll quickly converts an array index to a byte offset
    sll $t1, $a0, 2     #index * 4 (4 bytes = word)

    la $s1, wordBank    #loading our array into a base address ($s1)

    #move to correct element
    add $s1, $s1, $t1     #adds offset ($t1) into base address of array ($s1)
    lw $s2, 0($s1)        #load random word stored in base address ($s1) to $s2

    #print random word (USE THIS TO TEST)
    #li $v0, 4
    #move $a0, $s2
    #syscall
    li $s6, 0 #this will serve as our counter for the amount of guesses the user has inputted, 4 being max due to indexing(technically means 5)
    li $s5, 5 
    restart:
    printString(promptUserInput)
    
  
    
    li $v0, 8
    la $a0, guessBuffer
    li $a1, 16
    syscall
    
    la $t0, guessBuffer
    
    li $t2, 10
    li $t4, 0
    li $t5, 4
    
    loop: 
    
    lb $t3, 0($t0)
    beq $t3, $t2, restart
    beq $t4, $t5, checkIfLong
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    
    j loop
    
    promptUserToTryAgainIfWrong:  # come back here to work on
    move $t7, $s2 #word
    la $t0, guessBuffer # guess
    li $t9, 0 # counter
    li $t1, 5
    LoopToCheckForPerfectAnswer:
    lb $t5, 0($t7)
    lb $t6, 0($t0)
    beq $t9, $t1, correctGuess   
    bne $t5, $t6, incorrectGuess
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
    j restart
  
    
    
    checkIfLong: 
    addi $t0, $t0, 1
    lb $t3, 0($t0)
    
    bne $t3, $t2, printToUserTooLong
    
     # FROM HERE ON OUT WE CAN start the game, INPUT IS VALID
     
     
     
     
     
     
     #reload to adjust for the incrementation of the address we previously did
     #load immediate at position 1
     li $t2, 1
     la $t0, guessBuffer
     li $t4, 6
     #load the word into a safe temp register to not lose our word data in future
     move $t3, $s2
     loopForGame:
     lb $t5, 0($t0)
     lb $t6, 0($t3)
     beq $t2, $t4, promptUserToTryAgainIfWrong
     bne $t5, $t6, wrongCharAtPosition
     
     li $v0, 11
     move $a0, $t5
     syscall
     
   printString(correctPosition)
  
   
   li $v0, 1
   move $a0, $t2
   syscall
    printString(newLine)
  
   
   addi $t2, $t2, 1
   addi $t0, $t0, 1
   addi $t3, $t3, 1
   j loopForGame
   
     
     
   wrongCharAtPosition:
     
    li $v0, 11
    move $a0, $t5
    syscall
     
   printString(incorrectPosition)
   
   li $v0, 1
   move $a0, $t2
   syscall
   
   
   #temp variable to save address of word again safely
   move $t7, $s2
   
   li $t8, 0
   li $t9, 4
   
   
   checkIfExistsLoop:
   lb $t1, 0($t7) # CHECK IF t1 REGISTER IS OKAY TO USE HERE TYLER t7 has word address, t5 has letter byte currently
   beq $t8, $t9, doesNotExist
   beq $t5,$t1, printExists
   addi $t8, $t8, 1
   addi $t7, $t7, 1
   j checkIfExistsLoop
   
   
   doesNotExist:
   printString(doesNotExistInWord)
   printString(newLine)				# input here
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
    li $v0, 4
    move $a0, $s2
    syscall
    
    
    j exit
    
    incorrectGuess:
    beq $s5, $s6, maxAttempts
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
    
    li $v0, 4
    move $a0, $s2
    syscall
    j exit
    
    
    
    
    
    
    
    
     
     
    
   
     
     
     
     
     
     
     
     
     
     
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    #Printing newline below random word, so it shows 5 as string not 6
    printString(newLine)
    
    

exit:
    printString(exitMsg)

    #exit program
    li $v0, 10
    syscall
