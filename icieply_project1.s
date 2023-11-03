.data 0x10000000
#
# Prompt messages
#

# 0-byte offset
initial_prompt:         .asciiz "\nPlease choose one of the following options:\n\t1. Encode (e)\n\t2. Decode (d)\n\t3. Terminate (t)\n"
                        .align 7
# 128-byte offset
start_encode_prompt:    .asciiz "\nPlease enter a sequence of 11 0s and 1s, representing an unencoded vote count, to encode: "
                        .align 7
# 256-byte offset
end_encode_prompt:      .asciiz "\nEncoded data: "
                        .align 7
# 384-byte offset
start_decode_prompt:    .asciiz "\nPlease enter a sequence of 16 0s and 1s, representing an encoded vote count, to decode: "
                        .align 7
# 512-byte offset
unvalidated_prompt:     .asciiz "\nUnvalidated data bits: "
                        .align 7
# 640-byte offset
corrected_code_prompt:  .asciiz "\nCorrected codeword: "
                        .align 7
# 768-byte offset
corrected_data_prompt:  .asciiz "\nCorrected data: "
                        .align 7
# 896-byte offset
end_decode_prompt:      .asciiz "\nDecoded data: "
                        .align 7
# 1024-byte offset
terminate_prompt:       .asciiz "\nTerminating the program..."
                        .align 7
# 1152-byte offset
invalid_option_prompt:  .asciiz "\nInvalid option. Please try again...\n"
                        .align 7
# 1280-byte offset
parity_bit_prompt:      .asciiz "\nParity bits (P8, P4, P2, P1, PT): "
                        .align 7
# 1408-byte offset
syndrome_prompt:        .asciiz "\nHamming syndrome (P8, P4, P2, P1): "
                        .align 7
# 1536-byte offset
total_parity_pass:      .asciiz "\nTotal parity - PASS"
                        .align 7
# 1664-byte offset
total_parity_fail:      .asciiz "\nTotal parity - FAIL"
                        .align 7
# 1792-byte offset
result_0_error:         .asciiz "\nThe encoded codeword is valid"
                        .align 7
# 1920-byte offset
result_1_error:         .asciiz "\nThe encoded codeword has 1 error"
                        .align 7
# 2048-byte offset
result_2_error:         .asciiz "\nThe encoded codeword has 2 errors"
                        .align 7
# 2176-byte offset
error_2_prompt:         .asciiz "\nUnable to correct codeword if 2 errors are present"
                        .align 7

#
# Other values
#

# Buffer for user input strings
user_input_string_buf:      .space 16

# 2320-byte offset
# User's converted inputted codeword or data
user_input_codeword_data:   .word 0

# 2324-byte offset
# Parity bits
parity_bit_1:               .word 0
parity_bit_2:               .word 0
parity_bit_4:               .word 0
parity_bit_8:               .word 0
parity_bit_t:               .word 0

# User's unvalidated 11-bit data
unvalidated_data:           .word 0

# Hamming syndrome of inputted user codeword
hamming_syndrome:           .word 0

# User's fixed codeword
fixed_codeword:             .word 0

# Extracted data from fixed codeword
correct_data:               .word 0

.text
main:
    addi $s0, $0, 1
    addi $s1, $0, 2

    # Store $s0, $s1, and $ra on stack 
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    or $0, $0, $0
    sw $s1, 4($sp)
    or $0, $0, $0
    sw $ra, 8($sp)
    or $0, $0, $0

    # Load address of data segment start
    # Contains prompt messages first
    lui $s0, 0x1000

start_of_program:
    # Print initial prompt, displaying various options
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 0
    syscall

    # Get user's decision via reading character and store it in s1
    addiu $v0, $0, 12
    syscall
    addu $s1, $0, $v0

    # Force user's character to be lowercase
    ori $s1, $s1, 32

    # Branch if user's input is a valid option
    addiu $t0, $0, 100 # d ASCII code
    addiu $t1, $0, 101 # e ASCII code
    addiu $t2, $0, 116 # t ASCII code

    # Branch to decode
    bne $s1, $t0, skip0
    or $0, $0, $0
    jal hamming_decode
    or $0, $0, $0
