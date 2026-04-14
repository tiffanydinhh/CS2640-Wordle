.macro printString(%defString) 
	li $v0, 4
	la $a0, %defString
	syscall
.end_macro
