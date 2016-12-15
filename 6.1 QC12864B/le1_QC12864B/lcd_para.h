
	//    640 * 480 
`ifdef       VGA_640_480_60FPS_25MHz 
`define    H_FRONT    11'd16 
`define    H_SYNC     11'd96  
`define    H_BACK     11'd48  
`define    H_DISP    11'd640 
`define    H_TOTAL    11'd800     
                     
`define    V_FRONT    11'd10  
`define    V_SYNC     11'd2   
`define    V_BACK     11'd33 
`define    V_DISP     11'd480   
`define    V_TOTAL    11'd525 
`endif

//--------------------------------- 
//    800 * 600 
`ifdef       VGA_800_600_72FPS_50MHz 
`define    H_FRONT    11'd56 
`define    H_SYNC     11'd120  
`define    H_BACK     11'd64  
`define    H_DISP     11'd800 
`define    H_TOTAL    11'd1040 
                    
`define    V_FRONT    11'd37  
`define    V_SYNC     11'd6   
`define    V_BACK     11'd23  
`define    V_DISP     11'd600  
`define    V_TOTAL    11'd666 
`endif

//---------------------------------

`define    H_Start    (`H_SYNC + `H_BACK) 
`define    H_END     (`H_SYNC + `H_BACK + `H_DISP)

`define    V_Start    (`V_SYNC + `V_BACK) 
`define    V_END     (`V_SYNC + `V_BACK + `V_DISP)