module ctrl_unit(
    input wire clk,
    input wire reset,
    input wire [5:0] Instruction_31_26,
    input wire [15:0] Instruction_15_0,


    // Flags
    input wire Overflow,
    input wire Negative,
    input wire GT,
    input wire LT,
    input wire Zero,
    
    // Controllers
    output reg WritePC,
    output reg WriteA,
    output reg WriteB,
    output reg WriteALUOut,
    output reg WriteMem,
    output reg WriteInstruction,
    output reg WriteReg,

    // MUX Controllers
    output reg [2:0] MemAddrCtrl,
    output reg [1:0] ALUSrcACtrl,
    output reg [2:0] ALUSrcBCtrl,
    output reg [1:0] PCSrcCtrl,
    output reg [1:0] WriteRegCtrl,
    output reg [2:0] WriteDataCtrl,
    output reg [2:0] ALUCtrl,
    output reg reset_out

);

    reg [6:0] STATE;
    reg [2:0] COUNTER;
    
    // parameters OPCODE
    parameter OP_Type_r         =       6'b000000;
    parameter OP_Addi           =       6'b001000;
    parameter OP_Addiu          =       6'b001001;
    parameter OP_Beq            =       6'b000100;
    parameter OP_Bne            =       6'b000101;
    parameter OP_Ble            =       6'b000110;
    parameter OP_Bgt            =       6'b000111;
    parameter OP_Sllm           =       6'b000001;
    parameter OP_Lb             =       6'b100000;
    parameter OP_Lh             =       6'b100001;
    parameter OP_Lui            =       6'b001111;
    parameter OP_Lw             =       6'b100011;
    parameter OP_Sb             =       6'b101000;
    parameter OP_Sh             =       6'b101001;
    parameter OP_Slti           =       6'b001010; 
    parameter OP_Sw             =       6'b101011;
    parameter OP_J              =       6'b000010;
    parameter OP_Jal            =       6'b000011;

    // parameters funct
    parameter Funct_Add         =       6'b100000;
    parameter Funct_And         =       6'b100100;
    parameter Funct_Div         =       6'b011010;
    parameter Funct_Mult        =       6'b011000;
    parameter Funct_Jr          =       6'b001000;
    parameter Funct_Mfhi        =       6'b010000;
    parameter Funct_Mflo        =       6'b010010; 
    parameter Funct_Sll         =       6'b000000;
    parameter Funct_Sllv        =       6'b000100;
    parameter Funct_Slt         =       6'b101010;
    parameter Funct_Sra         =       6'b000011;
    parameter Funct_Srav        =       6'b000111;
    parameter Funct_Srl         =       6'b000010;
    parameter Funct_Sub         =       6'b100010;
    parameter Funct_Break       =       6'b001101; 
    parameter Funct_RTE         =       6'b010011;
    parameter Funct_Addm        =       6'b000101;
    
    // STATE
    parameter ST_RESET          =       6'd1;
    parameter ST_FETCH          =       6'd2;

    parameter ST_PRECALC        =       6'd5;
    parameter ST_PRECALC2       =       6'd6;
    
    // Type R
    parameter ST_ADD            =       6'd7;
    parameter ST_ADDI           =       6'd8;
    parameter ST_SAVE_RESULT    =       6'd9;
    

initial begin
    reset_out = 1'b1;
end


