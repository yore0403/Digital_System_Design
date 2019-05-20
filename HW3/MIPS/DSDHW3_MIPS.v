// Single Cycle MIPS
//=========================================================
// Input/Output Signals:
// positive-edge triggered         clk
// active low synchronous reset   rst_n
// instruction memory interface    IR_addr, IR
// output for testing purposes     RF_writedata  
//=========================================================
// Wire/Reg Specifications:
// control signals             MemToReg, MemRead, MemWrite, 
//                             RegDST, RegWrite, Branch, 
//                             Jump, ALUSrc, ALUOp
// ALU control signals         ALUctrl
// ALU input signals           ALUin1, ALUin2
// ALU output signals          ALUresult, ALUzero
// instruction specifications  r, j, jal, jr, lw, sw, beq
// sign-extended signal        SignExtend
// MUX output signals          MUX_RegDST, MUX_MemToReg, 
//                             MUX_Src, MUX_Branch, MUX_Jump
// registers input signals     Reg_R1, Reg_R2, Reg_W, WriteData 
// registers                   Register
// registers output signals    ReadData1, ReadData2
// data memory contral signals CEN, OEN, WEN
// data memory output signals  ReadDataMem
// program counter/address     PCin, PCnext, JumpAddr, BranchAddr
//=========================================================

module SingleCycle_CHIP( 
    clk,
    rst_n,
    IR_addr,
    IR,
    RF_writedata,
    ReadDataMem,
    CEN,
    WEN,
    A,
    ReadData2,
    OEN
);

//==== in/out declaration =================================
    //-------- processor ----------------------------------
    input         clk, rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr, RF_writedata;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  // read_data from memory
    output        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output  [6:0] A;  // address
    output [31:0] ReadData2;  // write_data to memory
    output        OEN;  // output_enable, 0

//==== reg/wire declaration ===============================
wire  Jump,RegDst, MemRead, MemWrite, RegWrite, Branch, ALUSrc, zero, Jal, Jr;
wire        MemToReg;
wire    [2:0]   ALUOp;
wire    [4:0]   mux_2016_1511_out; 
wire    [31:0]  mux_RD2_sign_ext_out; 
wire    [31:0]ReadData1,ReadData2,WriteData,RF_writedata;
wire    [31:0]PC_4_out;

reg [31:0] IR_addr;
wire [31:0] IR_addr_r;

wire [2:0] ALU_ctrl;
wire [31:0] ALU_out;

wire [4:0] return_addr;

assign RF_writedata = WriteData;
//assign wire_constant_31 = 5'd31; //31
assign A = ALU_out[8:2];
assign return_addr = 5'd31;
assign  WEN = (MemWrite == 1'b1)? 1'b0 : 1'b1;
assign  OEN = 1'b0;
assign  CEN = 1'b0;

CONTROL CONTROL_0(
    .zero(zero)  , 
    .I_31_26(IR[31:26]), 
    .I_5_0(IR[5:0]),
    .RegDst(RegDst), 
    .Jump(Jump),
    .Branch(Branch),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc), 
    .ALUOp(ALUOp), 
    .MemWrite(MemWrite), 
    .MemToReg(MemToReg),
    .Jal(Jal),
    .Jr(Jr)
);
PROGRAM_CONTROL pc_0(
    .PC_in(IR_addr),
    .sign_ext({{16{IR[15]}},IR[15:0]}),
    .zero(zero),
    .Branch(Branch),
    .Jump(Jump),
    .Jr(Jr),
    .Jump_addr({{6{IR[25]}},IR[25:0]}),
    .Jr_addr(ReadData1),
    .PC_out(IR_addr_r),
    .PC_4_out(PC_4_out)
);

MUX_5_2 mux_2016_1511_0(
    .A(IR[20:16]),
    .B(IR[15:11]),
    .C(return_addr),
    .sel1(RegDst),
    .sel2(Jal),
    .mux_out(mux_2016_1511_out)
);

RegisterFile register_file_0(
    .clk(clk),
    .rst_n(rst_n),
    .ReadAddr1(IR[25:21]),
    .ReadAddr2(IR[20:16]),
    .WriteAddr(mux_2016_1511_out),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .WriteData(WriteData),
    .RW(RegWrite|Jal)//ctrl
);

