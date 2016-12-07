module xiaodou(
	clk,rst_n,
	key,led
);
//按键消抖
input clk;
input rst_n;
input key;

output led;

parameter T20MS = 30'd999_999;
//开始时刻电平跳动
reg key1;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) key1 <= 1'b1;
	else key1 <= key;
end

reg key1_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) key1_r <= 1'b1;
	else key1_r <= key1;
end

//reg key1_en;
wire key1_en = (~key1)&key1_r;

//yanshi
reg[0:29] cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 30'd0;
	else if(key1_en) cnt <= 30'd0;
	else cnt <= cnt + 30'd1;
end

reg key2;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) key2 <= 1'b1;
	else if(cnt == T20MS) key2 <= key;
end 

reg key2_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) key2_r <= 1'b1;
	else key2_r <= key2;
end

wire key2_en = (~key2)&key2_r;

//led翻转
reg led_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) led_r <= 1'b0;
	else if(key2_en)led_r <= ~led_r;
end

assign led = led_r;

endmodule