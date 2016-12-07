	module top(
		clk ,rst_n,
	//	rx_data,
		cs, dx
	);
	
	
	input clk	; //50MHz
	input rst_n	; //低电平有效
	//input[7:0] rx_data

	output[1:0] cs;//位选，低有效
	output[7:0] dx; //段选
	
//	wire[1:0] cs_r;//位选，低有效
//	wire[7:0] dx_r; //段选
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