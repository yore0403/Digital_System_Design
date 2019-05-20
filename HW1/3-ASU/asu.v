module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;
wire [7:0]out0,out1;
wire carry1;

/*Write your code here*/
adder adder1(.x(x), .y(y), .carry(carry1), .out(out1));
barrel_shifter barrel1(.in(x), .shift(y[2:0]), .out(out0));

assign out = mode? out1: out0;
assign carry = mode? carry1: 1'b0;

/*End of code*/


endmodule