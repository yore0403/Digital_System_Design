module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;
//reg out_r,carry_r;
wire c0,c1,c2,c3,c4,c5,c6,c7;

/*Write your code here*/


FA FA0(.s_o(out[0]),.c_o(c0),.c_i(1'b0),.x_i(x[0]),.y_i(y[0]));
FA FA1(.s_o(out[1]),.c_o(c1),.c_i(c0),.x_i(x[1]),.y_i(y[1]));
FA FA2(.s_o(out[2]),.c_o(c2),.c_i(c1),.x_i(x[2]),.y_i(y[2]));
FA FA3(.s_o(out[3]),.c_o(c3),.c_i(c2),.x_i(x[3]),.y_i(y[3]));
FA FA4(.s_o(out[4]),.c_o(c4),.c_i(c3),.x_i(x[4]),.y_i(y[4]));
FA FA5(.s_o(out[5]),.c_o(c5),.c_i(c4),.x_i(x[5]),.y_i(y[5]));
FA FA6(.s_o(out[6]),.c_o(c6),.c_i(c5),.x_i(x[6]),.y_i(y[6]));
FA FA7(.s_o(out[7]),.c_o(carry),.c_i(c6),.x_i(x[7]),.y_i(y[7]));



/*End of code*/

endmodule

module FA(s_o,c_o,c_i,x_i,y_i);
input c_i,x_i,y_i;
output s_o,c_o;
wire s1, c1, c2;

xor #1 g1(s1, x_i, y_i);
xor #1 g2(s_o, s1, c_i);
and #1 g3(c1, x_i,y_i);
and #1 g4(c2, s1, c_i) ;
or #1 g5(c_o, c2, c1) ;	

endmodule
