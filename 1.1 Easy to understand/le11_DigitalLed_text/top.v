	module top(
		clk ,rst_n,
	//	rx_data,
		cs, dx
	);
	
	
	input clk	; //50MHz
	input rst_n	; //�͵�ƽ��Ч
	//input[7:0] rx_data

	output[1:0] cs;//λѡ������Ч
	output[7:0] dx; //��ѡ
	
//	wire[1:0] cs_r;//λѡ������Ч
//	wire[7:0] dx_r; //��ѡ
	DigitalLed my_DigitalLed(
			.clk(clk) ,
			.rst_n(rst_n),
			//.rx_data(rx_data),
			.cs(cs_r), 
			.dx(dx_r)
	);		
	
	assign cs = cs_r;
	assign dx = dx_r;
	
	endmodule