module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input               clk_i;
input               rst_i;

wire [31:0] adder_out;
wire [31:0] pc_out;
wire [31:0] IF_instruction, ID_instruction;
wire [1:0] ID_ALUOP, EX_ALUOP;
wire ID_ALUSrc, EX_ALUSrc;
wire ID_RegWrite, EX_RegWrite, MEM_RegWrite, WB_RegWrite;
wire [31:0] ID_immd, EX_immd;
wire [2:0] ALU_ctrl;
wire [31:0] EX_ALU_res, MEM_ALU_res, WB_ALU_res;
wire [31:0] ID_rs1, EX_rs1, EX_rs1_mux_out;
wire [31:0] ID_rs2, EX_rs2, EX_rs2_mux_out, MEM_rs2_mux_out;
wire [31:0] ALUSrc_mux_out;
wire zero;
wire ID_MemRead, EX_MemRead, MEM_MemRead;
wire ID_MemWrite, EX_MemWrite, MEM_MemWrite;
wire ID_MemtoReg, EX_MemtoReg, MEM_MemtoReg, WB_MemtoReg;
wire [31:0] MEM_mem_out, WB_mem_out;
wire [31:0] MemToReg_mux_out;
wire [2:0] EX_func3;
wire [6:0] EX_func7;
wire [4:0] EX_rd_addr, MEM_rd_addr, WB_rd_addr;
wire [4:0] EX_rs1_addr, EX_rs2_addr;
wire [1:0] ForwardA, ForwardB;
wire NoOP, PCWrite, Stall;
wire Branch, branch_ctrl;
wire [31:0] ID_pc, branch_addr, pc_mux_out;
wire selector_o;
wire [31:0] branch_addr_resolved_o, pc_mux_1_out;
wire [31:0] ID_EX_pc_plus_four_o, ID_EX_branch_addr_o;
wire EX_predict, EX_branch, IF_ID_flush;
wire [31:0] ID_EX_pc_plus_four_i;
wire branch_predict_result;

assign branch_ctrl = Branch & branch_predict_result;
assign IF_ID_flush = branch_ctrl | selector_o;
assign ID_EX_pc_plus_four_i = ID_pc + 4;

PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .PCWrite_i(PCWrite),
    .pc_i(pc_mux_1_out),
    .pc_o(pc_out)
);

Adder Add_PC(
    .pc(pc_out),
    .pc_plus_four(adder_out)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_out),
    .instr_o(IF_instruction)
);

Registers Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RS1addr_i(ID_instruction[19:15]),
    .RS2addr_i(ID_instruction[24:20]),
    .RDaddr_i(WB_rd_addr),
    .RDdata_i(MemToReg_mux_out),
    .RegWrite_i(WB_RegWrite),
    .RS1data_o(ID_rs1),
    .RS2data_o(ID_rs2)
);

Control Control(
    .op_code(ID_instruction[6:0]),
    .ALUOP(ID_ALUOP),
    .ALUSrc(ID_ALUSrc),
    .RegWrite(ID_RegWrite),
    .MemtoReg(ID_MemtoReg),
    .MemRead(ID_MemRead),
    .MemWrite(ID_MemWrite),
    .NoOP(NoOP),
    .Branch(Branch)
); 

Imm_Gen Imm_Gen(
    .in(ID_instruction),
    .out(ID_immd)
); 

ALU_Control ALU_Control(
    .ALUOP(EX_ALUOP),
    .func3(EX_func3),
    .func7(EX_func7),
    .out(ALU_ctrl)
); 

MUX2_32 MUX_ALUSrc(
    .ctrl(EX_ALUSrc),
    .in0(EX_rs2_mux_out),
    .in1(EX_immd),
    .out(ALUSrc_mux_out)
); 

ALU ALU(
    .data1_i(EX_rs1_mux_out),
    .data2_i(ALUSrc_mux_out),
    .ALUCtrl_i(ALU_ctrl),
    .Zero_o(zero),
    .data_o(EX_ALU_res)
); 

MUX2_32 MUX_MemToReg(
    .ctrl(WB_MemtoReg),
    .in0(WB_ALU_res),
    .in1(WB_mem_out),
    .out(MemToReg_mux_out)
); 

Data_Memory Data_Memory(
    .clk_i(clk_i),
    .addr_i(MEM_ALU_res),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_i(MEM_rs2_mux_out),
    .data_o(MEM_mem_out)
);

IF_ID IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .inst_i(IF_instruction),
    .PC_i(pc_out), 
    .inst_o(ID_instruction),
    .stall_i(Stall),
    .PC_o(ID_pc),
    .flush_i(IF_ID_flush)
);