MUX_32 mux_RD2_sign_ext_0(
    .A(ReadData2),
    .B({{16{IR[15]}},IR[15:0]}),
    .sel(ALUSrc),
    .mux_out(mux_RD2_sign_ext_out)
);


ALU_CTRL alu_ctrl_0(
    .op_10(ALUOp[1:0]),
    .funct_3_0(IR[3:0]),
    .ALU_ctrl(ALU_ctrl)
);

ALU_32_zero alu_32_zero_0(
    .ALU_in1(ReadData1),
    .ALU_in2(mux_RD2_sign_ext_out),
    .ALU_ctrl(ALUOp),
    .zero(zero),
    .ALU_out(ALU_out)
);


MUX_32_2 mux_32_mem_0(
    //.A(ReadDataMem),
    .A(ALU_out),
    .B(ReadDataMem),
    .C(PC_4_out),
    .sel1(MemToReg),
    .sel2(Jal),
    .mux_out(WriteData)
);


//==== combinational part =================================


//==== sequential part ====================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        IR_addr <= 0;
    end else begin
        IR_addr <= IR_addr_r;
        //$display("IR_addr",IR_addr);
    end
end

//=========================================================
endmodule



module PROGRAM_CONTROL(
    PC_in,
    sign_ext,
    zero,
    Branch,
    Jump,
    Jump_addr,
    PC_out,
    PC_4_out,
    Jr,
    Jr_addr
);
input           Jr, zero, Branch,Jump;
input   [31:0]   PC_in, sign_ext,Jump_addr,Jr_addr;
output  [31:0]   PC_out,PC_4_out;
wire    [31:0]   PC_4_out,sft_PC_4_out,branch_zero_out,Jr_addr;
reg     [31:0]   PC_out;
reg [1:0] w ;

assign PC_4_out = PC_in + 4;
assign sft_PC_4_out = PC_4_out + (sign_ext << 2);
//assign branch_zero_out = (Branch&zero)?sft_PC_4_out:PC_4_out;
//assign PC_out = Jump?(Jump_addr<<2):branch_zero_out;
always @(*) begin
    w ={{Jump|Jr},{(Branch&zero)|Jr}};
if(Jr)
    PC_out = Jr_addr;
else
    if(Jump)
        PC_out = (Jump_addr<<2);
    else if(Branch&zero)
        PC_out = sft_PC_4_out;
    else
        PC_out = PC_4_out;

end



endmodule

 

module RegisterFile(
    clk,
    rst_n,
    ReadAddr1,
    ReadAddr2,
    WriteAddr,
    ReadData1,
    ReadData2,
    WriteData,
    RW//ctrl
);
input   clk,rst_n,RW;
input   [4:0]ReadAddr1,ReadAddr2,WriteAddr;
input   [31:0]WriteData;
output  [31:0]ReadData1,ReadData2;

wire     [31:0]ReadData1,ReadData2;
reg     [31:0]reg_file_r[0:31];
//reg     [31:0]reg_file_w[0:31];

reg [5:0] i;


