###############################################################################
# Brennan Schmidt and Peter Collins
#
# Lecture section 2
#
# This program reads in a degree for a polynomial, then reads in coefficients
# for each degree of the polynomial, and then prints the coefficients back out. If
# anything other than a number is entered for the degree, an error message will
# print. The degree needs to be an integer between 0 and 4
###############################################################################

.data
intro: .asciiz "Polynomial program:\n"
enter_degree: .asciiz "Enter degree: "
enter_coeff: .asciiz "Enter coefficient for x^"
poly_entered: .asciiz "Polynomial entered:\n"
x_power_of: .asciiz "x^"
space_plus_space: .asciiz " + "
minus_sign: .byte '-'
err_msg: .asciiz "\nBad input. Quitting."
coefficients: .word 0:5
num_digits: .word 0:5
neg_array: .byte 0:5
colon: .byte ':'
degree: .word 0

.text
# $8 degree
# $9 temp 4 check value
# $10 coeffcient getter
# $11 ASCII minus sign check value
# $12 ASCII carriage return check value
# $13 pointer to negative boolean array
# $14 coeffcient value
# $15 minus sign bool
# $16 ASCII representation of degree
# $17 coeffcient digit to print
# $18 divided coeffcient
# $19 temp powers of ten to subtract
# $20 ASCII coeffcient to print
# $21 count of chars inputted
# $22 temp counter for finding left most digit
# $23 boolean value for if the first nonzero digit has been entered
# $24 pointer to next open location in coeffecients
# $25 pointer to next open location in num_digits
__start:
    puts intro
    puts enter_degree
    getc $8             	# store the degree of the polynomial into $8
    sub $8, $8, 0x30    	# convert from ASCII to integer
    bltz $8, input_err
    li $9, 4            	# check if not greater than 4
    bgt $8, $9, input_err
    getc $10            	# get the newline char
    li $12, 10              # ASCII new line
    bne $10, $12 input_err 	# check for new line
	sw $8, degree # store degree into memory
    la $24, coefficients 	# load address of coefficients array
    la $25, num_digits  	# load address of number of digits array
    la $13, neg_array 		# load address of number of negative array

coeff_loop:
    bltz $8, end_coeff_loop # If we have the coeffcients for all degrees, finish
    li $23, 0
	li $21, 0               # sets the digit count to 0
    puts enter_coeff		# print message to request coefficient
    add $16, $8, 0x30
    putc $16
    putc colon
    getc $10
    li $11, 45 				# load ASCII minus sign
    beq $10, $11, set_minus_sign # if first char is '-' set minus sign to true
no_minus_sign:
    sub $10, $10, 0x30       # first digit
    bltz $10, input_err      # validate int
    li $9, 9
    bgt $10, $9, input_err
    move $14, $10            # store first digit as integer    
    beqz $10, zero_digit1    # if the digit is a nonzero, set nonzero bool to true
    li $23, 1                # sets first nonzero digit to true
zero_digit1:
    beqz $23 no_incr1
	add $21, 1               # increment digit counter
no_incr1:
    li $15, 0                # set minus sign to false
    b get_int	
set_minus_sign:
    li $14, 0                # initialize integer as 0
    li $15, 1                # set minus sign to true
get_int:
    getc $10
    li $12, 10               # ASCII new line
    beq $10, $12 end_get_int # check for new line
    sub $10, $10, 0x30       # convert ASCII to integer
    bltz $10, input_err      # validate int
	li $9, 9
    bgt $10, $9, input_err
    mul $14, $14, 10         # multiply the current coefficient by 10
    add $14, $14, $10        # add the int
    beqz $10, zero_digit2    # if digit is a nonzero, set nonzero bool to true
    li $23, 1
zero_digit2:
    beqz $23, no_incr2
    add $21, 1               # increment digit counter
no_incr2:
    b get_int
end_get_int:
    sw $14, ($24)			 # store the integer coefficient its array
    sw $21, ($25)			 # store the number of digits for this coefficient in its array
    sb $15, ($13)	 	 	 # store the negation of the coefficient in its array
    add $24, $24, 4		 	 # increment the coefficient array pointer
    add $25, 4				 # increment the number of digits array pointer
    add $13, 1			 	 # increment the negative array pointer
    sub $8, $8, 1        	 # decrement degree
    bgez $8 coeff_loop   	 # loop back ask for next degree coeffcient
end_coeff_loop:
    puts poly_entered		 # print message for displaying polynomial
	la $13, neg_array        # load address pointer to beginning of negative array
	la $24, coefficients	 # load address pointer to beginning of coefficients array
    la $25, num_digits		 # load address pointer to beginning of number of digits array
	lw $8, degree			 # reload the actual degree of the polynomial
poly_loop:
	lb $15, ($13)   	 	 # load actual negation value for current coefficient
    lw $14, ($24)			 # load actual coefficient value for current coefficient
    lw $21, ($25)			 # load actual number of digits for current coefficient
    add $13, 1				 # increment pointer for negative array
    add $24, 4				 # increment pointer for coefficients array
    add $25, 4				 # increment pointer for number of digits array
    beqz $15, print_coeff 	 # goes to print coeff if integer is not negative
print_minus_sign:
    putc minus_sign
print_coeff:
    move $18, $14        	 # copy integer into temporary calculation register
    li $19, 1            	 # initialize power of ten to 1
	li $22, 0            	 # initialize left digit finder to 0
get_left_digit:
    rem $17, $18, 10     	 # find store what could be our left most digit
    div $18, $18, 10     	 # divide integer by ten
    mul $19, $19, 10     	 # multiply power of ten by ten
    add $22, 1
    blt $22, $21, get_left_digit # if we've have more left digits, loop & find more
    add $20, $17, 0x30    	 # we've found the digit, convert to ASCII
    putc $20
    div $19, $19, 10     	 # overcounted power of ten, divide by 10 once
    mul $19, $19, $17    	 # multiple power of ten by left most digit
    sub $14, $14, $19    	 # subtract from integer to delete left most digit
    sub $21, $21, 1       	 # decrement number of digits
    bgtz $21 print_coeff 	 # more digits? print more!
end_print_coeff:
    puts x_power_of
    add $16, $8, 0x30
    putc $16              	 # print degree
    beqz $8, no_plus
	puts space_plus_space 	 # print + only between degrees of polynomial, not at the end
no_plus:	
    sub $8, $8, 1         	 # decrement degree
    bgez $8 poly_loop   	 # loop back and print next degree
end_poly_loop:
    b finish
input_err:
    puts err_msg
finish:	
    done

