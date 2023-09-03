module Adder(pc, pc_plus_four);
    input [31:0] pc;
    output [31:0] pc_plus_four;

    assign pc_plus_four = pc + 4;
endmodule
