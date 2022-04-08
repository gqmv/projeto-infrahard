module ShiftLeft2_PC (

    input  wire [25:0] Instruction_25_0,
    output wire [27:0] Data_out

);

    assign Data_out = Instruction_25_0 << 2;

endmodule