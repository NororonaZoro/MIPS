`include "def.v"
`include "MIPS.v"
`include "InstMem.v"
`include "DataMem.v"

module SoC(
    input wire clk,
    input wire rst
);
    wire[31:0] romCe_MIPS;
    wire[31:0] codeAddr_MIPS;

    wire[31:0] memAddr_MIPS;
    wire[31:0] memwriteData_MIPS;
    wire memWrite_MIPS;
    wire memCe_MIPS;

    wire[31:0] data_InstMem;
    wire[31:0] data_DataMem;

    wire[5:0] intr;
    wire intimer;

    assign intr = {5'b0, intimer};


    InstMem instmem0(
        .ce(romCe_MIPS),
        .addr(codeAddr_MIPS),
        .data(data_InstMem)
    );

    DataMem datamem0(
        .clk(clk),
        .ce(memCe_MIPS),
        .we(memWrite_MIPS),
        .addr(memAddr_MIPS),
        .dataIn(memwriteData_MIPS),
        .dataOut(data_DataMem)
    );

    MIPS mips0(
        .clk(clk),
        .rst(rst),
        .code(data_InstMem),
        .data_DataMem(data_DataMem),

        .romCe_IF(romCe_MIPS),
        .codeAddr_IF(codeAddr_MIPS),
        .memAddr_MEM(memAddr_MIPS),
        .memwriteData_MEM(memwriteData_MIPS),
        .memWrite_MEM(memWrite_MIPS),
        .memCe_MEM(memCe_MIPS),
        .intr(intr),
        .intimer(intimer)
    );
endmodule

module SoC_tb;
    reg clk,rst;
    SoC soc0(clk,rst);

    initial
    begin
        clk <= 0;
        rst <= `RST_ENABLE;
    #100 rst <= `RST_DISABLE;
    #1200 $stop;
    end

    always #10 clk <= ~clk;
endmodule