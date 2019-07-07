`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2019 09:46:14 PM
// Design Name: 
// Module Name: register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



//Stage_1

module PC (
    input         RST,
    input         clk,
    input [31:0] beq_PC,
    input         hold,
    input         hold_2, 
    input         PC_control,
    output [31:0] address
    );
    
    reg [31:0] add_reg ;
    reg [31:0] next_PC ;
    integer file ;
    
assign address = add_reg ;

always @(posedge clk)
    begin
       if(RST)
            begin
             next_PC = 0;
             add_reg = 0;
            end
       
        else if (!PC_control)
            begin
                add_reg = beq_PC ;
              if(!hold)
                next_PC = beq_PC ;
            end
            
        else if (PC_control)
            begin
                  if(hold)
                     next_PC = next_PC - 4 ;
                  else
                     next_PC = next_PC + 4 ;
                     
                  add_reg = next_PC;
               
            end
                   
    end
    
    initial
        begin
            file = $fopen("E:/sandy/projects/co 2/mips/output_file/pc.txt");
            $fmonitor(file,"%d",(address/4));
        end
endmodule


module INSmem(instruction , address);

input  [31:0] address;
output [31:0] instruction;

reg    [31:0] instr_mem [0:1023];

assign instruction = instr_mem[address/4];

initial
    begin
        $readmemb("E:/sandy/projects/co 2/mips/test_case/code1.txt", instr_mem);
    end

endmodule



module stage1 (
    input RST,
    input [31:0]  beq_PC,
    input         clk,
    input         hold,
    input         hold_2,
    input         PC_control,
    output [31:0] next_PC,
    output [31:0] instruction
    );
    
    wire [31:0] PC_connection;
    
    assign  next_PC = PC_connection;
    
    PC       p   (RST, clk, beq_PC, hold,hold_2, PC_control,PC_connection);
    INSmem   IM  (instruction , PC_connection);
    
endmodule


///////////////***tb fot stage 1 ***///////////////////////

module tb_stage1();
         reg RST;
         reg [31:0]  beq_PC;
         reg         clk;
         reg         hold;
         reg         hold_2;
         reg         PC_control;
         wire [31:0] next_PC;
         wire [31:0] instruction;
         
   stage1 s1( RST,  beq_PC, clk, hold, hold_2, PC_control,next_PC, instruction );   
   
   always
      begin
         #5 clk= ~clk ;
      end
   
   
   initial
      begin
         clk   = 0;
          RST  = 1;
          hold = 0;
         $monitor("next_PC = %d , instruction = %b " , (next_PC/4), instruction );
         #10
         RST=1;
         beq_PC = 12;       
         PC_control = 1;
         #5

         beq_PC = 12;       
         PC_control = 0;
         #5

         beq_PC = 12;       
         hold=1 ;
         PC_control = 1;
         #5
         
         beq_PC = 16;       
         hold   = 0 ;
         PC_control = 0;
    
      end   

endmodule

/////////////*** stage 2 ***///////////////////////////////

module regfile(
    input  [4:0]  read1,
    input  [4:0]  read2,
    input  [4:0]  write_reg, 
    input  [31:0] data,
    input         reg_write,
    input         clk,
    output [31:0] data1,
    output [31:0] data2
    );
    
    reg [31:0] reg_mem [0:31];
    integer file ;
    integer i;
     
    assign data1 = reg_mem [read1];
    assign data2 = reg_mem [read2];
    
    always @(posedge clk)
        if(reg_write)
            reg_mem[write_reg] <= data ;
   initial
      begin
        $readmemb("E:/sandy/projects/co 2/mips/test_case/code2.txt", reg_mem);
        
        file = $fopen("E:/sandy/projects/co 2/mips/output_file/reg_mem.txt");
        $fmonitor(file,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d "
        ,reg_mem[0],reg_mem[0],reg_mem[1],reg_mem[2],reg_mem[3] ,reg_mem[4],reg_mem[5] ,reg_mem[6],reg_mem[7]
         ,reg_mem[8],reg_mem[9] ,reg_mem[10],reg_mem[11] ,reg_mem[12],reg_mem[13],reg_mem[14],reg_mem[15]
         ,reg_mem[16],reg_mem[17],reg_mem[18],reg_mem[19] ,reg_mem[20] ,reg_mem[21] ,reg_mem[22] ,reg_mem[23]
         ,reg_mem[24],reg_mem[25],reg_mem[26],reg_mem[27],reg_mem[28],reg_mem[29],reg_mem[30] ,reg_mem[31]);
                
      end 
      
              
endmodule


module signextend(
    input  [15:0] in,
    output [31:0] out
     );
     
    assign out = { {16 {in[15]} }, in };
     
endmodule


module control (
    input [31:0] data1,
    input [31:0] data2,
    input RST,
    input [5:0] in , // connect to instruction[31:26]
    input [5:0] FN, // connect to instruction[5:0]
    output jump,
    output branch,
    output mem_read,
    output mem_write,
    output mem_to_reg,
    output ALUSrc,
    output RegWrite,
    output RegDst,
    output IF_flush,
    output [2:0] ALUop
    );
    
    
    assign IF_flush    = (RST)? 0 :((branch || jump)? 1 : 0) ;  // this signal to make IF/ID reg = 0 
    assign RegDst      = (RST)? 0 :((in == 0 )? 1 :(( in == 6'b100011 || in == 6'b001000 || in == 6'b001101 )? 0 : 6'bx) );
    assign ALUSrc      = (RST)? 0 :((in == 6'b100011  || in == 6'b101011 || in == 6'b001000 || in == 6'b001101)? 1 : 0 );
    assign mem_to_reg  = (RST)? 0 :((in ==0 || in == 6'b001000 || in == 6'b001101 )? 0: (( in == 6'b100011)? 1 : 6'bx) );
    assign RegWrite    = (RST)? 0 :((in ==0 || in == 6'b100011 || in == 6'b001000 || in == 6'b001101 /*|| in ==6'b000011*/)? 1: (( /*in == 6'b000100 */ jump || branch || in == 6'b101011 )? 0 : 6'bz));
    assign mem_read    = (RST)? 0 :((in == 6'b100011 )? 1 : 0 );
    assign mem_write   = (RST)? 0 :((in ==0 || in == 6'b000100 || in == 6'b100011 || in == 6'b001101 )? 0: ((in == 6'b101011 )? 1: 6'bx ));
    assign branch      = (RST)? 0 :(((in == 6'b000100 )  && (data1 == data2))? 1 : 0 );
    assign jump        = (RST)? 0 :((in ==6'b000010 || in ==6'b000011 || ((in == 0)&&(FN ==6'b001000)) )? 1 : 0 );
    assign ALUop       = (RST)? 3'b100 :((in ==0 )? 3'b100 : ((in == 6'b100011  || in == 6'b101011)? 3'b000 :((in == 6'b000100)? 3'b010 :((in == 6'b001000)? 3'b110 :((in == 6'b001101)? 3'b111 : 3'bxxx) ) ) ) );
     // 100 --> R-type   000 -->LW/SW   010-->beq    110-->addi    111-->ori 
    
endmodule


module control_mux(
    input control_mux,
    input jump,
    input branch,
    input mem_read,
    input mem_write,
    input mem_to_reg,
    input ALUSrc,
    input RegWrite,
    input RegDst,
    output jump_op,
    output branch_op,
    output mem_read_op,
    output mem_write_op,
    output mem_to_reg_op,
    output ALUSrc_op,
    output RegWrite_op,
    output RegDst_op
    );
    
    assign RegDst_op      =  RegDst ;
    assign ALUSrc_op      =  ALUSrc ;
    assign mem_to_reg_op  = (!control_mux || jump ||  branch)? 0 : mem_to_reg ;
    assign RegWrite_op    = (!control_mux || jump ||  branch)? 0 : RegWrite ;
    assign mem_read_op    = (!control_mux || jump ||  branch)? 0 : mem_read ;
    assign mem_write_op   = (!control_mux || jump ||  branch)? 0 : mem_write;
    assign jump_op        =   jump ;
    assign branch_op      =   branch ;
  
    
    
endmodule



module stage2(
    input  RST,
    input  jump,
    input  bransh,
    input  [63:0] reg_IF_ID,
    input         reg_write_control,
    input  [4:0]  write_reg_control,
    input         clk,
    input         reg_dst,
    input  [31:0] data_mem,
    output [31:0] data1,
    output [31:0] data2,
    output [31:0] sign,
    output [9:0]  instruction_write_reg,  // instruction [20:11]   ---> [20:16] = RT  & [15:11]--->RD
    output reg [31:0] pc_beq_jump,
    output [4:0]  RS,
    output [10:0] SA_FN,
    output  reg      PC_control //this signal to cotrol the mux of pc
     );
     
     reg         reg_write;
     reg  [4:0]  write_reg;
     wire  [31:0] instruction;
     wire  [31:0] pc; //next pc
     reg   [31:0] save; // to select pc or data from mem
     reg      save_pc;
         
     assign  pc                    = reg_IF_ID [63:32] ;
     assign  instruction           = reg_IF_ID [31:0]  ;
     assign  instruction_write_reg = reg_IF_ID [20:11] ;
     assign  RS                    = reg_IF_ID [25:21] ;
     assign  SA_FN                 = reg_IF_ID [10:0]  ;

  
    regfile     R1( instruction[25:21] , instruction[20:16], write_reg, save ,reg_write, clk, data1, data2 );
    signextend  S1( instruction[15:0]  , sign );
    
 
    always @( instruction , data_mem , data1 , reg_write_control ,write_reg_control)
        begin
            if(instruction[31:26] == 6'b000011)
                begin
                 save        =  (pc+4) ;
                 reg_write   =  1 ;
                 write_reg   =  5'b11111 ;
                end
            else 
                begin
                 save        =  data_mem ;
                 reg_write   =  reg_write_control ;
                 write_reg   =  write_reg_control ;
                end
  
           if (((instruction[31:26] == 6'b000100 )  && (data1 == data2)) || (instruction[31:26] ==6'b000010) || (instruction[31:26] ==6'b000011) || ((instruction[31:26] == 0)&&(instruction[5:0] ==6'b001000)))
                PC_control  = 0;
            else
                 PC_control = 1 ;
                 
          if((instruction[31:26] == 6'b000100 )  && (data1 == data2))  // beq
             begin
                pc_beq_jump = (pc + 4 * instruction[15:0]);
                save_pc     = (pc + 4 * instruction[15:0]);
             end
          else if((instruction[31:26] ==6'b000010) || (instruction[31:26] ==6'b000011))
             begin
                pc_beq_jump = (pc + 4 * instruction[25:0]);
                save_pc     = (pc + 4 * instruction[25:0]);
             end
          else if((instruction[31:26] == 0)&&(instruction[5:0] ==6'b001000))
             begin
                pc_beq_jump = data1  ;
                save_pc     = data1  ;
             end
          else
                pc_beq_jump = save_pc  ;
        end

endmodule



module hazard(
    input        RST,
    input        mem_read, // from ex stage
    input [4:0]  write_reg, //from ex stage RT
    input [31:0] instruction,//from FE stage
    output  reg     REG_hold,
    output       hold_2, // to hold data to 2 clk cycle if 
    output reg      pc_hold,
    output reg      control_mux
    );
    
    assign hold_2      = (RST)? 0 :( (instruction[31:26] ==6'b000100) ? ((mem_read)? 1 : 0) : 0 );
    
    // 0 let mux outputs = 0 // 1 let mux outputs = control unit signal

    always @ (instruction or mem_read)
        begin
            if(RST)
                begin
                    REG_hold = 0;
                    pc_hold = 0;
                    control_mux = 1;
                end
            else if((mem_read) && ((instruction[31:26]!=6'b100011)&&((write_reg == instruction[25:21] )  || (write_reg == instruction[20:16] ))))
                begin
                  REG_hold = 1;
                  pc_hold = 1;
                  control_mux = 0;
                end 
            else 
            begin
                REG_hold = 0 ; 
                pc_hold  = 0 ;
                control_mux = 1 ;
            end
        end

endmodule

///////////////*** tb for stage 2 ***///////////////////

module tb_stage2();

    reg  RST;
    reg  jump;
    reg  bransh;
    reg  [63:0] reg_IF_ID;
    reg         reg_write_control;
    reg  [4:0]  write_reg_control;
    reg         clk;
    reg         reg_dst;
    reg  [31:0] data_mem;
    wire [31:0] data1;
    wire [31:0] data2;
    wire [31:0] sign;
    wire [9:0]  instruction_write_reg;  
    wire [31:0] pc_beq_jump;
    wire [4:0]  RS;
    wire [10:0] SA_FN;
    wire        PC_control;
    reg [31:0] a,b;
stage2  s2( RST, jump, bransh,reg_IF_ID, reg_write_control,write_reg_control,clk,reg_dst,
        data_mem , data1, data2, sign, instruction_write_reg, pc_beq_jump, RS,SA_FN, PC_control);
      
      
      always
              begin
                 #5 clk= ~clk ;
              end
           
     
    initial
         begin
           clk   = 0;
           RST  = 1;
           data_mem = 15 ;
           a = 0;
           b = 0;
           $monitor("data1 = %d, data2 = %d, sign = %d" , data1, data2, sign);
           #10
           RST  = 0;  
           jump = 0;
           bransh = 0 ;
           reg_dst = 0;
           reg_IF_ID = {{32{a}},{32{b}}};
           #5
           reg_write_control = 1;
           write_reg_control = 3 ;
           #5
           a = 32'b100011_00100_00101_00000_00000_000001;
           b = 2;           
           reg_dst = 0;
           reg_IF_ID = {{32{a}},{32{b}}};
           #5
           reg_write_control = 1;
           write_reg_control = 4 ;
           #5
           a = 32'b100011_00100_00101_00000_00000_000001;
           b = 2;           
           reg_dst = 0;
           reg_IF_ID = {{32{a}},{32{b}}};
           #5
           reg_write_control = 1;
           write_reg_control = 4 ;                               
           
           
           
           
        end

endmodule



////////////***stage3***//////////////////////////////


module ALU(
        output zeroFlag ,
        output reg [31:0] out,
        input  [4:0] shamt,
        input  [31:0] reg1,
        input  [31:0] reg2,
        input  [2:0] ALUcontrol
        );
 

assign zeroFlag = (out == 0);  
 
always @ (reg1, reg2, ALUcontrol)
begin
    case (ALUcontrol)
        0: out <= reg1 + reg2;
        1: out <= reg1 - reg2;
        2: out <= reg1 & reg2;
        3: out <= reg1 | reg2;
        4: out <= reg2 << shamt;
        5: out <= reg2 >> shamt;
        6: out <= (reg1<reg2)? 1:0;
    endcase
end
 
endmodule


 ///////////////***AluControl***///////////////////
 module ALUControl(
        output reg [2:0] ALUcontrol,
        input      [2:0] ALUop,
        input      [5:0] funct
        );
  
      // 100 --> R-type   000 -->LW/SW   010-->beq    110-->addi    111-->ori 

 always @(ALUop , funct)
 begin
 case(ALUop)
    3'b000: ALUcontrol = 0; //lw,sw
    3'b010: ALUcontrol = 1; //beq,bne
    3'b110: ALUcontrol = 0; //addi
    3'b101: ALUcontrol = 2; //andi
    3'b111: ALUcontrol = 3; //ori
    3'b100:  begin
                case(funct)
                    6'b10_0000: ALUcontrol= 0; //add
                    6'b10_0010: ALUcontrol= 1; //sub
                    6'b10_0100: ALUcontrol= 2; //and
                    6'b10_0101: ALUcontrol= 3; //or
                    6'b00_0000: ALUcontrol= 4; //sll
                    6'b00_0010: ALUcontrol= 5; //srl
                    6'b10_1010: ALUcontrol= 6; //slt
             endcase
         end
 endcase
 end
  
 endmodule

//////////***forwarding***////////////
module Forwarding (
        output [1:0] forwardA,
        output [1:0] forwardB,
        input RegWrite_EX,
        input RegWrite_MEM,
        input [4:0] Rs,
        input [4:0] Rt,
        input [4:0] MEM_WBRegisterRd,
        input [4:0] EX_MEMRegisterRd
           ); 
      
    reg [1:0] ForwardA_tmp,ForwardB_tmp; 
    
    assign forwardA = ForwardA_tmp;
    assign forwardB = ForwardB_tmp; 
    
always @(*)
begin
       

    if (RegWrite_EX && (EX_MEMRegisterRd !=0 ) && (EX_MEMRegisterRd == Rs) ) 
        ForwardA_tmp <= 2'b10;
        
    else  if (RegWrite_MEM && (MEM_WBRegisterRd !=0 ) && (EX_MEMRegisterRd !=Rs) && (MEM_WBRegisterRd == Rs) )
        ForwardA_tmp <= 2'b01;
     
    else 
          ForwardA_tmp = 2'b00;
          
             
    if (RegWrite_EX && (EX_MEMRegisterRd !=0 ) && (EX_MEMRegisterRd == Rt) )   
        ForwardB_tmp <= 2'b10;
        
    else  if (RegWrite_MEM && (MEM_WBRegisterRd !=0 ) && (EX_MEMRegisterRd != Rt) && (MEM_WBRegisterRd == Rt) )
        ForwardB_tmp <= 2'b01;
    
    else 
        ForwardB_tmp = 2'b00;
        
        
    /*if (RegWrite_MEM && (MEM_WBRegisterRd !=0 ) && !(RegWrite_EX && EX_MEMRegisterRd !=0) && (EX_MEMRegisterRd != Rs) && (MEM_WBRegisterRd == Rs) )
        ForwardA_tmp <= 2'b01;
        
        
    if (RegWrite_MEM && (MEM_WBRegisterRd !=0 ) && !(RegWrite_EX && EX_MEMRegisterRd !=0) && (EX_MEMRegisterRd != Rt) && (MEM_WBRegisterRd == Rt) )
        ForwardB_tmp <= 2'b01;*/
     
        
end 
 endmodule

///////////////***AluStage***/////////////////////
module stage3 ( 
                 output         zeroFlag,
                 output  [31:0] AluOut, 
                 output reg [31:0] O_data2,
                 output reg [4:0]  O_EX_MEMRegisterRd, 
                 input [4:0]  EX_MEMRegisterRd, 
                 input [4:0]  MEM_WBRegisterRd,
                 input [31:0] data1, 
                 input [31:0] data2, 
                 input [31:0] sign,  
                 input [31:0] WriteBack,
                 input [2:0] ALUop,
                 input [5:0] funct,
                 input [4:0] shamt,
                 input [4:0] Rd,
                 input [4:0] Rt,
                 input RegWrite_EX,
                 input RegWrite_MEM,
                 input RegDst,
                 input ALUSrc,
                 input [4:0] Rs,
                 input [31:0] ALU_op_reg
                 );

wire [2:0] ALUcontrol;
reg [31:0] in_data;
wire  [1:0] forwardA,forwardB;
reg  [31:0] Out_forwardA, Out_forwardB;
 

//assign in_data = (ALUSrc)? sign : Out_forwardB;
 
always @ (funct, ALU_op_reg , sign ,Out_forwardB ,data1, data2,Rd,Rt,RegDst)
begin
    
     O_data2 <= data2;
        if(RegDst)
            O_EX_MEMRegisterRd <= Rd;
         else
            O_EX_MEMRegisterRd <= Rt;  
     
     if(ALUSrc)
           in_data =  sign ;
     else
           in_data =  Out_forwardB;
           
    case (forwardA)
    0: Out_forwardA <= data1;
    1: Out_forwardA <= WriteBack;
    2: Out_forwardA <= ALU_op_reg;
    endcase   
     case (forwardB)
       0: Out_forwardB <= data2;
       1: Out_forwardB <= WriteBack;
       2: Out_forwardB <= ALU_op_reg;
       endcase         
end
ALUControl     AC (ALUcontrol, ALUop, funct);
ALU            AL (zeroFlag, AluOut, shamt, Out_forwardA ,in_data, ALUcontrol);
Forwarding     FW ( forwardA ,forwardB, RegWrite_EX, RegWrite_MEM, Rs, Rt, MEM_WBRegisterRd,EX_MEMRegisterRd); 

endmodule          

///////////////*** tb for stage 3 ***///////////////////

module tb_stage3 (); 
                 wire         zeroFlag;
                 wire  [31:0] AluOut;
                 wire  [31:0] O_data2;
                 wire  [4:0]  O_EX_MEMRegisterRd; 
                 reg [4:0]  EX_MEMRegisterRd;
                 reg [4:0]  MEM_WBRegisterRd;
                 reg [31:0] data1;
                 reg [31:0] data2; 
                 reg [31:0] sign; 
                 reg [31:0] WriteBack;
                 reg [2:0] ALUop;
                 reg [5:0] funct;
                 reg [4:0] shamt;
                 reg [4:0] Rd;
                 reg [4:0] Rt;
                 reg RegWrite_EX;
                 reg RegWrite_MEM;
                 reg RegDst;
                 reg ALUSrc;
                 reg [4:0] Rs;
                 reg [31:0] ALU_op_reg;
                 
       stage3  s3( zeroFlag,AluOut,  O_data2,  O_EX_MEMRegisterRd,  EX_MEMRegisterRd,  MEM_WBRegisterRd,data1, data2,  sign,   WriteBack,
                    ALUop, funct, shamt, Rd, Rt, RegWrite_EX,RegWrite_MEM, RegDst, ALUSrc, Rs, ALU_op_reg );
                    
   
        initial
           begin
             
                               
             $monitor( "zeroFlag = %d ,AluOut = %d ,  O_data2=%d  " ,zeroFlag,AluOut,  O_data2 );
             data1  = 1;
             data2  = 3;
             sign   = 2;
             ALUop  = 0;
             #3
             data1  = 2;
             data2  = 5;
             sign   = 6;
             ALUop  = 2;
             #3             
             data1  = 2;
             data2  = 5;
             sign   = 6;
             ALUop  = 3;
                   
             
           end
endmodule


///////////***stage4_datamem***//////////////////////////

module stage4(
    input  [31:0] address,
    input         mem_read, 
    input  [31:0] in_data,
    input         mem_write,
    input         clk,
    output  [31:0] op_data
    );
    
    reg [31:0] memory [0:1023];
    integer file;
   
    assign op_data =(mem_read)? memory[address] : 32'bz ;
   
    always @(posedge clk)
        begin

                if(mem_write)
                memory[address] = in_data ;
          
        end
                      
 initial
 begin
     $readmemh("E:/sandy/projects/co 2/mips/test_case/code2.txt",memory);
     
     file = $fopen("E:/sandy/projects/co 2/mips/output_file/data_mem.txt");
     $fmonitor(file,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d   "
     ,memory[0],memory[0],memory[1],memory[2],memory[3] ,memory[4],memory[5] ,memory[6],memory[7]
      ,memory[8],memory[9] ,memory[10],memory[11] ,memory[12],memory[13],memory[14],memory[15] );
 end
 

endmodule


///////////*** tb_stage4 ***//////////////////////////

module tb_stage4();
    reg  [31:0] address;
    reg         mem_read; 
    reg  [31:0] in_data;
    reg         mem_write;
    reg         clk;
    wire  [31:0] op_data;

  stage4 s4 ( address,mem_read,  in_data, mem_write, clk, op_data);
   
   always
        begin
           #5 clk= ~clk ;
        end
     
     
     initial
        begin
           clk   = 0;
            
           $monitor("op_data = %d ",op_data );
           #10
          address   = 0;
          mem_read  = 1; 
          in_data   = 0;
          mem_write = 0;
           #5
           address   = 1;
           mem_read  = 1; 
           in_data   = 0;
           mem_write = 0; 
           #5
           address   = 3;
           mem_read  = 0; 
           in_data   = 10;
           mem_write = 1;
           #5
            address   = 4;
            mem_read  = 0; 
            in_data   = 15;
            mem_write = 1;           
         
        end   

  
  
endmodule


////////////***Stage5_writeback***///////////////////////// 


module stage5 (clk , wait_reg,reg_write ,data , address , sel , datamem);
input clk ;
input wait_reg;
input  [31:0]  data ;
input  [31:0]  address ;
input          sel ; 
output  [31:0]  datamem ;
output  reg_write;


  assign reg_write =  wait_reg  ;
  assign datamem   = sel ? data : address   ; // sel =0 ----> address     sel=1 ---> data from mem

endmodule 

///////////*** tb_stage5 ***//////////////////////////

module tb_stage5();
        reg          clk ;
        reg          wait_reg;
        reg          data ;
        reg          address ;
        reg          sel ; 
        wire [31:0]  datamem ;
        wire         reg_write;

  stage5 s5(clk , wait_reg,reg_write ,data , address , sel , datamem);
  
  always
          begin
             #5 clk= ~clk ;
          end
       
       
       initial
          begin
             clk   = 0;
              
             $monitor("datamem = %d ",datamem);
             #5
             data     = 10 ;
             address  = 15 ;
             sel      = 0  ;
             #5
             data     = 10 ;
             address  = 15 ;
             sel      = 1  ; 
           end            

endmodule
////////////////////////***MIPS***///////////////////////////////////////////////////////


module mips(
    input clk,
    input RST,
    output  zeroFlag
    );

    reg still;
    reg [63:0]  reg_IF_ID;
    reg [63:0]  reg_IF_ID_hold;
    reg [132:0] reg_ID_EX;
    reg [72:0]  reg_EX_MEM;
    reg [70:0]  reg_MEM_WB;
    
    wire         hold_2;  // to hold data to 2 clk cycle if 
    wire [31:0]  beq_PC ;
    wire         pc_hold;
    wire         REG_hold;
    wire         PC_control;
    wire [31:0]  next_PC;
    wire [31:0]  instruction;
    wire [9:0]   instruction_write_reg; // this wire will enter the third stage to determine wire_reg as instruction_write_reg = RT & RD
    wire         reg_write;
    wire [4:0]   write_reg; // from EX stage
    wire         reg_dst;
    wire [31:0]  data_mem; // data comes from write back
    wire [31:0]  data1;
    wire [31:0]  data2;
    wire [31:0]  sign;  // the result of sign extension
    wire         jump;
    wire         branch;
    wire         mem_read; 
    wire         mem_write;
    wire         mem_to_reg;
    wire [2:0]   ALUop;
    wire         ALUSrc;
    wire         IF_flush; // this wire for 
    wire         jump_op;
    wire         branch_op;
    wire         mem_read_op;
    wire         mem_write_op;
    wire         mem_to_reg_op;
    wire         ALUSrc_op;
    wire         RegWrite_op;
    wire         RegDst_op;
    wire         control_mux;
    wire [31:0]  op_data;   
    wire [31:0]  AluOut; 
    wire [31:0]  O_data2;
    wire [4:0]  RS;
    wire [10:0] SA_FN;
    wire final_reg_write;
    
    
    stage1      S1 (RST, beq_PC , clk, pc_hold , hold_2 , PC_control , next_PC , instruction );
    stage2      S2 (RST, jump, branch ,reg_IF_ID,final_reg_write ,reg_MEM_WB[4:0], clk ,  reg_dst, data_mem , data1, data2, sign , instruction_write_reg , beq_PC , RS ,SA_FN,  PC_control );
    stage3      S3 ( zeroFlag, AluOut, O_data2, write_reg , reg_EX_MEM[4:0] , reg_MEM_WB[4:0],reg_ID_EX[105:74] ,reg_ID_EX[73:42],
                     reg_ID_EX[41:10], data_mem , reg_ID_EX[108:106] , reg_ID_EX[127:122], reg_ID_EX[132:128], reg_ID_EX[4:0],
                     reg_ID_EX[9:5], reg_EX_MEM[72] , final_reg_write , reg_ID_EX[121], reg_ID_EX[110],reg_ID_EX[120:116], reg_EX_MEM[68:37] );
                      
    stage4      S4 ( reg_EX_MEM[68:37] , reg_EX_MEM[71] ,  reg_EX_MEM[36:5] ,  reg_EX_MEM[70] ,  clk , op_data );
    stage5      S5 (clk, reg_MEM_WB[70] ,final_reg_write, reg_MEM_WB[68:37] , reg_MEM_WB[36:5] , reg_MEM_WB[69] , data_mem );
 
    control     C1 (data1, data2 , RST, reg_IF_ID [31:26] ,reg_IF_ID[5:0],jump_op , branch_op, mem_read_op, mem_write_op, mem_to_reg_op, ALUSrc_op, RegWrite_op, RegDst_op, IF_flush, ALUop);
    control_mux CM ( control_mux , jump_op , branch_op, mem_read_op, mem_write_op, mem_to_reg_op, ALUSrc_op, RegWrite_op, RegDst_op 
                                        ,jump, branch   , mem_read   , mem_write   , mem_to_reg   , ALUSrc   , reg_write  , reg_dst);
            
    hazard      HD (RST, reg_ID_EX[113] , reg_ID_EX[9:5] ,reg_IF_ID[31:0] , REG_hold , hold_2 , pc_hold, control_mux);                
    
    
    
    
    always @(posedge clk)
        begin
         if (IF_flush || REG_hold)
            reg_IF_ID <= 64'bz ;

         else 
           begin
            reg_IF_ID  <= { next_PC[31:0] , instruction[31:0] };
            reg_IF_ID_hold <= reg_IF_ID;
           end 
         
            
            
            reg_ID_EX  <= {  SA_FN   , reg_dst  ,    RS     ,  reg_write , jump , mem_read , mem_write , mem_to_reg , ALUSrc , IF_flush ,   ALUop      ,  data1  ,   data2 ,    sign    , instruction_write_reg } ;
                    //     [132:122]   [121]     [120:116]     [115]      [114]     [113]      [112]      [111]       [110]     [109]     [108:106]    [105:74]   [73:42]   [41:10]       [9:0]
            

            reg_EX_MEM <= {reg_ID_EX[115] ,reg_ID_EX[113] , reg_ID_EX[112],reg_ID_EX[111],  AluOut  , O_data2 , write_reg };
                        //    [72]               [71]            [70]          [69]         [68:37]    [36:5]      [4:0]
                        // reg_write        , mem_read      , mem_write    , mem_to_reg
            
            
            reg_MEM_WB <= { reg_EX_MEM[72] , reg_EX_MEM[69] , op_data  , reg_EX_MEM[68:37] , reg_EX_MEM[4:0] };
                        //      [70]            [69]          [68:37]        [36:5]             [4:0]
                        //    reg_write    , mem_to_reg                      AluOut            write_reg
            
        end
     
endmodule



module tb_mips();
    reg clk ;
    reg RST; 
    wire zeroFlag;
 


    mips G1(clk,RST,zeroFlag);

    always
        begin
           #5 clk= ~clk ;
        end
    
    initial 
       begin 
        clk=0;
        $monitor ("clk=%b zeroFlag=%b ",clk,zeroFlag);
        RST=1;
        #10
        RST=0;
        
       end 
endmodule 


