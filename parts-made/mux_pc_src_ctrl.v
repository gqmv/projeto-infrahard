module mux_pc_src_ctrl (
    input   wire  [1:0]    PCSourceCtrl,
    input   wire  [31:0]   Exception_Destiny,   // 00
    input   wire  [31:0]   EPC_Out,             // 01
    input   wire  [31:0]   ALU_Out,             // 10
    input   wire  [31:0]   Shift_Left_2,        // 11
    output   wire  [31:0]  Data_out
);

// Exception_Destiny --|
// EPC_Out           --|-- EPC_EXP --\
//                                    |---Data_out --->             
// ALU_Out           --|--Shift_ALU--/     
// Shift_Left_2      --| 
  
 
    wire [31:0] EPC_EXP;
    wire [31:0] Shift_ALU;

    assign EPC_EXP = (PCSourceCtrl[0]) ? EPC_Out : Exception_Destiny
    assign Shift_ALU = (PCSourceCtrl[0]) ? Shift_Left_2 : ALU_Out
    assign Data_out = (PCSourceCtrl[1]) ? Shift_ALU : EPC_EXP

endmodule