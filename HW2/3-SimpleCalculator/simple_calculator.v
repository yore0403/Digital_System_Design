module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    wire [7:0]mux_out;
    reg [7:0]mux_out_r;
    wire [7:0]alu_out;
    reg [7:0]alu_out_w,alu_out_r;
    wire [7:0]busX,busY;
    reg [7:0]busY_r,busY_w;

always @(*) begin
mux_out_r = Sel? busX:DataIn;
end


    register_file rf(
        .Clk(Clk)  ,
        .WEN(WEN)  ,
        .RW(RW)   ,
        .busW(alu_out) ,
        .RX(RX)   ,
        .RY(RY)   ,
        .busX(busX) ,
        .busY(busY)
    );
    alu_always alu_always(
        .ctrl(Ctrl)     ,
        .x(mux_out_r)        ,
        .y(busY)        ,
        .carry(Carry)    ,
        .out(alu_out)  
    ); 

    /*
    assign busY = busY_r;

assign mux_out = Sel? busX:DataIn;
    register_file rf(
        .Clk(Clk)  ,
        .WEN(WEN)  ,
        .RW(RW)   ,
        .busW(alu_out_r) ,
        .RX(RX)   ,
        .RY(RY)   ,
        .busX(busX) ,
        .busY(busY)
    );
    alu_always alu_always(
        .ctrl(Ctrl)     ,
        .x(mux_out_r)        ,
        .y(busY_w)        ,
        .carry(Carry)    ,
        .out(alu_out)  
    ); 

    always @(posedge Clk) begin
        busY_r <= busY_w;
        mux_out_r <= mux_out;
        alu_out_r<= alu_out;
    end  
    */
// submodule instantiation
  


endmodule
