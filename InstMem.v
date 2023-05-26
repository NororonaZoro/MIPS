`include "def.v"

/*
    指令只读存储器ROM
*/
module InstMem(
    input wire ce, //读使能信号，来自IF的romCe
    input wire[31:0] addr, //读地址信号，来自IF的PC
    output reg[31:0] data //读取的指令，流入IF
);
    //1024个32位寄存器
    reg[31:0] ROM[1023:0]; 

    //组合逻辑语句块，按字读取指令
    always@(*)
    begin
        if(ce == `ROMCE_ENABLE)
            data <= ROM[addr[11:2]];
        else
            data <= 32'b0;
    end

    //ROM中预先存储的指令字
    initial
    begin
/*        ROM[0] <= 32'h3463000a;
        ROM[1] <= 32'h34840001;
        ROM[2] <= 32'h34210000;
        ROM[3] <= 32'h0c000006;
        ROM[4] <= 32'h8c060004;
        ROM[5] <= 32'h00000000;
        ROM[6] <= 32'h00441020;
        ROM[7] <= 32'h20840001;
        ROM[8] <= 32'hac220000;
        ROM[9] <= 32'h20210004;
        ROM[10] <= 32'h1483fffb;
        ROM[11] <= 32'h03e00008;
*/
        ROM[0] <= 32'h34011100;
        ROM[1] <= 32'h34020020;
        ROM[2] <= 32'b00000_00010_00000_00000_00000_011001;
        ROM[3] <= 32'h3403ffff;
        ROM[4] <= 32'b00000_00000_00011_00011_10000_000000;
        ROM[5] <= 32'b00000_00011_00010_00000_00000_011000;
        ROM[6] <= 32'b00000_00001_00010_00000_00000_011011;
        ROM[7] <= 32'b00000_00011_00010_00000_00000_011010;

    end
endmodule

//独立测试模块
module InstMem_tb;
    reg ce;
    reg[31:0] addr;
    wire[31:0] data;

    InstMem U1(ce,addr,data);

    initial
    begin
        addr <= 32'b0;
        ce <= `RST_ENABLE;

    #10 ce <= `RST_DISABLE;
    #5  $stop;
    end

    always #1 addr <= addr + 4;

endmodule