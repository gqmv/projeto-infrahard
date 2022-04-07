module LOMux(
    input  wire HILOCrtl,
    input  wire [31:0] Mult, 
    input  wire [31:0] Div, 
    output wire [31:0] Data_out

);

// Div ---------|
// Mult ---------|--- Data_out --->

    assign Data_out = (HILOCrtl) ?  Div : Mult;

endmodule