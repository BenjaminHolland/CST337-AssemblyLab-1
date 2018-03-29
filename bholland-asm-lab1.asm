.data
	#user prompts
	int_prompt: .asciiz "GIVE ME A POSITIVE INTEGER: "
	noun_prompt: .asciiz "GIVE ME A NOUN: "
	place_prompt: .asciiz "GIVE ME A PLACE: "
	verb_prompt: .asciiz "GIVE ME A PAST TENSE VERB: "
	
	#story bits. I feel like there's a way to do this "better" by using markers and
	#iterating through and replacing the markers with stuff, but that's a lot more complicated
	#than seems to be required for this assignment
	
	story_0: .asciiz "Once upon a time there was a little "
	story_1: .asciiz ".\nOne day the little "
	story_2: .asciiz " went to a "
	story_3: .asciiz ".\nThe little "
	story_4: .asciiz " and "
	story_5: .asciiz " until becoming tired and going home.\nTHE END.\n"
	 
	#space for the strings read from users. I'm not sure if the alignment is required
	#but it's not going to hurt anyone, considering how large the code space is. 
	noun: 
		.space 64 
		.align 2
	place: 
		.space 64 
		.align 2
	verb: 
		.space 64 
		.align 2
	#space for the integer. should probably change the name. 
	input3: 
		.word 2

#MACROS (are the called macros in asm?) for the syscall codes. makes things more readable.
.eqv SYS_PRINT_INT 1
.eqv SYS_PRINT_CHAR 11
.eqv SYS_PRINT_STRING 4
.eqv SYS_READ_STRING 8
.eqv SYS_READ_INT 5
.eqv SYS_EXIT 10
 
.text

#gather some strings and an integer from a user, then print out a story that uses that data. 
#notes:
#While it's not flat, it only goes one "function" level deep for simplicities sake. While the program could benefit from 
#nested jumps, setting up the required stack frames (A) has not been covered in class up to this point and (B) would be 
#tedious and overengineered for a project of this size. I reserve the right to do this in future versions that aren't
#being made at 1 in the morning. 

main:
	#read first string
	la $a0,noun
	la $a1,noun_prompt
	jal prompt_for_string
	
	la $a0,noun
	jal fix_string
	
	#read second string
	la $a0,place
	la $a1,place_prompt
	jal prompt_for_string

	la $a0,place
	jal fix_string
		
	#read third string	
	la $a0,verb
	la $a1,verb_prompt
	jal prompt_for_string
	la $a0,verb
	jal fix_string
	
	#read integer
	jal prompt_for_int
	sw $v0,input3
	
	#move the integer into a register that functions should save on their own. For this programt that just means nothing will touch it.
	move $s0,$v0
	
	#print out the story
	la $a0,story_0
	jal write_string
	la $a0,noun
	jal write_string
	la $a0,story_1
	jal write_string
	la $a0,noun
	jal write_string
	la $a0,story_2
	jal write_string
	la $a0,place
	jal write_string
	la $a0,story_3
	jal write_string
	la $a0,noun
	jal write_string
	
	#because {noun} and {verb} are trimmed, we need a space between them for correctness. 
	jal print_space
	
	#print out at least one instance of the verb so the story flow is maintained even if the user is dumb and puts in 0 or a negative number.
	la $a0,verb,
	jal write_string
	
	#use the integer to repeat "and {verb}" n times, for a total of n+1
	verb_loop:
		la $a0,story_4
		jal write_string
		la $a0,verb
		jal write_string
		subi $s0,$s0,1
		bgez $s0,verb_loop
	
	la $a0,story_5
	jal write_string
	
	#write second string
	la $a0,place
	jal write_string
	
	#write third string
	la $a0,verb
	jal write_string
	
	#exit gracefully
	li $v0,SYS_EXIT
	syscall

#write a string to the console.
#args:
#	a0: address of the zt-string to write.
#returns:
#	nothing 
write_string:
	li $v0,SYS_PRINT_STRING
	syscall
	jr $ra
	
#write an integer to the console.
#args:
#	a0: the integer to write
#returns:
#	nothing
write_int:
	li $v0,SYS_PRINT_INT
	syscall
	jr $ra
#remote the newline character at the end of strings read by SYS_READ_STRING.
#args:
#	$a0: the address of the string to trim
#returns:
#	nothing
#uses:
#	$t0
fix_string:
	fix_string_loop:
		lb $t0,($a0)
		beq $t0,'\n',fix_string_write
		beq $t0,$zero,fix_string_end
		addi $a0,$a0,1
		j fix_string_loop
	fix_string_write:
		sb $zero,($a0)
	fix_string_end:
		jr $ra
#gets an integer from the user.
#args:
#	$a0: The address of the string used to prompt the user to enter the int.
#returns:
#	$v0: the value of the int that was read.
prompt_for_int:
	li $v0,SYS_PRINT_STRING
	la $a0,int_prompt
	syscall
	li $v0 SYS_READ_INT
	syscall
	jr $ra
	
#gets a string from the user
#args:
#	$a0: the address at which to store the string
#	$a1: the string used to prompt the user to enter the string
#returns:
#	nothing
#uses:
#	$t0
prompt_for_string:
	move $t0,$a0
	li $v0,SYS_PRINT_STRING
	la $a0,($a1)
	syscall
	
	li $v0,SYS_READ_STRING
	move $a0,$t0
	li $a1,64
	syscall
	jr $ra

#prints a space
#uses: $a0
print_space:
	li $a0,' '
	li $v0,SYS_PRINT_CHAR
	syscall
	jr $ra
	
	
	
	
	
