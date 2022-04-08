module SetSizeReg(

    input  wire [1:0] Size_Ctrl,
    input  wire [31:0] MDR,
    output wire [31:0] Data_out 
);
   
  
//	00 = byte 
//  01 = halfword  
//  10 = word
	
    wire [31:0] byte_half; 

    assign byte_half = (Size_Ctrl[0]) ? {16'd0, MDR[15:0]} : {24'd0, MDR[7:0]};
    assign Data_out = (Size_Ctrl[1]) ? MDR : byte_half;

endmodule