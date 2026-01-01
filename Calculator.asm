# This is a calculator with 2 ways to solve


.data
start_message1:.asciz "Press 1 if you want to write the whole expression all together "
start_message2:.asciz "Press 2 if you want to put the numbers and operator individually"
choice1:.asciz "Write your whole expression (no spaces) and end it with an equal sign (=)"
choice2_part1:.asciz "Please input the first number: "
choice2_part2:.asciz "Please input the second number: "
choice2_operation:.asciz "Please enter the operation (+, -, *, /): "
error_msg:.asciz "Invalid operation.\n"
newline:.asciz "\n"
div_zero_msg:.asciz "Error: Division by zero.\n"
result_msg:.asciz "Result = "
example:.asciz "Example: 2+2+2-3= (Don't forget the equal sign)"
empty:.space 200 
.text
.globl main
main:

li s5,1

li a7, 4
la a0, start_message1
ecall

li a7, 4
la a0, newline
ecall

li a7, 4
la a0, start_message2
ecall

li a7, 4
la a0, newline
ecall

li a7, 5
ecall

#reading the integer to see which option they want

li x8, 1
li x25, 2
beq x8,a0,all_in_one
beq x25,a0,each_one_by_itself
j syntax_error

all_in_one:

li a7,4
la a0,choice1
ecall

li a7,4
la a0,newline
ecall

li a7,4
la a0,example
ecall

li a7,4
la a0,newline
ecall

li a7, 8 
la a0,empty
li a1,200 #This means we can read up to 200 characters into the buffer (could be larger but no need since the calculator is meant for simple operations)
ecall

#checking if first character is an operand
la t0, empty  
lbu x1, 0(t0)
li x2, '+'
beq x1, x2, syntax_error
li x2, '-'
beq x1, x2, syntax_error
li x2, '*'
beq x1, x2, syntax_error
li x2, '/'
beq x1, x2, syntax_error

li t1, 0   
li t6, 0       
li s1, 0      
li s4, 0     

num1:
   
    lbu x1, 0(t0)     
    li x2, '='        
    beq x1, x2, only_one_number
    li x2, '+'        
    beq x1, x2, operator_found
    li x2, '-'        
    beq x1, x2, operator_found
    li x2, '*'
    beq x1, x2, operator_found
    li x2, '/'
    beq x1, x2, operator_found
    
    
    li t2, 48         # ASCII '0'
    sub x1, x1, t2	# Because "number" + 48 = "number" in ASCII
    li t2, 10
    mul t6, t6, t2    # to move on to the next character in the number
    add t6, t6, x1  # Its like the summation but using a jump

    addi t0, t0, 1    # move to next char
    j num1
    
operator_found:
    mv t5, x1        # save operator
    addi t0, t0, 1    # move past operator
    li t2, 0          # if you don't do this it messes up the calculation and gives a negative number (clearing accumulation)
    li s1, 0
num2:
    li x2, '=' #so it can detect when the string comes to an end
    lbu x1, 0(t0)
    beq x1, x2, do_op

    li x2, '+'        
    beq x1, x2, third_found
    li x2, '-'        
    beq x1, x2, third_found
    li x2, '*'
    beq x1, x2, third_found
    li x2, '/'
    beq x1, x2, third_found
    li t2, 48
    sub x1, x1, t2
    li t2, 10
    mul s1, s1, t2
    add s1, s1, x1

    addi t0, t0, 1
    j num2

third_found:
mv s6, x1
li s4, 1
j do_op

one_more: # If there are multiple operators 
mv t6,t4
mv t5,s6
li s4, 0
addi t0,t0,1
li s1, 0 

li t2,0
j num2

do_op:
mv s10, t6    # First number
    mv t1, s1    # Second number
    li t3, '+'
    beq t5, t3, do_add
    li t3, '-'
    beq t5, t3, do_sub
    li t3, '*'
    beq t5, t3, do_mul
    li t3, '/'
    beq t5, t3, do_div

    # Invalid operator
    li a7, 4
    la a0, error_msg
    ecall
    j exit
each_one_by_itself:
    # Prompt for first number
    li a7, 4
    la a0, choice2_part1
    ecall

    li a7, 5         # read integer
    ecall
    mv s10, a0

    # Prompt for second number
    li a7, 4
    la a0, choice2_part2
    ecall

    li a7, 5         # read integer
    ecall
    mv t1, a0

    # Prompt for operation
    li a7, 4
    la a0, choice2_operation
    ecall

    li a7, 12        # read char
    ecall
    mv t2, a0

    # Check operator
    li t3, '+' 
    beq t2, t3, do_add

    li t3, '-' 
    beq t2, t3, do_sub

    li t3, '*' 
    beq t2, t3, do_mul

    li t3, '/' 
    beq t2, t3, do_div

    # else case (invalid)
    li a7, 4
    la a0, error_msg
    ecall
    j exit

do_add:
    add t4, s10, t1
    beq s4,s5,one_more
    j print_result

do_sub:
    sub t4, s10, t1
    beq s4,s5,one_more
    j print_result

do_mul:
    mul t4, s10, t1
    beq s4,s5,one_more
    j print_result

do_div:
    # Division by zero check
    beq t1,x0, div_zero_error
    div t4, s10, t1
    beq s4,s5,one_more
    j print_result

only_one_number:

li a7, 4
    la a0, newline
    ecall

    li a7, 4
    la a0, result_msg
    ecall

    mv a0, t6
    li a7, 1
    ecall

    li a7, 4
    la a0, newline
    ecall
    
    j exit

div_zero_error:
    li a7, 4
    la a0, div_zero_msg
    ecall
    j exit

print_result:
    li a7, 4
    la a0, newline
    ecall

    li a7, 4
    la a0, result_msg
    ecall

    mv a0, t4
    li a7, 1
    ecall

    li a7, 4
    la a0, newline
    ecall

exit:
    li a7, 10
    ecall
    
syntax_error:
li a7,4
la a0,error_msg
ecall

j exit
