/// Single Cycle RISCV
//=========================================================
// Input/Output Signals:
// positive-edge triggered         clk
// active low synchronous reset   rst_n
// instruction memory interface    IR_addr, IR
// output for testing purposes     RF_writedata  
//=========================================================
// Wire/Reg Specifications:
// control signals             MemToReg, MemRead, MemWrite, 
//                             RegWrite, Branch,
//                             Jalr, Jal, ALUSrc, ALUOp
// ALU control signals         ALUctrl
// ALU output signals          ALUresult, ALUzero
// instruction specifications  r, jal, jalr, lw, sw, beq
// registers input signals     Reg_R1, Reg_R2, Reg_W, WriteData 
// immediate generated signals ImmGenOut
// registers output signals    ReadData1, ReadData2
// data memory control signals CEN, OEN, WEN
// data memory output signals  ReadDataMem
// Memory address              A
//=========================================================
//==== parameter declaration ==============================

`define ALU_CTRL_AND  4'b0000
`define ALU_CTRL_OR   4'b0001
`define ALU_CTRL_ADD  4'b0010
`define ALU_CTRL_SUB  4'b0110
`define ALU_CTRL_SLT  4'b1000

`define OPCODE_6_2_JAL  5'b11011
`define OPCODE_6_2_JR   5'b11001
`define OPCODE_6_2_SW   5'b01000
`define OPCODE_6_2_LW   5'b00000
`define OPCODE_6_2_BEQ  5'b11000
`define OPCODE_6_2_R    5'b01100

//==== module =============================================
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
    input  [31:0] IR;//program script
    output [31:0] IR_addr;//program counter
    output [31:0] RF_writedata;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  // read_data from memory
    output        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output  [6:0] A;  // address
    output [31:0] ReadData2;  // write_data to memory
    output        OEN;  // output_enable, 0



//==== reg/wire declaration ===============================
reg     [31:0]  IR_addr;
wire    [31:0]  IR_addr_r;
wire    [31:0]  IR_ = {{IR[7:0]},{IR[15:8]},{IR[23:16]},{IR[31:24]}};
wire    [31:0]  ReadDataReg = {{ReadDataMem[7:0]},{ReadDataMem[15:8]},{ReadDataMem[23:16]},{ReadDataMem[31:24]}};
//CONTROL_0
wire            Branch, RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Jal, Jalr, RW;
//RegisterFile
wire    [31:0]  ReadData1;
wire    [31:0]  ReadData2_;
wire    [31:0]  WriteData;
//IMM_GEN
wire    [31:0]  immediate;
//MUX_src
wire    [31:0]  RD2_imm_out;
//ALU_CTRL
wire    [3:0]   ALU_ctrl;
//ALU
wire zero;
wire [31:0]ALU_out;
//MUX
wire    [31:0]  WriteData_;
wire [31:0] PC_4_out;



//==== combinational part =================================


assign  RF_writedata = WriteData;
assign  A            = ALU_out[8:2]; // not sure
assign  WEN          = ~MemWrite;
assign  OEN          = 1'b0;
assign  CEN          = 1'b0;
assign  ReadData2    = {{ReadData2_[7:0]},{ReadData2_[15:8]},{ReadData2_[23:16]},{ReadData2_[31:24]}};


CONTROL_0 control_0(
    //.funct3(IR[22:20]),//IR_[14:12]
    .op_6_2(IR_[6:2]),//IR[30:26]
    .Jal(Jal),
    .Jalr(Jalr),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemToReg(MemToReg),   
    .MemWrite(MemWrite),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc)
);


RegisterFile register_file_0(
    .clk(clk),
    .rst_n(rst_n),
    .ReadAddr1(IR_[19:15]),//{IR[11:8],IR[23]}
    .ReadAddr2(IR_[24:20]),//{IR[0],IR[15:12]}
    .WriteAddr(IR_[11:7]),//{IR[19:16],IR[31]}
    .ReadData1(ReadData1),
    .ReadData2(ReadData2_),
    .WriteData(WriteData),
    .RW(RegWrite)//ctrl
);

IMM_GEN imm_gen_0(
    .inst(IR_),
    .immediate(immediate)
);


MUX_32 mux_32_src_0(
    .A(ReadData2_),
    .B(immediate),
    .sel(ALUSrc),
    .mux_out(RD2_imm_out)
);

ALU_CTRL_0 alu_ctrl_0(
    .op_43(IR_[4:3]),//IR[28:27]
    .funct3(IR_[14:12]),//IR[22:20]
    .funct7_5(IR_[30]),//IR[6]
    .ALU_ctrl(ALU_ctrl)
);

ALU_32_zero alu_32_zero_0(
    .ALU_in1(ReadData1),
    .ALU_in2(RD2_imm_out),
    .ALU_ctrl(ALU_ctrl),
    .zero(zero),
    .ALU_out(ALU_out)
);

//memory
/*
MUX_32 mux_32_mem_0(
    .A(ReadDataReg),
    .B(ALU_out),
    .sel(MemToReg),
    .mux_out(WriteData_)
);

MUX_32 mux_jalr_regwrite_0(
    .A(WriteData_),
    .B(PC_4_out),
    .sel(Jalr|Jal),
    .mux_out(WriteData)
)*/
MUX_32_2 mux_32_mem_jalr_regwrite_0(//combine mux_32_mem_0 mux_jalr_regwrite_0
    .A(ReadDataReg),
    .B(ALU_out),
    .C(PC_4_out),
    .sel1(MemToReg),
    .sel2(Jalr),
    .sel3(Jal),
    .mux_out(WriteData)
);
PROGRAM_COUNTER pc_0(
    .clk(clk),
    .rst_n(rst_n),
    .Branch(Branch),
    .zero(zero),
    .Jal(Jal),
    .Jalr(Jalr),
    .PC_in(IR_addr),
    .immediate(immediate),
    .ReadData1(ReadData1),
    .PC_4_out(PC_4_out),
    .PC_out(IR_addr_r)
);


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
//==== submodule ==========================================




module PROGRAM_COUNTER (
    clk,
    rst_n,
    Branch,
    zero,
    Jal,
    Jalr,
    PC_in,
    immediate,
    ReadData1,
    PC_4_out,
    PC_out
);


input   clk, rst_n ,Branch,zero,Jal,Jalr;
input   [31:0]  PC_in,immediate,ReadData1;
output  [31:0]  PC_out,PC_4_out;
wire    [31:0]  PC_out, PC_4_out;
reg     [31:0]  IR_imm_4_out,RD1_imm_out,PC_imm_out;

assign PC_4_out = PC_in + 4;
assign PC_out = Jalr?(ReadData1+immediate):IR_imm_4_out;
always @(*) begin
if((Branch&zero)|Jal)begin
    IR_imm_4_out = PC_in + immediate;
end else begin
    IR_imm_4_out = PC_4_out;
end
end

/*
assign PC_4_out = PC_in + 4;
always @(*) begin

RD1_imm_out = ReadData1+immediate;
PC_imm_out = PC_in + immediate;

case({{(Branch&zero)|Jal},{Jalr}})
    2'b00:PC_out = PC_4_out;
    2'b01,2'b11:PC_out = RD1_imm_out;
    2'b10:PC_out = PC_imm_out;
endcase
end


assign PC_4_out = PC_in + 4;
assign PC_out = (Jalr|(Branch&zero)|Jal)?((Jalr?ReadData1:PC_in)+immediate):PC_4_out;
*/
endmodule


//immediate generator======================================
module IMM_GEN(
    inst,
    immediate
);
input   [31:0]  inst;
output  [31:0]  immediate;
reg     [31:0]  immediate;
always @(*) begin
            immediate[31:20] = {12{inst[31]}};
            immediate[10:5] = inst[30:25];

    case(inst[6:2])
        `OPCODE_6_2_JAL: begin//jal
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25];
            immediate[19:12] = inst[19:12];
            immediate[11] = inst[20];
            immediate[4:1] = inst[24:21];
            immediate[0] = 0;
        end
        `OPCODE_6_2_JR: begin//jr
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25];
            immediate[19:12] = {8{inst[31]}};
            immediate[11] = inst[31];
            immediate[4:0] = inst[24:20];
        end
        `OPCODE_6_2_SW: begin//sw
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25];
            immediate[19:12] = {8{inst[31]}};
            immediate[11] = inst[31];
            //immediate[4:0] = inst[11:7];
            immediate[4:1] = inst[11:8];
            immediate[0] = inst[7];
        end
        `OPCODE_6_2_LW:begin//lw ALU
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25];
            immediate[19:12] = {8{inst[31]}};
            immediate[11] = inst[31];
            //immediate[4:0] = inst[24:20];
            immediate[4:1] = inst[24:21];
            immediate[0] = inst[20];
        end
        `OPCODE_6_2_BEQ:begin//BEQ
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25];
            immediate[19:12] = {8{inst[31]}};
            immediate[11] = inst[7];
            immediate[4:1] = inst[11:8];
            immediate[0] = 1'b0;
        end
    
        default : begin//R-type
            //immediate[31:20] = {12{inst[31]}};
            //immediate[10:5] = inst[30:25]; 
            immediate[19:12] = 8'b0;
            immediate[11] = 1'b0;
            immediate[4:1] = 4'b0;
            immediate[0] = 1'b0;
        end
    endcase

