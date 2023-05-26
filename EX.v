`include "def.v"


module EX(
    input wire rst, //复位信号，来自MIPS CPU
    input wire[5:0] op_i, //译码后操作码，来自ID
    input wire[31:0] regaData, //译码后源操作数A，来自ID
    input wire[31:0] regbData, //译码后源操作数B，来自ID
    input wire[4:0] regcAddr_i, //译码后写入的寄存器地址，来自ID
    input wire regcWrite_i, //译码后写入使能信号，来自ID

    output reg[31:0] regcData, //执行/运算后目的操作数C(结果)，流入寄存器组
    output wire[4:0] regcAddr, //执行后写入的地址，流入寄存器组
    output wire regcWrite, //执行后写使能信号，控制写入寄存器组
    output wire[5:0] op, //判断读写寄存器or内存，传给访存模块
    output wire[31:0] memAddr,//访存地址，传给访存模块
    output wire[31:0] memData //访存数据，传给访存模块
);

    assign op = op_i;
    assign memAddr = regaData;
    assign memData = regbData;

    //组合逻辑语句块，根据rst和op操作码执行指令
    always @(*)
    begin
        if(rst == `RST_ENABLE)
            regcData <= `ZERO;
        else
        begin
            case(op_i)
            //I型
            `op_or:
                regcData <= regaData | regbData;
            
            `op_xor:
                regcData <= regaData ^ regbData;
            
            `op_add:
                regcData <= regaData + regbData;
            
            `op_and:
                regcData <= regaData & regbData;
            
            `op_lui:
                regcData <= regbData << 16;


            //R型
            `op_sub:
                regcData <= regaData - regbData;
            
            `op_sll:
                regcData <= regaData << regbData;
            
            `op_srl:
                regcData <= regaData >> regbData;

            `op_sra:
                regcData <= ($signed(regaData)) >>> regbData;
            
            //J型
            `op_jal:
                regcData <= regaData;
            default:
                regcData <= `ZERO;
            endcase
        end
    end

    //写信号与地址采用透传直连
    assign regcWrite = regcWrite_i;
    assign regcAddr = regcAddr_i;
endmodule

//测试模块
module EX_tb;
    reg rst;
    reg[5:0] op;
    reg[31:0] regaData;
    reg[31:0] regbData;
    reg[4:0] regcAddr_i;
    reg regcWrite_i;

    wire[31:0] regcData;
    wire[4:0] regcAddr;
    wire regcWrite;
    EX U3(rst,op,regaData,regbData,regcAddr_i,regcWrite_i,regcData,regcAddr,regcWrite);
    
    initial
    begin

    #10 $stop;
    end
endmodule
