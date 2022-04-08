module MultDivMuxes (
    input wire HILOCtrl,
	input wire [31:0] mult,
	input wire [31:0] div,
	output wire [31:0] Data_out
);

	assign Data_out = (HILOCtrl) ? div : mult;
    
endmodule 