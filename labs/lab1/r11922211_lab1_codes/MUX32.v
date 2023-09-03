module MUX32(ALUSrc, rs2, immd, out);

input ALUSrc;
input [31:0] rs2, immd;
output [31:0] out;

assign out = (ALUSrc == 1'b0) ? rs2 : immd;

endmodule
