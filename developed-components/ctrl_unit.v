module ctrl_unit(
    input wire clk,
    input wire reset,
    input wire [5:0] Instruction_31_26,
    input wire [15:0] Instruction_15_0,
    input mult_end,
    input div_end,


    // Flags
    input wire Overflow,
    input wire Negative,
    input wire GT,
    input wire LT,
    input wire Zero,
    input wire ET,
    
    // Controllers
    output reg WritePC,
    output reg WriteA,
    output reg WriteB,
    output reg WriteALUOut,
    output reg WriteMem,
    output reg WriteInstruction,
    output reg WriteReg,
    output reg ShiftSrcCtrl,
    output reg [1:0] ShiftNCtrl,
    output reg [2:0] ShiftCtrl,
    output reg WriteHILO,
    output reg DivCtrl,
    output reg MultCtrl,

    // MUX Controllers
    output reg [2:0] MemAddrCtrl,
    output reg [1:0] ALUSrcACtrl,
    output reg [2:0] ALUSrcBCtrl,
    output reg [1:0] PCSrcCtrl,
    output reg [1:0] WriteRegCtrl,
    output reg [2:0] WriteDataCtrl,
    output reg [2:0] ALUCtrl,
    output reg HILOCtrl,
    output reg reset_out

);

    reg [6:0] STATE;
    reg [2:0] COUNTER;
    
    // parameters OPCODE
    parameter OP_Type_r         =       6'b000000;
    parameter OP_Addi           =       6'b001000;      // DONE
    parameter OP_Addiu          =       6'b001001;      // DONE
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

    parameter ST_MULT_CALC      =       6'd46;
    parameter ST_MULT_RESULT    =       6'd47;
    parameter ST_DIV_CALC       =       6'd48;
    parameter ST_DIV_RESULT     =       6'd49;

    parameter ST_BRANCH_COMMON  =       6'd50;

    // Type R
    parameter ST_ADD            =       6'd7;      // DONE
    parameter ST_AND            =       6'd8;      // DONE
    parameter ST_SUB            =       6'd9;      // DONE
    parameter ST_SAVE_RESULT    =       6'd10;      // DONE
    parameter ST_MULT           =       6'd11;      // DONE
    parameter ST_DIV            =       6'd12;      // DONE (broke probably)
    parameter ST_MFHI           =       6'd13;      // DONE
    parameter ST_MFLO           =       6'd14;      // DONE
    parameter ST_SLL            =       6'd15;      // DONE (broke probably)
    parameter ST_SRL            =       6'd16;
    parameter ST_SRA            =       6'd17;
    parameter ST_SLLV           =       6'd18;
    parameter ST_SRAV           =       6'd19;
    parameter ST_SLT            =       6'd20;
    parameter ST_BREAK          =       6'd21;      // DONE
    parameter ST_ADDM           =       6'd22;
    parameter ST_JR             =       6'd23;
    parameter ST_RTE            =       6'd24;      // doing (nathan)
    parameter ST_J              =       6'd25;
    parameter ST_JAL            =       6'd26;
    parameter ST_SB             =       6'd27;
    parameter ST_SH             =       6'd28;
    parameter ST_SW             =       6'd29;
    parameter ST_LB             =       6'd30;
    parameter ST_LH             =       6'd31;
    parameter ST_LW             =       6'd32;
    parameter ST_LUI            =       6'd33;
    parameter ST_SLTI           =       6'd34;
    parameter ST_BGT            =       6'd35;      // DONE need testing
    parameter ST_BLE            =       6'd36;      // DONE need testing
    parameter ST_BEQ            =       6'd37;      // DONE need testing
    parameter ST_BNE            =       6'd38;      // DONE need testing
    parameter ST_ADDIU          =       6'd39;      // DONE
    parameter ST_ADDI           =       6'd40;      // DONE
    parameter ST_ADDI_ADDIU     =       6'd41;      // DONE
    parameter ST_SLLM           =       6'd42;

    parameter ST_OPCODE404      =       6'd43;
    parameter ST_OVERFLOW       =       6'd44;
    parameter ST_DIVZERO        =       6'd45;

initial begin
    reset_out = 1'b1;
end


