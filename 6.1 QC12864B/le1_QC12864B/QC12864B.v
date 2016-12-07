module QC12864B(

    clk, rst_n,
//	 BUSY,
	 RS,
	 RW,
	 EN,PSB,
	 //REST,
	 DB,
);
//////////////////////////////////////////////////////////////////////	
	//50MHz，20ns
	//1.1 输入
	input clk;
	input rst_n;
//	input BUSY;					//读忙标志                  位 
	
	//1.2 输出
	output      RS;         //数据-高,指令-低
	output      RW;         //读-高，写-低
	output      PSB;	      //并口-高，串口-低
	output      EN;         //使能-高
	//output      REST ;      //复位-低有效                                                                           
	output[7:0] DB;         //三态数据线
	//output[3:0] led;
	
	//1.3 寄存器
	reg [7:0] 	state;
	//reg [7:0] 	nextstate;
	reg[3:0] led;
	
	reg       RS;         //数据-高,指令-低
	wire      RW;         //读-高，写-低
	wire     PSB;	       //并口-高，串口-低
	wire      EN;         //使能-高
	//reg     REST;         //复位-低有效                                                                           
	reg[7:0]  DB;         //三态数据线
	
	//1.4 常数
	//1.4.1 独热码
	parameter   Idle	 		= 8'b0000_0001,
					SetRE1      = 8'b0000_0010,
					SetRE2		= 8'b0000_0011,
					SetDisplay 	= 8'b0000_0100,
					Clear 		= 8'b0000_0101,
					Remove 		= 8'b0000_0110,
					SetAddrOne	= 8'b0000_0111,
					WtLineOne	= 8'b0000_1000,
					AddrReturn	= 8'b0000_1001,
					STOP			= 8'b0000_1010;
					
					
	//1.4.2 时间计数
	//parameter T1MS    = 18'd249_999; //5ms
	parameter T5MS    = 18'd249_999; //5ms
	parameter T2500US = 18'd125_000; //2.5ms
//	parameter T1S    	= 18'd49_999_999; //1s
//	parameter T2500US = 18'd25_000_000; //500ms
//	parameter 1D6Ms_CNT = 18'd80000;//1.6ms
//	parameter OTHER_CNT = 18'd3600 ;//72us
	

	//1.4.3 屏幕指令
	parameter RE_BASIC  	= 8'h30;  //基本指令集	
	parameter DISPLAY 	= 8'h0C;  //开显示及光标设置
	parameter CLEAR  		= 8'h01;  //清屏
	parameter REMOVE 		= 8'h06;  //显示光标移动设置
	
	parameter ADDR_ONE 	= 8'h80;  //第1行地址
	parameter ADDR_TWO 	= 8'h90;  //第2行地址
	parameter ADDR_THREE = 8'h88;  //第3行地址
	parameter ADDR_FOUR 	= 8'h98;  //第4行地址
	
