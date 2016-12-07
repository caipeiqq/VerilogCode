//按键消抖模块测试成功
//向左流水灯完成
module johnson(
		clk ,rst_n,
		key0,key1,key2,
		led0,led1,led2,led3
);

input clk	; //50MHz
input rst_n	; //低电平有效

input key0	;	//按键，移动和停止
input key1	;	//左移
input key2	;	//右移

output led0 	;	//输出，灯
output led1 	;
output led2 	;
output led3 	;

parameter T1S = 26'd50_000_000;

//调用模块，如果按键按下，按键消抖，返回一个en
//移动使能
keyscan U0(
		.clk(clk),
		.rst_n(rst_n),
		.key(key0),
		.key_en(Move_en)
);
//左移使能
keyscan U1(
		.clk(clk),
		.rst_n(rst_n),
		.key(key1),
		.key_en(left_en)
);
//右移使能
keyscan U2(
		.clk(clk),
		.rst_n(rst_n),
		.key(key2),
		.key_en(right_en)
);

//延时1s，f=50M，n = 50_000_000
reg[25:0]cnt;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 26'd0;
	else if(cnt <= T1S ) cnt <= cnt + 26'd1;
	else cnt <= 26'd0;
end

// 1向左，0向右
reg choice;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)  choice <= 1'b0;
	else if((left_en)&&(~right_en)) choice <= 1'b0;
	else if((~left_en)&&(right_en)) choice <= 1'b1;
	else if((left_en)&&(right_en)) choice <= ~choice;
end

//运动和方向
reg[3:0] led;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) led <= 4'b0001;
	else if((cnt == T1S)&&Move_en)	begin
		if(choice)  begin
			if(led == 4'b1000) led <= 4'b0001;
			else led <= led<<1;
		end
		else begin
			if(led == 4'b0001) led <= 4'b1000;
			else led <= led>>1;
		end
	end
end

assign led0 = led[0];
assign led1 = led[1];
assign led2 = led[2];
assign led3 = led[3];


/*
//按键消抖
reg d0;
reg d1;
reg d2;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
			d0 <=	1'b0;
			d1 <=	1'b0;
			d2 <= 1'b0;
	end
	else	begin
		if(move_en) d0 <= ~d0;
		else if(leftMove_en) d1 <= ~d1;
		else if(rightMove_en) d2 <= ~d2;
	end
end

assign led0 =	d0;	//输出，灯
assign led1 =	d1;
assign led2 =	d2;

*/


endmodule