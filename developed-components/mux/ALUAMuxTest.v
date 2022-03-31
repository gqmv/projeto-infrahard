`include "developed-components/mux/ALUAMux.v"

module ALUAMuxTest();

reg [31:0] PC, A, MDR;
reg [1:0] ALUSrcA;
wire [31:0] out;

ALUAMux dut(.ALUSrcA(ALUSrcA), .PC(PC), .A(A), .MDR(MDR), .Data_out(out));

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    ALUSrcA = 0; PC = 5; A = 0; MDR = 0;
    #5
    ALUSrcA = 1; PC = 0; A = 5; MDR = 0;
    #5
    ALUSrcA = 2; PC = 0; A = 0; MDR = 5;
    #5
    $finish();
end

endmodule