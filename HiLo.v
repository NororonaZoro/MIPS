`include "def.v"

module HiLo(
	input wire rst,
	input wire clk,
	input wire[31:0] wHiData,
	input wire[31:0] wLoData,
	input wire whi,
	input wire wlo,
	output reg[31:0] rHiData,
	output reg[31:0] rLoData
);

	reg[31:0] hi, lo;
	always@ (*)
		if(rst == `RST_ENABLE)
			begin
				rHiData = `ZERO;
				rLoData = `ZERO;
			end
		else
			begin
				rHiData = hi;
				rLoData = lo;
			end
	always@ (posedge clk)
		if(rst == `RST_DISABLE && whi == `VALID)
			hi = wHiData;
		else ;
	always@ (posedge clk)
		if(rst == `RST_DISABLE && wlo == `VALID)
			lo = wLoData;
		else ;
		
endmodule