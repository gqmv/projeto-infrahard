module mult(
    input wire clk,
    input wire MultCtrl,
    input wire reset,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] high,
    output reg [31:0] low,
    output reg mult_end

);

    integer cont = -1;
    reg [64:0] add;
    reg [64:0] sub;
    reg [64:0] produto;
    reg [31:0] comp;

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            high = 32'b0;
            low = 32'b0;
            mult_end = 1'b0;
            add = 65'b0;
            sub = 65'b0;
            produto = 65'b0;
            comp = 32'b0;
            cont = -1;
        end
        if(MultCtrl == 1'b1) begin
            add = {a, 33'b0};
            comp = (~a + 1'b1);         // invert bits + add one
            sub = {comp, 33'b0}; 
            produto = {32'b0, b, 1'b0};
            cont = 32;
            mult_end = 1'b0;
        end

        case (produto[1:0])
            2'b01: produto = produto + add;
            2'b10: produto = produto + sub;
        endcase

        produto = produto >> 1;
        if(produto[63] == 1'b1) begin
            produto[64] = 1'b1;
        end
        
        if(cont > 0) begin
            cont = (cont - 1);
        end

        if(cont == 0) begin
            high = produto[64:33];
            low = produto[32:1];
            mult_end = 1'b1;

            // reseting
            add = 65'b0;
            sub = 65'b0;
            produto = 65'b0;
            cont = -1;
        end
    end

endmodule