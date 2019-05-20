//continuous assignment tb
`timescale 1ns/10ps
`define CYCLE   10
`define HCYCLE  5

module alu_assign_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    alu_assign alu_assign(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

   initial begin
       $fsdbDumpfile("alu_assign.fsdb");
       $fsdbDumpvars;
   end

    initial begin
       ctrl = 4'b1101;
        x    = 8'd0;
        y    = 8'd0;
        
        #(`CYCLE);
        // 0100 boolean not
        ctrl = 4'b0100;
        
        #(`HCYCLE);
        if( out == 8'b1111_1111 ) $display( "PASS --- 0100 boolean not" );
        else $display( "FAIL --- 0100 boolean not" );
        #(`HCYCLE);

        ctrl = 4'b0000;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00101110 && carry == 1'b0 ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add%b",out );
        #(`HCYCLE);
 
        ctrl = 4'b0000;//add
        x    = 8'b10110101;
        y    = 8'b11111001;
        #(`HCYCLE);
        if( out == 8'b10101110 && carry == 1'b1 ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add%b",out );
        #(`HCYCLE);

        ctrl = 4'b0000;//add
        x    = 8'b00110101;
        y    = 8'b01101001;
        #(`HCYCLE);
        if( out == 8'b10011110 && carry == 1'b0 ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add%b",out );
        #(`HCYCLE);

        ctrl = 4'b0000;//add
        x    = 8'b01010101;
        y    = 8'b01011000;
        #(`HCYCLE);
        if( out == 8'b10101101 && carry == 1'b0 ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add%b",out );
        #(`HCYCLE);

        ctrl = 4'b0000;//add
        x    = 8'b10110101;
        y    = 8'b11001001;
        #(`HCYCLE);
        if( out == 8'b01111110 && carry == 1'b1 ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add%b",out );
        #(`HCYCLE);

        ctrl = 4'b0001;//sub
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00111100 && carry == 1'b1 ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0001 sub%b",out );
        #(`HCYCLE);

        ctrl = 4'b0001;//sub
        x    = 8'b00100100;
        y    = 8'b01001001;
        #(`HCYCLE);
        if( out == 8'b11011011 && carry == 1'b1 ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0001 sub%b",out );
        #(`HCYCLE);

        ctrl = 4'b0001;//sub
        x    = 8'b00111011;
        y    = 8'b00000010;
        #(`HCYCLE);
        if( out == 8'b00111001 && carry == 1'b0 ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0001 sub%b",out );
        #(`HCYCLE);


        ctrl = 4'b0001;//sub
        x    = 8'd2;
        y    = 8'd47;
        #(`HCYCLE);
        if( out == 8'b11010011 && carry == 1'b1 ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0010 sub%b",out );
        #(`HCYCLE);

        ctrl = 4'b0001;//sub
        x    = 8'b00110101;
        y    = 8'b11111000;
        #(`HCYCLE);
        if( out == 8'b00111101 && carry == 1'b0 ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0010 sub%b",out );
        #(`HCYCLE);

        ctrl = 4'b0010;//and
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00110001 ) $display( "PASS --- 0010 and" );
        else $display( "FAIL --- 0010 add%b",out );
        #(`HCYCLE);        

        ctrl = 4'b0011;//or
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b11111101 ) $display( "PASS --- 0011 or" );
        else $display( "FAIL --- 0011 or%b",out );
        #(`HCYCLE);  
        ctrl = 4'b0100;//not
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b01001010 ) $display( "PASS --- 0100 not" );
        else $display( "FAIL --- 0100 not%b",out );
        #(`HCYCLE);  

        ctrl = 4'b0101;//xor
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b11001100 ) $display( "PASS --- 0101 xor" );
        else $display( "FAIL --- 0101 xor %b",out );
        #(`HCYCLE); 

        ctrl = 4'b0110;//nor
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00000010 ) $display( "PASS --- 0110 nor" );
        else $display( "FAIL --- 0110 nor%b",out );
        #(`HCYCLE);   

        ctrl = 4'b0111;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00100000 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);

        ctrl = 4'b1000;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b0000011 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);

        ctrl = 4'b1001;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b11011010 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);   
        ctrl = 4'b1010;//add
        x    = 8'b10110101;
        y    = 8'b01011001;
        #(`HCYCLE);
        if( out == 8'b01101011 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE); 

        ctrl = 4'b1011;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b11011010 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);

        ctrl = 4'b1100;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 1100 " );
        else $display( "FAIL --- 1100 %b",out );
        #(`HCYCLE);

        ctrl = 4'b1100;//add
        x    = 8'b10110101;
        y    = 8'b10110101;
        #(`HCYCLE);
        if( out == 8'b00000001 ) $display( "PASS --- 1100 " );
        else $display( "FAIL --- 1100 %b",out );
        #(`HCYCLE);
        ctrl = 4'b1101;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);  
        ctrl = 4'b1110;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);  

        ctrl = 4'b1111;//add
        x    = 8'b10110101;
        y    = 8'b01111001;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 0111 " );
        else $display( "FAIL --- 0111 %b",out );
        #(`HCYCLE);            

        // finish tb
        #(`CYCLE) $finish;
    end

endmodule
