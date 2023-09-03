module Control(op_code, ALUOP, ALUSrc, RegWrite, MemtoReg, MemRead, MemWrite, NoOP, Branch);
    input [6:0] op_code;
    input NoOP;
    output reg [1:0] ALUOP;
    output reg ALUSrc;
    output reg RegWrite;
    output reg MemtoReg;
    output reg MemRead;
    output reg MemWrite;
    output reg Branch;

    always @(*) begin
        if (NoOP) begin
            ALUSrc = 1'b0;
            ALUOP = 2'b00;
            RegWrite = 1'b0;
            MemtoReg = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
        end
        else begin
            case (op_code)
                7'b0110011: begin // r-type
                    ALUSrc = 1'b0;
                    ALUOP = 2'b10;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                end
                7'b0010011: begin // I-type
                    ALUSrc = 1'b1;
                    ALUOP = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                end
                7'b0000011: begin // lw
                    ALUSrc = 1'b1;
                    ALUOP = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                end
                7'b0100011: begin // sw
                    ALUSrc = 1'b1;
                    ALUOP = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 1'b0;
                end
                7'b1100011: begin // beq
                    ALUSrc = 1'b0;
                    ALUOP = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b1;
                end
                default: begin // beq
                    ALUSrc = 1'b0;
                    ALUOP = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                end
            endcase
        end
    end
endmodule

module Imm_Gen(in, out);
    input [31:0] in;
    output [31:0] out;

    reg [31:0] out;

    always @(*)begin
    case (in[6:0]) // op code
        7'b0010011: // addi or srai
            case (in[14:12]) // funct3
                3'b000: // addi
                    out = {{20{in[31]}}, in[31:20]};
                default: // srai
                    out = {{27{in[24]}}, in[24:20]};
            endcase
        7'b0000011: // lw
            out = {{20{in[31]}}, in[31:20]};
        7'b0100011: // sw
            out = {{20{in[31]}}, in[31:25], in[11:7]};
        7'b1100011: // beq
            out = {{20{in[31]}}, in[31], in[7], in[30:25], in[11:8]};
        default:
            out = 32'b0;
    endcase
    end
endmodule

module Hazard_Detection(EX_MemRead, EX_rd_addr, ID_rs1_addr, ID_rs2_addr, NoOP, PCWrite, Stall);
    input EX_MemRead;
    input [4:0] EX_rd_addr; 
    input [4:0] ID_rs1_addr; 
    input [4:0] ID_rs2_addr; 
    output reg NoOP; 
    output reg PCWrite; 
    output reg Stall;

    always @(*) begin
        if (EX_MemRead && ( EX_rd_addr == ID_rs1_addr | EX_rd_addr == ID_rs2_addr )) begin
            NoOP = 1'b1;
            PCWrite = 1'b0;
            Stall = 1'b1;
        end
        else begin
            NoOP = 1'b0;
            PCWrite = 1'b1;
            Stall = 1'b0;
        end
    end
endmodule

module Branch_Controller(ID_rs1, ID_rs2, ID_Branch, out);
    input [31:0] ID_rs1; 
    input [31:0] ID_rs2; 
    input ID_Branch; 
    output out;
    assign out = ID_Branch & (ID_rs1 == ID_rs2);
endmodule

module Branch_Address_Resolver(immd, ID_PC, branch_addr);
    input [31:0] immd;
    input [31:0] ID_PC; 
    output [31:0] branch_addr;
    assign branch_addr = ID_PC + (immd << 1);
endmodule
