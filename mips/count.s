# Informatics 2C - Introduction to Computer Systems
# Coursework 1: MIPS Programming
# 
# Write a MIPS program that counts the number of characters in a sequence
# of characters entered from the terminal. The program should expect the
# sequence to end with a $ character and should ignore whitespace characters.
# Assume the sequence otherwise does not contain any $ characters.

        .data                                    # define global variables
stringEnterText:    .asciiz    "\n\nEnter text, followed by $:\n"
stringCount:        .asciiz    "\n\nCount: "
newline:            .asciiz     "\n"
        
        .globl main                              # define main as entry-point
        
        .text                                    # after here follows program text/code
        
main:                                            # entry-point into the program
        move      $s0, $zero                     # we'll use to $s0 keep track of the char-count, init it to $s0 = 0
        
printstringEnterText:                            # display "Enter text, followed by $:\n"
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, stringEnterText           # load address of string to print into first argument register
        syscall                                  # perform syscall defined by $v0: print string in $a0 to screen
        
loopGetInput:                                    # collect input, one character at a time
        li        $v0, 12                        # load call code for "read_char" into $v0 in prep for syscall
        syscall                                  # perform syscall: collect char, char is now in $v0
        move      $t0, $v0                       # save $v0 (just in case), $t0 = $v0
        beq       $t0, 0x24, endloopGetInput     # exit loop if we see a '$'
        beq       $t0, 0x20, loopGetInput        # if we see a space skip it by jumping back to start of loop
        beq       $t0, 0x09, loopGetInput        # if we see a \t skip it by jumping back to start of loop
        beq       $t0, 0x0a, loopGetInput        # if we see a \n skip it by jumping back to start of loop
        beq       $t0, 0x0d, loopGetInput        # if we see a \r skip it by jumping back to start of loop
        addi      $s0, $s0, 1                    # seen a non-whitespace character, increment char-count, s0 += 1
        j         loopGetInput                   # jump to start of loop, get next input character
        
endloopGetInput:
        
printstringCount:                                # display "\n\nCount: "
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, stringCount               # load address of string to print into first argument register
        syscall                                  # perform syscall defined by $v0: print string in $a0 to screen
        
printintCount:                                   # print $s0 to screen
        li        $v0, 1                         # load call code for "print_int" into $v0 in prep for syscall
        move      $a0, $s0                       # load $s0 into first argument register, $a0 = $s0
        syscall                                  # perform syscall: print integer in $a0 to screen
        
exit:                                            # exit program graciously
        jal       printstringNewline             # print newline for better readability when called from terminal
        li        $v0, 10                        # load call code for "exit" into $v0 in prep for syscall
        syscall                                  # perform syscall defined by $v0: exit program
        
printstringNewline:                              # prints a newline
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, newline                   # load address of newline into first argument register
        syscall                                  # perform syscall: print string in $a0 to screen
        jr        $ra                            # jump back to where we were
