.data 0x10000000
# Prompt messages are aligned at 128 byte memory addresses to simplify access.
# 0 byte offset
initial_prompt:     .asciiz "Please choose one of the following options:\n\t1. Encode (e)\n\t2. Decode (d)\n\t3. Terminate (t)\n"
                    .align 7
# 128 byte offset
encode_prompt:      .asciiz "Please enter a sequence of 0s and 1s to encode: "
                    .align 7
# 256 byte offset
decode_prompt:      .asciiz "Please enter a sequence of 0s and 1s to decode: "
                    .align 7
# 384 bytes offset
terminate_prompt:   .asciiz "Terminating the program..."

.text
.globl main
main:
    # Load address of data segment start
    # Contains prompt messages first
    lui $s0, 0x1000

    # Print initial prompt, displaying various options
    addiu $v0, $0, 4
    addu $a0, $0, $s0
    addiu $a0, $a0, 0
    syscall

    jr $ra
    or $0, $0, $0
