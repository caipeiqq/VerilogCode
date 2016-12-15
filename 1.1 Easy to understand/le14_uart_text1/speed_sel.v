module speed_sel(
		clk,rst_n,
		bps_start,clk_bps

);

input clk;			// 50MHz主时钟
input rst_n;		//低电平复位信号
input bps_start;
output clk_bps;

/*
parameter 	bps9600 		= 5207,	//波特率为9600bps
			 	bps19200 	= 2603,	//波特率为19200bps
				bps38400 	= 1301,	//波特率为38400bps
				bps57600 	= 867,	//波特率为57600bps
				bps115200	= 433;	//波特率为115200bps

parameter 	bps9600_2 	= 2603,
				bps19200_2	= 1301,
				bps38400_2	= 650,
				bps57600_2	= 433,
				bps115200_2 = 216;  
*/

`define bps_PARA	= 5207;		//波特率的分频计数值
`define bps_PARA2 = 2603;		//波特率的分频计数值的一半

REG[12:0] cnt;	
reg clk_bps_r;

////////////////////////////////////////////
reg[2:0] uart_ctrl;  //波特率选择寄存器
////////////////////////////////////////////

always@(posedge clk or negedge rst_n)begin
		if(!rst_n) cnt <= 13'd0;
		else if((cnt == `BPS_PARA)||(!bps_start)) begin
					cnt <= 13'd0;
		end
		else cnt <= cnt + 1'b1;
end

always@(posedge clk or negedge rst_n)begin
		if(!rst_n) cnt_bps_r <= 13'd0;
		else if(cnt == `BPS_PARA2)begin
					cnt_bps_r <= 1'b1;
		end
		else clk_bps_r <= 1'b0;
end

always@ (posedge clk or negedge rst_n)begin
		if(!rst_n) 

end

assign clk_kps = clk_bps_r;

endmodule