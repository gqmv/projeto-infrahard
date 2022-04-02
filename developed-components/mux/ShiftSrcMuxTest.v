`include "developed-components/mux/ShiftSrcMux.v"

module ShiftSrcMuxTest();
reg [31:0] B, A;
reg ShiftSrcCtrl;
wire [31:0] Data_out;

ShiftSrcMux dut(
    .A(A),
    .B(B),
    .ShiftSrcCrtl(ShiftSrcCtrl),
    .Data_out(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    A = 1; B = 2; ShiftSrcCtrl = 0;
    #5
    A = 1; B = 2; ShiftSrcCtrl = 1;
    #5
    $finish();
end

endmodule