module Sign_Extend(in, out);

input [11:0] in;
output [31:0] out;

reg [31:0] out;

always @(*)begin
  case (in[11:5])
    7'b0100000:
        out = {{27{in[4]}}, in[4:0]};
    default: 
        out = {{20{in[11]}}, in};
  endcase
end

endmodule