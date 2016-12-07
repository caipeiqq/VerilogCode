//实验目的：两位数码管，从0到f循环递增
module DigitalLed(
	clk ,rst_n,
	cs1_n,cs2_n,
	dx
);

input clk	; //50MHz
input rst_n	; //低电平有效

output cs1_n;//位选，低有效
output cs2_n;
output[7:0] dx; //段选

//延时
parameter T1S = 26'd50_000_000;

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


//计数
reg[25:0] cnt;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 26'd0;
	else if(cnt == T1S) cnt <= 26'd0;
	else cnt <= cnt + 26'd1;
end

//段选
reg[4:0] num;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)  num <= 5'h0;
	else if(cnt == T1S) begin
		if(num <= 5'hF) num <= num + 5'h1;
		else num <= 5'h0;	
	end
end

reg[7:0] dx_rst; 
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) dx_rst <= 8'd0;
	else begin
		case(num)
		5'h0: dx_rst = N0; 
		5'h1: dx_rst = N1;
		5'h2: dx_rst = N2;
		5'h3: dx_rst = N3;
		5'h4: dx_rst = N4;
		5'h5: dx_rst = N5;
		5'h6: dx_rst = N6;
		5'h7: dx_rst = N7;
		5'h8: dx_rst = N8;
		5'h9: dx_rst = N9;
		5'hA: dx_rst = NA;
		5'hB: dx_rst = NB;
		5'hC: dx_rst = NC;
		5'hD: dx_rst = ND;
		5'hE: dx_rst = NE;
		5'hF: dx_rst = NF;
		default;
	endcase
	end		
end


//片选
assign cs1_n = 1'b0;
assign cs2_n = 1'b0;
assign dx = dx_rst;

endmodule


/*
//要使用阻塞赋值 <=
reg[:0] ;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)  <= ;
	else	;
end
*/