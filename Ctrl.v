`include "def.v"

module Ctrl(
    input wire rst,               //????
    input wire [31:0] excptype,    //?????????
    input wire [31:0] epc,        //??epc?????eret??
    output reg [31:0] ejpc,        //??ejpc??
    output reg excpt
    //?????????
); 
    always@(*)
      if(rst == `RST_ENABLE)
        begin
          excpt = `INVALID;
          ejpc = `ZERO;
        end
      else
        begin
          excpt = `VALID;
          case(excptype)
          //timerInt
          32'h0000_0004:
             ejpc = 32'h00000050;
          //Syscall
          32'h0000_0100:
             ejpc = 32'h00000040;
          //Eret
          32'h0000_0200:
             ejpc = epc;
          default:
             begin
                ejpc = `ZERO;
                excpt = `INVALID;
             end
          endcase
        end
endmodule