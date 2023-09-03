module CPU
(
    clk_i, 
    rst_i,
);

// Ports
input               clk_i;
input               rst_i;

// TODO:
PC PC();

Instruction_Memory Instruction_Memory();

Registers Registers();

/* Hints

Control Control();

Adder Add_PC();

MUX32 MUX_ALUSrc();

Sign_Extend Sign_Extend();
  
ALU ALU();

ALU_Control ALU_Control();

*/

endmodule

