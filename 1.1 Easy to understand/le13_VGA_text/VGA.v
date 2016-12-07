`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    
// Design Name:    
// Module Name:    
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module VGA(
			clk,rst_n,
			hsync,vsync,
			vga_r,vga_g,vga_b
		);

input clk;		//50MHz
input rst_n;	//低电平复位

output hsync;	//行同步信号1039
output vsync; //场同步信号 665
                                                                          
output vga_r;
output vga_g;
output vga_b;
//-------------------------------------------------------
//VS,HS计数器
reg[11:0] x_cnt;
reg[11:0] y_cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) x_cnt <= 12'd0;
	else if(x_cnt < 12'd1039) x_cnt <= x_cnt + 12'd1;
	else x_cnt <= 12'd0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) y_cnt <= 12'd0;
	else if(x_cnt == 12'd1039)y_cnt <= y_cnt + 12'd1;
	else if(y_cnt == 12'd665) y_cnt <= 12'd0;
	
end
//-------------------------------------------------------
//产生VS,HS信号
reg hsync_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) hsync_r <= 12'd1;
	else if(x_cnt == 12'd0)hsync_r<=  12'd0;
	else if(x_cnt == 12'd120) hsync_r <= 12'd1;
end

reg vsync_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) vsync_r <= 12'd0;
	else if(y_cnt == 12'd0) vsync_r <= 12'd0;
	else if(y_cnt == 12'd6) vsync_r <= 12'd1;
end

assign vsync = vsync_r;
assign hsync = hsync_r;
//-------------------------------------------------------
//x,y有效坐标
wire[11:0] xpos;
wire[11:0] ypos;
assign xpos = x_cnt - 12'd187;
assign ypos = y_cnt - 12'd31;
//-------------------------------------------------------
//有效区域
//wire valid;
//assign valid = (x_cnt >= 12'd187)&&(x_cnt < 12'd987)
//							&&(y_cnt>=12'd31)&&(y_cnt< 12'd631);

wire redValid;
assign redValid = (xpos >= 12'd0)&&(xpos < 12'd400)
							&&(ypos>=12'd0)&&(ypos< 12'd600);				
//-------------------------------------------------------							
assign vga_r = redValid?1'b1:1'b0;							
							
endmodule