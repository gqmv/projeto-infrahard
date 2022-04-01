module SignExtend(
    input wire [15:0] OriginSignal,

    output wire [31:0] SignExtendOutput
);

    assign SignExtendOutput = (OriginSignal[15]) ? {{16{1'b1}}, OriginSignal} : {{16{1'b0}}, OriginSignal};

endmodule

