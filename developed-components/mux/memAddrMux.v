module memAddrMux(
    input wire  [2:0]  MemAddrCtrl,
    input wire  [31:0] regA,
    input wire  [31:0] regB,
    input wire  [31:0]  PC,
    input wire  [31:0] ALUOut,

    output wire [31:0]  Data_out
);

// regA -- |
// regB -- | -- |
//              | --   |            
// PC --   |    |      |
// 253 --  | -- |      |
//                     |  ---
// 254 --  |           |
// 255 --  | --  |     |
//               | --  |
// ALUOut -----  |   


    wire [31:0]  int_regA_regB;
    wire [31:0]  int_PC_253;
    wire [31:0]  int_254_255;

    wire [31:0]  int_t0;
    wire [31:0]  int_t1;

    assign int_regA_regB = (MemAddrCtrl[0] ? regB : regA);
    assign int_PC_253 = (MemAddrCtrl[0] ? 32'd253: PC);
    assign int_254_255 = (MemAddrCtrl[0] ? 32'd254: 32'd255);

    assign int_t0 = (MemAddrCtrl[1] ? int_PC_253 : int_regA_regB);
    assign int_t1 = (MemAddrCtrl[1] ? ALUOut : int_254_255);

    assign Data_out = (MemAddrCtrl[2] ? int_t1 : int_t0);

endmodule