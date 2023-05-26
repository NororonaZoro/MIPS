`include "def.v"

module RegFile(
    input wire clk, //时钟信号，来自MIPS CPU
    input wire rst, //复位信号，来自MIPS CPU
    input wire[4:0] regaAddr, //源寄存器A地址，来自ID
    input wire regaRead, //源寄存器A读使能，来自ID，似乎没啥用
    output reg[31:0] regaData, //源寄存器A数据，流入ID

    input wire[4:0] regbAddr, //源寄存器B地址，来自ID
    input wire regbRead, //源寄存器B读使能，来自ID，似乎没用
    output reg[31:0] regbData, //源寄存器B数据，流入ID

    input wire[4:0] writeAddr, //写入地址,来自EX
    input wire write, //写使能，来自EX
    input wire[31:0] writeData //写数据，来自EX
);
    reg[31:0] reg32[31:0]; //32个32位寄存器

    //组合逻辑语句块，根据rst与地址控制读取寄存器A
    always @(*)
    begin
        if(rst == `RST_ENABLE)
            regaData <= `ZERO;

        //注意：MIPS中R0始终为0且只读
        else if(regaAddr == `ZERO) 
            regaData <= `ZERO;
        else
            regaData <= reg32[regaAddr];
    end

    //组合逻辑语句块，根据rst与地址控制读取寄存器B
    always @(*)
    begin
        if(rst == `RST_ENABLE)
            regbData <= `ZERO;
        //注意：MIPS中R0始终为0且只读
        else if(regbAddr == `ZERO) 
            regbData <= `ZERO;
        else
            regbData <= reg32[regbAddr];
    end

    //时序逻辑语句块，根据clk,rst,写信号，写地址及数据控制写入
    always@(posedge clk)
    begin
        if(rst == `RST_DISABLE)
        begin
            //注意：MIPS中R0始终为0且只读
            if(write == `VALID && writeAddr != `ZERO)
                reg32[writeAddr] <= writeData;
            else; //防止下板时出现锁存器
        end
        else;
    end

    //为方便系统测试，加入初始化0的操作
    initial
    begin
        reg32[0] <= 32'b0;
        reg32[1] <= 32'b0;
        reg32[2] <= 32'b0;
        reg32[3] <= 32'b0;
        reg32[4] <= 32'b0;
        reg32[5] <= 32'b0;
        reg32[6] <= 32'b0;
        reg32[7] <= 32'b0;
        reg32[8] <= 32'b0;
        reg32[9] <= 32'b0;
        reg32[10] <= 32'b0;
        reg32[11] <= 32'b0;
        reg32[12] <= 32'b0;
        reg32[13] <= 32'b0;
        reg32[14] <= 32'b0;
        reg32[15] <= 32'b0;
        reg32[16] <= 32'b0;
        reg32[17] <= 32'b0;
        reg32[18] <= 32'b0;
        reg32[19] <= 32'b0;
        reg32[20] <= 32'b0;
        reg32[21] <= 32'b0;
        reg32[22] <= 32'b0;
        reg32[23] <= 32'b0;
        reg32[24] <= 32'b0;
        reg32[25] <= 32'b0;
        reg32[26] <= 32'b0;
        reg32[27] <= 32'b0;
        reg32[28] <= 32'b0;
        reg32[29] <= 32'b0;
        reg32[30] <= 32'b0;
        reg32[31] <= 32'b0;
    end
    
endmodule

//独立测试模块
module RegFile_tb;
    reg clk,rst;
    reg[4:0] regaAddr,regbAddr,writeAddr;
    reg regaRead,regbRead,write;
    wire[31:0] regaData,regbData;
    reg[31:0] writeData;

    RegFile U1(
        clk,
        rst,
        regaAddr,
        regaRead,
        regaData,
        regbAddr,
        regbRead,
        regbData,
        writeAddr,
        write,
        writeData
        );

    initial
    begin
        clk <= 0;rst <= `RST_ENABLE;
    #4  rst <= `RST_DISABLE;
        writeAddr <= 5'd10;
        write <= `VALID;
        writeData <= 32'hFFFF0000;

    #2  writeAddr <= 5'd8;
        write <= `VALID;
        writeData <= 32'hFFFFFFFF;

    #2  write <= `INVALID;
        regaAddr <= 5'd10;
        regbAddr <= 5'd8;
    
    #2  regaAddr <= 0;

    #2 rst <= `RST_ENABLE;

    #5 $stop;
    end

    always #1 clk <= ~clk;
endmodule