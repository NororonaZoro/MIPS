`timescale 1ns/10ps

//部件使能信号

`define RST_ENABLE 1
`define RST_DISABLE 0
`define ROMCE_ENABLE 1
`define ROMCE_DISABLE 0
`define INVALID 0
`define VALID 1
`define ZERO 0



//I型指令
`define code_ori 6'b001101
`define code_addi 6'b001000
`define code_andi 6'b001100
`define code_xori 6'b001110
`define code_lui 6'b001111
`define code_beq 6'b000100
`define code_bne 6'b000101

`define code_bgtz 6'b000111
`define code_bltz 6'b000001

//R型指令
`define code_r   6'b000000
`define code_add 6'b100000
`define code_sub 6'b100010
`define code_and 6'b100100
`define code_or  6'b100101
`define code_xor 6'b100110
`define code_sll 6'b000000
`define code_srl 6'b000010
`define code_sra 6'b000011
`define code_jr  6'b001000

//乘除法指令
`define code_mult  6'b011000
`define code_multu 6'b011001
`define code_div   6'b011010
`define code_divu  6'b011011

`define code_slt  6'b101010
`define code_jalr 6'b001001
`define code_mfhi 6'b010000
`define code_mflo 6'b010010
`define code_mthi 6'b010001
`define code_mtlo 6'b010011

//load-store型指令
`define code_lw 6'b100011
`define code_sw 6'b101011

//wait
`define code_ll 6'b110000
`define code_sc 6'b111000

//J型指令
`define code_j 6'b000010
`define code_jal 6'b000011


`define code_nop 6'b111111

//译码前后不同指令的操作码，注意op或code中不同指令的字段不可相同
//I型指令

`define op_lui 6'b000000
`define op_beq 6'b000001
`define op_bne 6'b000010

`define op_bgtz 6'b011010
`define op_bltz 6'b011011

//R型指令
`define op_add 6'b000011
`define op_sub 6'b000100
`define op_and 6'b000101
`define op_or  6'b000110
`define op_xor 6'b000111
`define op_sll 6'b001000
`define op_srl 6'b001001
`define op_sra 6'b001010
`define op_jr  6'b001011

//乘除法指令
`define op_mult  6'b010000
`define op_multu 6'b010001
`define op_div   6'b010010
`define op_divu  6'b010011

`define op_slt  6'b010100
`define op_jalr 6'b010101
`define op_mfhi 6'b010110
`define op_mflo 6'b010111
`define op_mthi 6'b011000
`define op_mtlo 6'b011001

//J型指令
`define op_j   6'b001100
`define op_jal 6'b001101

//wait
`define op_ll 6'b011100
`define op_sc 6'b011101

//load-store型指令
`define op_lw 6'b001110
`define op_sw 6'b001111

`define op_nop 6'b111111

//???????exceptype
`define timerInt      32'h0000_0004
`define code_syscall  32'h0000_000c
`define code_eret     32'h4200_0018
`define code_cp0      6'b010000
`define code_mfc0     5'b00000
`define code_mtc0     5'b00100

`define op_syscall  6'b011110
`define op_eret     6'b011111
`define op_mfc0     6'b100000
`define op_mtc0     6'b100001

//ExcCode
`define ExcCode_Int 0
`define ExcCode_Syscall 8 

//CP0?????????????
`define CP0_Cause   13
`define CP0_Status  12
`define CP0_Count   9
`define CP0_Compare 11
`define CP0_EPC     14