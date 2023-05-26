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

//load-store型指令
`define code_lw 6'b100011
`define code_sw 6'b101011

//J型指令
`define code_j 6'b000010
`define code_jal 6'b000011


`define code_nop 6'b111111

//译码前后不同指令的操作码，注意op或code中不同指令的字段不可相同
//I型指令

`define op_lui 6'b000000
`define op_beq 6'b000001
`define op_bne 6'b000010

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

//J型指令
`define op_j   6'b001100
`define op_jal 6'b001101

//load-store型指令
`define op_lw 6'b001110
`define op_sw 6'b001111

`define op_nop 6'b111111