skip0:
    # Branch to encode
    bne $s1, $t1, skip1
    or $0, $0, $0
    jal hamming_encode
    or $0, $0, $0
skip1:
    # Branch to terminate
    bne $s1, $t2, skip2
    or $0, $0, $0
    j terminate
    or $0, $0, $0
skip2:
    j start_of_program
    or $0, $0, $0


terminate:
    # Print termination prompt
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 1024
    syscall

    # Pull $s0, $s1, and $ra off stack
    lw $ra, 8($sp)
    or $0, $0, $0
    lw $s1, 4($sp)
    or $0, $0, $0
    lw $s0, 0($sp)
    or $0, $0, $0
    addi $sp, $sp, 12

    jr $ra
    or $0, $0, $0


# Name: hamming_encode
# Purpose: Encode a given piece of data as a 16-11 hamming code
# Input: 11 bits of data
# Output: 16-bit hamming code
hamming_encode:
    # Start of data segment
    lui $t0, 0x1000

    # Print start encode prompt
    addiu $v0, $0, 4
    addu $a0, $0, $t0
    addiu $a0, $a0, 128
    syscall

    # Take in user 11-character data string and store in data segment
    addiu $v0, $0, 8
    addiu $a0, $t0, 2304 # Buffer
    addiu $a1, $0, 18   # Character read limit
    syscall

    # Convert user's data to word
    # String buffer starts at 2304-byte offset and LSB is 10 bytes from start of buffer
    addi $t1, $t0, 2314 # String buffer offset
    addi $t2, $0, 10 # Counter
    addi $t5, $0, 10 # For calculating shift amount
    addi $t3, $0, 49 # 1 ascii code
    addi $t7, $0, -1 # Loop limit
    loop_start0:
        # Load character
        lb $t4, 0($t1)
        or $0, $0, $0
        # Branch if character is not 1
        bne $t4, $t3, skip_loop0
        or $0, $0, $0
        # Calculate shift amount (10 - counter)
        sub $t6, $t5, $t2
        # Move 1 into position of character
        addi $t4, $0, 1
        sll $t6, $t4, $t6
        # OR to place 1 into converted word
        or $t9, $t9, $t6
    skip_loop0:
        # Decrement counter
        addi $t2, $t2, -1
        # Decrement string buffer offset
        addi $t1, $t1, -1
        # Go to next iteration if counter >= 0
        bne $t2, $t7, loop_start0
        or $0, $0, $0

    # Save converted data to data segment
    sw $t9, 2320($t0)
    or $0, $0, $0

    # Place data bits into 16,11 codeword
    add $t0, $0, $0 # Codeword
    addi $t1, $0, 1 # Bitmask
    # Data bit 0
    and $t2, $t9, $t1 # Isolate data bit
    sll $t1, $t1, 1   # Shift bitmask left by 1 bit
    sll $t2, $t2, 3   # Shift data bit left by 3 bits
    or $t0, $t0, $t2  # OR codeword by shifted data bit
    # Data bits 1 to 3
    add $t3, $0, $0 # Counter
    addi $t4, $0, 3 # Loop limit
    bits1to3loopstart:
        and $t2, $t9, $t1 # Isolate data bit
        sll $t1, $t1, 1   # Shift bitmask left by 1 bit
        sll $t2, $t2, 4   # Shift data bit left by 4 bits
        or $t0, $t0, $t2  # OR codeword by shifted data bit

        addi $t3, $t3, 1                # Increment counter
        bne $t3, $t4, bits1to3loopstart # Exit loop if Counter is not less than 3
        or $0, $0, $0
    # Data bits 4 to 11
    add $t3, $0, $0 # Counter
    addi $t4, $0, 8 # Loop limit
    bits4to11loopstart:
        and $t2, $t9, $t1 # Isolate data bit
        sll $t1, $t1, 1   # Shift bitmask left by 1 bit
        sll $t2, $t2, 5   # Shift data bit left by 5 bits
        or $t0, $t0, $t2  # OR codeword by shifted data bit

        addi $t3, $t3, 1                 # Increment counter
        bne $t3, $t4, bits4to11loopstart # Exit loop if Counter is not less than 8
        or $0, $0, $0

    # Calculate parity bits
    add $t0, $0, $t0 # Codeword
    add $t1, $0, $0  # Column index
    add $t2, $0, $0  # Total parity count
    addi $t9, $0, 2324 # Offset to parity bit data segment
    # Loop iteration for each parity bit
    parity_loop_start:
        addi $t3, $0, 1 # For shift
        sllv $t3, $t3, $t1 # Column mask
        add $t4, $0, $0 # Bit index
        add $t5, $0, $0 # One count
        bit_index_loop_start:
            # Isolate bit's value into $t6
            addi $t6, $0, 1 # For shift
            sllv $t6, $t6, $t4
            and $t6, $t0, $t6
            srlv $t6, $t6, $t4 # Value isolated
            
            # Is the value a 1, then increment
            addi $t7, $0, 1
            bne $t6, $t7, skip_not_one # If not 1, branch
            or $0, $0, $0

            # Then check if the bit corrsponds to the current column mask
            and $t8, $t4, $t3 # AND bit index with column mask
            bne $t8, $t3, skip_not_one
            or $0, $0, $0
            # If it does correspond, increment by 1
            addi $t5, $t5, 1 # Increment 1 counter
        skip_not_one:
            addi $t4, $t4, 1 # Increment bit index
            addi $t7, $0, 16
            bne $t4, $t7, bit_index_loop_start # Exit loop if bit index reaches 16
            or $0, $0, $0

        # If the parity is odd, set parity bit
        addi $t7, $0, 1
        andi $t6, $t5, 1
        bne $t6, $t7, skip_not_odd
        or $0, $0, $0

        # Increment total parity count
        addi $t2, $t2, 1
        # Set parity bit
        lui $t8, 0x1000
        add $t8, $t8, $t9 # Calculate address of parity bit
        sw $t7, 0($t8)    # Place a 1 in the memory slot
        or $0, $0, $0
    
    skip_not_odd:
        addi $t1, $t1, 1 # Increment column index
        addi $t9, $t9, 4 # Increment parity bit data segment offset

        # Exit loop if column index reaches 4
        addi $t7, $0, 4
        bne $t1, $t7, parity_loop_start
        or $0, $0, $0

    # Calculate total parity bit
    add $t3, $0, $0 # Reset bit index  
    total_parity_loop_start:
        # Isolate bit's value into $t6
        addi $t6, $0, 1 # For shift
        sllv $t6, $t6, $t3
        and $t6, $t0, $t6
        srlv $t6, $t6, $t3 # Value isolated

        # Is the bit's value 1?
        addi $t4, $0, 1
        bne $t6, $t4, skip_not_one2 # Branch if its not 1
        or $0, $0, $0
        addi $t2, $t2, 1 # Increment total parity count

    skip_not_one2:
        addi $t3, $t3, 1 # Increment bit index

        # Exit loop if bit index reaches 16
        addi $t5, $0, 16
        bne $t5, $t3, total_parity_loop_start
        or $0, $0, $0

    # If the parity is odd, set parity bit
    addi $t7, $0, 1
    andi $t8, $t2, 1
    bne $t8, $t7, skip_not_odd2
    or $0, $0, $0

    # Set parity bit
    lui $t8, 0x1000
    addi $t8, $t8, 2340 # Calculate address of parity bit
    sw $t7, 0($t8)      # Place a 1 in the memory slot
    or $0, $0, $0

skip_not_odd2:
    # Insert parity bits into codeword and print

    jr $ra
    or $0, $0, $0


# Name: hamming_decode
# Purpose: Decode a given 16-11 hamming code
# Input: 16-bit hamming code
# Output: 11 bits of data
hamming_decode:
    # Print  
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 384
    syscall

    jr $ra
    or $0, $0, $0