assign    ReadData1 = (ReadAddr1 != 32'b0) ? reg_file_r[ReadAddr1]: 32'b0;
assign    ReadData2 = (ReadAddr2 != 32'b0) ? reg_file_r[ReadAddr2]: 32'b0;

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            reg_file_r[0] <= 32'b0;
            reg_file_r[1] <= 32'b0;
            reg_file_r[2] <= 32'b0;
            reg_file_r[3] <= 32'b0;
            reg_file_r[4] <= 32'b0;
            reg_file_r[5] <= 32'b0;
            reg_file_r[6] <= 32'b0;
            reg_file_r[7] <= 32'b0;
            reg_file_r[8] <= 32'b0;
            reg_file_r[9] <= 32'b0;
            reg_file_r[10] <= 32'b0;
            reg_file_r[11] <= 32'b0;
            reg_file_r[12] <= 32'b0;
            reg_file_r[13] <= 32'b0;
            reg_file_r[14] <= 32'b0;
            reg_file_r[15] <= 32'b0;
            reg_file_r[16] <= 32'b0;
            reg_file_r[17] <= 32'b0;
            reg_file_r[18] <= 32'b0;
            reg_file_r[19] <= 32'b0;
            reg_file_r[20] <= 32'b0;
            reg_file_r[21] <= 32'b0;
            reg_file_r[22] <= 32'b0;
            reg_file_r[23] <= 32'b0;
            reg_file_r[24] <= 32'b0;
            reg_file_r[25] <= 32'b0;
            reg_file_r[26] <= 32'b0;
            reg_file_r[27] <= 32'b0;
            reg_file_r[28] <= 32'b0;
            reg_file_r[29] <= 32'b0;
            reg_file_r[30] <= 32'b0;
            reg_file_r[31] <= 32'b0;
    end else begin
        if(RW)reg_file_r[WriteAddr] <= WriteData;
    end

end

endmodule



module ALU_CTRL(
    //ALU_op,
    op_10,
    funct_3_0,
    ALU_ctrl
);

input   [1:0]   op_10;
input   [3:0]   funct_3_0;
output  [2:0]   ALU_ctrl;
wire [2:0]ALU_ctrl;


assign ALU_ctrl[0] = (funct_3_0[3]|funct_3_0[0])&op_10[1];
assign ALU_ctrl[1] = !(op_10[1] & funct_3_0[2]);
assign ALU_ctrl[2] = ((op_10[1]) & funct_3_0[1]) | op_10[0];


endmodule



module ALU_32_zero(
    ALU_in1,
    ALU_in2,
    ALU_ctrl,
    zero,
    ALU_out
);
input   [31:0]  ALU_in1,ALU_in2;
input   [2:0]   ALU_ctrl;
output  [31:0]  ALU_out;
output          zero;
reg     [31:0]  ALU_out;
reg             zero;

always @(*) begin
    zero = 0;


case (ALU_ctrl)
    3'b000:begin
        //$display("&");
        ALU_out = ALU_in1 & ALU_in2;
    end
    3'b001:begin
        //$display("|");
        ALU_out = ALU_in1 | ALU_in2;
    end
    3'b010:begin
        ALU_out = ALU_in1 + ALU_in2;
        //$display("add %d",ALU_out);
    end
    3'b110:begin
        //$display("-");

        ALU_out = ALU_in1 - ALU_in2;
        zero = !ALU_out;
        /*
        if(ALU_out == 32'b0) begin
            zero = 1'b1;
        end 
        */        
    end
    3'b111:begin
        //$display("diff");
        ALU_out = ALU_in1[31] | ALU_in2[31]?ALU_in1[31]:ALU_in1[30:0] < ALU_in2[30:0];
        /*
        if (ALU_in1[31] != ALU_in2[31]) begin //different sign
            if (ALU_in1[31]) begin
                ALU_out = 32'b1;
            end else begin
                ALU_out = 32'b0;
            end
        end else begin //same sign
            if (ALU_in1[30:0] < ALU_in2[30:0]) begin
                ALU_out = 32'b1;
            end else begin
                ALU_out = 32'b0;
            end
        end
        */
    end
    default : begin 
        ALU_out = 31'b0;
        //$display("def");
    end
endcase
end
endmodule

module CONTROL(
    zero,
    I_31_26,
    I_5_0,
    RegDst,
    Jump,
    Branch,
    RegWrite,
    ALUSrc,
    ALUOp,
    MemWrite,
    MemToReg,
    Jal,
    Jr
);

input   zero;
input   [5:0] I_31_26; //opcode
input   [5:0] I_5_0;
output   MemToReg;
output  RegDst, Branch, RegWrite, ALUSrc, MemWrite, Jump, Jal,Jr;

output  [2:0] ALUOp; //ALUOp is ALUControl here

reg     RegDst, Branch, RegWrite, ALUSrc, MemWrite, Jump, Jal,Jr;
reg      MemToReg;
reg     [2:0] ALUOp;

always @(*) begin
    ALUOp    = 3'b000;
    //RegDst   = 2'b0;
    MemToReg = 1'b0;
    Jump     = 1'b0;
    RegWrite = 1'b0;
    Branch   = 1'b0;
    ALUSrc   = 1'b0;
    MemWrite = 1'b0;
    Jal      = 1'b0;
    Jr       = 1'b0;
    case(I_31_26) //opcode
        6'b000000:begin //R type
            RegDst   = 2'b1;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUSrc   = 1'b0;
            MemWrite = 1'b0;
            case(I_5_0) //funct
                6'b100000: begin //add
                    ALUOp    = 3'b010;
                    Jump     = 1'b0;
                end
                6'b100010: begin //SUB
                    ALUOp    = 3'b110;
                    Jump     = 1'b0;
                end
                6'b100100: begin //and
                    ALUOp    = 3'b000;
                    Jump     = 1'b0;
                end
                6'b100101: begin //or
                    ALUOp    = 3'b001;
                    Jump     = 1'b0;
                end
                6'b101010: begin //slt
                    ALUOp    = 3'b111;
                    Jump     = 1'b0;
                end
                6'b001000: begin //jr
                    ALUOp    = 3'b000;
                    Jump     = 1'b0;
                    Jr       = 1'b1;

                end
            endcase
        end
        6'b000100: begin //beq
            ALUOp    = 3'b110;//-
            RegDst   = 1'b0;
            MemToReg = 1'b0;
            Jump     = 1'b0;
            RegWrite = 1'b0;
            Branch   = 1'b1;
            ALUSrc   = 1'b0;
            MemWrite = 1'b0;
        end
        6'b100011: begin //lw
            ALUOp    = 3'b010;
            RegDst   = 1'b0;
            MemToReg = 1'b1;
            Jump     = 1'b0;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUSrc   = 1'b1;
            MemWrite = 1'b0;
        end
        6'b101011: begin //sw
            ALUOp    = 3'b010;
            RegDst   = 1'b0;
            MemToReg = 1'b0; //should be dont care
            Jump     = 1'b0;
            RegWrite = 1'b0;
            Branch   = 1'b0;
            ALUSrc   = 1'b1;
            MemWrite = 1'b1;
        end
        6'b000010: begin //j
            ALUOp    = 3'b000;
            RegDst   = 1'b0;
            MemToReg = 1'b0;
            Jump     = 1'b1;
            RegWrite = 1'b0;
            Branch   = 1'b0;
            ALUSrc   = 1'b0;
            MemWrite = 1'b0;
        end
        6'b000011: begin //jal
            ALUOp    = 3'b000;
            RegDst   = 1'b0;
            MemToReg = 1'b0;
            Jump     = 1'b1;
            RegWrite = 1'b1;
            Branch   = 1'b0;
            ALUSrc   = 1'b0;
            MemWrite = 1'b0;
            Jal      = 1'b1;
        end
    endcase
end
endmodule

module MUX_32(
    A,
    B,
    sel,
    mux_out

);

input   [31:0]  A, B;
input           sel;
output  [31:0]  mux_out;
reg     [31:0]  mux_out;

always @(*) begin
    //mux_out = 32'b0;
    if(~sel) begin
        mux_out = A;
    end else begin
        mux_out = B;
    end
end
endmodule

module MUX_32_2(
    A,
    B,
    C,
    sel1,
    sel2,
    mux_out

);

input   [31:0]  A, B, C;
input           sel1,sel2;
output  [31:0]  mux_out;
reg     [31:0]  mux_out;

always @(*) begin
    //mux_out = 32'b0;
case({sel1,sel2})
    2'b00:mux_out = A;
    2'b10:mux_out = B;
    2'b01:mux_out = C;
    default:mux_out = 0;
endcase
end
endmodule

module MUX_5_2(
    A,
    B,
    C,
    sel1,
    sel2,
    mux_out

);

input   [4:0]  A, B, C;
input           sel1,sel2;
output  [4:0]  mux_out;
reg     [4:0]  mux_out;

always @(*) begin
    //mux_out = 32'b0;
case({sel1,sel2})
    2'b00:mux_out = A;
    2'b10:mux_out = B;
    2'b01:mux_out = C;
    default:mux_out = 0;
endcase
end
endmodule

module MUX_5(
    A,
    B,
    sel,
    mux_out

);

input   [4:0]  A, B;
input           sel;
output  [4:0]  mux_out;
reg     [4:0]  mux_out;

always @(*) begin
    //mux_out = 32'b0;
    if(~sel) begin
        mux_out = A;
    end else begin
        mux_out = B;
    end
end
endmodule


