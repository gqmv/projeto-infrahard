module WriteRegMux(
    input  wire [1:0]  WriteRegCtrl,
    input  wire [15:0] Instruction_15_0,
    input  wire [4:0] Instruction_20_16,

    output wire [4:0] Data_out
);

 

// Instruction_15_11 -- |
// 29 ----------------- | --- |
//                            | ---
// 31 ----------------- | --- |
// Instruction_20_16 -- |
    wire [4:0] Instruction_15_11;
    assign Instruction_15_11 = Instruction_15_0[15:11];

    wire [4:0] int_Instruction_15_11_29;
    wire [4:0] int_31_Instruction_20_16;

    assign int_Instruction_15_11_29 = (WriteRegCtrl[0]) ? 5'd29 : Instruction_15_11;
    assign int_31_Instruction_20_16 = (WriteRegCtrl[0]) ? Instruction_20_16 : 5'd31;

    assign Data_out = (WriteRegCtrl[1]) ? int_31_Instruction_20_16 : int_Instruction_15_11_29;

endmodule