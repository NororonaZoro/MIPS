`include "def.v"

module CP0(
    input wire clk,             //????
    input wire rst,              //????
    input wire cp0we,           //CP0???????
    input wire[4:0] cp0Addr,     //CP0????????
    input wire[31:0] cp0wData,   //CP0????????
    output reg[31:0] cp0rData,    //CP0????????
    input wire[5:0] intr,          //??????
    output reg intimer,           //??????
    input wire[31:0] excptype,    //??????????
    input wire[31:0] pc,         //??????
    output wire[31:0] cause,      //???Cause????
    output wire[31:0] status      //???Status????
);
    reg[31:0] Count;
    reg[31:0] Compare;
    reg[31:0] Status;
    reg[31:0] Cause;
    reg[31:0] Epc;   
 
    assign cause = Cause;
    assign status = Status;  
  
    always@(*)
       Cause[15:10] = intr;    
    always@(posedge clk)
       if(rst == `RST_ENABLE)
         begin
           Count = `ZERO;
           Compare = `ZERO;
           Status = 32'h10000000;
           Cause = `ZERO;
           Epc = `ZERO;
           intimer = `INVALID;
         end
       else
         begin
           Count = Count + 1; 
           if(Compare != `ZERO && Count == Compare)
             intimer = `INVALID;
           if(cp0we == `VALID)
             case(cp0Addr)
               `CP0_Count:
                  Count = cp0wData;
               `CP0_Compare:
                  begin
                    Compare = cp0wData;
                    intimer = `INVALID;
                  end
               `CP0_Status:
                    Status = cp0wData;
               `CP0_EPC:
                    Epc = cp0wData;
               `CP0_Cause:
                    begin
                      Cause[9:8] = cp0wData[9:8];
                      Cause[23:22] = cp0wData[23:22];
                    end
               default: ;
             endcase
             case(excptype)
               //timerInt
               32'h0000_0004:
                  begin
                    //interupt instruction
                    Epc = pc;
                    //Status's Exl
                    Status[1] = 1'b1;
                    //Cause's ExcCode
                    Cause[6:2] = 5'b00000;
                  end
               //Syscall
               32'h0000_0100:
                 begin
                    Epc = pc + 4;
                    Status[1] = 1'b1;
                    Cause[6:2] = 5'b01000;
                 end
               //Eret  
               32'h0000_0200:
                    Status[1] = 1'b0;
               default: ;
             endcase
         end 
    always@(*)
      if(rst == `RST_ENABLE)
        cp0rData = `ZERO;
      else
        case(cp0Addr)
          `CP0_Count:
            cp0rData = Count ;
          `CP0_Compare:
            cp0rData = Compare;
          `CP0_Status:
            cp0rData = Status;
          `CP0_EPC:
            cp0rData = Epc;
          `CP0_Cause:
            cp0rData = Cause;
          default: 
            cp0rData = `ZERO;
        endcase
endmodule
