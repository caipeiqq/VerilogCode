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
	//50MHz��20ns
	//1.1 ����
	input clk;
	input rst_n;
//	input BUSY;					//��æ��־                  λ 
	
	//1.2 ���
	output      RS;         //����-��,ָ��-��
	output      RW;         //��-�ߣ�д-��
	output      PSB;	      //����-�ߣ�����-��
	output      EN;         //ʹ��-��
	//output      REST ;      //��λ-����Ч                                                                           
	output[7:0] DB;         //��̬������
	//output[3:0] led;
	
	//1.3 �Ĵ���
	reg [7:0] 	state;
	//reg [7:0] 	nextstate;
	reg[3:0] led;
	
	reg       RS;         //����-��,ָ��-��
	wire      RW;         //��-�ߣ�д-��
	wire     PSB;	       //����-�ߣ�����-��
	wire      EN;         //ʹ��-��
	//reg     REST;         //��λ-����Ч                                                                           
	reg[7:0]  DB;         //��̬������
	
	//1.4 ����
	//1.4.1 ������
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
					
					
	//1.4.2 ʱ�����
	//parameter T1MS    = 18'd249_999; //5ms
	parameter T5MS    = 18'd249_999; //5ms
	parameter T2500US = 18'd125_000; //2.5ms
//	parameter T1S    	= 18'd49_999_999; //1s
//	parameter T2500US = 18'd25_000_000; //500ms
//	parameter 1D6Ms_CNT = 18'd80000;//1.6ms
//	parameter OTHER_CNT = 18'd3600 ;//72us
	

	//1.4.3 ��Ļָ��
	parameter RE_BASIC  	= 8'h30;  //����ָ�	
	parameter DISPLAY 	= 8'h0C;  //����ʾ���������
	parameter CLEAR  		= 8'h01;  //����
	parameter REMOVE 		= 8'h06;  //��ʾ����ƶ�����
	
	parameter ADDR_ONE 	= 8'h80;  //��1�е�ַ
	parameter ADDR_TWO 	= 8'h90;  //��2�е�ַ
	parameter ADDR_THREE = 8'h88;  //��3�е�ַ
	parameter ADDR_FOUR 	= 8'h98;  //��4�е�ַ
	
//////////////////////////////////////////////////////////////////////				
	//2.1 ��Ƶ5MS,200HZ
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
	//״̬��
	//3.1ÿһ��ʱ�Ӳ���һ�����ܵı仯����ʱ���߼�����	

	//���
	assign PSB  = 1'b1;
	//assign REST = 1'b1;
	assign RW 	= 1'b0;
	
	//���RS
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
	
	//3.2����߼�����
	always @ (posedge clk_5ms or negedge rst_n)begin
		 if(!rst_n) begin																		
						DB <= 8'b0;	
						cnt_addr <= 16'h0;
						state<=Idle;
						flag <= 1'b1;
					end
		 else begin							
				case (state)
					//a ��ʼ��
					Idle : 	begin										
									DB <= 8'hz;
									state <= SetRE1;
								end
								
								
					//b ָ�����--����ָ� 11_0000
					SetRE1 : begin
									DB <= 8'h30; 										
									state <= SetRE2;
								end	
						
					SetRE2 : begin
									DB <= 8'h30; 										
									state <= SetDisplay;
								end	
					
					//c ����ʾ���������  1100����1110
					SetDisplay: begin
										DB <= 8'b1110 ; 
										state <= Clear;
									end	
									
					//d ����
					Clear : begin
									DB <= 8'h01;  	
									state <= Remove;
							  end
							  
					//e ��ʾ����ƶ����� 110
					Remove : begin
									DB <= 8'b110 ;  		
									state <= SetAddrOne;
								end	  
					

					//f д��һ�е�ַ
					SetAddrOne : 	begin										
											DB <= 8'h80; 		
											state <= WtLineOne;
										end
										
					//g д��һ������
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
					

      			
					//e дָ�� 110
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
					
					//�����ۺ���case����Ѿ�ָ��������״̬�������ۺ����ͻ�ɾ������Ҫ�������·��ʹ���ɵĵ�·��
					default : state = Idle;		
				endcase
			end
	 end

//////////////////////////////////////////////////////////////////////
reg[7:0] ddram;	
always@(cnt_addr)begin                 //д����Ҫ���ַ�����
		case(cnt_addr)
			//A
			0:ddram =8'hA3;//
			1:ddram =8'hC1;//
			//��
			2:ddram =8'hCF;//
			3:ddram =8'hE0;//
			//��
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
			//��
			12:ddram=8'hB7;//
			13:ddram=8'hFC;//
			//��
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
			//��
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



		 
	