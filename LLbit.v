`include "def.v"
module LLbit(
    input wire clk,
    input wire rst,
    input wire excpt,
    input wire wbit,
    input wire wLLbit,
    output reg rLLbit
);
    reg LLbit;
    always@(posedge clk) //????
      begin
	if(rst == `RST_ENABLE || excpt == `VALID)
	    LLbit <= `INVALID;
	else if(wbit == `VALID)
	    LLbit <= wLLbit;
      end
    always@(*) //????
      rLLbit <= LLbit;
endmodule

	