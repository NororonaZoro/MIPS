`include "def.v"

module IF(
    input wire clk, //时钟信号
    input wire rst, //复位信号，来自MIPS CPU
    input wire[31:0] jAddr, //转移地址，来自ID
    input wire jCe, //转移使能信号，来自ID
    output reg romCe,//指令存储器读使能信号
    output reg[31:0] pc //程序计数器，传给指令ROM
);

    //该语句块为组合逻辑，根据rst只控制romCe
    always@(*) 
    begin
        if(rst == `RST_ENABLE)
        begin
            romCe <= `ROMCE_DISABLE;
        end
        else
            romCe <= `ROMCE_ENABLE;
    end

    //该语句块为时序逻辑，根据rst在每个时钟上升沿控制PC自增
    always@(posedge clk) 
    begin
        if(romCe == `ROMCE_DISABLE)
            pc <= `ZERO;
        else if(jCe == `VALID)
            pc <= jAddr;
        else
            pc <= pc + 4;
    end

endmodule

//独立测试模块
module IF_tb;
    reg clk,rst;
    wire romCe;
    wire[31:0] pc;

    IF U1(clk,rst,romCe,pc);

    initial
    begin
        clk <= 0;rst <= `RST_ENABLE;
    #5  rst <= `RST_DISABLE;
    #50 rst <= `RST_ENABLE;
    #10 $stop;
    end

    always #1 clk = ~clk;
endmodule