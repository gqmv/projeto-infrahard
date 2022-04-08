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
    wire MultCtrl;
    wire DivCtrl;
    wire WriteHILO;
    wire WriteEPC;
    

// ALU Flags
    wire Overflow;
    wire Negative;
    wire GT;
    wire LT;
    wire Zero;
    wire ET;

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
    wire HILOCtrl;
    
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
    wire [31:0] ShiftLeft2Out;
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
    wire [31:0] MuxHIOut;
    wire [31:0] MuxLOOut;

    wire [31:0] mult_high_out;
	wire [31:0] mult_low_out;
	wire [31:0] div_high_out;
	wire [31:0] div_low_out;
	wire [31:0] high_in;
	wire [31:0] low_in;
	wire [31:0] high_out;
	wire [31:0] low_out;

// Data Wires (Less than 32 BITS)
    wire [4:0] WriteRegOut;
    wire [4:0] ShiftRegN;
    wire [27:0] ShiftLeft2PCOut;


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

    Registrador EPC_reg(
        clk,
        reset,
        WriteEPC,
        ALUResult,
        EPCOut
    );

    Registrador HI_reg(
        clk,
        reset,
        WriteHILO,
        high_in,
        HI
    );

    Registrador LO_reg(
        clk,
        reset,
        WriteHILO,
        low_in,
        LO
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
        ShiftLeft2Out,
        Sign_Extend,
        Mem_Data,
        ALUSrcB
    );

    PCSrcCtrlMux PCSrc_mux(
        PCSrcCtrl,
        ExceptionDestiny,
        EPCOut,
        ALUOut,
        {PC[31:28],ShiftLeft2PCOut},
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
        ET,
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

// Shift Lefts
    ShiftLeft2 Shift_Left_2(
        Sign_Extend,
        ShiftLeft2Out
    );

    ShiftLeft2_PC Shift_Left_2_PC(
        {Instruction_25_21,Instruction_20_16,Instruction_15_0},
        ShiftLeft2PCOut
    );

// Mult module
    mult MULT (
		clk,
		MultCtrl,
		reset,
		A,
		B,
		mult_high_out,
		mult_low_out,
		mult_end
	);

// Div module
    div DIV (
    	clk,
    	DivCtrl,
        reset,
        A,
    	B,
        div_high_out,
    	div_low_out,
    	div_end,
    	div_zero
	);

// Muxes at mult and div
	MultDivMuxes Low_Mux ( //done
		HILOCtrl,
        mult_low_out,
		div_low_out,
		low_in
	);

    // Muxes at mult and div
	MultDivMuxes High_Mux ( //done
		HILOCtrl,
        mult_high_out,
		div_high_out,
		high_in
	);   

// Control Unit
    ctrl_unit CTRL(
        clk,
        reset,
        Instruction_31_26,
        Instruction_15_0,
        mult_end,
        div_end,
        Overflow,
        Negative,
        GT,
        LT,
        Zero,
        ET,
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
        WriteHILO,
        DivCtrl,
        MultCtrl,
        WriteEPC,
        MemAddrCtrl,
        ALUSrcACtrl,
        ALUSrcBCtrl,
        PCSrcCtrl,
        WriteRegCtrl,
        WriteDataCtrl,
        ALUCtrl,
        HILOCtrl,
        reset
    );

endmodule