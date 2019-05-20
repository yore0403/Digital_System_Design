module adder(x, y, carry, out);
input [7:0] x, y;
output carry;
wire [8:0]sum;
output [7:0] out;

/*Write your code here*/

assign sum = {1'b0,x} + {1'b0,y};
assign out = sum[7:0];
assign carry = sum[8];

/*End of code*/

endmodule