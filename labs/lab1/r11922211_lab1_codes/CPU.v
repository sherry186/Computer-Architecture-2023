module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input               clk_i;
input               rst_i;

wire [31:0]adder_out;
wire [31:0]pc_out;
wire [31:0]instruction;
wire [1:0]ALUOP;
wire ALUSrc;
wire RegWrite;
wire [31:0]immd;
wire [2:0]ALU_ctrl;
wire [31:0]ALU_res;
wire [31:0]rs1;
wire [31:0]rs2;
wire [31:0]mux_out;
wire zero;

// TODO:
PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_i(adder_out),
    .pc_o(pc_out)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_out),
    .instr_o(instruction)
);

Registers Registers(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RS1addr_i(instruction[19:15]),
    .RS2addr_i(instruction[24:20]),
    .RDaddr_i(instruction[11:7]),
    .RDdata_i(ALU_res),
    .RegWrite_i(RegWrite),
    .RS1data_o(rs1),
    .RS2data_o(rs2)
);

Control Control(
    .op_code(instruction[6:0]),
    .ALUOP(ALUOP),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
); 

Adder Add_PC(
    .pc(pc_out),
    .pc_plus_four(adder_out)
); 

MUX32 MUX_ALUSrc(
    .ALUSrc(ALUSrc),
    .rs2(rs2),
    .immd(immd),
    .out(mux_out)
); 

Sign_Extend Sign_Extend(
    .in(instruction[31:20]),
    .out(immd)
); 
  
ALU ALU(
    .op1(rs1),
    .op2(mux_out),
    .ALU_ctrl(ALU_ctrl),
    .zero(zero),
    .ALU_res(ALU_res)
); 

ALU_Control ALU_Control(
    .ALUOP(ALUOP),
    .func3(instruction[14:12]),
    .func7(instruction[31:25]),
    .out(ALU_ctrl)
); 


endmodule

