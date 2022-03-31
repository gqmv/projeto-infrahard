`include "parts-made/WriteDataMux.v"

module WriteDataMuxTest();

reg [31:0] ALUOut, LO, HI, LTSignExtend, ShiftLeft4, ShiftRegOut, SetSizeOut; 
reg [2:0] WriteDataCtrl;
wire [31:0] Data_out;

WriteDataMux dut(
    .ALUOut(ALUOut),
    .LO(LO),
    .HI(HI),
    .LTSignExtend(LTSignExtend),
    .ShiftLeft4(ShiftLeft4),
    .ShiftRegOut(ShiftRegOut),
    .SetSizeOut(SetSizeOut),
    .WriteDataCtrl(WriteDataCtrl),
    .Data_out(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    WriteDataCtrl = 0; ALUOut = 1; LO = 0; HI = 0; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 1; ALUOut = 0; LO = 2; HI = 0; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 2; ALUOut = 0; LO = 0; HI = 3; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 3; ALUOut = 0; LO = 0; HI = 0; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 4; ALUOut = 1; LO = 0; HI = 0; LTSignExtend = 5; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 5; ALUOut = 1; LO = 0; HI = 0; LTSignExtend = 0; ShiftLeft4 = 6; ShiftRegOut = 0; SetSizeOut = 0;
    #5
    WriteDataCtrl = 6; ALUOut = 1; LO = 0; HI = 0; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 7; SetSizeOut = 0;
    #5
    WriteDataCtrl = 7; ALUOut = 1; LO = 0; HI = 0; LTSignExtend = 0; ShiftLeft4 = 0; ShiftRegOut = 0; SetSizeOut = 8;
    #5
    $finish();
end

endmodule