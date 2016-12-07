//Á÷Ë®µÆ
module Johnson(
	clk,rst_n,
	key0,key1,key2,
	led0,led1,led2,led3
);
input clk;
input rst_n;
input key0;//Í£Ö¹
input key1;//×óÒÆ
input key2;//ÓÒÒÆ

output led0;
output led1;
output led2;
output led3;

parameter Stop 	 = 4'b0001;
parameter Left  	 = 4'b0010;
parameter Right 	 = 4'b0100;
parameter T1S = 26'd50_000_000;


wire key0_r;
xiaodou U0(
	.clk(clk),
	.rst_n(rst_n),
	.key(key0),
	.key_r(key0_r)	
);

wire key1_r;
xiaodou U1(
	.clk(clk),
	.rst_n(rst_n),
	.key(key1),
	.key_r(key1_r)	
);

wire key2_r;
xiaodou U2(
	.clk(clk),
	.rst_n(rst_n),
	.key(key2),
	.key_r(key2_r)	
);


reg[3:0] state;
reg[3:0] nextstate;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		state <= Stop;
	end
	else state <= nextstate;
end

always@(state or key0_r or key1_r or key2_r)begin
	case(state)
		Stop: if(key0_r) nextstate = Left;
				else nextstate = Stop;
							
		Left: if(!key0_r) nextstate = Stop;
				else if(!key2_r) nextstate = Right;
				
		Right:if(!key0_r) nextstate = Stop;
				else if(!key1_r)	nextstate = Left;
				
		default: nextstate = 4'bxxxx;
	endcase
end

//delay
reg[29:0] cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 30'b0;
	else if(cnt <= T1S) cnt <= cnt + 30'b1;
	else cnt <= 30'b0;
end

//Í£Ö¹	
reg[3:0] led;
always@(posedge clk or negedge rst_n)begin
		if(!rst_n) led =4'b0001;
		else if(cnt == T1S)begin
			case(nextstate)
				Stop:  led <= led;
				Left:  led <= {led[0],led[3:1]};
				Right: led <= {led[2:0],led[3]};
				default: ;
			endcase
		end
end

assign led0 = led[0];
assign led1 = led[1];
assign led2 = led[2];
assign led3 = led[3];


endmodule