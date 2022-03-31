module mux_ulaB (
    input   wire  [2:0]    ALUSrcB,
    input   wire  [31:0]   B,             // 000
    input   wire  [31:0]   Select_4,      // 001
    input   wire  [31:0]   Shift_Left_2,  // 010
    input   wire  [31:0]   Sign_Extend,   // 011
    input   wire  [31:0]   Mem_Data,      // 100
    output  wire  [31:0]   Data_out
);



// B             -----|
// Select_4      -----|-- B_4 -------\
//                                    |----|              
// Shift_Left_2  -----|--Sign_Shift--/     |
// Sign_Extend   -----|                    |
//                                         |----Data_out --->
// Mem_Data      --------------------------|


    wire [31:0] B_4;
    wire [31:0] Sign_Shift;
    wire [31:0] Sign_Shift_B_4;

    assign B_4 = (ALUSrcB[0]) ? 32'd4 : B;
    assign Sign_Shift= (ALUSrcB[0]) ? Sign_Extend : Shift_Left_2;
    assign Sign_Shift_B_4 = (ALUSrcB[1]) ? Sign_Shift : B_4;
    assign Data_out = (ALUSrcB[2]) ? Mem_Data : Sign_Shift_B_4;

endmodule