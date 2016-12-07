module mux16(
	clk,rst_n,
	start,
	yout,done
);
input clk;
input rst_n;
input start;

output yout;
output done;



parameter aBin = 16'd65535;
parameter bBin = 16'd65535;
//reg[15:0] aBin;	//in
//reg[15:0] bBin;	//in
reg[31:0] yout;	//out
reg done;			
//start 读使能，计算结束，拉低
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 
end
//done 计算完成，输出，先拉低，再拉高，再拉低


//乘法器
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) yout <= 32'd0;
	else if(start) 
end
