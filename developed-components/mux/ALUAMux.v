module ALUAMux(

    input  wire [1:0]  ALUSrcA,  //00
    input  wire [31:0] PC,       //01 
    input  wire [31:0] A,        //10
    input  wire [31:0] MDR,      //11

    output wire [31:0] Data_out

);

 

// PC  - |
// A   - |-- PC_A --|
// MDR -------------|-- Data_out -->

    wire [31:0] PC_A;

    assign PC_A = (ALUSrcA[0]) ? A : PC;
    assign Data_out = (ALUSrcA[1]) ? MDR : PC_A;

endmodule