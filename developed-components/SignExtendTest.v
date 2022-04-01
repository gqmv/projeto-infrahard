`include "developed-components/SignExtend.v"

module SignExtendTest();

reg [15:0] OriginSignal;
wire [31:0] Data_out;

SignExtend dut(
    .OriginSignal(OriginSignal),
    .SignExtendOutput(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    OriginSignal = 16'b1001001001001001;
    #5
    OriginSignal = 16'b0101001001001000;
    #5
    $finish();
end

endmodule