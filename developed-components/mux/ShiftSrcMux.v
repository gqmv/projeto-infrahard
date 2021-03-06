module ShiftSrcMux(
    input  wire ShiftSrcCrtl,
    input  wire [31:0] B, 
    input  wire [31:0] A, 
    output wire [31:0] Data_out

);

// B ---------|
// A ---------|--- Data_out --->

    assign Data_out = (ShiftSrcCrtl) ? A : B;

endmodule