`include "developed-components/mux/WriteRegMux.v"

module WriteRegMuxTest();

reg [4:0] Instruction_15_11, Instruction_20_16;
reg [1:0] WriteRegCtrl;
wire [4:0] Data_out;

WriteRegMux dut(
    .WriteRegCtrl(WriteRegCtrl),
    .Instruction_15_11(Instruction_15_11),
    .Instruction_20_16(Instruction_20_16),
    .Data_out(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    WriteRegCtrl = 0; Instruction_15_11 = 2; Instruction_20_16 = 0;
    #5
    WriteRegCtrl = 1; Instruction_15_11 = 0; Instruction_20_16 = 0;
    #5
    WriteRegCtrl = 2; Instruction_15_11 = 0; Instruction_20_16 = 0;
    #5
    WriteRegCtrl = 3; Instruction_15_11 = 0; Instruction_20_16 = 2;
    #5
    $finish();
end

endmodule