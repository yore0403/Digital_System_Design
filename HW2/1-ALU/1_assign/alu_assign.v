//RTL (use continuous assignment)
module alu_assign(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    wire  [8:0] out1;
    output       carry;
    output [7:0] out;
    assign out1 = ctrl[0]?{{x[7]},x}-{{y[7]},y}:{{x[7]},x}+{{y[7]},y};
    assign  out = 
            (ctrl[3]?
                (ctrl[2]?
                    (ctrl[1]?
                        8'b0//1110,1111
                    :
                        (ctrl[0]? 8'b0 : x == y )
                    )
                :
                    (ctrl[1]?
                        (ctrl[0]?{x[0] , x[7:1]}:{x[6:0] , x[7]})
                    :
                        (ctrl[0]?{x[7],x[7:1]}:y >> x[2:0])
                    )
                )                
            :
                (ctrl[2]?
                    (ctrl[1]?
                        (ctrl[0]?y << x[2:0]:~(x|y))
                    :
                        (ctrl[0]?x^y:~x)
                    )
                :
                    (ctrl[1]?
                        (ctrl[0]?x|y:x&y)
                    :
                        //(ctrl[0]?x-y:x+y)
			out1[7:0]
                    )
                )   
            );
    
    assign carry = ctrl[3:1] == 3'b0 ? out1[8]:0;
                    

endmodule
