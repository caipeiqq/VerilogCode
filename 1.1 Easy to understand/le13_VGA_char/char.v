module char(
                 clk,
					  rst_n,
					  hsync,
					  vsync,			
					  vga_r,
					  vga_g,
					  vga_b);
input clk;                   //输入时钟，50MZ
input rst_n;                 //复位信号，低电平有效

output hsync;                 //行同步信号
output vsync;                //场同步信号
output [2:0]vga_r;
output [2:0]vga_g;
output [1:0]vga_b;
             //色彩信号


//*************************************VGA驱动部分**************************

 
reg [10:0]x_cnt;                //行坐标计数器
reg [9:0]y_cnt;                  //列坐标计数器

always @ (posedge clk or negedge rst_n)          //行坐标刷新
   if(!rst_n) x_cnt <= 1'b0;
	else if(x_cnt == 11'd1038) x_cnt <= 1'b0;
	else x_cnt <= x_cnt + 1'b1;

always @ (posedge clk or negedge rst_n)           //列坐标刷新
   if(!rst_n) y_cnt <= 1'b0;
	else if(y_cnt ==10'd665) y_cnt <= 1'b0;
	else if(x_cnt == 11'd1038) y_cnt <= y_cnt +1'b1;
	
wire [9:0]x_dis;
wire [8:0]y_dis;                              //有效区域标志位，高有效

assign x_dis = x_cnt - 11'd187;

assign y_dis = y_cnt - 10'd31;

wire valid = (x_cnt >= 11'd187)&&(x_cnt <=11'd987)         //定义有效区域

              &&(y_cnt >=31)&&(y_cnt <=631);
reg hsync_r,vsync_r;

always @ (posedge clk or negedge rst_n)               //产生行同步信号
   if(!rst_n) hsync_r<= 1'b1;
	else if(x_cnt==11'd0) hsync_r <= 1'b0;
	else if(x_cnt == 11'd120) hsync_r <= 1'b1;
	
always @ (posedge clk or negedge rst_n)                 //产生场同步信号
   if(!rst_n) vsync_r <= 1'b1;
	else if(y_cnt==10'd0) vsync_r <=1'b0;
	else if(y_cnt==10'd6) vsync_r <= 1'b1;
	
assign hsync = hsync_r;
assign vsync = vsync_r;

//*******************************************************************************

//*************************字符色彩部分*******************************************
parameter 	
	word1_line1=		 128'h00000000_00000000_00000000_00000000,
	word1_line2=		 128'h00000000_00000000_00000000_00000000,
	word1_line3=		 128'h00010000_02000040_00000000_00040100,
	word1_line4=		 128'h0001C000_03FFFFE0_04000010_01020180,
	word1_line5=		 128'h0001C000_03018040_07FFFFF8_01830380,
	word1_line6=		 128'h00018000_03218440_04000030_00C38300,
	word1_line7=		 128'h00018000_03318E40_04000030_00E18600,
	word1_line8=		 128'h00018000_03198840_04000030_00618400,
	word1_line9=		 128'h00018000_03199040_04000630_00610C00,
	word1_line10=		 128'h00018000_0301A040_04FFFF30_00000818,
	word1_line11=		 128'h00418000_03FFFFC0_04000030_0FFFFFFC,
	word1_line12=		 128'h00718400_03018040_04000030_0C000018,
	word1_line13=	    128'h00718200_00018040_04000030_0C000030,
	word1_line14=		 128'h00E18300_07FFFFE0_04000830_1C000040,
	word1_line15=		 128'h00C18180_02018000_041FFE30_18000600,
	word1_line16=		 128'h018180C0_00018010_04100C30_01FFFF00,
	word1_line17=		 128'h01818060_00018038_04100C30_00000C00,
	word1_line18=		 128'h03018070_1FFFFFFC_04100C30_00001000,
	word1_line19=		 128'h02018038_02202080_04100C30_00016000,
	word1_line20=		 128'h04018038_02101060_04100C30_00018010,
	word1_line21=		 128'h0C018018_06081830_04100C30_00018038,
	word1_line22=		 128'h08018018_0E0D1818_041FFC30_3FFFFFFC,
	word1_line23=		 128'h10018008_1C0DC818_04100C30_00018000,
	word1_line24=		 128'h20018000_00098100_04100830_00018000,
	word1_line25=		 128'h00018000_03FFFF80_04000030_00018000,
	word1_line26=		 128'h00018000_01018000_04000030_00018000,
	word1_line27=		 128'h00018000_00018000_04000030_00018000,
	word1_line28=		 128'h00398000_00018010_04000030_00018000,
	word1_line29=		 128'h000F8000_00108038_040003F0_001F8000,
	word1_line30=		 128'h00070000_1FFFFFFC_0C0000E0_00078000,
	word1_line31=		 128'h00020000_00000000_08000040_00020000,
	word1_line32=		 128'h00000000_00000000_00000000_00000000;


reg[7:0] cnt_car;
reg [7:0] vga_rgb;			
always @ (posedge clk )
    if(x_dis==300) cnt_car <= 8'd128;
	 else if(x_dis>300 && x_dis<428) 
	       cnt_car <= cnt_car -1'b1;
			
always @ (posedge clk)begin 
   if(!valid) vga_rgb <= 8'd0;
	else if((x_dis>300)&&(x_dis<=428))begin 
	    case (y_dis)
		  9'd231 : if(word1_line1[cnt_car])  vga_rgb <= 8'b111_000_00;    //字母处显示红色
		           else vga_rgb  <= 8'b000_111_00;                        //非字母处显示绿色
		  9'd232 : if(word1_line2[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
	     9'd233 : if(word1_line3[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
		  9'd234 : if(word1_line4[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;					  
		  9'd235 : if(word1_line5[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		
		  9'd236 : if(word1_line6[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd237 : if(word1_line7[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd238 : if(word1_line8[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	  
		  9'd239 : if(word1_line9[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		          
	     9'd240 : if(word1_line10[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
		  9'd241 : if(word1_line11[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;					  
		  9'd242 : if(word1_line12[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		
		  9'd243 : if(word1_line13[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd244 : if(word1_line14[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd245 : if(word1_line15[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	  
		  9'd246 : if(word1_line16[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
		  9'd247 : if(word1_line17[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;                        
		  9'd248 : if(word1_line18[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
	     9'd249 : if(word1_line19[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
		  9'd250 : if(word1_line20[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;					  
		  9'd251 : if(word1_line21[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		
		  9'd252 : if(word1_line22[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd253 : if(word1_line23[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd254 : if(word1_line24[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	  
		  9'd255 : if(word1_line25[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		          
	     9'd256 : if(word1_line26[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
		  9'd257 : if(word1_line27[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;					  
		  9'd258 : if(word1_line28[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;		
		  9'd259 : if(word1_line29[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd260 : if(word1_line30[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	
		  9'd261 : if(word1_line31[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;	  
		  9'd262 : if(word1_line32[cnt_car])  vga_rgb <= 8'b111_000_00;    //显示红色
		           else vga_rgb  <= 8'b000_111_00;
					  
		       			
		  default : ;
      endcase		  
					  
	end
	else vga_rgb  <= 8'd0;

end 

assign vga_r = vga_rgb[7:5];
assign vga_g = vga_rgb[4:2];
assign vga_b = vga_rgb[1:0];


endmodule 