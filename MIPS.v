`include "def.v"
`include "IF.v"
`include "ID.v"
`include "EX.v"
`include "RegFile.v"
`include "MEM.v"
`include "CP0.v"
`include "Ctrl.v"

module MIPS(
    input wire clk,
    input wire rst,
    input wire[31:0] code,
    input wire[31:0] data_DataMem,

    output wire romCe_IF,
    output wire[31:0] codeAddr_IF,

    output wire[31:0] memAddr_MEM,
    output wire[31:0] memwriteData_MEM,
    output wire memWrite_MEM,
    output wire memCe_MEM,
    input wire[5:0] intr,     //?????????
    output wire intimer     //?????????
);

    wire[31:0] regaData_RegFile;
    wire[31:0] regbData_RegFile;

    wire[5:0] op_ID;
    wire[31:0] regaData_ID;
    wire[31:0] regbData_ID;
    wire regcWrite_ID;
    wire[4:0] regcAddr_ID;
    wire regaRead_ID;
    wire[4:0] regaAddr_ID;
    wire regbRead_ID;
    wire[4:0] regbAddr_ID;
    wire[31:0] jAddr_ID;
    wire jCe_ID;

    wire[31:0] regcData_EX;
    wire[4:0] regcAddr_EX;
    wire regcWrite_EX;
    wire[5:0] op_EX;
    wire[31:0] memAddr_EX;
    wire[31:0] memData_EX;
    wire whi_EX;
    wire wlo_EX;
    wire[31:0] wHiData_EX;
    wire[31:0] wLoData_EX;

    wire[31:0] regData_MEM;
    wire[4:0] regAddr_MEM;
    wire regWrite_MEM;


    wire[31:0] rHiData_HiLo;
    wire[31:0] rLoData_HiLo;
	
    wire wbit_MEM;
    wire wLLbit_MEM;
    wire rLLbit_LLbit;

    wire cp0we;
    wire[4:0] cp0Addr;
    wire[31:0] cp0wData;
    wire[31:0] cp0rData;
    wire[31:0] epc_ex , ejpc;
    wire[31:0] excptype_id,excptype_ex;
    wire[31:0] cause, status;
    wire[31:0] pc_id, pc_ex;

    IF if0(
        .clk(clk),
        .rst(rst),
        .romCe(romCe_IF),
        .pc(codeAddr_IF),
        .jAddr(jAddr_ID),
        .jCe(jCe_ID),
        .ejpc(ejpc),      //?????????
        .excpt(excpt)     //???????
    );

    ID id0(
        .rst(rst),
        //.pc(codeAddr_IF),
        .pc_i(codeAddr_IF),        //pc?????
        .jAddr(jAddr_ID),
        .jCe(jCe_ID),
        .code(code),
        .regaData_i(regaData_RegFile),
        .regbData_i(regbData_RegFile),
        .op(op_ID),
        .regaData(regaData_ID),
        .regbData(regbData_ID),
        .regcWrite(regcWrite_ID),
        .regcAddr(regcAddr_ID),
        .regaRead(regaRead_ID),
        .regaAddr(regaAddr_ID),
        .regbAddr(regbAddr_ID),
        .regbRead(regbRead_ID),
        .pc(pc_id),             //pc?????
        .excptype(excptype_id)  //??????????
    );

    EX ex0(
        .rst(rst),
        .op_i(op_ID),
        .regaData(regaData_ID),
        .regbData(regbData_ID),
        .regcAddr_i(regcAddr_ID),
        .regcWrite_i(regcWrite_ID),
        .rHiData(rHiData_HiLo),
        .rLoData(rLoData_HiLo),
        .regcData(regcData_EX),
        .regcAddr(regcAddr_EX),
        .regcWrite(regcWrite_EX),
        .op(op_EX),
        .memAddr(memAddr_EX),
        .memData(memData_EX),
        .whi(whi_EX),
        .wlo(wlo_EX),
        .wHiData(wHiData_EX),
        .wLoData(wLoData_EX),
        .cp0we(cp0we),         //CP0????
        .cp0Addr(cp0Addr),      //CP0?????
        .cp0wData(cp0wData),    //CP0?????
        .cp0rData(cp0rData),//CP0?????
        .pc_i(pc_id),             //pc????
        .excptype_i(excptype_id),//?????????????
        .excptype(excptype_ex),    //?????????????
        .epc(epc_ex),             //epc????
        .pc(pc_ex),              //pc????
        .cause(cause),            //cause????
        .status(status)            //status????
    );
    
    HiLo hilo0(
        .rst(rst),
        .clk(clk),
        .wHiData(wHiData_EX),
        .wLoData(wLoData_EX),
        .whi(whi_EX),
        .wlo(wlo_EX),
        .rHiData(rHiData_HiLo),
        .rLoData(rLoData_HiLo)
	);
	
    MEM mem0(
        .rst(rst),
        .op(op_EX),
        .regcData(regcData_EX),
        .regcAddr(regcAddr_EX),
        .regcWrite(regcWrite_EX),
        
        .regData(regData_MEM),
        .regAddr(regAddr_MEM),
        .regWrite(regWrite_MEM),

        .memAddr_i(memAddr_EX),
        .memData_i(memData_EX),
        .memreadData(data_DataMem),

        .memAddr(memAddr_MEM),
        .memwriteData(memwriteData_MEM),
        .memWrite(memWrite_MEM),
        .memCe(memCe_MEM),
        .rLLbit(rLLbit_LLbit),
        .wLLbit(wLLbit_MEM),
        .wbit(wbit_MEM)
    );

    LLbit llbit0(
        .clk(clk),
        .rst(rst),
        .excpt(excpt_LLbit),
        .wbit(wbit_MEM),
        .wLLbit(wLLbit_MEM),
        .rLLbit(rLLbit_LLbit)
    );


    RegFile regfile0(
        .clk(clk),
        .rst(rst),
        
        .regaAddr(regaAddr_ID),
        .regaRead(regaRead_ID),
        .regaData(regaData_RegFile),
        
        .regbAddr(regbAddr_ID),
        .regbRead(regbRead_ID),
        .regbData(regbData_RegFile),

        .write(regWrite_MEM),
        .writeAddr(regAddr_MEM),
        .writeData(regData_MEM)
    );

    CP0 cp0(                //?????
        .clk(clk),
        .rst(rst),
        .cp0we(cp0we),
        .cp0wData(cp0wData),
        .cp0Addr(cp0Addr),
        .cp0rData(cp0rData),
        .intr(intr),
        .intimer(intimer),
        .pc(pc_ex),
        .excptype(excptype_ex),
        .cause(cause),
        .status(status)
    );
    Ctrl ctrl0(               //?????
        .rst(rst),
        .ejpc(ejpc),
        .excpt(excpt),
        .excptype(excptype_ex),
        .epc(epc_ex)
    );
    
endmodule