module SignExtend_1_32(
    input wire LT,

    output wire [31:0] SignExtendOutput
);

    assign SignExtendOutput = {31'b0, LT};

endmodule
