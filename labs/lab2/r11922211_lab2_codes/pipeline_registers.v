module IF_ID
    (   
        rst_i,
        clk_i,
        instruction_i, 
        pc_i,
        instruction_o,
        Stall,
        pc_o,
        Flush
    );

    input rst_i;
    input clk_i;
    input [31:0] instruction_i;
    input Stall;
    input [31:0] pc_i;
    input Flush;
    output reg [31:0] instruction_o;
    output reg [31:0] pc_o;

    // Write Data   
    always@(posedge clk_i or negedge rst_i) begin
        if (~rst_i | Flush) begin
            instruction_o <= 32'b0;
            pc_o <= 32'b0;
        end
        else if (~Stall) begin
            instruction_o <= instruction_i;
            pc_o <= pc_i;
        end
    end

endmodule


module ID_EX
    (   
        rst_i,
        clk_i,
        RegWrite_i, 
        MemToReg_i,
        MemRead_i,
        MemWrite_i,
        ALUOP_i,
        ALUSrc_i,
        rs1_i,
        rs2_i,
        rd_addr_i,
        immd_i,
        func3_i,
        func7_i,
        rs1_addr_i,
        rs2_addr_i,
        RegWrite_o, 
        MemToReg_o,
        MemRead_o,
        MemWrite_o,
        ALUOP_o,
        ALUSrc_o,
        rs1_o,
        rs2_o,
        immd_o,
        func3_o,
        func7_o,
        rd_addr_o,
        rs1_addr_o,
        rs2_addr_o
    );

    input rst_i;
    input clk_i;
    input RegWrite_i;
    input MemToReg_i;
    input MemRead_i;
    input MemWrite_i;
    input [1:0] ALUOP_i;
    input ALUSrc_i;
    input [31:0] rs1_i;
    input [31:0] rs2_i;
    input [31:0] immd_i;
    input [2:0] func3_i;
    input [6:0] func7_i;
    input [4:0] rd_addr_i;
    input [4:0] rs1_addr_i;
    input [4:0] rs2_addr_i;

    output reg RegWrite_o;
    output reg MemToReg_o;
    output reg MemRead_o;
    output reg MemWrite_o;
    output reg [1:0] ALUOP_o;
    output reg ALUSrc_o;
    output reg [31:0] rs1_o;
    output reg [31:0] rs2_o;
    output reg [31:0] immd_o;
    output reg [2:0] func3_o;
    output reg [6:0] func7_o;
    output reg [4:0] rd_addr_o;
    output reg [4:0] rs1_addr_o;
    output reg [4:0] rs2_addr_o;


    // Write Data   
    always@(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            RegWrite_o <= 1'b0; 
            MemToReg_o <= 1'b0;
            MemRead_o <= 1'b0;
            MemWrite_o <= 1'b0;
            ALUOP_o <= 2'b0;
            ALUSrc_o <= 1'b0;
            rs1_o <= 32'b0;
            rs2_o <= 32'b0;
            immd_o <= 32'b0;
            func3_o <= 3'b0;
            func7_o <= 7'b0;
            rd_addr_o <= 5'b0;
            rs1_addr_o <= 5'b0;
            rs2_addr_o <= 5'b0;
        end
        else begin
            RegWrite_o <= RegWrite_i;
            MemToReg_o <= MemToReg_i;
            MemRead_o <= MemRead_i;
            MemWrite_o <= MemWrite_i;
            ALUOP_o <= ALUOP_i;
            ALUSrc_o <= ALUSrc_i;
            rs1_o <= rs1_i;
            rs2_o <= rs2_i;
            immd_o <= immd_i;
            func3_o <= func3_i;
            func7_o <= func7_i;
            rd_addr_o <= rd_addr_i;
            rs1_addr_o <= rs1_addr_i;
            rs2_addr_o <= rs2_addr_i;
        end
    end

endmodule


module EX_MEM
    (
        rst_i,
        clk_i,
        RegWrite_i, 
        MemToReg_i,
        MemRead_i,
        MemWrite_i,
        ALU_res_i,
        rs2_i,
        rd_addr_i,
        RegWrite_o, 
        MemToReg_o,
        MemRead_o,
        MemWrite_o,
        ALU_res_o,
        rs2_o,
        rd_addr_o
    );

    input rst_i;
    input clk_i;
    input RegWrite_i;
    input MemToReg_i;
    input MemRead_i;
    input MemWrite_i;
    input [31:0] ALU_res_i;
    input [31:0] rs2_i;
    input [4:0] rd_addr_i;
    output reg RegWrite_o;
    output reg MemToReg_o;
    output reg MemRead_o;
    output reg MemWrite_o;
    output reg [31:0] ALU_res_o;
    output reg [31:0] rs2_o;
    output reg [4:0] rd_addr_o;

    always@(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            RegWrite_o <= 1'b0; 
            MemToReg_o <= 1'b0;
            MemRead_o <= 1'b0;
            MemWrite_o <= 1'b0;
            ALU_res_o <= 32'b0;
            rs2_o <= 32'b0;
            rd_addr_o <= 5'b0;
        end
        else begin
            RegWrite_o <= RegWrite_i;
            MemToReg_o <= MemToReg_i;
            MemRead_o <= MemRead_i;
            MemWrite_o <= MemWrite_i;
            ALU_res_o <= ALU_res_i;
            rs2_o <= rs2_i;
            rd_addr_o <= rd_addr_i;
        end
    end

endmodule


module MEM_WB
    (
        rst_i,
        clk_i,
        RegWrite_i, 
        MemToReg_i,
        ALU_res_i,
        mem_data_i,
        rd_addr_i,
        RegWrite_o, 
        MemToReg_o,
        ALU_res_o,
        mem_data_o,
        rd_addr_o
    );

    input rst_i;
    input clk_i;
    input RegWrite_i;
    input MemToReg_i;
    input [31:0] ALU_res_i;
    input [31:0] mem_data_i;
    input [4:0] rd_addr_i;

    output reg RegWrite_o;
    output reg MemToReg_o;
    output reg [31:0] ALU_res_o;
    output reg [31:0] mem_data_o;
    output reg [4:0] rd_addr_o;

    always@(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            RegWrite_o <= 1'b0; 
            MemToReg_o <= 1'b0;
            ALU_res_o <= 32'b0;
            mem_data_o <= 32'b0;
            rd_addr_o <= 5'b0;
        end
        else begin
            RegWrite_o <= RegWrite_i;
            MemToReg_o <= MemToReg_i;
            ALU_res_o <= ALU_res_i;
            mem_data_o <= mem_data_i;
            rd_addr_o <= rd_addr_i;
        end
    end

endmodule