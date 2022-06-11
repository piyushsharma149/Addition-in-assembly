.data
prompt: .asciiz "Please input a value for N = "
warning: .asciiz "Floating point entered, truncating..."
result: .asciiz "The sum of the integers from 1 to N is "
bye: .asciiz "* * * * Adios Amigo - Have a good day* * * * "
newline: .asciiz "\n" #I'm doing this because the newlines in the other strings just don't make the program look good
.globl main
.text

	#prints "prompt"
main:	li $v0, 4
	la $a0, prompt
	syscall
	
	#read entered floating point
	li $v0, 6
	syscall
	
	#truncate floating point START
	mfc1 $t1, $f0 #copy floating point to $t0
	srl $t2, $t1, 23 #get exponent bits
	
	#check if negative number
	srl $t3, $t2, 8
	bnez $t3, end
	
	add $t2, $t2, -127 #get exponent
	
	#check if exponent is less than 0
	bltz $t2, end
	
	#zero out exponent and sign
	sll $t3, $t1, 9
	srl $t3, $t3, 9
	
	add $t3, $t3, 8388608 #insert implied bit
	
	#so right now:
	#$t1 contains original floating point
	#$t2 contains exponent - 127
	#t3 contains fraction with implied bit
	
	#get integer portion on right side
	add $t4, $t2, 9
	rol $t7, $t3, $t4
	
	#$t7 contains rotated fraction
	
	#check if floating point is actually an integer
	li $s1, 31
	sub $s2, $s1, $t2 #how much bits to shift to isolate integer
	sub $s3, $s1, $s2 #how much bits to shift to isolate fraction
	add $s3, $s3, 1
	
	srlv $s4, $t7, $s3 #isolate fraction
	move $s1, $t7
	
	#$s1 contains rotated fraction
	#$s2 contains shift amount to isolate integer
	#$s3 contains shift amount to isolate fraction
	#s4 contains isolated fraction
	
	#if fraction is not equal to 0, warn. if fraction is equal to 0, continue to loopp
	beqz $s4, cont
	li $v0, 4
	la $a0, warning
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#extract integer from floating point
	sllv $s1, $s1, $s2
	srlv $s1, $s1, $s2
	#truncate floating point END
	
	#prepare for loop
cont:	move $v0, $s1	
	li $t0, 0
	
	#start summing up the consecutive numbers	
loop:	add $t0, $t0, $v0
	addi $v0, $v0, -1
	bnez $v0, loop	
	
	#prints "result"
	li $v0, 4
	la $a0, result
	syscall
	
	#prints result
	li $v0, 1
	move $a0, $t0
	syscall
	
	#added by me to call a newline
	li $v0, 4
	la $a0, newline
	syscall
	b main
	
end:	li $v0, 4
	la $a0, bye
	syscall
	li $v0, 10
	syscall
	
