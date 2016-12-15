module sreen
	#(	parameter CHAR1 , //parameter DATA1,
		parameter CHAR2 , parameter DATA2,
		parameter CHAR3 , parameter DATA3,
		parameter CHAR4 , parameter DATA4)
(
    clk, rst_n,
	 RS,
	 RW,
	 EN,PSB,
	 DB,
	 DATA1
);
//////////////////////////////////////////////////////////////////////	
	//50MHz��20ns
	//1.1 ����
	input clk;
	input rst_n;
	input[31:0] DATA1;
	
	//1.2 ���
	output      RS;         //����-��,ָ��-��
	output      RW;         //��-�ߣ�д-��
	output      PSB;	      //����-�ߣ�����-��
	output      EN;         //ʹ��-��                                                                         
	output[7:0] DB;         //��̬������

	
	//1.3 �Ĵ���
	reg [7:0] 	state;
	
	
	reg       RS;         //����-��,ָ��-��
	wire      RW;         //��-�ߣ�д-��
	wire      PSB;	       //����-�ߣ�����-��
	wire      EN;         //ʹ��-��                                                                         
	reg[7:0]  DB;         //��̬������
	wire[31:0] DATA1;
	
//////////////////////////////////////////////////////////////////////	
//	reg[48:0] DATA1_r;
//	always @(posedge clk or negedge rst_n)begin
//		if(!rst_n) DATA1_r <= 47'd0 ;
//		else begin
//			
//			
//			DATA1_r[47:40] ;
//			DATA1_r[39:32];
//			DATA1_r[31:24];
//			DATA1_r[23:16];
//			DATA1_r[15:8];
//			DATA1_r[7:0];
//		end
//	end
	
	// 6λ
	reg[31:0]  DATA1_1,DATA1_2,DATA1_3,DATA1_4,DATA1_5,DATA1_6;
			
	//+8'h30Ϊת��ΪASCII
	always @(posedge clk_5ms or negedge rst_n)begin
		if(!rst_n) begin
			DATA1_1 <= 32'd0;
			DATA1_2 <= 32'd0;
			DATA1_3 <= 32'd0;
			DATA1_4 <= 32'd0;
			DATA1_5 <= 32'd0;
			DATA1_6 <= 32'd0;
		end
		else begin
			DATA1_1 <= DATA1 / 32'd100_000 + 32'h30;
			DATA1_2 <= DATA1 / 32'd10_000 % 32'd10 + 32'h30;
			DATA1_3 <= DATA1 / 32'd1000 % 32'd10 + 32'h30;
			DATA1_4 <= DATA1 / 32'd100 % 32'd10 + 32'h30;
			DATA1_5 <= DATA1 / 32'd10 % 32'd10  + 32'h30;
			DATA1_6 <= DATA1 % 32'd10 + 32'h30;
		end
	
	end
//	
//
//	assign DATA1_1 = DATA1_1_r[7:0];
//	assign DATA1_2 = DATA1_2_r[7:0];
//	assign DATA1_3 = DATA1_3_r[7:0];
//	assign DATA1_4 = DATA1_4_r[7:0];
//	assign DATA1_5 = DATA1_5_r[7:0];
//	assign DATA1_6 = DATA1_6_r[7:0];
//////////////////////////////////////////////////////////////////////			
	
	//1.4 ����
	//1.4.1 ������
	localparam   	Idle	 		= 8'b0000_0001,
						SetRE1      = 8'b0000_0010,
						SetRE2		= 8'b0000_0011,
						SetDisplay 	= 8'b0000_0100,
						Clear 		= 8'b0000_0101,
						Remove 		= 8'b0000_0110,
						SetAddr		= 8'b0000_0111,
						WtLine		= 8'b0000_1000,
						//AddrReturn	= 8'b0000_1001,
						STOP			= 8'b0000_1010;
					
					
	//1.4.2 ʱ�����
	//parameter T1MS    = 18'd249_999; //5ms
	localparam T5MS    = 18'd249_999; //5ms
	localparam T2500US = 18'd125_000; //2.5ms
