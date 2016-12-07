
//流水灯
module Johnson(
	clk,rst_n,
	key0,key1,key2,
	led0,led1,led2,led3
);
input clk;
input rst_n;
input key0;//停止
input key1;//左移
input key2;//右移

output led0;
output led1;
output led2;
output led3;

parameter T1S = 30'd50_000_000;
/////////////////////////////////////
wire move;
keyscan U0(
	.clk(clk),
	.rst_n(rst_n),
	.key(key0),
	.key_en(move)	
);
/////////////////////////////////////
wire key1_r;
keyscan U1(
	.clk(clk),
	.rst_n(rst_n),
	.key(key1),
	.key_en(key1_r)	
);
/////////////////////////////////////
wire key2_r;
keyscan U2(
	.clk(clk),
	.rst_n(rst_n),
	.key(key2),
	.key_en(key2_r)	
);
/////////////////////////////////////
/*
reg move; //运动停止
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) move <= 1'b0;
	else if(move)LOR <= 3'b001;;
end
*/

parameter Stop    = 4'b0001;
parameter Left    = 4'b0010;
parameter Right   = 4'b0100;
parameter Problem = 4'b1000;

reg[3:0] LOR;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) LOR <= 1'b0;
	else if(move) begin
		if((key1_r)&&(key2_r))   LOR <= Problem;	//problem
		else if((key1_r)&&(!key2_r))  LOR <= Left; //Left
		else if((!key1_r)&&(key2_r))  LOR <= Right; //right
		else if((!key1_r)&&(!key2_r)) LOR <= Problem; //problem
	end
	else LOR <= Stop;
end

//delay
reg[29:0] cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 30'd0;
	else if(cnt <= T1S) cnt <= cnt + 30'd1;
	else cnt <= 30'd0;
end

//led使能
reg[3:0] led;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) led <= 4'b0001;
	else if(cnt == T1S)begin
		if(LOR == Left) 			led <= {led[0],led[3:1]}; //left
		else if(LOR == Right)	led <= {led[2:0],led[3]};//right
		else if(LOR == Stop)    led <= led;
		else if(LOR == Problem) led <= 4'b0001;
	end
end

assign led0 = led[0];
assign led1 = led[1];
assign led2 = led[2];
assign led3 = led[3];

endmodule