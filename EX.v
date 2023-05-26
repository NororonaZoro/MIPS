`include "def.v"

module EX(
    input wire rst, //复位信号，来自MIPS CPU
    input wire[5:0] op_i, //译码后操作码，来自ID
    input wire[31:0] regaData, //译码后源操作数A，来自ID
    input wire[31:0] regbData, //译码后源操作数B，来自ID
    input wire[4:0] regcAddr_i, //译码后写入的寄存器地址，来自ID
    input wire regcWrite_i, //译码后写入使能信号，来自ID

    input wire[31:0] rHiData,
    input wire[31:0] rLoData,

    output reg[31:0] regcData, //执行/运算后目的操作数C(结果)，流入寄存器组
    output wire[4:0] regcAddr, //执行后写入的地址，流入寄存器组
    output wire regcWrite, //执行后写使能信号，控制写入寄存器组
    output wire[5:0] op, //判断读写寄存器or内存，传给访存模块
    output wire[31:0] memAddr,//访存地址，传给访存模块
    output wire[31:0] memData, //访存数据，传给访存模块
	
    output reg whi,
    output reg wlo,
    output reg[31:0] wHiData,
    output reg[31:0] wLoData,

    output reg cp0we, //cp0???????
    output reg[4:0] cp0Addr, //cp0????????
    output reg[31:0] cp0wData, //cp0????????
    input wire[31:0] cp0rData, //cp0????????
    input wire[31:0] pc_i, //??????
    input wire[31:0] excptype_i, //
    output reg[31:0] excptype,
    output wire[31:0] epc,
    output wire[31:0] pc,
    input wire[31:0] cause,
    input wire[31:0] status
);

    assign op = op_i;
    assign memAddr = regaData;
    assign memData = regbData;

    assign pc = pc_i;
    assign op = (excptype == `ZERO) ? op_i : `op_nop;
    assign regcWrite = (excptype == `ZERO) ? regcWrite_i : `INVALID;
    //组合逻辑语句块，根据rst和op操作码执行指令
    always @(*)
    begin
        if(rst == `RST_ENABLE)
          begin
            regcData <= `ZERO;
            cp0we <= `INVALID;
            cp0wData <= `ZERO;
            cp0Addr <= `CP0_EPC;
          end
        else
          begin
            regcData <= `ZERO;
            cp0we <= `INVALID;
            cp0wData <= `ZERO;
            cp0Addr <= `CP0_EPC;
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
				
	    //乘法除法
            `op_mult:
                begin
                 whi <= `VALID;
                 wlo <= `VALID;
                 {wHiData,wLoData} <= $signed(regaData) * $signed(regbData);
                end
			
            `op_multu:
                begin
                 whi <= `VALID;
                 wlo <= `VALID;
                 {wHiData,wLoData} <= regaData * regbData;
                end
				
            `op_div:
                begin
                 whi <= `VALID;
                 wlo <= `VALID;
                 wHiData <= $signed(regaData) % $signed(regbData);
                 wLoData <= $signed(regaData) / $signed(regbData);
                end
				
            `op_divu:
                begin
                 whi <= `VALID;
                 wlo <= `VALID;
                 wHiData <= regaData % regbData;
                 wLoData <= regaData / regbData;
                end

            `op_slt:
                begin
                 if(regaData < regbData) regcData <= 1;
                 else regcData <= `ZERO;
                end

            `op_mfhi:
                regcData <= rHiData;

            `op_mflo:
                regcData <= rLoData;

            `op_mthi:
                wHiData <= regaData;

            `op_mtlo:
                wLoData <= regaData;

            `op_mfc0:
               begin
                cp0Addr <= regaData[4:0];
                regcData <= cp0rData;
               end

            `op_mtc0:
               begin
                regcData <= `ZERO;
                cp0we <= `VALID;
                cp0Addr <= regaData[4:0];
                cp0wData <= regbData;
               end

            default:
                regcData <= `ZERO;
            endcase
        end
    end

    /*??????????????*/
    assign epc = (excptype == 32'h0000_0200) ? cp0rData : `ZERO;
    always@(*)
      if(rst == `RST_ENABLE)
         excptype = `ZERO;
      //Cause's IP[2] Status's IM[2]; Status EXL, IE
      else if(cause[10]&& status[10] == 1'b1 && status[1:0] == 2'b01)  
         //timerInt
         excptype = 32'h0000_0004;
      else if(excptype_i[8] == 1'b1 && status[1] == 1'b0)
         //Syscall
         excptype = 32'h00000100;
      else if(excptype_i[9] == 1'b1)
         //Eret
         excptype = 32'h0000_0200;
      else
         excptype = `ZERO;

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
