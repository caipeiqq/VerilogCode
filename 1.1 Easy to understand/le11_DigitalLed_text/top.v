	`timescale 1 ns/ 1 ps
	module top(
		clk ,rst_n,
		cs, dx, led
	);
	
	
	input clk	; //50MHz
	input rst_n	; //低电平有效
	//input[7:0] data

	output[1:0] cs;//位选，低有效
	output[7:0] dx; //段选
	output[3:0] led; 
	
	wire[1:0] cs;
	wire[7:0] dx;
	wire[3:0] led;
	/////////////////////////////////////////////////////////
		//延时时间
		parameter T1S 	   = 26'd49_999_999;		//26'd50_000_000;
		parameter T500MS  = 26'd24_999_999;		//26'd25_000_000;	
		parameter T1MS  	= 26'd49_999;			//26'd50_000;
		parameter T500US  = 26'd24_999;			//26'd25_000;
		
/////////////////////////////////////////////////////////		
		//0.延时
		reg[25:0] cnt;
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) cnt <= 26'd0;
			else if(cnt == T1S) cnt <= 26'd0;
			else cnt <= cnt + 26'd1;
		end
		
		reg clk_1s;
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) clk_1s <= 1'd0;
			else if(cnt < T500MS) clk_1s <= 1'd1;
			else clk_1s <= 1'd0;
		end

		//parameter data = 28'd25_123_456;

/////////////////////////////////////////////////////////	
	reg[7:0] data;
	always @(posedge clk_1s or negedge rst_n)begin
		if(!rst_n) data <= 8'd0;
		else if(data == 8'd99) data <= 8'd56;
		else data <= data + 8'd1;
	end

	DigitalLed my_DigitalLed(
			.clk(clk) ,
			.rst_n(rst_n),
			.data(data),
			.cs(cs), 
			.dx(dx),
			.led(led)
	);		

	
	endmodule