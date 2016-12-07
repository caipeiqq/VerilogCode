module uart(
		clk,rst_n,
		rs232_rx,rs232_tx,
		cs,dx
);

input clk;			// 50MHz主时钟
input rst_n;		//低电平复位信号

input rs232_rx;		// RS232接收数据信号
output rs232_tx;		//	RS232发送数据信号

output[1:0] cs;  	//片选
output[7:0] dx;	//段选









endmodule