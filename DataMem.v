`include "def.v"

module DataMem(
    input wire clk,
    input wire ce,
    input wire we,
    input wire[31:0] addr,
    input wire[31:0] dataIn,
    output reg[31:0] dataOut
);
    reg[31:0] RAM[1023:0];
    
    always @(*) //读取load
    begin
        if(ce == `INVALID) dataOut <= `ZERO;
        else dataOut <= RAM[addr[11:2]];
    end

    always @(posedge clk) //存储写入 store
    begin
        if(we == `VALID && ce == `VALID)
        RAM[addr[11:2]] <= dataIn;
        else;//防止下板时出现锁存器
    end
endmodule

module DataMem_tb;
    reg clk,ce,we;
    reg[31:0] addr,dataIn;
    wire[31:0] dataOut;

    DataMem U1(clk,ce,we,addr,dataIn,dataOut);

    initial
    begin
        clk <= 0;ce <= 1;we <= 1;dataIn <= 32'hFFFF;addr <= 8;
        #2 we <= 0;
        #2 $stop;
    end
    
    always #1 clk <= ~clk;
endmodule