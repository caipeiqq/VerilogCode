
 module lcd1602(clk,rst,LCD_E,LCD_RW,LCD_RS,LCD_D);
	input clk,rst;
	output LCD_E,LCD_RW,LCD_RS;
	output [7:0] LCD_D;
	reg LCD_E,LCD_RW,LCD_RS;
	reg [7:0] LCD_D;
	
	reg [9:0] state;
	reg [5:0] address;
	 
	
	parameter IDLE		=10'b0000000000;
	parameter CLEAR		=10'b0000000001;		//清屏
	
	parameter RETURNCURSOR	=10'b0000000010;	//归home位
	
	parameter SETMODE	=10'b0000000111;		
	//输入方式设置，读写数据后ram地址增/减1；画面动/不动
	
	parameter SWITCHMODE	=10'b0000001111;	
	//显示状态设置，显示开/关；光标开/关；闪烁开/关
	
	parameter SHIFT		=10'b0000011100;		
	//光标画面滚动 画面/光标平移一位；左/右平移一位
	
	parameter SETFUNCTION	=10'b0000111100;	
	//工作方式设置 1：8/1：4位数据接口；两行/一行显示；5x10/5x7点阵
	
	parameter SETCGRAM	=10'b0001000000;		//设置CGRAM
	parameter SETDDRAM1	=10'b0010000001;		//设置DDRAM
	parameter SETDDRAM2	=10'b0010000010;		//设置DDRAM
	parameter READFLAG	=10'b0100000000;		//读状态
	parameter WRITERAM1	=10'b1000000001;		//写RAM
	parameter WRITERAM2	=10'b1000000010;		//写RAM
	parameter READRAM	=10'b1100000000;		//读RAM

	parameter cur_inc      	=1;
	parameter cur_dec      	=0;
	parameter cur_shift    	=1;
	parameter cur_noshift  	=0;
	parameter open_display 	=1;
	parameter open_cur     	=0;
	parameter blank_cur    	=0;
	parameter shift_display	=1;
	parameter shift_cur    	=0;
	parameter right_shift  	=1;
	parameter left_shift   	=0;
	parameter LCD_Dwidth8   	=1;
	parameter LCD_Dwidth4   	=0;
	parameter twoline      	=1;
	parameter oneline      	=0;
	parameter font5x10     	=1;
	parameter font5x7      	=0;

/******************************************************************/
	function [7:0] dd ram;                 //写入需要的字符数据
		input [5:0] n;
		begin
			case(n)
			0:ddram=8'h48;//H
			1:ddram=8'h65;//e
			2:ddram=8'h6c;//l
			3:ddram=8'h6c;//l
			4:ddram=8'h6f;//o
			5:ddram=8'h21;//!
			6:ddram=8'h21;//!
			7:ddram=8'hA0;//space
			8:ddram=8'h7E;//->
			9:ddram=8'hA0;//space
			10:ddram=8'h5A;//Z
			11:ddram=8'h52;//R
			12:ddram=8'h74;//t
			13:ddram=8'h65;//e
			14:ddram=8'h63;//c
			15:ddram=8'h68;//h
			16:ddram=8'h77;//w
			17:ddram=8'h77;//w
			18:ddram=8'h77;//w
			19:ddram=8'h2E;//.
			20:ddram=8'h5A;//Z
			21:ddram=8'h52;//R
			22:ddram=8'hB0;//R
			23:ddram=8'h74;//t
			24:ddram=8'h65;//e
			25:ddram=8'h63;//c
			26:ddram=8'h68;//h
			27:ddram=8'h2E;//.
			28:ddram=8'h6E;//n
			29:ddram=8'h65;//e
			30:ddram=8'h74;//t
			31:ddram=8'hA0;//space
			default:  ddram=8'hxx;
			endcase
		end
	endfunction
