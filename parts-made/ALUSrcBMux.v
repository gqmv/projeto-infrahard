module ALUSrcBMux (
    input   wire  [2:0]    selector,
    input   wire  [31:0]   B,             // 000
    //input wire  [31:0]   Select_4,      // 001
    input   wire  [31:0]   Shift_Left_2,  // 010
    input   wire  [31:0]   Sign_Extend,   // 011
    input   wire  [31:0]   Mem_Data,      // 100
    input   wire  [31:0]   Data_out
);



// B -------------|
// Select_4 ------|----|
// Shift_Left_2 -------|----|
// Sign_Extend -------------|----|
// Mem_Data ---------------------|


    wire [31:0] A2;
    wire [31:0] A1;

    assign A3 = (selector[0]) ? 32'b00000000000000000000000000000100 : B
    assign A2 = (selector[0]) ? Sign_Extend : Shift_Left_2
    assign A1 = (selector[1]) ? A2 : A3
    assign Data_out = (selector[2]) ? Mem_Data : A1

endmodule