ID_EX ID_EX(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .RegWrite_i(ID_RegWrite), 
    .MemToReg_i(ID_MemtoReg),
    .MemRead_i(ID_MemRead),
    .MemWrite_i(ID_MemWrite),
    .ALUOP_i(ID_ALUOP),
    .ALUSrc_i(ID_ALUSrc),
    .rs1_i(ID_rs1),
    .rs2_i(ID_rs2),
    .rd_addr_i(ID_instruction[11:7]),
    .immd_i(ID_immd),
    .func3_i(ID_instruction[14:12]),
    .func7_i(ID_instruction[31:25]),
    .rs1_addr_i(ID_instruction[19:15]),
    .rs2_addr_i(ID_instruction[24:20]),
    .RegWrite_o(EX_RegWrite), 
    .MemToReg_o(EX_MemtoReg),
    .MemRead_o(EX_MemRead),
    .MemWrite_o(EX_MemWrite),
    .ALUOP_o(EX_ALUOP),
    .ALUSrc_o(EX_ALUSrc),
    .rs1_o(EX_rs1),
    .rs2_o(EX_rs2),
    .immd_o(EX_immd),
    .func3_o(EX_func3),
    .func7_o(EX_func7),
    .rd_addr_o(EX_rd_addr),
    .rs1_addr_o(EX_rs1_addr),
    .rs2_addr_o(EX_rs2_addr),
    .branch_i(Branch),
    .predict_i(branch_predict_result),
    .flush_i(selector_o),
    .branch_o(EX_branch),
    .predict_o(EX_predict),
    .pc_plus_four_i(ID_EX_pc_plus_four_i),
    .branch_addr_i(branch_addr),
    .pc_plus_four_o(ID_EX_pc_plus_four_o),
    .branch_addr_o(ID_EX_branch_addr_o)
);

EX_MEM EX_MEM(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .RegWrite_i(EX_RegWrite), 
    .MemToReg_i(EX_MemtoReg),
    .MemRead_i(EX_MemRead),
    .MemWrite_i(EX_MemWrite),
    .ALU_res_i(EX_ALU_res),
    .rs2_i(EX_rs2_mux_out),
    .rd_addr_i(EX_rd_addr),
    .RegWrite_o(MEM_RegWrite), 
    .MemToReg_o(MEM_MemtoReg),
    .MemRead_o(MEM_MemRead),
    .MemWrite_o(MEM_MemWrite),
    .ALU_res_o(MEM_ALU_res),
    .rs2_o(MEM_rs2_mux_out),
    .rd_addr_o(MEM_rd_addr)
);

MEM_WB MEM_WB(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .RegWrite_i(MEM_RegWrite), 
    .MemToReg_i(MEM_MemtoReg),
    .ALU_res_i(MEM_ALU_res),
    .mem_data_i(MEM_mem_out),
    .rd_addr_i(MEM_rd_addr),
    .RegWrite_o(WB_RegWrite), 
    .MemToReg_o(WB_MemtoReg),
    .ALU_res_o(WB_ALU_res),
    .mem_data_o(WB_mem_out),
    .rd_addr_o(WB_rd_addr)
);

Forwarding_Unit Forwarding_Unit(
    .EX_rs1_addr(EX_rs1_addr),
    .EX_rs2_addr(EX_rs2_addr),
    .MEM_RegWrite(MEM_RegWrite),
    .MEM_rd_addr(MEM_rd_addr),
    .WB_RegWrite(WB_RegWrite),
    .WB_rd_addr(WB_rd_addr),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

MUX4_32 rs1_MUX(
    .in1(EX_rs1),
    .in2(MemToReg_mux_out),
    .in3(MEM_ALU_res),
    .in4({32'b0}),
    .sel(ForwardA),
    .out(EX_rs1_mux_out)
);

MUX4_32 rs2_MUX(
    .in1(EX_rs2),
    .in2(MemToReg_mux_out),
    .in3(MEM_ALU_res),
    .in4({32'b0}),
    .sel(ForwardB),
    .out(EX_rs2_mux_out)
);

Hazard_Detection Hazard_Detection(
    .EX_MemRead(EX_MemRead),
    .EX_rd_addr(EX_rd_addr), 
    .ID_rs1_addr(ID_instruction[19:15]), 
    .ID_rs2_addr(ID_instruction[24:20]), 
    .NoOP(NoOP), 
    .PCWrite(PCWrite), 
    .Stall(Stall)
);

Branch_Address_Resolver Branch_Address_Resolver(
    .immd(ID_immd), 
    .ID_PC(ID_pc), 
    .branch_addr(branch_addr)
);

MUX2_32 PC_MUX(
    .ctrl(branch_ctrl),
    .in0(adder_out),
    .in1(branch_addr),
    .out(pc_mux_out)
);

MUX2_32 PC_MUX_2(
    .ctrl(selector_o),
    .in0(pc_mux_out),
    .in1(branch_addr_resolved_o),
    .out(pc_mux_1_out)
);

branch_corrector branch_corrector(
    .pc_plus_four_i(ID_EX_pc_plus_four_o),
    .branch_addr_i(ID_EX_branch_addr_o),
    .result_i(zero),
    .predict_i(EX_predict),
    .selector_o(selector_o),
    .branch_addr_resolved_o(branch_addr_resolved_o),
    .branch_i(EX_branch)
);

branch_predictor branch_predictor(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .result_i(zero),
    .update_i(EX_branch),
    .predict_o(branch_predict_result)
);

endmodule