/******************************************************************/
//分频模块 0-40000 clkdiv为0;40000-80000 clkdiv为1;
reg [16:0] clkcnt;
reg clkdiv; 
always @ (posedge clk)
	if(!rst)
		clkcnt<=17'b0_0000_0000_0000_0000;
	else
		begin
			if(clkcnt<17'b0_1001_1100_0100_0000) //17'd40_000
				begin
				clkcnt<=clkcnt+1;
				 clkdiv<=0;
				end
				
			else if(clkcnt==17'b1_0011_1000_0111_1111) //17'd79_999
				 clkcnt<=17'b0_0000_0000_0000_0000;
				 
			else
				begin
				clkcnt<=clkcnt+1;
				 clkdiv<=1;
				end
		  end
	

reg clk_int;          
always @ (posedge clkdiv or negedge rst) //原为clkdiv
	if(!rst)
		clk_int<=0;
	else
		clk_int<=~clk_int;

	
always @ (negedge clkdiv or negedge rst) // T 为clkdiv的2倍,3.2ms;100000个clk: 500Hz,2ms
	if(!rst)
		LCD_E<=0;
	else
		LCD_E<=~LCD_E;
	
/******************************************************************/
always @ (posedge clk_int or negedge rst)
	if(!rst)
		begin
			state<=IDLE;
			address<=6'b000000;
			LCD_D<=8'b00000000;
			LCD_RS<=0;
			LCD_RW<=0;
		end
	else
	begin
		case(state)
		IDLE		    	:begin 
								LCD_D<=8'bzzzz_zzzz;
								state<=CLEAR;
							end
								
		CLEAR				:begin LCD_RS<=0;LCD_RW<=0;LCD_D<=8'b0000_0001;  //清屏01
								state<=SETFUNCTION;
							end
								
		SETFUNCTION		:begin LCD_RS<=0;LCD_RW<=0;LCD_D[7:5]<=3'b001; //功能设置3C
									  LCD_D[4]<=LCD_Dwidth8;LCD_D[3]<=twoline;
									  LCD_D[2]<=font5x10;LCD_D[1:0]<=2'b00;
								state<=SWITCHMODE;
							end
							
		SWITCHMODE 		:begin LCD_RS<=0;LCD_RW<=0;LCD_D[7:3]<=5'b00001; //显示状态开关设置0C
									  LCD_D[2]<=open_display;LCD_D[1]<=open_cur;
									  LCD_D[0]<=blank_cur;
								state<=SETMODE;end  
							
		SETMODE			:begin LCD_RS<=0;LCD_RW<=0;LCD_D[7:2]<=6'b000001; //输入方式设置06
									  LCD_D[1]<=cur_inc;LCD_D[0]<=cur_noshift;
								state<=SHIFT;end
								
		SHIFT				:begin LCD_RS<=0;LCD_RW<=0;LCD_D[7:4]<=4'b0001;  //光标画面滚动
									  LCD_D[3]<=shift_cur;LCD_D[2]<=left_shift;LCD_D[1:0]<=2'b00;
										state<=SETDDRAM1;end
								
		SETDDRAM1		:begin LCD_RS<=0;LCD_RW<=0;LCD_D<=8'b10000000;   //显示数据存储器地址80
									  state<=WRITERAM1;end
									  
		SETDDRAM2		:begin LCD_RS<=0;LCD_RW<=0;LCD_D<=8'b11000000;   //显示数据存储器地址80+40
									  state<=WRITERAM2;end
									  
		WRITERAM1		:begin  //写第一行数据
								if(address<=15)
									begin
										LCD_RS<=1;
										LCD_RW<=0;
										LCD_D<=ddram(address);
										address<=address+1;
										state<=WRITERAM1;
									end
								else
									begin
										LCD_RS<=0;
										LCD_RW<=0;
										state<=SETDDRAM2;
									end
							end
						
		WRITERAM2      :begin //写第二行数据
								if(address<=31)
									begin
										LCD_RS<=1;
										LCD_RW<=0;
										LCD_D<=ddram(address);
										address<=address+1;
										state<=WRITERAM2;
									end
								else
									begin
										LCD_RS<=0;
										LCD_RW<=0;
										state<=SHIFT;
										address<=6'b000000;
									end
							end
		endcase
	end
endmodule
			
