module LOWReg (
    input in,
    input clk,
    input reset,
    input WriteHILO,
    output [0:31] LO,
    reg [0:31] out_nxt
);

assign LO = out_nxt;

always@ (posedge clk)
    begin
        if (reset)
            out_nxt <= 32'b0;
        else
            if (WriteHILO)
                out_nxt = {out_nxt, in};
    end

endmodule