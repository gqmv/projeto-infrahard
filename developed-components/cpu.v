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
    wire [2:0] ShiftCtrl;

// ALU Flags
    wire Overflow;
    wire Negative;
    wire GT;
    wire LT;
    wire Zero;

// MUX Control Signals
    wire [2:0] MemAddrCtrl;
    wire [1:0] ALUSrcACtrl;
    wire [2:0] ALUSrcBCtrl;
    wire [1:0] PCSrcCtrl;
    wire [1:0] WriteRegCtrl;
    wire [2:0] WriteDataCtrl;
    wire [2:0] ALUCtrl;
    wire [1:0] ShiftNCtrl;
    wire ShiftSrcCtrl;
    
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
    wire [31:0] ExceptionDestiny;
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
    wire [31:0] WriteData;
    wire [31:0] ShiftRegIn;

// Data Wires (Less than 32 BITS)
    wire [4:0] WriteRegOut;
    wire [4:0] ShiftRegN;


// Instructions
    wire [5:0] Instruction_31_26; // OPCODE
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
        ALUResult,
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

    ShiftNMux ShiftN_mux(
        ShiftNCtrl,
        B,
        Mem_Data,
        Instruction_15_0,
        ShiftRegN
    );

    ShiftSrcMux ShiftSrc_mux(
        ShiftSrcCtrl,
        B,
        A,
        ShiftRegIn
    );

// High level components

    Memoria Memory_(
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
        MemDataOut,
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

    RegDesloc ShiftReg(
        clk,
        reset,
        ShiftCtrl,
        ShiftRegN,
        ShiftRegIn,
        ShiftRegOut
    );

// Signal Extenders
    SignExtend SignExtend_(
        Instruction_15_0,
        Sign_Extend
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
        ShiftSrcCtrl,
        ShiftNCtrl,
        ShiftCtrl,
        MemAddrCtrl,
        ALUSrcACtrl,
        ALUSrcBCtrl,
        PCSrcCtrl,
        WriteRegCtrl,
        WriteDataCtrl,
        ALUCtrl,
        reset    
    );

endmodule