end
endmodule

module CONTROL_0(
    op_6_2,
    Jal,
    Jalr,
    Branch,
    MemRead,
    MemToReg,    
    MemWrite,
    RegWrite,
    ALUSrc
);
input   [4:0] op_6_2;
output  MemToReg, Jal, Jalr;
output  Branch, RegWrite, ALUSrc, MemRead, MemWrite;

//output  [2:0] ALUOp; //ALUOp is ALUControl here

reg     Branch, RegWrite, ALUSrc, MemWrite, MemRead;
reg     MemToReg, Jal, Jalr;
//reg     [2:0] ALUOp;

always @(*) begin
    //ALUOp    = 3'b000;
    MemToReg = 1'b0;
    Jal      = 1'b0;
    Jalr     = 1'b0;
    RegWrite = 1'b0;
    Branch   = 1'b0;
    ALUSrc   = 1'b0;
    MemWrite = 1'b0;
    MemRead  = 1'b0;

    case(op_6_2) //opcode
        `OPCODE_6_2_R: begin //R type
            MemToReg = 1'b1;
            //jal      = 1'b0;
            //jalr     = 1'b0;
            RegWrite = 1'b1;
            //Branch   = 1'b0;
            //ALUSrc   = 1'b0;
            //MemWrite = 1'b0;
            //MemRead  = 1'b0;
        end
        `OPCODE_6_2_SW: begin //beq sw
            //MemToReg = 1'b0;
            //jal      = 1'b0;
            //jalr     = 1'b0;
            //RegWrite = 1'b0;
            //Branch   = 1'b0;
            //MemWrite = 1'b0;
            //MemRead  = 1'b0;
            ALUSrc   = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b1;
        end
        `OPCODE_6_2_BEQ: begin //beq
            //MemToReg = 1'b0;
            //jal      = 1'b0;
            //jalr     = 1'b0;
            //RegWrite = 1'b0;
            //Branch   = 1'b0;
            //MemWrite = 1'b0;
            //MemRead  = 1'b0;
            ALUSrc   = 1'b0;
            Branch = 1'b1;
            MemWrite = 1'b0;
        end
        `OPCODE_6_2_JR: begin //Jalr
            //MemToReg = 1'b0;
            //jal      = 1'b0;
            Jalr     = 1'b1;
            RegWrite = 1'b1;
            //Branch   = 1'b0;
            //ALUSrc   = 1'b0;
            //MemWrite = 1'b0;
            //MemRead  = 1'b0;
        end
        `OPCODE_6_2_JAL: begin //Jal
            //MemToReg = 1'b0;
            Jal      = 1'b1;
            //jalr     = 1'b0;
            RegWrite = 1'b1;
            //Branch   = 1'b0;
            //ALUSrc   = 1'b0;
            //MemWrite = 1'b0;
            //MemRead  = 1'b0;
        end
        `OPCODE_6_2_LW: begin //lw
            //MemToReg = 1'b0;
            //jal      = 1'b0;
            //jalr     = 1'b0;
            RegWrite = 1'b1;
            //Branch   = 1'b0;
            ALUSrc   = 1'b1;
            //MemWrite = 1'b0;
            MemRead  = 1'b1;
        end
            default:;
    endcase
