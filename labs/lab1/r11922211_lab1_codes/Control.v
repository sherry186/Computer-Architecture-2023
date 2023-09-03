module Control(op_code, ALUOP, ALUSrc, RegWrite);

input [6:0] op_code;
output [1:0] ALUOP;
output ALUSrc;
output RegWrite;

assign ALUSrc = (op_code[5] == 1'b1 ? 1'b0 : 1'b1); // 0110011: rs2. 0010011: immd
assign ALUOP =(op_code[5] == 1'b1 ? 2'b10 : 2'b00); // 10: r, 00: ld/imm
assign RegWrite = 1'b1;

endmodule