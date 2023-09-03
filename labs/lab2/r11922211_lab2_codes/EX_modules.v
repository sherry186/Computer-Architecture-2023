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
            ALU_res = $signed(op1) >>> op2; 
    endcase

    zero = (ALU_res == 32'h00000000) ? 1'b1 : 1'b0;

    end

endmodule

module ALU_Control(ALUOP, func3, func7, out);

    input [1:0] ALUOP;
    input [2:0] func3;
    input [6:0] func7;
    output [2:0] out;

    reg [2:0]out;

    always @(*) begin
        case (ALUOP)
            2'b00: // lw, sw, immd
                case (func3)
                    3'b000: 
                        out = 3'b110;
                    3'b101:
                        out = 3'b111;
                    default: 
                        out = 3'b011; // lw or sw
                endcase
            default: 
                case (func3)
                    3'b000: 
                        case (func7)
                            7'b0000000:
                                out = 3'b011;
                            7'b0100000:
                                out = 3'b100; 
                            default: 
                                out = 3'b101;
                        endcase
                    3'b001:
                        out = 3'b010;
                    3'b100:
                        out = 3'b001;
                    default: 
                        out = 3'b000;
                endcase
        endcase
    end

endmodule

module MUX4_32(in1, in2, in3, in4, sel, out);
    
    input [31:0] in1;
    input [31:0] in2;
    input [31:0] in3;
    input [31:0] in4;
    input [1:0] sel;
    output reg [31:0] out;

    always @(*) begin
      case (sel)
        2'b00: out = in1; 
        2'b01: out = in2; 
        2'b10: out = in3; 
        default: out = in4;
      endcase
    end

endmodule


module Forwarding_Unit(EX_rs1_addr, EX_rs2_addr, MEM_RegWrite, MEM_rd_addr, WB_RegWrite, WB_rd_addr, ForwardA, ForwardB);

    input [4:0] EX_rs1_addr;
    input [4:0] EX_rs2_addr;
    input MEM_RegWrite;
    input [4:0] MEM_rd_addr;
    input WB_RegWrite;
    input [4:0] WB_rd_addr;
    output reg [1:0] ForwardA;
    output reg [1:0] ForwardB;

    always @(*) begin
        if (MEM_RegWrite && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs1_addr)) begin
            ForwardA = 2'b10;
        end
        else if (WB_RegWrite && (WB_rd_addr != 0) && !(MEM_RegWrite && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs1_addr)) && (WB_rd_addr == EX_rs1_addr)) begin
            ForwardA = 2'b01;
        end
        else begin
          ForwardA = 2'b00;
        end

        if (MEM_RegWrite && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs2_addr)) begin
            ForwardB = 2'b10;
        end
        else if (WB_RegWrite && (WB_rd_addr != 0) && !(MEM_RegWrite && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs2_addr)) && (WB_rd_addr == EX_rs2_addr)) begin
            ForwardB = 2'b01;
        end
        else begin
          ForwardB = 2'b00;
        end
    end

endmodule