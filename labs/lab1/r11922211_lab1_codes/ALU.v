module ALU(op1, op2, ALU_ctrl, zero, ALU_res);

input [31:0] op1, op2;
input [2:0] ALU_ctrl;
output zero;
output [31:0] ALU_res;

reg [31:0] ALU_res;
reg zero;

always @(*) begin

case (ALU_ctrl)
    3'b000: 
        ALU_res = op1 & op2;
    3'b001: 
        ALU_res = op1 ^ op2;
    3'b010: 
        ALU_res = op1 << op2;
    3'b011: 
        ALU_res = op1 + op2;
    3'b100: 
        ALU_res = op1 - op2;
    3'b101:
        ALU_res = op1 * op2;
    3'b110: 
        ALU_res = op1 + op2; 
    default: 
        ALU_res = op1 >>> op2; 
endcase

zero = (ALU_res == 32'h00000000) ? 1'b1 : 1'b0;

end

endmodule