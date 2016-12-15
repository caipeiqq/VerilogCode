module uart_rx(
			clk,rst_n,
			rs232_rx,rx_data,rx_int,
			clk_bps,bps_start
);

input clk;
input rst_n;
input rs232_rx;
input clk_bps;

output bps_start;
output[7:0] rx_data;
output rx_int;

/////////////////////////////////////////////////////

reg rx0,rx1,rx2,rx3;	//接收数据寄存器
wire neg_rx;  			//数据接收到下降沿
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rx0 <= 1'b0;
		rx1 <= 1'b0;
		rx2 <= 1'b0;
		rx3 <= 1'b0;
	end
	else begin
		rx0 <= rs232_rx;
		rx1 <= rx0;
		rx2 <= rx1;
		rx3 <= rx2;
	end
end

//滤波
assign neg_rx = rx3 & rx2 & rx1 & rx0;

reg bps_start_r;
reg[3:0] num;
reg rx_int; //接收数据中断信号,接收到数据期间始终为高电平

always @ (posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		bps_start_r <= 1'bz;
		rx_int <= 1'b1;
	end
	else if(neg_rx)begin
		bps_start_r <= 1'b0;
		rx_int <= 1'b0;
	end
end

assign bps_






endmodule