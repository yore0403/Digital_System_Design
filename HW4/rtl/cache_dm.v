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
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready; 
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;

    reg [154:0] cache_mem_r [7:0];
    reg [154:0] cache_mem_w [7:0];
    
    reg proc_stall;
    reg [31:0] proc_rdata;

    reg [1:0] state_r;
    reg [1:0] state_w;

    reg mem_read, mem_write;
    reg [27:0] mem_addr;
    reg [127:0] mem_wdata;

    integer i;

    parameter IDLE          = 2'b00; 
    parameter COMPARE_TAG   = 2'b01;
    parameter WRITE_BACK    = 2'b10;
    parameter ALLOCATE      = 2'b11;
    
    wire cpu_valid;
    wire [2:0]  block_idx;
    wire [1:0]  data_offset;
    wire [24:0] data_tag;
    wire hit;
    assign cpu_valid            = proc_read || proc_write;
    assign data_tag             = proc_addr[29:5];    
    assign block_idx            = proc_addr[4:2];
    assign data_offset          = proc_addr[1:0];
    assign hit                  = cache_mem_r[block_idx][154] && (cache_mem_r[block_idx][152:128] == data_tag);

//==== combinational circuit ==============================
always @(*) begin
    //avoid latches
    for(i = 0 ; i < 8; i = i + 1) begin
        cache_mem_w[i] = cache_mem_r[i];
    end
    
    proc_stall = 1;
    proc_rdata = 0;
    state_w = state_r;
    
    mem_wdata = cache_mem_r[block_idx][127:0];   
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
            //Each block has a valid bit, the block is in the cache if the tags match and the valid bit is set.
            if (hit) begin
                cache_mem_w[block_idx][154]     = 1'b1; //set valid and tag
                cache_mem_w[block_idx][152:128] = data_tag;
                proc_stall = 0;
                state_w = IDLE; // already hit
                if (proc_write) begin
                    cache_mem_w[block_idx][153] = 1'b1; //set dirty
                    //write data
                    case(data_offset)
                        2'd0: cache_mem_w[block_idx][31:0]    = proc_wdata;
                        2'd1: cache_mem_w[block_idx][63:32]   = proc_wdata;
                        2'd2: cache_mem_w[block_idx][95:64]   = proc_wdata;
                        2'd3: cache_mem_w[block_idx][127:96]  = proc_wdata;
                    endcase

                end
                else begin
                //read data
                    case(data_offset)
                        2'd0: proc_rdata = cache_mem_r[block_idx][31:0];
                        2'd1: proc_rdata = cache_mem_r[block_idx][63:32];
                        2'd2: proc_rdata = cache_mem_r[block_idx][95:64];
                        2'd3: proc_rdata = cache_mem_r[block_idx][127:96];
                    endcase

                end
            end else begin
                if( cache_mem_r[block_idx][153] == 1'b1 ) begin
                    state_w = WRITE_BACK; 
                end 
                else begin
                    state_w = ALLOCATE; 
                end
            end
        end
        WRITE_BACK: begin
            //write old block to memory
            mem_addr = {cache_mem_r[block_idx][152:128],block_idx};
            mem_write = 1'b1;
            if (mem_ready) begin
                state_w = ALLOCATE;
               end
        end
        ALLOCATE: begin
            //read new memory from block
            mem_addr = proc_addr[29:2]; //left most 28 bit
            mem_read = 1'b1;
            if (mem_ready) begin
                state_w = COMPARE_TAG;

                
                cache_mem_w[block_idx][154] = 1'b1; // valid
                cache_mem_w[block_idx][153] = 1'b0; // not dirty
                cache_mem_w[block_idx][152:128] = data_tag;
                cache_mem_w[block_idx][127:0] = mem_rdata;
            end
        end
    endcase
end
//==== sequential circuit =================================
always@( posedge clk or posedge proc_reset ) begin
    if( proc_reset ) begin
        for(i = 0 ; i < 8; i = i + 1) begin
            cache_mem_r[i] <= 0;
        end
        state_r <= IDLE;

    end
    else begin
        for(i = 0 ; i < 8; i = i + 1) begin
            cache_mem_r[i] <= cache_mem_w[i];
        end
        state_r <= state_w;

    end
end

endmodule
