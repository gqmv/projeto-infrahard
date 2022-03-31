`include "developed-components/mux/PCSrcCtrlMux.v"

module PCSrcCtrlMuxTest();
reg [31:0] Exception_Destiny, EPC_Out, ALU_Out, Shift_Left_2;
reg [1:0] PCSourceCtrl;
wire [31:0] Data_out;

PCSrcCtrlMux dut(
    .PCSourceCtrl(PCSourceCtrl),
    .Exception_Destiny(Exception_Destiny),
    .EPC_Out(EPC_Out),
    .ALU_Out(ALU_Out),
    .Shift_Left_2(Shift_Left_2),
    .Data_out(Data_out)
);

initial begin
    $dumpfile("memAddrMuxTest.vcd");
    $dumpvars;
end

initial begin
    PCSourceCtrl = 0; Exception_Destiny = 5; EPC_Out = 0; ALU_Out = 0; Shift_Left_2 = 0;
    #5
    PCSourceCtrl = 1; Exception_Destiny = 0; EPC_Out = 5; ALU_Out = 0; Shift_Left_2 = 0;
    #5
    PCSourceCtrl = 2; Exception_Destiny = 5; EPC_Out = 0; ALU_Out = 5; Shift_Left_2 = 0;
    #5
    PCSourceCtrl = 3; Exception_Destiny = 0; EPC_Out = 0; ALU_Out = 0; Shift_Left_2 = 5;
    #5
    $finish();
end

endmodule