end
endmodule

//==== RegisterFile =============================================

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

//==== ALU_Control =============================================


module ALU_CTRL_0(
    //ALU_op,
    op_43,
    funct3,
    funct7_5,
    ALU_ctrl
);
//input ALU_op;
input   [1:0]   op_43;
input   [2:0]   funct3;
input           funct7_5;
output  [3:0]   ALU_ctrl;
wire    [3:0]   ALU_ctrl;

assign ALU_ctrl[0] = op_43[1] & funct3[2] & funct3[1] & (~funct3[0]);
assign ALU_ctrl[1] = ~(op_43[1] & (~op_43[0]) & funct3[1]);
assign ALU_ctrl[2] = ((~op_43[1]) & (~funct3[1])) | (funct7_5 & op_43[1]);
assign ALU_ctrl[3] = op_43[1] & (~funct3[2]) & funct3[1];

endmodule


//ALU_32===================================================
//0000  AND     AND(bit)
//0001  OR      OR
//0010  ADD     LW SW
//0110  SUB     SUB BR
//1000  SLT     SLT
//ALU_ctrl[0] = OP[4] & funct3[2] & funct3[1] & (!funct3[0])
//ALU_ctrl[1] = !(OP[4] & (!OP[3]) & funct3[1])
//ALU_ctrl[2] = ((!OP[4]) & (!funct3[1])) | (funct7[5] & OP[4])
//ALU_ctrl[3] = OP[4] & (!funct3[2]) & funct3[1]

