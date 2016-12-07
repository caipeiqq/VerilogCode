	module uart_text(
			clk ,rst_n,
			cs, 
			dx,
		);
	input clk	; //50MHz
	input rst_n	; //低电平有效

	output[1:0] cs;//位选，低有效
	output[7:0] dx; //段选
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