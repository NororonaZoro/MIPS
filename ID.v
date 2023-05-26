`include "def.v"

module ID(
    input wire rst, //复位信号，来自MIPS CPU
    input wire[31:0] pc, //程序计数器，来自IF模块
    input wire[31:0] code, //32位指令字，来自指令ROM
    input wire[31:0] regaData_i, //源操作数1，来自寄存器组
    input wire[31:0] regbData_i, //源操作数2，来自寄存器组
    
    output reg[31:0] jAddr, //跳转地址，传给IF
    output reg jCe, //跳转使能信号，传给IF
    output reg[5:0] op, //译码后操作码
    output reg[31:0] regaData, //译码后源操作数1 寄存器 or 立即数
    output reg[31:0] regbData, //译码后源操作数2 寄存器 or 立即数
    output reg[4:0] regcAddr, //译码后目的操作寄存器地址
    output reg regcWrite, //译码后目的寄存器写入使能信号 根据指令功能
    output reg[4:0] regaAddr, //译码后源操作数1的寄存器地址
    output reg regaRead, //译码后操作数1的寄存器读信号 选择立即数 or 寄存器
    output reg[4:0] regbAddr, //译码后源操作数2的寄存器地址
    output reg regbRead //译码后操作数2的寄存器读信号 选择立即数 or 寄存器
    
);
    wire[5:0] code_op; //指令中的操作码[31:26]，与译码后操作码不同
    wire[5:0] func; //指令中第二操作码[5:0],主要用于R型指令
    reg[31:0] imm; //指令中提取的立即数
    wire[31:0] npc; //下一条指令的地址 pc + 4,主要用于jal指令

    assign code_op = code[31:26];
    assign func = code[5:0];
    assign npc = pc + 4;
    //组合逻辑语句块，根据rst与指令操作码确定：1.寄存器读信号 立即数 or 寄存器 2.目的操作数是否需要写回，及写回地址
    always@(*) 
    begin
        //复位信号有效
        if(rst == `RST_ENABLE) 
        begin
            op <= `op_nop;
            regaRead <= `INVALID;
            regbRead <= `INVALID;
            regcWrite <= `INVALID;
            regaAddr <= `ZERO;
            regbAddr <= `ZERO;
            regcAddr <= `ZERO;
            imm <= `ZERO;
            jCe <= `INVALID;
            jAddr <= `ZERO;
        end
        else
        begin
            //先假设不跳转，清除使能和地址
            jCe <= `INVALID;
            jAddr <= `ZERO;

            case(code_op)
            `code_ori: //ori指令，源a为寄存器，b为立即数，需要写入到目的寄存器
            begin
                op <= `op_or;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= code[25:21];
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= {16'h0,code[15:0]};
            end
            
            `code_xori: //xori指令，源a为寄存器，b为立即数，需要写入到目的寄存器
            begin
                op <= `op_xor;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= code[25:21];
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= {16'h0,code[15:0]};
            end
            
            `code_addi: //addi指令，源a为寄存器，b为立即数，需要写入到目的寄存器
            begin
                op <= `op_add;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= code[25:21];
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= {16'h0,code[15:0]};
            end

            `code_andi://andi指令，源a为寄存器，b为立即数，需要写入到目的寄存器
            begin
                op <= `op_and;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= code[25:21];
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= {16'h0,code[15:0]};
            end
            
            `code_lui: //lui指令，源a为立即数，无需源b，需要写入到目的寄存器
            begin
                op <= `op_lui;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= `ZERO;
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= {16'h0,code[15:0]};
            end

            `code_r: //R型指令[31:26]均为0
            begin
                    case(func)
                    `code_add: //add指令，a为rs,b为rt,c为rd
                    begin
                        op <= `op_add;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO;
                    end
                    
                    `code_sub: //sub指令，a为rs,b为rt,c为rd,rd = rs - rt
                    begin
                        op <= `op_sub;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO; 
                    end
                    
                    `code_and: //and指令，a为rs,b为rt,c为rd,rd = rs & rt
                    begin
                        op <= `op_and;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO; 
                    end
                    
                    `code_or: //or指令，a为rs,b为rt,c为rd,rd = rs | rt
                    begin
                        op <= `op_or;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO; 
                    end
                    
                    `code_xor: //xor指令，a为rs,b为rt,c为rd,rd = rs ^ rt
                    begin
                        op <= `op_xor;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO; 
                    end
                    
                    `code_sll: //sll指令，a为rt，b为sa，c为rd，rd = rt ^ sa
                    begin
                        op <= `op_sll;
                        regaRead <= `VALID; 
                        regbRead <= `INVALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[20:16];
                        regbAddr <= `ZERO;
                        regcAddr <= code[15:11];
                        imm <= code[10:6];
                    end
                    
                    `code_srl: //srl指令，a为rt，b为sa，c为rd，rd = rt ^ sa
                    begin
                        op <= `op_srl;
                        regaRead <= `VALID; 
                        regbRead <= `INVALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[20:16];
                        regbAddr <= `ZERO;
                        regcAddr <= code[15:11];
                        imm <= code[10:6];
                    end
                    
                    `code_sra: //sla指令，a为rt，b为sa，c为rd，rd = rt ^ sa
                    begin
                        op <= `op_sra;
                        regaRead <= `VALID; 
                        regbRead <= `INVALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[20:16];
                        regbAddr <= `ZERO;
                        regcAddr <= code[15:11];
                        imm <= code[10:6];
                    end
					
                     `code_jr:
                    begin
                        op <= `op_jr;
                        regaRead <= `VALID;
                        regbRead <= `INVALID;
                        regcWrite <= `INVALID;
                        regaAddr <= code[25:21];
                        regbAddr <= `ZERO;
                        regcAddr <= `ZERO;
                        jAddr <= regaData[31:0];
                        jCe <= `VALID;
                    end

                     `code_jalr:
                    begin
                        op <= `op_jalr;
                        regaRead <= `VALID;
                        regbRead <= `INVALID;
                        regcWrite <= `VALID;
                        regaAddr <= `ZERO;
                        regbAddr <= `ZERO;
                        regcAddr <= 5'b11111;
                        jAddr <= regaData[31:0];
                        jCe <= `VALID;
                        imm <= npc;
                    end
					
                     `code_mult: //mult指令，a为rs,b为rt,c为rd, {hi,lo} = rs * rt
                    begin
                        op <= `op_mult;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `INVALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= `ZERO;
                        imm <= `ZERO; 
                    end
					
                     `code_multu: //multu指令，a为rs,b为rt,c为rd, {hi,lo} = rs * rt
                    begin
                        op <= `op_multu;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `INVALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= `ZERO;
                        imm <= `ZERO; 
                    end
					
                     `code_div: //div指令，a为rs,b为rt,c为rd, {hi,lo} = rs / rt
                    begin
                        op <= `op_divu;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `INVALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= `ZERO;
                        imm <= `ZERO; 
                    end
					
                     `code_divu: //divu指令，a为rs,b为rt,c为rd, {hi,lo} = rs / rt
                    begin
                        op <= `op_mult;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `INVALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= `ZERO;
                        imm <= `ZERO; 
                    end

                     `code_slt:
                    begin
                        op <= `op_slt;
                        regaRead <= `VALID;
                        regbRead <= `VALID;
                        regcWrite <= `VALID;
                        regaAddr <= code[25:21];
                        regbAddr <= code[20:16];
                        regcAddr <= code[15:11];
                        imm <= `ZERO; 
                    end
					
                    default:
                    begin
                        op <= `op_nop;
                        regaRead <= `INVALID;
                        regbRead <= `INVALID;
                        regcWrite <= `INVALID;
                        regaAddr <= `ZERO;
                        regbAddr <= `ZERO;
                        regcAddr <= `ZERO;
                        imm <= `ZERO;
                    end
                    endcase
            end

            //J型
            `code_jal:
            begin
                op = `op_jal;
                regaRead <= `INVALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= `ZERO;
                regbAddr <= `ZERO;
                regcAddr <= 5'b11111;
                jAddr <= {npc[31:28],code[25:0],2'b00};
                jCe <= `VALID;
                imm <= npc;
            end

            `code_j:
            begin
                op <= `op_j;
                regaRead <= `INVALID;
                regbRead <= `INVALID;
                regcWrite <= `INVALID;
                regaAddr <= `ZERO;
                regbAddr <= `ZERO;
                regcAddr <= `ZERO;
                jAddr <= {npc[31:28],code[25:0],2'b00};
                jCe <= `VALID;
            end

            `code_beq: //beq指令，源a、b为寄存器,[15:0]为转移地址，无需写寄存器
            begin
                op <= `op_beq;
                regaRead <= `VALID;
                regbRead <= `VALID;
                regcWrite <= `INVALID;
                regaAddr <= code[25:21];
                regbAddr <= code[20:16];
                regcAddr <= `ZERO;
                if(regaData == regbData)
                begin
                    jAddr <= npc + { {14{code[15]}},code[15:0],2'b00};
                    jCe <= `VALID;
                end
            end

            `code_bne: //bne指令，源a、b为寄存器,[15:0]为转移地址，无需写寄存器
            begin
                op <= `op_bne;
                regaRead <= `VALID;
                regbRead <= `VALID;
                regcWrite <= `INVALID;
                regaAddr <= code[25:21];
                regbAddr <= code[20:16];
                regcAddr <= `ZERO;
                if(regaData != regbData)
                begin
                    jAddr <= npc + { {14{code[15]} },code[15:0],2'b00};
                    jCe <= `VALID;
                end
            end

            `code_bgtz:
            begin
                op <= `op_bgtz;
                regaRead <= `VALID;
                regbRead <= `VALID;
                regcWrite <= `INVALID;
                regaAddr <= code[25:21];
                regbAddr <= code[20:16];
                regcAddr <= `ZERO;
                if(regaData > regbData)
                begin
                    jAddr <= npc + { {14{code[15]} },code[15:0],2'b00};
                    jCe <= `VALID;
                end
            end

            `code_bltz:
            begin
                op <= `op_bltz;
                regaRead <= `VALID;
                regbRead <= `VALID;
                regcWrite <= `INVALID;
                regaAddr <= code[25:21];
                regbAddr <= code[20:16];
                regcAddr <= `ZERO;
                if(regaData < regbData)
                begin
                    jAddr <= npc + { {14{code[15]} },code[15:0],2'b00};
                    jCe <= `VALID;
                end
            end

            `code_lw: //lw指令，源a寄存器值为指令[25:21]中基址，指令中[15:0]为内存偏移地址，作为立即数，需要写入寄存器
            begin
                op <= `op_lw;
                regaRead <= `VALID;
                regbRead <= `INVALID;
                regcWrite <= `VALID;
                regaAddr <= code[25:21];
                regbAddr <= `ZERO;
                regcAddr <= code[20:16];
                imm <= { {16{code[15]} },code[15:0]};
            end
            
            `code_sw: //sw指令，源a寄存器值为指令[25:21]中基址,源b为取数据的寄存器，指令中[15:0]为内存偏移地址，作为立即数，无需写入寄存器
            begin
                op <= `op_sw;
                regaRead <= `VALID;
                regbRead <= `VALID;
                regcWrite <= `INVALID;
                regaAddr <= code[25:21];
                regbAddr <= code[20:16];
                regcAddr <= `ZERO;
                imm <= { {16{code[15]} },code[15:0]};
            end

            default:
            begin
                op <= `op_nop;
                regaRead <= `INVALID;
                regbRead <= `INVALID;
                regcWrite <= `INVALID;
                regaAddr <= `ZERO;
                regbAddr <= `ZERO;
                regcAddr <= `ZERO;
                imm <= `ZERO;
            end
        endcase
        end
    end

    

    //组合逻辑语句块，根据rst、源操作数A的read信号来完成寄存器 or 立即数的赋值 or 读写内存的地址计算
    always@(*)
    begin
        if(rst == `RST_ENABLE)
            regaData <= `ZERO;
        else if(op == `op_lw || op == `op_sw)
            regaData <= regaData_i + imm;//从寄存器值得到的基地址+偏移地址
        else if(regaRead == `VALID)
            regaData <= regaData_i;
        else
            regaData <= imm;
    end

    //组合逻辑语句块，根据rst、源操作数B的read信号来完成寄存器 or 立即数的赋值
    always@(*)
    begin
        if(rst == `RST_ENABLE)
            regbData <= `ZERO;
        else if(regbRead == `VALID)
            regbData <= regbData_i;
        else
            regbData <= imm;
    end

endmodule

//独立测试模块
module ID_tb;
    reg rst;
    reg[31:0] code,regaData_i,regbData_i;
    wire[4:0] op,regaAddr,regbAddr,regcAddr;
    wire[31:0] regaData,regbData;
    wire regcWrite,regaRead,regbRead;

    ID U2(
        rst,
        code,
        regaData_i,
        regbData_i,
        op,
        regaData,
        regbData,
        regcAddr,
        regcWrite,
        regaAddr,
        regaRead,
        regbAddr,
        regbRead
        );

    initial
    begin
        rst <= `RST_ENABLE;
    #5  rst <= `RST_DISABLE;
        code <= 32'h3443FFFF;//ori R3,R2,#FFFF
        regaData_i <= 32'hFF0F00FF;
        regbData_i <= 0;
    #5 rst <= `RST_ENABLE;
    $stop;
    end
endmodule