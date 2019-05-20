module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input        Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output [7:0] busX, busY;
reg [7:0] busX_r, busY_r;
reg [7:0] busX_w, busY_w;
    
// write your design here, you can delcare your own wires and regs. 
// The code below is just an eaxmple template
reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;
assign busX = busX_r;
assign busY = busY_r;
    
always@(*) begin
			r0_w = 8'b0;
			r0_r = 8'b0;
			r1_w = r1_r;
			r2_w = r2_r;
			r3_w = r3_r;
			r4_w = r4_r;
			r5_w = r5_r;
			r6_w = r6_r;
			r7_w = r7_r;
			busX_w = busX_r;
			busY_w = busY_r;
	if(WEN)begin
		case(RW)
			//3'b000:
			3'b001:r1_w = busW;
			3'b010:r2_w = busW;
			3'b011:r3_w = busW;
			3'b100:r4_w = busW;
			3'b101:r5_w = busW;
			3'b110:r6_w = busW;
			3'b111:r7_w = busW;
			default:r0_w = 8'b0;
		endcase
	end else begin
                        r0_w = 8'b0;
                        r0_r = 8'b0;
                        r1_w = r1_r;
                        r2_w = r2_r;
                        r3_w = r3_r;
                        r4_w = r4_r;
                        r5_w = r5_r;
                        r6_w = r6_r;
                        r7_w = r7_r;
	end
		case(RX) 
			3'b000:busX_w = r0_r;
			3'b001:busX_w = r1_r;
			3'b010:busX_w = r2_r;
			3'b011:busX_w = r3_r;
			3'b100:busX_w = r4_r;
			3'b101:busX_w = r5_r;
			3'b110:busX_w = r6_r;
			3'b111:busX_w = r7_r;
			default:busX_w= busX_r;
		endcase	
		case(RY)
			3'b000:busY_w = r0_r;
			3'b001:busY_w = r1_r;
			3'b010:busY_w = r2_r;
			3'b011:busY_w = r3_r;
			3'b100:busY_w = r4_r;
			3'b101:busY_w = r5_r;
			3'b110:busY_w = r6_r;
			3'b111:busY_w = r7_r;
			default:busY_w = busY_r;
		endcase	

end

always@(posedge Clk) begin
	//r0_r <= 0;
	//r0_w <= 0;
	r1_r <= r1_w;
	r2_r <= r2_w;
	r3_r <= r3_w;
	r4_r <= r4_w;
	r5_r <= r5_w;
	r6_r <= r6_w;
	r7_r <= r7_w;


end	
always @(*) begin
	busX_r <= busX_w;
	busY_r <= busY_w;
end

endmodule
