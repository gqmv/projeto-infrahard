module SetSizeMem(
    
    input  wire [1:0]  SizeMem_Ctrl,
    input  wire [31:0] MDR,
    input  wire [31:0] B,
    output wire  [31:0] Data_out

);

//	00 = byte 
//  01 = halfword  
//  10 = word
	
    wire [31:0] byte_half; 

    assign byte_half = (SizeMem_Ctrl[0]) ? {MDR[31:16], B[15:0]} : {MDR[31:8], B[7:0]};
    assign Data_out = (SizeMem_Ctrl[1]) ? B : byte_half;


endmodule 