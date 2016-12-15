module QC12864B(
    clk, rst_n,
	 RS,
	 RW,
	 EN,PSB,
	 DB
);
//////////////////////////////////////////////////////////////////////	
	//50MHz��20ns
	//1.1 ����
	input clk;
	input rst_n;
	
	//1.2 ���
	output      RS;         //����-��,ָ��-��
	output      RW;         //��-�ߣ�д-��
	output      PSB;	      //����-�ߣ�����-��
	output      EN;         //ʹ��-��                                                                         
	output[7:0] DB;         //��̬������	
	
//	//1.3 �Ĵ���	
	wire       RS;         //����-��,ָ��-��
	wire       RW;         //��-�ߣ�д-��
	wire      PSB;	       //����-�ߣ�����-��
	wire       EN;         //ʹ��-��                                                                       
	wire[7:0]  DB;         //��̬������	

	localparam CHAR1 = 16'h0;
	//localparam DATA1 = 16'h0;
	localparam CHAR2 = 16'h0;
	localparam DATA2 = 16'h0;
	localparam CHAR3 = 16'h0;
	localparam DATA3 = 16'h0;
	localparam CHAR4 = 16'h0;
	localparam DATA4 = 16'h0;
	/////////////////////////////////
	localparam T5MS    = 18'd249_999; //5ms
	localparam T2500US = 18'd125_000; //2.5ms
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
		else	if(cnt_1s == 10'd200) clk_1s <= 1'd1;
		else clk_1s <= 1'd0;
	end

	reg[31:0] DATA1;
	always @(posedge clk_1s or negedge rst_n)begin
		if(!rst_n) DATA1 <= 32'd123456 ;
		else	if(DATA1 == 32'd123556) DATA1 <= 32'd123456;
		else DATA1 <= DATA1 + 1'd1;
	end
	/////////////////////////////////
	sreen #(	.CHAR1 (80'hA3C1_CFE0_B5E7_D1B9_A3D6),	//5λ����
				//.DATA1 (48'h313233343536),	 				//3λ�ַ�
				
				.CHAR2 (80'hA3C2_CFE0_B5E7_D1B9_A3D6),	//5λ����
				.DATA2 (48'h313233343536),	 				//3λ�ַ�
				
				.CHAR3 (80'hA3C3_CFE0_B5E7_D1B9_A3D6),	//5λ����
				.DATA3 (48'h313233343536),	 				//3λ�ַ�
				
				.CHAR4 (80'hD7DCB9A6C2CA_A3D7),			//5λ����
				.DATA4 (48'h313233343536) 					//3λ�ַ�
				
				)  
			sreen_re(
				 .clk(clk), 
				 .rst_n(rst_n),
				 .RS(RS),
				 .RW(RW),
				 .EN(EN),
				 .PSB(PSB),
				 .DB(DB),
				 .DATA1(DATA1)
	);

endmodule

	