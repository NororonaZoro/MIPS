`include "def.v"

module MEM(
    input wire rst,
    input wire[5:0] op,
    input wire[31:0] regcData,
    input wire[4:0] regcAddr,
    input wire regcWrite,

    output wire[31:0] regData,
    output wire[4:0] regAddr,
    output wire regWrite,
    

    input wire[31:0] memAddr_i,//来自EX
    input wire[31:0] memData_i,

    input wire[31:0] memreadData,//来自Datamem
    output wire[31:0] memAddr,
    output reg[31:0] memwriteData,
    output reg memWrite,
    output reg memCe,

    input wire rLLbit,
    output reg wLLbit,
    output reg wbit
);
    assign regAddr = regcAddr;
    assign regWrite = regcWrite;
    assign memAddr = memAddr_i;
    //透传
    //assign regData = (op == `op_lw || op == `op_ll)?memreadData:regcData;
    //若为load指令，则将赋值从mem读取的数据，否则赋值结果寄存器数据
    assign regData = (op == `op_lw || op == `op_ll) ? memreadData :
                     (op != `op_sc) ? regcData : 
                     (op == `op_sc && rLLbit == `VALID) ? 32'b1 : 32'b0;


    //根据读写指令对内存进行操作
    always @(*)
    begin
        if(rst == `RST_ENABLE)
        begin
            memwriteData <= `ZERO;
            memWrite <= `INVALID;
            memCe <= `INVALID;
        end
        else
        begin
            case(op)
            `op_lw: //读取内存，将读取的数据写入寄存器
            begin
                memwriteData <= `ZERO;
                memWrite <= `INVALID;
                memCe <= `VALID;
            end

            `op_sw: //写入内存，将寄存器数据写入内存
            begin
                memwriteData <= memData_i;
                memWrite <= `VALID;
                memCe <= `VALID;
            end

            `op_ll:
            begin
                memwriteData <= `ZERO;
                memWrite <= `INVALID;
                memCe <= `VALID;
                wbit <= `VALID;
                wLLbit <= `VALID;
            end

            `op_sc:
            begin
                if(rLLbit == `VALID) 
                  begin
                    memwriteData <= memData_i;
                    memWrite <= `VALID;
                    memCe <= `VALID;
		    wbit <= `VALID;
                    wLLbit <= `INVALID;
                  end
                else ;
            end

            default:
            begin
                memwriteData <= `ZERO;
                memWrite <= `INVALID;
                memCe <= `INVALID;
            end
            endcase
        end
    end
    
endmodule