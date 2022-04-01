//`include "developed-components/mux/ALUAMux.v"
//`include "developed-components/mux/ALUBMux.v"
//`include "developed-components/mux/memAddrMux.v"
//`include "developed-components/mux/PCSrcCtrlMux.v"
//`include "developed-components/mux/WriteDataMux.v"
//`include "developed-components/mux/WriteRegMux.v"

module cpu(
    input wire clk,
    input wire reset
);

// Control Signals
    wire WritePC;
    wire WriteA;
    wire WriteB;
    wire WriteALUOut;
    wire WriteMem;
    wire WriteInstruction;
    wire WriteReg;

// ALU Flags
    wire Overflow;
    wire Negative;
    wire GT;
    wire LT;
    wire Zero;

// MUX Control Signals
    wire [2:0] memAddrCtrl;
    wire [1:0] ALUSrcACtrl;
    wire [2:0] ALUSrcBCtrl;
    wire [1:0] PCSrcCtrl;
    wire [1:0] WriteRegCtrl;
    wire [1:0] WriteDataCtrl;
    wire [2:0] ALUCtrl;
    
// Data Wires (32 BITS)
    wire [31:0] PCSrc;
    wire [31:0] PC;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] ALUOut;
    wire [31:0] memAddr;
    wire [31:0] MDR;
    wire [31:0] ALUSrcA;
    wire [31:0] ALUSrcB;
    wire [31:0] Shift_Left_2;
    wire [31:0] Sign_Extend;
    wire [31:0] Mem_Data;
    wire [31:0] Exception_Destiny;
    wire [31:0] EPCOut;
    wire [31:0] LO;
    wire [31:0] HI;
    wire [31:0] LTSignExtend;
    wire [31:0] ShiftLeft4;
    wire [31:0] ShiftRegOut;
    wire [31:0] SetSizeOut;
    wire [31:0] MemDataIn;
    wire [31:0] MemDataOut;
    wire [31:0] InstructionIn;
    wire [31:0] ALUResult;

// Data Wires (Less than 32 BITS)
    wire [4:0] WriteRegOut;

// Instructions
    wire [4:0] Instruction_31_26; // OPCODE
    wire [4:0] Instruction_25_21;
    wire [4:0] Instruction_20_16;
    wire [15:0] Instruction_15_0;

// Registers

    Registrador PC_reg(
        clk,
        reset,
        WritePC,
        PCSrc,
        PC
    );

    Registrador A_reg(
        clk,
        reset,
        WriteA,
        ReadData1,
        A
    );

    Registrador B_reg(
        clk,
        reset,
        WriteB,
        ReadData2,
        B
    );

    Registrador ALUOut_reg(
        clk,
        reset,
        WriteALUOut,
        ALUOut
    );

// Multiplexers

    memAddrMux memAddr_mux(
        MemAddrCtrl,
        A,
        B,
        PC,
        ALUOut,
        memAddr
    );

    ALUAMux ALUSrcA_mux(
        ALUSrcACtrl,
        PC,
        A,
        MDR,
        ALUSrcA
    );

    ALUBMux ALUSrcB_mux(
        ALUSrcBCtrl,
        B,
        Shift_Left_2,
        Sign_Extend,
        Mem_Data,
        ALUSrcB
    );

    PCSrcCtrlMux PCSrc_mux(
        PCSrcCtrl,
        ExceptionDestiny,
        EPCOut,
        ALUOut,
        Shift_Left_2,
        PCSrc
    );

    WriteRegMux WriteReg_mux(
        WriteRegCtrl,
        Instruction_15_0,
        Instruction_20_16,
        WriteRegOut
    );

    WriteDataMux WriteData_mux(
        WriteDataCtrl,
        ALUOut,
        LO,
        HI,
        LTSignExtend,
        ShiftLeft4,
        ShiftRegOut,
        SetSizeOut,
        WriteData
    );

// High level components

    Memoria Memory(
        memAddr,
        clk,
        WriteMem,
        MemDataIn,
        MemDataOut
    );

    Instr_Reg IR(
        clk,
        reset,
        WriteInstruction,
        InstructionIn,
        Instruction_31_26,
        Instruction_25_21,
        Instruction_20_16,
        Instruction_15_0
    );

    Banco_reg Registers(
        clk,
        reset,
        WriteReg,
        Instruction_25_21,
        Instruction_20_16,
        WriteRegOut,
        WriteData,
        ReadData1,
        ReadData2
    );

    ula32 ALU(
        ALUSrcA,
        ALUSrcB,
        ALUCtrl,
        ALUResult,
        Overflow,
        Negative,
        Zero,
        Equals,
        GT,
        LT
    );

// Control Unit
    ctrl_unit CTRL(
        clk,
        reset,
        Instruction_31_26,
        Instruction_15_0,
        Overflow,
        Negative,
        GT,
        LT,
        Zero,
        WritePC,
        WriteA,
        WriteB,
        WriteALUOut,
        WriteMem,
        WriteInstruction,
        WriteReg,
        memAddrCtrl,
        ALUSrcACtrl,
        ALUSrcBCtrl,
        PCSrcCtrl,
        WriteRegCtrl,
        WriteDataCtrl,
        ALUCtrl,
        reset
    );

endmodule