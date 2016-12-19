//实验目的：两位数码管，从0到f循环递增
	`timescale 1ns / 1ps
	module DigitalLed(
		clk ,rst_n,
		data,
	   cs, dx
	);


	input clk	; //50MHz
	input rst_n	; //低电平有效
	input[7:0] data;

	output[1:0] cs;//位选，低有效
	output[7:0] dx; //段选

	//parameter rx_data = 28'd25_123_456;
	//延时时间
	parameter T1S 	   = 26'd50_000_000;
	parameter T500MS  = 26'd25_000_000;
	parameter T1MS  	= 26'd50_000;
	parameter T500US  = 26'd25_000;
	
	//数码管编码
	parameter N0 = 8'b1100_0000;
	parameter N1 = 8'b1111_1001;			
	parameter N2 = 8'b1010_0100;	
	parameter N3 = 8'b1011_0000;	
	parameter N4 = 8'b1001_1001;	
	parameter N5 = 8'b1001_0010;	
	parameter N6 = 8'b1000_0010;	
	parameter N7 = 8'b1111_1000;	
	parameter N8 = 8'b1000_0000;	
	parameter N9 = 8'b1001_0000;	
	parameter NA = 8'b1000_1000;	
	parameter NB = 8'b1000_0011;	
	parameter NC = 8'b1100_0110;	
	parameter ND = 8'b1010_0001;	
	parameter NE = 8'b1000_0110;	
	parameter NF = 8'b1000_1110;	

	
	//reg[7:0] data;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) data <= 8'd0;
		else data <= rx_data;
	end
	
	
	//0.延时
	reg[25:0] cnt;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) cnt <= 26'd0;
		else if(cnt == T1MS) cnt <= 26'd0;
		else cnt <= cnt + 26'd1;
	end
	
	reg[4:0] cnt_ms;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) cnt_ms <= 5'd0;
		else if(cnt_ms == 5'd20) cnt_ms <= 5'd0;
		else if(cnt == T1MS)cnt_ms <= cnt_ms + 5'd1;
	end

	//1.取位模块
	reg[7:0] oneData;
	reg[7:0] tenData;

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) oneData <= 8'd0;
		else oneData <= data % 8'd10;
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) tenData <= 8'd0;
		else tenData <= data / 8'd10 % 8'd10;
	end

	//2.转SMG码
	//2.1 oneData段选
	reg[7:0] oneData_smg;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) oneData_smg <= 8'd0;
		else begin
			case(oneData)
			5'h0: oneData_smg = N0; 
			5'h1: oneData_smg = N1;
			5'h2: oneData_smg = N2;
			5'h3: oneData_smg = N3;
			5'h4: oneData_smg = N4;
			5'h5: oneData_smg = N5;
			5'h6: oneData_smg = N6;
			5'h7: oneData_smg = N7;
			5'h8: oneData_smg = N8;
			5'h9: oneData_smg = N9;
			5'hA: oneData_smg = NA;
			5'hB: oneData_smg = NB;
			5'hC: oneData_smg = NC;
			5'hD: oneData_smg = ND;
			5'hE: oneData_smg = NE;
			5'hF: oneData_smg = NF;
			default;
		endcase
		end		
	end
	
	//2.2 tenData段选
	reg[7:0] tenData_smg;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) tenData_smg <= 8'd0;
		else begin
			case(tenData)
			5'h0: tenData_smg = N0; 
			5'h1: tenData_smg = N1;
			5'h2: tenData_smg = N2;
			5'h3: tenData_smg = N3;
			5'h4: tenData_smg = N4;
			5'h5: tenData_smg = N5;
			5'h6: tenData_smg = N6;
			5'h7: tenData_smg = N7;
			5'h8: tenData_smg = N8;
			5'h9: tenData_smg = N9;
			5'hA: tenData_smg = NA;
			5'hB: tenData_smg = NB;
			5'hC: tenData_smg = NC;
			5'hD: tenData_smg = ND;
			5'hE: tenData_smg = NE;
			5'hF: tenData_smg = NF;
			default;
		endcase
		end		
	end
	

	//3. 输出片选和段选
	reg[1:0] cs_r;
	reg[7:0] dx_r;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			dx_r <= 8'd0;
			cs_r  <= 2'b11;
		end
		else if(cnt_ms == 5'd20) begin
			cs_r  <= 2'b10;
			dx_r <= oneData_smg;			//个位		
		end
		else if(cnt_ms == 5'd10) begin
			cs_r  <= 2'b01;
			dx_r <= tenData_smg;			//百位		
		end
	end	

	assign cs = cs_r;
	assign dx = dx_r;
	
	endmodule