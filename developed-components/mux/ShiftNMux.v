module ShiftNMux(

    input  wire [1:0]  ShiftNCrtl,
    input  wire [31:0] B,                //00
    input  wire [31:0] MemDataOut,       //01
    input  wire [15:0] Instruction_15_0, //10
    output wire [4:0] Data_out

);

// B ----------------|
// MemDataOut--------|-- B_MemOut --\
//                                   |---Data_out --->
// Instruction_10_6-----------------/

    wire [4:0] B_MemOut;

    assign B_MemOut = (ShiftNCrtl[0]) ? MemDataOut[4:0] : B[4:0];
    assign Data_out = (ShiftNCrtl[1]) ? Instruction_15_0[10:6] : B_MemOut;

endmodule