//=========================================================

module ALU_32_zero(
    ALU_in1,
    ALU_in2,
    ALU_ctrl,
    zero,
    ALU_out
);
input   [31:0]  ALU_in1,ALU_in2;
input   [3:0]   ALU_ctrl;
output  [31:0]  ALU_out;
output          zero;
reg     [31:0]  ALU_out;
reg             zero;
wire     [31:0]  sub = ALU_in1 - ALU_in2;
wire     [31:0]  add = ALU_in1 + ALU_in2;

always @(*) begin
    zero = 0;


case (ALU_ctrl)
    `ALU_CTRL_AND:begin
        //$display("&");
        ALU_out = ALU_in1 & ALU_in2;
    end
    `ALU_CTRL_OR:begin
        //$display("|");
        ALU_out = ALU_in1 | ALU_in2;
    end
    `ALU_CTRL_ADD:begin
        ALU_out = add;
        //ALU_out = ALU_in1 + ALU_in2;
        //$display("add %d",ALU_out);
    end
    `ALU_CTRL_SUB:begin
        //$display("-");

        ALU_out = sub;
        //ALU_out = ALU_in1 - ALU_in2;
        zero = !ALU_out;
        /*
        if(ALU_out == 32'b0) begin
            zero = 1'b1;
        end 
        */        
    end
    `ALU_CTRL_SLT:begin
        //$display("diff");
        ALU_out = ALU_in1[31] | ALU_in2[31] ? ALU_in1[31] : ALU_in1[30:0] < ALU_in2[30:0];
    end
    default : begin 
        ALU_out = 31'b0;
        //$display("def");
    end
endcase
end

endmodule

//MUX_32===================================================
module MUX_32_2(
    A,
    B,
    C,
    sel1,
    sel2,
    sel3,
    mux_out

);

input   [31:0]  A, B, C;
input           sel1,sel2,sel3;
output  [31:0]  mux_out;
reg     [31:0]  mux_out;

always @(*) begin
case ({sel1,{sel2|sel3}})
    2'b11,2'b01:mux_out = C;
    2'b00:mux_out = A;
    2'b10:mux_out = B;

    default :mux_out = 0;
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

//memory_data convert to reg_data
/*
module mem_to_reg_data_convert(
    mem_data,
    reg_data
    );
input   [31:0] mem_data;
output  [31:0] reg_data;
reg    [31:0] reg_data;

always @(*)reg_data = {{mem_data[7:0]},{mem_data[15:8]},{mem_data[23:16]},{mem_data[31:24]}};


endmodule
*/

