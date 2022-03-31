`include "developed-components/mux/memAddrMux.v"

module memAddrMuxTest();

reg [31:0] regA, regB, PC, ALUOut;
reg [2:0] MemAddrCtrl;
wire [31:0] out;

memAddrMux dut(.MemAddrCtrl(MemAddrCtrl), .regA(regA), .regB(regB), .PC(PC), .ALUOut(ALUOut), .Data_out(out));

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    MemAddrCtrl = 0; regA = 5; regB = 0; PC = 0; ALUOut = 0;
    #5
    MemAddrCtrl = 1; regA = 0; regB = 5; PC = 0; ALUOut = 0;
    #5
    $finish();
end

endmodule