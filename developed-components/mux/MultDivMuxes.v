module MultDivMuxes (
    input wire HILOCtrl;
	input wire [31:0] a;
	input wire [31:0] b;
	output wire [31:0] Data_out;
);

	assign Data_out = (HILOCtrl) ? b : a;
    
endmodule 