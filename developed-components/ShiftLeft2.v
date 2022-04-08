module ShiftLeft2 (

    input  wire [31:0] Sign_Extend,
    output wire [31:0] Data_out

);

    assign Data_out = Sign_Extend << 2;

endmodule