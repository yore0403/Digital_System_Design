//RT �Vlevel (event-driven) 
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;
    reg [7:0] out;
reg [8:0]out1;
reg carry;
    always @(*) begin
	out1 =ctrl[0]?{x[7],x} - {y[7],y}:{x[7],x} + {y[7],y};
	carry = out1[8];
        case (ctrl)
            4'b0000:out = x + y;
            4'b0001:out = x - y;
            4'b0010:out = x & y;
            4'b0011:out = x | y;
            4'b0100:out = ~x;
            4'b0101:out = x ^ y;
            4'b0110:out = ~(x | y);
            4'b0111:out = y << x[2:0];
            4'b1000:out = y >> x[2:0];
            4'b1001:out ={x[7],x[7:1]};
            4'b1010:out = {x[6:0] , x[7]};
            4'b1011:out = {x[0] , x[7:1]};
            4'b1100:out = (x==y)?1:0;
            4'b1101:out = 0;
            4'b1110:out = 0;
            4'b1111:out = 0;
            default : out = 0;
        endcase
    
    end

endmodule
