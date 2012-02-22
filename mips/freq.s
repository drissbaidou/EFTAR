# Informatics 2C - Introduction to Computer Systems
# Coursework 1: MIPS Programming
# 
# Write a MIPS program that reads in a sequence of characters from the terminal
# again terminated with a $ character, and this time that counts the number of
# occurrences of each letter of the alphabet A-Z. The program should not distinguish
# between upper and lower case versions of each letter. Counts of character
# occurrences should be held in an array of 26 32-bit integers.

        .data                                    # define global variables
stringEnterText:    .asciiz    "\n\nEnter text, followed by $:\n"
newline:            .asciiz    "\n"
colonBlank:         .asciiz    ": "
arrayInt:           .word      26                # 26*sizeof(word) = 104 bytes reserved -> array of 26 integers
        
        .globl main                              # define main as entry-point
        
        .text                                    # after here follows program text/code
        
main:                                            # entry-point into the program
        
preloopInitArray:                                # make sure saved-value registers are properly inited
        move      $s1, $zero                     # $s1 = 0, $s1 is used to point to the next position in arrayInt
        
loopInitArray:                                   # init all positions in intArray to 0
        la        $t0, arrayInt                  # load starting_address of arrayInt into $t0
        add       $t0, $t0, $s1                  # $t2 = arrayInt_starting_address + offset
        sw        $zero, 0($t0)                  # intArray[$s1] = 0
        addi      $s1, 4                         # $s1 += 4, move $s1 to point to next entry (size of int = 4)
        bge       $s1, 104, endloopInitArray     # exit loop if we've set all 26 elements of arrayInt (26*4=104)
        j         loopInitArray                  # jump to start of loop, set next entry
        
endloopInitArray:                                # finished init of array, clean up saved-values registers
        move      $s1, $zero                     # $s1 = 0, $s1 is used to point to current position in arrayInt
        
printstringEnterText:                            # display "Enter text, followed by $:\n"
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, stringEnterText           # load address of string to print into first argument register
        syscall                                  # perform syscall defined by $v0: print string in $a0 to screen
        
preeloopGetInput:                                # make sure saved-value registers are properly inited
        move      $s0, $zero                     # $s0 = 0, $s0 is used to hold currently read input character
        
loopGetInput:                                    # collect input, one character at a time
        li        $v0, 12                        # load number for "read character" into $v0 in prep for syscall
        syscall                                  # perform syscall: collect char, char is now in $v0
        move      $s0, $v0                       # save $v0, $s0 = $v0
        beq       $s0, 0x24, endloopGetInput     # exit loop if we see a '$'
        blt       $s0, 0x41, loopGetInput        # skip chars with values less than 'A' (includes whitespace)
        ble       $s0, 0x5a, processUpper        # if we see an upper-case letter (<='Z'), goto code handling it
        blt       $s0, 0x61, loopGetInput        # skip chars with values less than 'a'
        ble       $s0, 0x7a, processLower        # if we see a lower-case letter (<='z'), goto code handling it
        j         loopGetInput                   # skip chars with values more than 'z'
        
processLower:                                    # subtracts 'a' from $s0 to normalize it to 1..26
        sub       $s0, $s0, 0x61                 # $s0 -= 'a' - $s0 => index we want to increment in arrayInt
        j         incrementArrayElement          # continue with array-handling
        
processUpper:                                    # subtracts 'A' from $s0 to normalize it to 1..26
        sub       $s0, $s0, 0x41                 # $s0 -= 'A' - $s0 => index we want to increment in arrayInt
        j         incrementArrayElement          # continue with array-handling
        
incrementArrayElement:                           # do arrayInt[$s0]++
        la        $t0, arrayInt                  # load starting_address of arrayInt into $t0
        sll       $t1, $s0, 2                    # $t1 = $s0 * 4 - needed because of 4-bit int size
        add       $t2, $t0, $t1                  # $t2 = arrayInt_starting_address + offset
        lw        $t3, ($t2)                     # $t3 = arrayInt[$s0]
        addi      $t3, 1                         # $t3 += 1
        sw        $t3, ($t2)                     # arrayInt[$s0] = $t3, last two opperations => arrayInt[$s0]++
        j         loopGetInput                   # jump to start of loop, get next input character
        
endloopGetInput:                                 # finished input loop, clean up saved-values registers
        move      $s0, $zero                     # $s0 = 0, $s0 is used to hold currently read input character
        
preloopPrintArray:                               # make sure saved-value registers are properly inited
        move      $s1, $zero                     # $s2 = 0, $s2 is used to hold track of current character (1-26)
        move      $s2, $zero                     # $s2 = 0, $s2 is used to hold track of current character (1-26)
        
loopPrintArray:                                  # print elements in arrayInt
        jal       printstringNewline             # print newline character
        jal       printstringCurrentChar         # print current character
        lw        $a0, arrayInt + 0($s1)         # $a0 = arrayInt[$s1] using pseudo instruction
        li        $v0, 1                         # load call code for "print_int" into $v0 in prep for syscall
        syscall                                  # perform syscall defined by $v0: print integer in $a0 to screen
        addi      $s1, 4                         # move $s1 to next position in arrayInt
        addi      $s2, 1                         # move $s2 to next character
        bge       $s2, 26, endloopPrintArray     # exit loop if we've printed all 26 elements of arrayInt
        j         loopPrintArray                 # jump to start of loop, print next entry
        
endloopPrintArray:                               # finished printing array, clean up saved-value registers
        move      $s1, $zero                     # $s1 = 0, $s1 is used to point to current position in arrayInt
        move      $s2, $zero                     # $s2 = 0, $s2 is used to hold track of current character (1-26)
        
exit:                                            # exit program graciously
        jal       printstringNewline             # print newline for better readability when called from terminal
        li        $v0, 10                        # load call code for "exit" into $v0 in prep for syscall
        syscall                                  # perform syscall defined by $v0: exit program
        
printstringCurrentChar:                          # prints "%D: " where %D is the current upper-case character
        li        $v0, 11                        # load call code for "print_char" into $v0 in prep for syscall
        move      $a0, $s2                       # load $s2 into first argument register
        addi      $a0, 0x41                      # $a0 += 'A' -> map $a0 to upper-case character
        syscall                                  # perform syscall: print char in $a0 to screen
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, colonBlank                # load address of colonBlank into first argument register
        syscall                                  # perform syscall: print string in $a0 to screen
        jr        $ra                            # jump back to where we were
        
printstringNewline:                              # prints a newline
        li        $v0, 4                         # load call code for "print_string" into $v0 in prep for syscall
        la        $a0, newline                   # load address of newline into first argument register
        syscall                                  # perform syscall: print string in $a0 to screen
        jr        $ra                            # jump back to where we were
