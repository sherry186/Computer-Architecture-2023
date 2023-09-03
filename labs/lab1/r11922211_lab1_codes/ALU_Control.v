module ALU_Control(ALUOP, func3, func7, out);

input [1:0] ALUOP;
input [2:0]func3;
input [6:0]func7;
output [2:0]out;

reg [2:0]out;

always @(*) begin
    case (ALUOP)
        2'b00: 
            case (func3)
                3'b000: 
                    out = 3'b110;
                default: 
                    out = 3'b111;
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