module mux_ulaA(

    input  wire [1:0]  ALUSrcA,
    input  wire [31:0] PC,
    input  wire [31:0] A,
    input  wire [31:0] MDR,

    output wire [31:0] Data_out

);

 

// PC  - |
// A   - |-- PC_A --|
// MDR -------------|-- Data_out -->

    wire [31:0] PC_A;

    assign PC_A = (ALUSrcA[0]) ? A : PC;
    assign data_out = (ALUSrcA[1]) ? MDR : PC_A;

endmodule