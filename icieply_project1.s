.data 0x10000000
#
# Prompt messages
#

# 0 byte offset
initial_prompt:         .asciiz "\nPlease choose one of the following options:\n\t1. Encode (e)\n\t2. Decode (d)\n\t3. Terminate (t)\n"
                        .align 7
# 128 byte offset
start_encode_prompt:    .asciiz "\nPlease enter a sequence of 0s and 1s to encode: "
                        .align 7
# 256 byte offset
end_encode_prompt:      .asciiz "\nEncoded data: "
                        .align 7
# 384 byte offset
start_decode_prompt:    .asciiz "\nPlease enter a sequence of 0s and 1s to decode: "
                        .align 7
# 512 byte offset
end_decode_prompt:      .asciiz "\nDecoded data: "
                        .align 7
# 640 byte offset
terminate_prompt:       .asciiz "\nTerminating the program..."
                        .align 7
# 768 byte offset
invalid_option_prompt:  .asciiz "\nInvalid option. Please try again...\n"

#
# Other values
#


.text
main:
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
    beq $s1, $t0, decode
    # Branch to encode
    beq $s1, $t1, encode
    # Branch to terminate
    beq $s1, $t2, terminate
    # Otherwise, ask for input again
    j invalid_option

    jr $ra
    or $0, $0, $0

encode:
    # Print initial prompt, displaying various options
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 128
    syscall

    jr $ra
    or $0, $0, $0

decode:
    # Print initial prompt, displaying various options
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 384
    syscall

    jr $ra
    or $0, $0, $0

terminate:
    # Print initial prompt, displaying various options
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 640
    syscall

    jr $ra
    or $0, $0, $0

invalid_option:
    # Prints the invalid option prompt
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 768
    syscall

    # Ask for input again
    j start_of_program
    or $0, $0, $0