//////////////////////////////////////////////////////////////////////				
	//2.1 分频5MS,200HZ
	reg[17:0] cnt;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) cnt <= 18'd0 ;
		else	if(cnt == T5MS)cnt <= 18'd0;
		else cnt <= cnt + 18'd1;
	end
	
	reg clk_5ms;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) clk_5ms <= 1'd0 ;
		else	if(cnt < T2500US) clk_5ms <= 1'd1;
		else clk_5ms <= 1'd0;
	end
	
	reg[9:0] cnt_1s;
	always @(posedge clk_5ms or negedge rst_n)begin
		if(!rst_n) cnt_1s <= 1'd0 ;
		else	if(cnt_1s == 10'd500) cnt_1s <= 1'd0;
		else cnt_1s <= cnt_1s + 1'd1;
	end
	
	reg clk_1s;
	always @(posedge clk_5ms or negedge rst_n)begin
		if(!rst_n) clk_1s <= 1'd0 ;
		else	if(cnt_1s == 10'd500) clk_1s <= 1'd1;
		else clk_1s <= 1'd0;
	end
	
	
//////////////////////////////////////////////////////////////////////	
	//状态机
	//3.1每一个时钟产生一个可能的变化，即时序逻辑部分	

	//输出
	assign PSB  = 1'b1;
	//assign REST = 1'b1;
	assign RW 	= 1'b0;
	
	//输出RS
	always @ (posedge clk_5ms or negedge rst_n)begin
			if(!rst_n) RS <= 1'b0;
			else if(state == WtLineOne) RS <= 1'b1;
			else RS <= 1'b0;
	end
	
	//EN
	reg flag;
	assign EN = flag ? clk_5ms:1'b0;
	
//	reg flag;
//	always @ (posedge clk_5ms or negedge rst_n)begin
//			if(!rst_n) EN <= 1'b0;
//			else if(flag) EN <= clk_5ms;
//			else if(state == STOP) EN <= 1'b0;
//	end
	
	reg[15:0] cnt_addr;	
	
	//3.2组合逻辑部分
	always @ (posedge clk_5ms or negedge rst_n)begin
		 if(!rst_n) begin																		
						DB <= 8'b0;	
						cnt_addr <= 16'h0;
						state<=Idle;
						flag <= 1'b1;
					end
		 else begin							
				case (state)
					//a 初始化
					Idle : 	begin										
									DB <= 8'hz;
									state <= SetRE1;
								end
								
								
					//b 指令集设置--基本指令集 11_0000
					SetRE1 : begin
									DB <= 8'h30; 										
									state <= SetRE2;
								end	
						
					SetRE2 : begin
									DB <= 8'h30; 										
									state <= SetDisplay;
								end	
					
					//c 开显示及光标设置  1100、、1110
					SetDisplay: begin
										DB <= 8'b1110 ; 
										state <= Clear;
									end	
									
					//d 清屏
					Clear : begin
									DB <= 8'h01;  	
									state <= Remove;
							  end
							  
					//e 显示光标移动设置 110
					Remove : begin
									DB <= 8'b110 ;  		
									state <= SetAddrOne;
								end	  
					

					//f 写第一行地址
					SetAddrOne : 	begin										
											DB <= 8'h80; 		
											state <= WtLineOne;
										end
										
					//g 写第一行数据
//					WtLineOne : 	begin				
//											DB <= 8'h48; 
//											state <= STOP;
//										end     
										
					WtLineOne : 	begin
						//page1
						if(cnt_addr < 16'd15)begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLineOne;	
						end
						else if(cnt_addr == 16'd15) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= AddrReturn;		
						end
						//page2
						else if((cnt_addr >= 16'd16)&&(cnt_addr < 16'd28)) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLineOne;	
						end
						else	begin
							cnt_addr <= 16'd0;
							state <= AddrReturn;
						end					
					end
					

      			
					//e 写指令 110
					AddrReturn : begin	
										if(clk_1s == 1)begin
											DB <= 8'b01; 		
											state <= WtLineOne;
										end
									 end
						
					STOP : 	begin
									state <= STOP;
									flag <= 1'b0;
								end
					
					//告诉综合器case语句已经指定了所有状态，这样综合器就会删除不需要的译码电路，使生成的电路简单
					default : state = Idle;		
				endcase
			end
	 end

//////////////////////////////////////////////////////////////////////
reg[7:0] ddram;	
always@(cnt_addr)begin                 //写入需要的字符数据
		case(cnt_addr)
			//A
			0:ddram =8'hA3;//
			1:ddram =8'hC1;//
			//相
			2:ddram =8'hCF;//
			3:ddram =8'hE0;//
			//：
			4:ddram =8'hA3;//
			5:ddram =8'hBA;//
			//V
			6:ddram =8'hA3;//
			7:ddram =8'hD6;//
			//=
			8:ddram =8'hA3;//
			9:ddram =8'hBD;//
			//3
			10:ddram=8'hA3;//
			11:ddram=8'hB3;//
			//伏
			12:ddram=8'hB7;//
			13:ddram=8'hFC;//
			//，
			14:ddram=8'hA3;// 
			15:ddram=8'hAC;//
			
			//I
			16:ddram=8'hA3;//
			17:ddram=8'hC9;//
			//=
			18:ddram=8'hA3;//
			19:ddram=8'hBD;//
			//2
			20:ddram=8'hA3;//
			21:ddram=8'hB2;//
			//安
			22:ddram=8'hB0;//
			23:ddram=8'hB2;//
			//
			24:ddram=8'hA1;//
			25:ddram=8'hA0;//
			//
			26:ddram=8'hA3;//
			27:ddram=8'hA6;//		

			default:  ddram=8'hxx;
		endcase
	end

endmodule



		 
	