module PCSourceCtrlMux (
    input   wire  [1:0]    selector,
    input   wire  [31:0]   Exception_Destiny,   // 00
    input   wire  [31:0]   EPC_Out,             // 01
    input   wire  [31:0]   ALU_Out,             // 10
    input   wire  [31:0]   Shift_Left_2,        // 11
    input   wire  [31:0]   Data_out
);



// Exception_Destiny ----|----|
// EPC_Out -------------------|----|
// ALU_Out -------------------|----|
// Shift_Left_2 -------------------|


    wire [31:0] A2;
    wire [31:0] A1;

    assign A2 = (selector[0]) ? EPC_Out : Exception_Destiny
    assign A1 = (selector[0]) ? Shift_Left_2 : ALU_Out
    assign Data_out = (selector[1]) ? A1 : A2

endmodule