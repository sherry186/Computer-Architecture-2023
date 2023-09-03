module MUX2_32(ctrl, in0, in1, out);

input ctrl;
input [31:0] in0, in1;
output [31:0] out;

assign out = (ctrl == 1'b0) ? in0 : in1;

endmodule