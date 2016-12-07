/*
 按键按下，led翻转
*/
module xiaodou(
	clk,rst_n,
	keyUp,//keyMidd,keyDown
	led0
);

input clk;
input rst_n;
input keyUp;			//按键
//input keyMidd;		//按键
//input keyDown;		//按键

output led0;		//LED灯输出

//记录跳变	
reg Fall_edge;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) Fall_edge <= 1'b1;
	else Fall_edge <= keyUp;
end	

reg Fall_edge_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) Fall_edge_r <= 1'b1;
	else Fall_edge_r <= Fall_edge;
end	


wire Fall_edge_en = Fall_edge_r&(~Fall_edge);

//key_an--有抖动就清零
reg[19:0] cent;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) cent <= 20'd0;
	else if(Fall_edge_en) cent <= 20'd0;
	else cent <= cent+20'd1;
end

//延时20ms,记录下降沿	
reg Rose_edge;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) Rose_edge <= 1'b1;
	//
	else if(cent == 20'd999999) Rose_edge <= keyUp;
end

reg Rose_edge_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) Rose_edge_r <= 1'b1;
	else  Rose_edge_r <= Rose_edge;
end

wire Rose_edge_en = Rose_edge_r&(~Rose_edge);

//led值的寄存器
reg d0;
//led翻转
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) d0 <= 1'b0;
	else if(Rose_edge_en == 1'b1) d0 <= ~d0;
end	

assign led0 = d0;

endmodule