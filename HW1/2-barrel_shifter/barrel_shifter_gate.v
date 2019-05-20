module barrel_shifter_gate(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;

/*Write your code here*/
wire [7:0]x1,x2,x3;

mux mux10(.x(x1[0]),.b( 1'b0),.a(in[0]),.sel(shift[0]));
mux mux11(.x(x1[1]),.b(in[0]),.a(in[1]),.sel(shift[0]));
mux mux12(.x(x1[2]),.b(in[1]),.a(in[2]),.sel(shift[0]));
mux mux13(.x(x1[3]),.b(in[2]),.a(in[3]),.sel(shift[0]));
mux mux14(.x(x1[4]),.b(in[3]),.a(in[4]),.sel(shift[0]));
mux mux15(.x(x1[5]),.b(in[4]),.a(in[5]),.sel(shift[0]));
mux mux16(.x(x1[6]),.b(in[5]),.a(in[6]),.sel(shift[0]));
mux mux17(.x(x1[7]),.b(in[6]),.a(in[7]),.sel(shift[0]));

mux mux20(.x(x2[0]),.b( 1'b0),.a(x1[0]),.sel(shift[1]));
mux mux21(.x(x2[1]),.b( 1'b0),.a(x1[1]),.sel(shift[1]));
mux mux22(.x(x2[2]),.b(x1[0]),.a(x1[2]),.sel(shift[1]));
mux mux23(.x(x2[3]),.b(x1[1]),.a(x1[3]),.sel(shift[1]));
mux mux24(.x(x2[4]),.b(x1[2]),.a(x1[4]),.sel(shift[1]));
mux mux25(.x(x2[5]),.b(x1[3]),.a(x1[5]),.sel(shift[1]));
mux mux26(.x(x2[6]),.b(x1[4]),.a(x1[6]),.sel(shift[1]));
mux mux27(.x(x2[7]),.b(x1[5]),.a(x1[7]),.sel(shift[1]));

mux mux30(.x(out[0]),.b( 1'b0),.a(x2[0]),.sel(shift[2]));
mux mux31(.x(out[1]),.b( 1'b0),.a(x2[1]),.sel(shift[2]));
mux mux32(.x(out[2]),.b( 1'b0),.a(x2[2]),.sel(shift[2]));
mux mux33(.x(out[3]),.b( 1'b0),.a(x2[3]),.sel(shift[2]));
mux mux34(.x(out[4]),.b(x2[0]),.a(x2[4]),.sel(shift[2]));
mux mux35(.x(out[5]),.b(x2[1]),.a(x2[5]),.sel(shift[2]));
mux mux36(.x(out[6]),.b(x2[2]),.a(x2[6]),.sel(shift[2]));
mux mux37(.x(out[7]),.b(x2[3]),.a(x2[7]),.sel(shift[2]));

/*End of code*/
endmodule

module mux (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not #1 n0(sel_i,sel);
and #1 a1(w1,a,sel_i);
and #1 a2(w2,b,sel);
or  #1 o1(x,w1,w2);

	
endmodule
