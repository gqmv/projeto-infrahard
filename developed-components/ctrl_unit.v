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
    output reg [2:0] memAddrCtrl,
    output reg [1:0] ALUSrcACtrl,
    output reg [2:0] ALUSrcBCtrl,
    output reg [1:0] PCSrcCtrl,
    output reg [1:0] WriteRegCtrl,
    output reg [1:0] WriteDataCtrl,
    output reg [2:0] ALUCtrl,

    output reg resetOut

);

    reg [6:0] STATE;
    reg [2:0] COUNTER;
    
    // parameters OPCODE
    parameter Op_Type_r         =       6'b000000;
    parameter Op_Addi           =       6'b001000;
    parameter Op_Addiu          =       6'b001001;
    parameter Op_Beq            =       6'b000100;
    parameter Op_Bne            =       6'b000101;
    parameter Op_Ble            =       6'b000110;
    parameter Op_Bgt            =       6'b000111;
    parameter Op_Sllm           =       6'b000001;
    parameter Op_Lb             =       6'b100000;
    parameter Op_Lh             =       6'b100001;
    parameter Op_Lui            =       6'b001111;
    parameter Op_Lw             =       6'b100011;
    parameter Op_Sb             =       6'b101000;
    parameter Op_Sh             =       6'b101001;
    parameter Op_Slti           =       6'b001010; 
    parameter Op_Sw             =       6'b101011;
    parameter Op_J              =       6'b000010;
    parameter Op_Jal            =       6'b000011;

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
    
    // States
    parameter ST_RESET          =       6'd1;
    parameter ST_FETCH          =       6'd2;
    parameter ST_FETCH2         =       6'd3;
    parameter ST_FETCH3         =       6'd4;
    parameter ST_PRECALC        =       6'd5;
    parameter ST_PRECALC2       =       6'd6;
    
    // Type R
    parameter ST_ADD            =       6'd7;
    parameter ST_ADDI           =       6'd8;
    parameter ST_SAVE_RESULT    =       6'd9;
    

initial begin
    resetOut = 1'b1;
end


always @(posedge clk) begin
    if (reset == 1'b1) begin
        if (STATE != ST_RESET) begin
            STATE = ST_FETCH;
            WritePC = 1'b0;
            WriteA = 1'b0;
            WriteB = 1'b0;
            WriteALUOut = 1'b0;
            WriteMem = 1'b0;
            WriteInstruction = 1'b0;
            WriteReg = 1'b1;

            memAddrCtrl = 3'b000;
            ALUSrcACtrl = 2'b00;
            ALUSrcBCtrl = 2'b00;
            PCSrcCtrl = 2'b00;
            WriteReg = 1'b1;
            WriteRegCtrl = 2'b01;
            WriteDataCtrl = 3'b011;
            ALUCtrl = 3'b000;

            resetOut = 1'b1; //

            COUNTER = 3'b000;
        end 
        else begin
            STATE = ST_FETCH;

            WritePC = 1'b0;
            WriteA = 1'b0;
            WriteB = 1'b0;
            WriteALUOut = 1'b0;
            WriteMem = 1'b0;
            WriteInstruction = 1'b0;
            WriteReg = 1'b0;

            memAddrCtrl = 3'b000;
            ALUSrcACtrl = 2'b00;
            ALUSrcBCtrl = 2'b00;
            PCSrcCtrl = 2'b00;
            WriteReg = 1'b0;
            WriteRegCtrl = 2'b000;
            WriteDataCtrl = 3'b000;
            ALUCtrl = 3'b000;

            resetOut = 1'b0; //

            COUNTER = 3'b000;
        end
    end
    else begin
        case (STATE)
            ST_FETCH: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b001;
                PCSrcCtrl = 2'b00;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_FETCH2;
            end

            ST_FETCH2: begin
                WritePC = 1'b1;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b001;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_FETCH3;
            end

            ST_FETCH3: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b1;
                WriteReg = 1'b0;
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b001;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_PRECALC;
            end
            
            ST_PRECALC: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b0;
                
                memAddrCtrl = 3'b010;
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
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b00;
                ALUSrcBCtrl = 3'b010;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                
                case (Instruction_31_26)
                    Op_Type_r: begin
                        case (Instruction_15_0[5:0])
                            Funct_Add: begin
                                STATE = ST_ADD;
                            end
                        endcase
                    end
                    
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
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b000;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
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
                
                memAddrCtrl = 3'b010;
                ALUSrcACtrl = 2'b01;
                ALUSrcBCtrl = 3'b011;
                PCSrcCtrl = 2'b10;
                WriteRegCtrl = 2'b00;
                WriteDataCtrl = 2'b00;
                ALUCtrl = 3'b001;

                COUNTER = 3'b000;
                STATE = ST_SAVE_RESULT;

            ST_SAVE_RESULT: begin
                WritePC = 1'b0;
                WriteA = 1'b0;
                WriteB = 1'b0;
                WriteALUOut = 1'b1;
                WriteMem = 1'b0;
                WriteInstruction = 1'b0;
                WriteReg = 1'b1;
                
                memAddrCtrl = 3'b010;
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

