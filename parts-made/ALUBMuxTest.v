`include "parts-made/ALUBMux.v"

module ALUBMuxTest();

reg [31:0] B, Select_4, Shift_Left_2, Sign_Extend, Mem_Data;
reg [1:0] ALUSrcB;
wire [31:0] out;

ALUBMux dut(.ALUSrcB(ALUSrcB), .B(B), .Select_4(Select_4), .Shift_Left_2(Shift_Left_2), .Sign_Extend(Sign_Extend), .Mem_Data(Mem_Data), .Data_out(out));

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    ALUSrcB = 0; B = 1; Select_4 = 0; Shift_Left_2 = 0; Sign_Extend = 0; Mem_Data = 0; 
    #1
    ALUSrcB = 1; B = 0; Select_4 = 2; Shift_Left_2 = 0; Sign_Extend = 0; Mem_Data = 0; 
    #2
    ALUSrcB = 2; B = 5; Select_4 = 0; Shift_Left_2 = 3; Sign_Extend = 0; Mem_Data = 0; 
    #3
    ALUSrcB = 3; B = 5; Select_4 = 0; Shift_Left_2 = 0; Sign_Extend = 4; Mem_Data = 0; 
    #4
    ALUSrcB = 4; B = 5; Select_4 = 0; Shift_Left_2 = 0; Sign_Extend = 0; Mem_Data = 5;
    #5
    $finish();
end

endmodule