always @(posedge clk) begin
    if (reset == 1'b1) begin
            
            WritePC = 1'b0;
            WriteA = 1'b0;
            WriteB = 1'b0;
            WriteALUOut = 1'b0;
            WriteMem = 1'b0;
            WriteInstruction = 1'b0;
            

            WriteReg = 1'b1;
            WriteRegCtrl = 2'b01;
            WriteDataCtrl = 3'b011;
            
            
            reset_out= 1'b0; 
            STATE = ST_FETCH;
            COUNTER = 3'b000;
    end else begin
        case (STATE)
            ST_FETCH: begin
                if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin 
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b1;
                    
                    WriteReg = 1'b0;
                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b00;
                    ALUSrcBCtrl = 3'b001;
                    ALUCtrl = 3'b001;
                    WriteALUOut = 1'b1;

                    PCSrcCtrl = 2'b00;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;

                    COUNTER = COUNTER + 3'b001;

                end 
                else if (COUNTER == 3'b011) begin 
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteReg = 1'b0;
                    
                    WriteInstruction = 1'b0;
                    PCSrcCtrl = 2'b10;
                    WritePC = 1'b1;

                    COUNTER = 3'b000;
                    STATE = ST_PRECALC;
                end
            end
        
            ST_PRECALC: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b010;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_PRECALC2;
            end

            ST_PRECALC2: begin
                WritePC = 1'b0;
                WriteA = 1'b1;
                WriteB = 1'b1;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b010;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b001;
                
                case (Instruction_31_26)
                    OP_Type_r: begin
                        case (Instruction_15_0[5:0])

                            Funct_Add: begin
                                STATE = ST_ADD;
                            end

                            Funct_And: begin
                                STATE = ST_AND;
                            end
                            
                            Funct_Div: begin
                                STATE = ST_DIV;
                            end
                           
                            Funct_Mult: begin
                                STATE = ST_MULT;
                            end
                            
                            Funct_Jr: begin
                                STATE = ST_JR;
                            end
                            
                            Funct_Mfhi: begin
                                STATE = ST_MFHI;
                            end
                            
                            Funct_Mflo: begin
                                STATE = ST_MFLO;
                            end
                            
                            Funct_Sll: begin
                                STATE = ST_SLL;
                            end
                            
                            
                            Funct_Sllv: begin
                                STATE = ST_SLLV;
                            end
                            
                            Funct_Slt: begin
                                STATE = ST_SLT;
                            end
                            
                            Funct_Sra: begin
                                STATE = ST_SRA;
                            end
                            
                            Funct_Srav: begin
                                STATE = ST_SRAV;
                            end
                            
                            Funct_Srl: begin
                                STATE = ST_SRL;
                            end

                            Funct_Sub: begin
                                STATE = ST_SUB;
                            end
                            
                            Funct_Break: begin
                                STATE = ST_BREAK;
                            end
                            /
                            Funct_RTE: begin
                                STATE = ST_RTE;
                            end

                            Funct_Addm: begin
                                STATE = ST_ADDM;
                            end
                            default: //erro de opcode
                                STATE = ST_OPCODE404;
                            endcase
                    end
                    OP_Addi: begin
                        STATE = ST_ADDI;
                    end
                    //Op ADDIU
                    OP_Addiu: begin
                        STATE = ST_ADDIU;
                    end
                    //Op BEQ
                    OP_Beq: begin
                        STATE = ST_BEQ;
                    end
                    //Op BNE
                    OP_Bne: begin
                        STATE = ST_BNE;
                    end
                    //Op BLE
                    OP_Ble: begin
                        STATE = ST_BLE;
                    end
                    //Op BGT
                    OP_Bgt: begin
                        STATE = ST_BGT;
                    end
                    //Op SLLM
                    OP_Sllm: begin
                        STATE = ST_SLLM;
                    end
                    //Op LB
                    OP_Lb: begin
                        STATE = ST_LB;
                    end
                    //Op LH
                    OP_Lh: begin
                        STATE = ST_LH;
                    end
                    //Op LUI
                    OP_Lui: begin
                        STATE = ST_LUI;
                    end
                    //Op LW
                    OP_Lw: begin
                        STATE = ST_LW;
                    end
                    //Op SB
                    OP_Sb: begin
                        STATE = ST_SB;
                    end
                    //Op SH
                    OP_Sh: begin
                        STATE = ST_SH;
                    end
                    //Op SLTI
                    OP_Slti: begin
                        STATE = ST_SLTI;
                    end
                    //Op SW
                    OP_Sw: begin
                        STATE = ST_SW;
                    end
                    //Op J
                    OP_J: begin
                        STATE = ST_J;
                    end
                    //Op JAL
                    OP_Jal: begin
                        STATE = ST_JAL;
                    end
                    default:
                        STATE = ST_OPCODE404;
                    endcase
                    
                endcase

            end


            ST_ADD: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b001;
                STATE = ST_SAVE_RESULT;
            end

            ST_ADDI: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b011;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b010;
                STATE = ST_SAVE_RESULT;
            end

            ST_SAVE_RESULT: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b1;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_FETCH;         // mudar para estado onde tudo é resetado
            end
        endcase
    end
end
endmodule

