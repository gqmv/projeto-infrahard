module WriteDataMux (
    input   wire  [2:0]    WriteDataCtrl,
    input   wire  [31:0]   ALUOut,                 // 000  A1  int_ALUOut_LO  ALUOut
    input   wire  [31:0]   LO,                  // 001  A1  int_ALUOut_LO  LO
    input   wire  [31:0]   HI,                  // 010  A1  int_227_HI  HI
//  input   wire  [31:0]   Select_227,              // 011  A1  int_227_HI  Select_227
    input   wire  [31:0]   LTSignExtend,    // 100  A2  ShiftLeft4_LTSignExtend  LTSignExtend
    input   wire  [31:0]   ShiftLeft4,        // 101  A2  ShiftLeft4_LTSignExtend  ShiftLeft4
    input   wire  [31:0]   ShiftRegOut,           // 110  A2  SetSizeOut_ShiftRegOut  ShiftRegOut
    input   wire  [31:0]   SetSizeOut,            // 111  A2  SetSizeOut_ShiftRegOut  SetSizeOut
    
    output  wire  [31:0]   Data_out
);

// ALUOut --------- | 
// LO ------------- | -int_ALUOut_LO- |
//                                    | ----------A1-- |
// HI ------------- | -int_227_HI---- |                |
// 227 ------------ |                                  |
//                                                     | ---- > Data_out
// LTSignExtend --- |                                  |
// ShiftLeft4 ----- | -ShiftLeft4_LTSignExtend- |      |
//                                              | -A2- |
// ShiftRegOut ---- | -SetSizeOut_ShiftRegOut-- |
// SetSizeOut ----- |


    wire [31:0] SetSizeOut_ShiftRegOut;
    wire [31:0] ShiftLeft4_LTSignExtend;
    wire [31:0] int_227_HI;
    wire [31:0] int_ALUOut_LO;
    wire [31:0] A2;
    wire [31:0] A1;

    assign int_ALUOut_LO = (WriteDataCtrl[0]) ? LO : ALUOut;
    assign int_227_HI = (WriteDataCtrl[0]) ?  32'd227 : HI;
    assign ShiftLeft4_LTSignExtend = (WriteDataCtrl[0]) ? ShiftLeft4 : LTSignExtend;
    assign SetSizeOut_ShiftRegOut = (WriteDataCtrl[0]) ? SetSizeOut : ShiftRegOut;

    assign A1 = (WriteDataCtrl[1]) ? int_227_HI : int_ALUOut_LO;
    assign A2 = (WriteDataCtrl[1]) ? SetSizeOut_ShiftRegOut : ShiftLeft4_LTSignExtend;

    assign Data_out = (WriteDataCtrl[2]) ? A2 : A1;

endmodule