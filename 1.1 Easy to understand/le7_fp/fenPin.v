
/*实现分频计数

input		:程序
output 	:流水灯
功能		:
*/
module fenPin(
	clk ,rst_n,
	led0,led1,led2,led3
);

input clk	; //50MHz
input rst_n	; //低电平有效

output led0 	;
output led1 	;
output led2 	;
output led3 	;


//25MHz
reg[25:0] cnt;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)	cnt <= 26'd0;
	else if(cnt <= 26'd49_999_999) cnt <= cnt +1'b1;
	else cnt <= 26'd0;
end

assign led0 = (cnt <= 26'd24_999_999) ? 1'b0:1'b1;
assign led1 = (cnt <= 26'd24_999_999) ? 1'b0:1'b1;
assign led2 = 1'b0;
assign led3 = 1'b1;

endmodule