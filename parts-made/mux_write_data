module mux_ulaB (
    input   wire  [3:0]    WriteDataCtrl,
    input   wire  [31:0]   ALU_OUT,                 // 000  A1  A3  ALU_OUT
    input   wire  [31:0]   LO_OUT,                  // 001  A1  A3  LO_OUT
    input   wire  [31:0]   HI_OUT,                  // 010  A1  A4  HI_OUT
    input   wire  [31:0]   Select_227,              // 011  A1  A4  Select_227
    input   wire  [31:0]   Sign_Extend_1_32_OUT,    // 100  A2  A5  Sign_Extend_1_32_OUT
    input   wire  [31:0]   Shift_Left_4_OUT,        // 101  A2  A5  Shift_Left_4_OUT
    input   wire  [31:0]   Shift_Reg_OUT,           // 110  A2  A6  Shift_Reg_OUT
    input   wire  [31:0]   Set_Size_OUT,            // 111  A2  A6  Set_Size_OUT
    output  wire  [31:0]   Data_out
);


    wire [31:0] A6;
    wire [31:0] A5;
    wire [31:0] A4;
    wire [31:0] A3;
    wire [31:0] A2;
    wire [31:0] A1;

    assign A6 = (selector[0]) ? Set_Size_OUT : Shift_Reg_OUT
    assign A5 = (selector[0]) ? Shift_Left_4_OUT : Sign_Extend_1_32_OUT
    assign A2 = (selector[1]) ? A5 : A6

    assign A4 = (selector[0]) ? Select_227 : HI_OUT
    assign A3 = (selector[0]) ? LO_OUT : ALU_OUT
    assign A1 = (selector[1]) ? A4 : A3

    assign Data_out = (selector[2]) ? A1 : A2

endmodule