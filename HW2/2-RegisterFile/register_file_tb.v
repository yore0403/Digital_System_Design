`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test

    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW,busW_w;
    wire [7:0] busX, busY;
    reg  [7:0] reg_file[0:7];
    reg [7:0]err_cnt;
    reg [2:0]X_cnt;
    reg [2:0]Y_cnt;
    reg [3:0] i, j;
    
    // instantiate the design-under-test
    always begin #(`HCYCLE) Clk = ~Clk; end

    register_file rf(
        .Clk(Clk)  ,
        .WEN(WEN)  ,
        .RW(RW)   ,
        .busW(busW) ,
        .RX(RX)   ,
        .RY(RY)   ,
        .busX(busX) ,
        .busY(busY)
    );

    initial begin
    $fsdbDumpfile("register.fsdb");
    $fsdbDumpvars;

        err_cnt = 0;
        WEN = 1;
        Clk = 0;
        X_cnt = 0;
        Y_cnt = 0;
        #(`CYCLE)
        $display("-------------------------------------------");
        $display("         write into the register");
        $display("-------------------------------------------");
        for (i = 0; i <= 8; i = i + 1) begin
            #(`CYCLE)
            RW = i;
            busW = $urandom%256;
            reg_file[i] = i == 0?8'b0:busW;
            $display("reg_file[%d]:%b",i,reg_file[i]);
        end

        reg_file[0] = 8'b0;
        #(`CYCLE)
        WEN = 0;
        $display("-------------------------------------------");
        $display("           read the register");
        $display("-------------------------------------------");       

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin                
                RX = X_cnt;
                RY = Y_cnt;
                #(`CYCLE)
                if(busX == reg_file[i] && busY == reg_file[j])begin
                    $display("RX = %d RY = %d is correct.",i,j);
                end else begin
                    $display("error: output = %b, %b; ans = %b, %b;",busX,busY,reg_file[i],reg_file[j]);
                    err_cnt = err_cnt + 1;
                end
                Y_cnt = Y_cnt + 1;
            end
            X_cnt = X_cnt + 1;
        end
        $display("-------------------------------------------");
        $display("        over write the register");
        $display("-------------------------------------------");
        err_cnt = 0;
        X_cnt = 0;
        Y_cnt = 0;
        WEN = 1;
        #(`CYCLE)
        for (i = 0; i < 8; i = i + 1) begin
            
            #(`CYCLE)
            RW = i;
            busW = ~reg_file[i];
            reg_file[i] = i==0?8'b0:~reg_file[i];
            $display("reg_file[%d]:%b",i,reg_file[i]);

        end

        reg_file[0] = 8'b0;
        #(`CYCLE)
        
        $display("-------------------------------------------");
        $display("           read the register");
        $display("-------------------------------------------");         

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin                
                
                WEN = 0;
                RX = X_cnt;
                RY = Y_cnt;
                #(`CYCLE)

                if(busX == reg_file[i] && busY == reg_file[j])begin
                    $display("RX = %d RY = %d is correct.",i,j);
                end else begin
                    $display("error: RX = %d RY = %d output = %b, %b; ans = %b, %b;",i,j,busX,busY,reg_file[i],reg_file[j]);
                    err_cnt = err_cnt + 1;
                end

                Y_cnt = Y_cnt + 1;
            end
            X_cnt = X_cnt + 1;
        end



        if(!err_cnt)$display("--------SIMULATION PASS---------");
        else $display("%d error.",err_cnt);

        $finish;
    end



    // write your test pattern here


endmodule
