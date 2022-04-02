`include "developed-components/mux/ShiftNMux.v"

module ShiftNMuxTest();
reg [31:0] B, MemDataOut;
reg [15:0] Instruction_15_0;
reg [1:0] ShiftNCrtl;
wire [4:0] Data_out;

ShiftNMux dut(
    .B(B),
    .Instruction_15_0(Instruction_15_0),
    .MemDataOut(MemDataOut),
    .ShiftNCrtl(ShiftNCrtl),
    .Data_out(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    B = 1; MemDataOut = 2; Instruction_15_0 = 16'b1111111111111111; ShiftNCrtl = 0;
    #5
    B = 1; MemDataOut = 2; Instruction_15_0 = 16'b1111111111111111; ShiftNCrtl = 1;
    #5
    B = 1; MemDataOut = 2; Instruction_15_0 = 16'b1111111111111111; ShiftNCrtl = 2;
    #5
    $finish();
end

endmodule