# --- INITIALIZATION ---
00000513    addi a0, x0, 0       # a0 = 0 (Total Sum Accumulator)
00200293    addi t0, x0, 2       # t0 = 2 (The first term of the sequence)
00300313    addi t1, x0, 3       # t1 = 3 (The common difference)
00A00593    addi a1, x0, 10      # a1 = 10 (Loop counter: calculate 10 terms)

# --- LOOP START ---
00058863    beq a1, x0, seq_end  # If counter (a1) == 0, break out of loop (+16 bytes)

seq_loop:
00550533    add a0, a0, t0       # Sum (a0) = Sum (a0) + current_term (t0)
006282B3    add t0, t0, t1       # current_term (t0) = current_term (t0) + difference (t1)
FFF58593    addi a1, a1, -1      # counter (a1) = counter (a1) - 1
FE0592E3    bne a1, x0, seq_loop # If counter (a1) != 0, jump back to seq_loop (-12 bytes)

# --- PROGRAM END ---
seq_end:
0000006F    jal x0, seq_end      # Infinite loop to safely trap the processor (jump offset 0)