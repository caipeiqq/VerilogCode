	module uart_text(
			clk ,rst_n,
			cs, 
			dx,
		);
	input clk	; //50MHz
	input rst_n	; //�͵�ƽ��Ч

	output[1:0] cs;//λѡ������Ч
	output[7:0] dx; //��ѡ
	wire[1:0] cs;
	wire[7:0] dx;
	
	parameter rx_data = 8'd255;
   DigitalLed U1(
		.clk(clk),
		.rst_n(rst_n),
		.rx_data(rx_data),
		.cs(cs), 
		.dx(dx)
	);
	

	
	endmodule