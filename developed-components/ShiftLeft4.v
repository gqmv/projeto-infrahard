module ShiftLeft4 (

    input  wire [15:0] Instruction_15_0,
    output wire [31:0] Data_out

);

    assign Data_out = Instruction_15_0 << 16;

endmodule