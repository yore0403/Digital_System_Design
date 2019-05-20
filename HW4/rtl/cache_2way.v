module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;

    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;

    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    
    reg [155:0] cache_mem_r [1:0][3:0]; 
    reg [155:0] cache_mem_w [1:0][3:0]; 
    reg [3:0] LRU_array_r;
    reg [3:0] LRU_array_w;

    reg proc_stall;
    reg [31:0] proc_rdata;

    reg [1:0] state_r,state_w;

    reg mem_read, mem_write;
    reg [27:0] mem_addr;
    reg [127:0] mem_wdata;
    reg choose_way_r, choose_way_w;
    integer i;

    parameter IDLE          = 2'd0; 
    parameter COMPARE_TAG   = 2'd1;
    parameter WRITE_BACK    = 2'd2;
    parameter ALLOCATE      = 2'd3;
    
    wire cpu_valid;
    wire [1:0]  block_idx;
    wire [1:0]  data_offset;
    wire [25:0] data_tag;
    wire hit0,hit1;
    assign cpu_valid        = proc_read || proc_write;
    assign data_tag         = proc_addr[29:4];
    assign block_idx        = proc_addr[3:2];
    assign data_offset      = proc_addr[1:0];
    assign hit0             = cache_mem_r[0][block_idx][155] && (cache_mem_r[0][block_idx][153:128] == data_tag);
    assign hit1             = cache_mem_r[1][block_idx][155] && (cache_mem_r[1][block_idx][153:128] == data_tag);

//==== combinational circuit ==============================
always @(*) begin
    for(i = 0 ; i < 4; i = i + 1) begin
        cache_mem_w[0][i] = cache_mem_r[0][i];
        cache_mem_w[1][i] = cache_mem_r[1][i];
    end
    
    proc_stall = 1;
    proc_rdata = 0;
    state_w = state_r;

    LRU_array_w = LRU_array_r;
    choose_way_w = choose_way_r;

    mem_wdata = cache_mem_r[choose_way_r][block_idx][127:0];

    mem_read    = 0;
    mem_write   = 0;
    mem_addr    = 0;
    
    case(state_r)
        IDLE:begin
            if( cpu_valid ) begin
                state_w = COMPARE_TAG;
            end
        end
        COMPARE_TAG: begin
            if(hit0|hit1) begin

                choose_way_w = ~hit0;//hit0 = 1 => choose_way = 0
                LRU_array_w[block_idx] = hit0;//hit0 = 1 => LRU = 1
                proc_stall = 1'b0;                
                state_w = IDLE; // already hit 

                if (proc_write) begin
                    cache_mem_w[choose_way_w][block_idx][154] = 1'b1; //set dirty
                    //write data
                    case(data_offset)
                        2'd0: cache_mem_w[choose_way_w][block_idx][31:0]    = proc_wdata;
                        2'd1: cache_mem_w[choose_way_w][block_idx][63:32]   = proc_wdata;
                        2'd2: cache_mem_w[choose_way_w][block_idx][95:64]   = proc_wdata;
                        2'd3: cache_mem_w[choose_way_w][block_idx][127:96]  = proc_wdata;
                    endcase

                end else begin
                    //read data
                    case(data_offset)
                        2'd0: proc_rdata = cache_mem_r[choose_way_w][block_idx][31:0];
                        2'd1: proc_rdata = cache_mem_r[choose_way_w][block_idx][63:32];
                        2'd2: proc_rdata = cache_mem_r[choose_way_w][block_idx][95:64];
                        2'd3: proc_rdata = cache_mem_r[choose_way_w][block_idx][127:96];
                    endcase
                    
                end
            end else begin //miss                
                choose_way_w = LRU_array_r[block_idx];//update choose_way by LRU array
                LRU_array_w = LRU_array_r;
                if( cache_mem_r[choose_way_w][block_idx][154] == 1'b1 )
                    state_w = WRITE_BACK; //dirty
                else
                    state_w = ALLOCATE;   //clean

            end


        end
        WRITE_BACK: begin
            //write old block to memory
            mem_addr = {cache_mem_r[choose_way_r][block_idx][153:128],block_idx}; 
            mem_write = 1'b1;
            if (mem_ready) begin
                state_w = ALLOCATE;
            end
        end
        ALLOCATE: begin
            //read new memory from block
            mem_addr = proc_addr[29:2]; 
            mem_read = 1'b1;
            if (mem_ready) begin
                state_w = COMPARE_TAG;
                              
                cache_mem_w[choose_way_r][block_idx][155] = 1'b1; 
                cache_mem_w[choose_way_r][block_idx][154] = 1'b0; 
                cache_mem_w[choose_way_r][block_idx][153:128] = data_tag;
                cache_mem_w[choose_way_r][block_idx][127:0] = mem_rdata;  
            end
        end
    endcase
end
//==== sequential circuit =================================
always@( posedge clk or posedge proc_reset ) begin
    if( proc_reset ) begin
        for(i = 0; i < 4; i = i + 1) begin
            cache_mem_r[0][i] <= 0;
            cache_mem_r[1][i] <= 0;
        end
        LRU_array_r     <= 0;
        state_r           <= IDLE;
        choose_way_r    <= 0;
    end
    else begin
        for(i = 0; i < 4; i = i + 1) begin
            cache_mem_r[0][i] <= cache_mem_w[0][i];
            cache_mem_r[1][i] <= cache_mem_w[1][i];
        end
        LRU_array_r <= LRU_array_w;
        state_r <= state_w;
        choose_way_r <= choose_way_w;

    end
end

endmodule