always @(posedge clk) begin
    if (reset == 1'b1) begin
            HILOCtrl = 1'b0;
            WriteHILO = 1'b0;
            DivCtrl = 1'b0;
            MultCtrl = 1'b0;
            WritePC = 1'b0;
            WriteA = 1'b0;
            WriteB = 1'b0;
            WriteALUOut = 1'b0;
            WriteMem = 1'b0;
            WriteInstruction = 1'b0;
            

            WriteReg = 1'b1;
            WriteRegCtrl = 2'b01;
            WriteDataCtrl = 3'b011;
            ShiftNCtrl = 1'b0;
            ShiftCtrl = 1'b0;
            ShiftSrcCtrl = 1'b0;
            
            
            reset_out= 1'b0; 
            STATE = ST_FETCH;
            COUNTER = 3'b000;
    end else begin
        case (STATE)
            ST_FETCH: begin
                if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
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
                    ShiftNCtrl = 1'b0;
                    ShiftCtrl = 1'b0;
                    ShiftSrcCtrl = 1'b0;

                    PCSrcCtrl = 2'b00;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;

                    COUNTER = COUNTER + 3'b001;

                end 
                else if (COUNTER == 3'b011) begin 
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteReg = 1'b0;
                    
                    WriteInstruction = 1'b0;
                    PCSrcCtrl = 2'b10;
                    WritePC = 1'b1;
                    ShiftNCtrl = 1'b0;
                    ShiftCtrl = 1'b0;
                    ShiftSrcCtrl = 1'b0;

                    COUNTER = 3'b000;
                    STATE = ST_PRECALC;
                end
            end
        
            ST_PRECALC: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_PRECALC2;
            end

            ST_PRECALC2: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                
                case (Instruction_31_26) // OPCODE
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
                   
                    OP_Addiu: begin
                        STATE = ST_ADDIU;
                    end
                    
                    OP_Beq: begin
                        STATE = ST_BEQ;
                    end
                    
                    OP_Bne: begin
                        STATE = ST_BNE;
                    end
                    
                    OP_Ble: begin
                        STATE = ST_BLE;
                    end
                    
                    OP_Bgt: begin
                        STATE = ST_BGT;
                    end
                    
                    OP_Sllm: begin
                        STATE = ST_SLLM;
                    end
                   
                    OP_Lb: begin
                        STATE = ST_LB;
                    end
                    
                    OP_Lh: begin
                        STATE = ST_LH;
                    end
                    
                    OP_Lui: begin
                        STATE = ST_LUI;
                    end
                    
                    OP_Lw: begin
                        STATE = ST_LW;
                    end
                    
                    OP_Sb: begin
                        STATE = ST_SB;
                    end
                    
                    OP_Sh: begin
                        STATE = ST_SH;
                    end
                    
                    OP_Slti: begin
                        STATE = ST_SLTI;
                    end
                    
                    OP_Sw: begin
                        STATE = ST_SW;
                    end
                    
                    OP_J: begin
                        STATE = ST_J;
                    end
                    
                    OP_Jal: begin
                        STATE = ST_JAL;
                    end
                    default: begin//erro de opcode
                        STATE = ST_OPCODE404;
                    end
                
                endcase

            end


            ST_ADD: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_SAVE_RESULT;
            end

            ST_ADDI: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b010;

                if(Overflow) begin
                    STATE = ST_OVERFLOW;
                end
                else begin
                    STATE = ST_ADDI_ADDIU;
                end
            end

            ST_ADDI_ADDIU: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b1;
                
                MemAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b011;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b001;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_FETCH;  
            end

            ST_SAVE_RESULT: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;

                if (Overflow) begin
                    STATE = ST_OVERFLOW;
                end else begin
                    STATE = ST_FETCH;
                end       // mudar para estado onde tudo é resetado
            end

            ST_AND: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ALUCtrl = 3'b011;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_SAVE_RESULT;
            end

            ST_SUB: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ALUCtrl = 3'b010;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_SAVE_RESULT;
            end

            ST_ADDIU: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
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
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b010;
                STATE = ST_ADDI_ADDIU;
            end
            ST_MULT: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b1;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_MULT_CALC;
            end

            ST_MULT_CALC: begin // ver se ta certo
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;
                if (mult_end) 
                    STATE = ST_MULT_RESULT;
                else
                    STATE = ST_MULT_CALC;
            end

            ST_MULT_RESULT: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b1;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_FETCH;
            end

            ST_DIV: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b1;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_DIV_CALC;
            end

            ST_DIV_CALC: begin // ver se ta certo
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;
		    	if (ST_DIVZERO)
		    		STATE = ST_FETCH;           // quando tiver erro de divzero trocar aqui
		    	else begin
		    		if (div_end)
		    			STATE = ST_DIV_RESULT;
		    		else 
		    			STATE = ST_DIV_CALC;
		    	end
            end

            ST_DIV_RESULT: begin
                HILOCtrl = 1'b1;
                WriteHILO = 1'b1;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_FETCH;
            end

            ST_MFHI: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b1;            //

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b010;     //
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_FETCH;
            end

            ST_MFLO: begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b1;            //

                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b001;     //
                ALUCtrl = 3'b000;
                COUNTER = 3'b000;

                STATE = ST_FETCH;
            end
            
            ST_SLL: begin
                if (COUNTER == 3'b000) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b0;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b10;
                    ShiftCtrl = 3'b001;
                    ShiftSrcCtrl = 1'b0;

                    COUNTER = COUNTER + 1'b1;
                end else if (COUNTER == 3'b001) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b0;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b10;
                    ShiftCtrl = 3'b010;
                    ShiftSrcCtrl = 1'b0;

                    COUNTER = COUNTER + 1'b1;
                end else if (COUNTER == 3'b010) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b1;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 3'b110;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b10;
                    ShiftCtrl = 3'b010;
                    ShiftSrcCtrl = 1'b0;

                    COUNTER = 3'b000;
                    STATE = ST_FETCH;
                end
            end

            ST_SLLV: begin
                if (COUNTER == 3'b000) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b0;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b00;
                    ShiftCtrl = 3'b001;
                    ShiftSrcCtrl = 1'b1;

                    COUNTER = COUNTER + 1'b1;
                end else if (COUNTER == 3'b001) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b0;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 2'b00;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b00;
                    ShiftCtrl = 3'b010;
                    ShiftSrcCtrl = 1'b1;

                    COUNTER = COUNTER + 1'b1;
                end else if (COUNTER == 3'b010) begin
                    HILOCtrl = 1'b0;
                    WriteHILO = 1'b0;
                    DivCtrl = 1'b0;
                    MultCtrl = 1'b0;
                    WritePC = 1'b0;
                    WriteA = 1'b0;
                    WriteB = 1'b0;
                    WriteALUOut = 1'b0;
                    WriteMem = 1'b0;
                    WriteInstruction = 1'b0;
                    WriteReg = 1'b1;

                    MemAddrCtrl = 3'b010;
                    ALUSrcACtrl = 2'b01;
                    ALUSrcBCtrl = 3'b000;
                    PCSrcCtrl = 2'b10;
                    WriteRegCtrl = 2'b00;
                    WriteDataCtrl = 3'b110;
                    ALUCtrl = 3'b100;
                    ShiftNCtrl = 2'b00;
                    ShiftCtrl = 3'b010;
                    ShiftSrcCtrl = 1'b1;

                    COUNTER = 3'b000;
                    STATE = ST_FETCH;
                end
            end

            ST_BEQ: begin
                if (COUNTER == 3'b000) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b111;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = COUNTER + 1'b1;
                
            end else if (COUNTER == 3'b001 && (ET)) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b1;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_FETCH;
                end else begin
                    STATE = ST_FETCH;
                end
            end

            ST_BGT: begin
                if (COUNTER == 3'b000) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b111;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = COUNTER + 1'b1;
                
            end else if (COUNTER == 3'b001 && (GT)) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b1;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_FETCH;
                end else begin
                    STATE = ST_FETCH; 
                end
            end

            ST_BLE: begin
                if (COUNTER == 3'b000) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b111;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = COUNTER + 1'b1;
                
            end else if (COUNTER == 3'b001 && (ET or LT)) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b1;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_FETCH;

                end else begin
                    STATE = ST_FETCH; 
                end

            end

            ST_BNE: begin
                if (COUNTER == 3'b000) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b0;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b111;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = COUNTER + 1'b1;
                
            end else if (COUNTER == 3'b001 && (!ET)) begin
                HILOCtrl = 1'b0;
                WriteHILO = 1'b0;
                DivCtrl = 1'b0;
                MultCtrl = 1'b0;
                WritePC = 1'b1;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                MemAddrCtrl = 3'b000;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 3'b000;
                WriteDataCtrl = 3'b000;
                ALUCtrl = 3'b000;
                ShiftNCtrl = 1'b0;
                ShiftCtrl = 1'b0;
                ShiftSrcCtrl = 1'b0;

                COUNTER = 3'b000;
                STATE = ST_FETCH;

                end else begin
                    STATE = ST_FETCH; 
                end

            end

        endcase
    end
end

endmodule