//	parameter T1S    	= 18'd49_999_999; //1s
//	parameter T2500US = 18'd25_000_000; //500ms
//	parameter 1D6Ms_CNT = 18'd80000;//1.6ms
//	parameter OTHER_CNT = 18'd3600 ;//72us
	

	//1.4.3 ��Ļָ��
	localparam RE_BASIC  	= 8'h30;  //����ָ�	
	localparam DISPLAY 	= 8'h0C;  //����ʾ���������
	localparam CLEAR  		= 8'h01;  //����
	localparam REMOVE 		= 8'h06;  //��ʾ����ƶ�����
	
	localparam ADDR_ONE 	= 8'h80;  //��1�е�ַ
	localparam ADDR_TWO 	= 8'h90;  //��2�е�ַ
	localparam ADDR_THREE = 8'h88;  //��3�е�ַ
	localparam ADDR_FOUR 	= 8'h98;  //��4�е�ַ
	
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
	
//	reg[9:0] cnt_1s;
//	always @(posedge clk_5ms or negedge rst_n)begin
//		if(!rst_n) cnt_1s <= 1'd0 ;
//		else	if(cnt_1s == 10'd500) cnt_1s <= 1'd0;
//		else cnt_1s <= cnt_1s + 1'd1;
//	end
//	
//	reg clk_1s;
//	always @(posedge clk_5ms or negedge rst_n)begin
//		if(!rst_n) clk_1s <= 1'd0 ;
//		else	if(cnt_1s == 10'd500) clk_1s <= 1'd1;
//		else clk_1s <= 1'd0;
//	end
	
	
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
			else if(state == WtLine) RS <= 1'b1;
			else RS <= 1'b0;
	end
	
	//EN
	reg flag;
	assign EN = flag ? clk_5ms:1'b0;
	
	reg[15:0] cnt_addr;	
	reg[2:0]  line;
	//3.2����߼�����
	always @ (posedge clk_5ms or negedge rst_n)begin
		 if(!rst_n) begin																		
						DB <= 8'b0;	
						line <= 3'd1;
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
										DB <= 8'b1100 ; 
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
									state <= SetAddr;
								end	  
					

					//f д��һ�е�ַ
					SetAddr : 	begin	
										if(line == 3'd1)begin
												DB <= 8'h80; 		
												state <= WtLine;
										end
										else if(line == 3'd2)begin
												DB <= 8'h90; 		
												state <= WtLine;
										end
										else if(line == 3'd3)begin
												DB <= 8'h88; 		
												state <= WtLine;
										end
										else if(line == 3'd4)begin
												DB <= 8'h98; 		
												state <= WtLine;
										end
									end	
									   
										
					WtLine : 	begin
						//line1
						if(cnt_addr < 16'd15)begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLine;	
						end
						else if(cnt_addr == 16'd15) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;	
	                     line <= 3'd2;						
								state <= SetAddr;		
						end
						
						//line2
						else if((cnt_addr >= 16'd16)&&(cnt_addr < 16'd31)) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLine;	
						end
						else if(cnt_addr == 16'd31) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;	
								line <= 3'd3;
								state <= SetAddr;		
						end	
							
						//line3
						else if((cnt_addr >= 16'd32)&&(cnt_addr < 16'd47)) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLine;	
						end
						else if(cnt_addr == 16'd47) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;	
								line <= 3'd4;
								state <= SetAddr;		
						end
						
						//line4
						else if((cnt_addr >= 16'd48)&&(cnt_addr < 16'd63)) begin
								DB <= ddram; 
								cnt_addr <= cnt_addr + 16'd1;
								state <= WtLine;	
						end
						else if(cnt_addr == 16'd63) begin
								DB <= ddram; 
								cnt_addr <=  16'd0;	
								line <= 3'd1;
								state <= SetAddr;		
						end
					end
					

      			
					//e дָ�� 110
//					AddrReturn : begin	
//										if(clk_1s == 1)begin
//											DB <= 8'b01; 		
//											state <= WtLine;
//										end
//									 end
						
					STOP : 	begin
									state <= STOP;
									flag <= 1'b0;
								end
					
					//�����ۺ���case����Ѿ�ָ��������״̬�������ۺ����ͻ�ɾ������Ҫ�������·��ʹ���ɵĵ�·��
					default : state = Idle;		
				endcase
			end
	 end

///////////////////////////////////////////////////////////////////
// 4141CFE0B5E7D1B9
//parameter LINE1 = 256'h4141_CFE0_B5E7_D1B9;

reg[7:0] ddram;	
always@( cnt_addr,DATA1_1,DATA1_2,DATA1_3,DATA1_4,DATA1_5,DATA1_6)begin                 //д����Ҫ���ַ�����
		case(cnt_addr)
			//��1���ַ�
			0:ddram = CHAR1[79:72];
			1:ddram = CHAR1[71:64];
			2:ddram = CHAR1[63:56];
			3:ddram = CHAR1[55:48];
			4:ddram = CHAR1[47:40];
			5:ddram = CHAR1[39:32];
			6:ddram = CHAR1[31:24];
			7:ddram = CHAR1[23:16];	
			
			//��1����ֵ
			8:ddram 	= DATA1_1[7:0];
			9:ddram 	= DATA1_2[7:0];
			10:ddram	= DATA1_3[7:0];
			11:ddram	= DATA1_4[7:0];
			12:ddram	= DATA1_5[7:0];
			13:ddram	= DATA1_6[7:0];
			
			//��1�е�λ
			14:ddram	= CHAR1[15:8];
			15:ddram	= CHAR1[7:0];
			
			///////////////////
			//��2���ַ�
			16:ddram = CHAR2[79:72];
			17:ddram = CHAR2[71:64];
			18:ddram = CHAR2[63:56];
			19:ddram = CHAR2[55:48];
			20:ddram = CHAR2[47:40];
			21:ddram = CHAR2[39:32];
			22:ddram = CHAR2[31:24];
			23:ddram = CHAR2[23:16];	
			
			//��2����ֵ
			24:ddram = DATA2[47:40];
			25:ddram = DATA2[39:32];
			26:ddram	= DATA2[31:24];
			27:ddram	= DATA2[23:16];
			28:ddram	= DATA2[15:8];	
			29:ddram	= DATA2[7:0];	
			
			//��2�е�λ
			30:ddram= CHAR2[15:8]; 
			31:ddram= CHAR2[7:0];	
			
			///////////////////////////		
			//��3���ַ�
			32:ddram = CHAR3[79:72];
			33:ddram = CHAR3[71:64];
			34:ddram = CHAR3[63:56];
			35:ddram = CHAR3[55:48];
			36:ddram = CHAR3[47:40];
			37:ddram = CHAR3[39:32];
			38:ddram = CHAR3[31:24];
			39:ddram = CHAR3[23:16];
			
			//��3����ֵ
			40:ddram = DATA3[47:40];
			41:ddram = DATA3[39:32];
			42:ddram	= DATA3[31:24];
			43:ddram	= DATA3[23:16];
			44:ddram	= DATA3[15:8];
			45:ddram	= DATA3[7:0];
			
			//��3�е�λ
			46:ddram= CHAR3[15:8];
			47:ddram= CHAR3[7:0];
			
			//////////////////////////			
			//��4���ַ�
			48:ddram = CHAR4[79:72];
			49:ddram = CHAR4[71:64];
			50:ddram = CHAR4[63:56];
			51:ddram = CHAR4[55:48];
			52:ddram = CHAR4[47:40];
			53:ddram = CHAR4[39:32];
			54:ddram = CHAR4[31:24];
			55:ddram = CHAR4[23:16];
			
			//��4����ֵ
			56:ddram = DATA4[47:40];
			57:ddram = DATA4[39:32];
			58:ddram	= DATA4[31:24];
			59:ddram	= DATA4[23:16];
			60:ddram	= DATA4[15:8];
			61:ddram	= DATA4[7:0];
			
			//��4�е�λ
			62:ddram	= CHAR4[15:8];
			63:ddram	= CHAR4[7:0];

			default:  ddram=8'hxx;
		endcase
	end
//parameter LINE1 = 256'h4141_CFE0_B5E7_D1B9;
//reg[9:0] ddram;	
//always@(cnt_addr)begin                 //д����Ҫ���ַ�����
//		case(cnt_addr)
//			//
//			0:ddram = LINE1[63:32];//55;//U
//			1:ddram = LINE1[31:0];//31;//1
//			//
//			2:ddram = LINE1[127:96];//CF;//=
//			3:ddram = LINE1[95:63];//E0;//
//			//��
//			4:ddram = LINE1[191:160];//
//			5:ddram = LINE1[159:128];//
//			//V
//			6:ddram = LINE1[256:224];//
//			7:ddram = LINE1[223:192];//
//			//=
//			8:ddram = LINE1[256:224];//
//			9:ddram = LINE1[223:192];//
//			//3
//			10:ddram= LINE1[256:224];//
//			11:ddram= LINE1[223:192];//

endmodule

