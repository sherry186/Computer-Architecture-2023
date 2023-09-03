module ALU(data1_i, data2_i, ALUCtrl_i, data_o, Zero_o);
input signed [31:0] data1_i, data2_i;
input  [2:0]  ALUCtrl_i;
output [31:0] data_o;
output        Zero_o;

// TODO
reg [31:0] data_o;
reg Zero_o;

always @(*) begin
    case (ALUCtrl_i)
        3'b000: 
            data_o = data1_i & data2_i;
        3'b001: 
            data_o = data1_i ^ data2_i;
        3'b010: 
            data_o = data1_i << data2_i;
        3'b011: 
            data_o = data1_i + data2_i;
        3'b100: 
            data_o = data1_i - data2_i;
        3'b101:
            data_o = data1_i * data2_i;
        3'b110: 
            data_o = data1_i + data2_i; 
        default: 
            data_o = data1_i >>> data2_i; 
    endcase

    Zero_o = (data_o == 32'h00000000) ? 1'b1 : 1'b0;
end

endmodule

module branch_corrector
(
    pc_plus_four_i,
    branch_addr_i,
    result_i,
    predict_i,
    selector_o,
    branch_addr_resolved_o,
    branch_i
);
input [31:0] pc_plus_four_i, branch_addr_i;
input result_i, predict_i, branch_i;
output reg selector_o;
output reg [31:0] branch_addr_resolved_o;

always @(*) begin
    if (result_i == predict_i || ~branch_i) begin
        selector_o = 1'b0;
        branch_addr_resolved_o = pc_plus_four_i;
    end
    else begin
        selector_o = 1'b1;
        branch_addr_resolved_o = result_i ? branch_addr_i : pc_plus_four_i;
    end
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
                    3'b000: //addi
                        out = 3'b110;
                    3'b101: //srai
                        out = 3'b111;
                    default: 
                        out = 3'b011; // lw or sw
                endcase
            2'b01: // beq
                out = 3'b100;
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