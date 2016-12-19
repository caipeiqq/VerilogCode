		//实验目的：两位数码管，从0到f循环递增
		module DigitalLed#(parameter data)(
			clk ,rst_n,
			//data,
			cs,dx
		);


		input clk	; //50MHz
		input rst_n	; //低电平有效
		//input[7:0] data;

		output[1:0] cs;//位选，低有效
		output[7:0] dx; //段选
		
/////////////////////////////////////////////////////////
		//延时时间
		parameter T1S 	   = 26'd49_999_999;		//26'd50_000_000;
		parameter T500MS  = 26'd24_999_999;		//26'd25_000_000;	
		parameter T1MS  	= 26'd49_999;			//26'd50_000;
		parameter T500US  = 26'd24_999;			//26'd25_000;	
	
///////////////////////////////////////////////////////////		
		//1.取位模块
		reg[7:0] oneBit;
		reg[7:0] tenBit;

		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) oneBit <= 8'd0;
			else oneBit <= data % 8'd10;
		end
		
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) tenBit <= 8'd0;
			else tenBit <= data / 8'd10 % 8'd10;
		end
		
		
/////////////////////////////////////////////////////////
		reg[1:0] cs_r;
		reg[7:0] dx_r;
		reg[7:0] state;
		reg[7:0] nstate;
//		reg[1:0]		flag;
		parameter 	Idle 		= 8'd1,
						OneNum 	= 8'd2,
						OneDx 	= 8'd3,
						TenNum 	= 8'd4,
						TenDx 	= 8'd5,
						Stop		= 8'd6;
						
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) state <= Idle;			
			else state <= nstate ;
		end
		
		always@(nstate )begin
			case(state)
				Idle 		: nstate <= OneNum ;
				OneNum 	: nstate <= OneDx  ;
				OneDx 	: nstate <= TenNum ;
				TenNum 	: nstate <= TenDx  ;
				TenDx 	: nstate <= OneNum ;
				default 	: nstate <= Idle 	 ;
			endcase
		end
			
		always @(posedge clk or negedge rst_n)begin
			if(!rst_n) begin
							dx_r <= 	8'hf;
					end
			else begin
					case (nstate)
					//a 初始化
					Idle : 	begin		
									dx_r 	<= 8'hf;	
								end
								
					//b 写个位
					OneNum : begin
									cs_r  <= 2'b10;					
									num  	<= oneBit;
								end	
							
					OneDx : begin																			
									dx_r 	<= num_smg;
								end			
							
					//b 写十位	
					TenNum : begin
									cs_r  <= 2'b01;	
									num  	<= tenBit; 
							end	
							
					TenDx : begin
									dx_r 	<= num_smg;
							  end	
								
					Stop : ;
							
					default : ;	
				endcase
			end
		end
/////////////////////////////////////////////////////////		
//		always @(posedge clk or negedge rst_n)begin
//			if(!rst_n) begin
//						state<= Idle;			
//					end
//			else begin
//					case (state)
//					//a 初始化
//					Idle : 	begin		
//									dx_r 	<= 8'hf;	
//									state <= OneNum;	
//								end
//								
//					//b 写个位
//					OneNum : begin
//									cs_r  <= 2'b10;					
//									num  	<= oneBit;																			
//									state <= OneDx;
//								end	
//							
//					OneDx : begin																			
//									dx_r 	<= num_smg;								
//									state <= TenNum;
//								end			
//							
//					//b 写十位	
//					TenNum : begin
//									cs_r  <= 2'b01;	
//									num  	<= tenBit; 										
//									state <= TenDx;
//							end	
//							
//					TenDx : begin
//									dx_r 	<= num_smg;											
//									state <= OneNum;
//							  end	
//								
//					Stop : begin
//									state <= Stop;
//							end
//							
//					default : state = Idle;	
//				endcase
//			end
//		end
		
///////////////////////////////////////////////////////////	
reg[7:0] num;
reg[7:0] num_smg;		
always@(num)begin
	case(num)
		8'h0: num_smg = 8'b1100_0000;
		8'h1: num_smg = 8'b1111_1001;
		8'h2: num_smg = 8'b1010_0100;
		8'h3: num_smg = 8'b1011_0000;
		8'h4: num_smg = 8'b1001_1001;
		8'h5: num_smg = 8'b1001_0010;
		8'h6: num_smg = 8'b1000_0010;
		8'h7: num_smg = 8'b1111_1000;
		8'h8: num_smg = 8'b1000_0000;
		8'h9: num_smg = 8'b1001_0000;
		default:  num_smg = 8'hxx;
	endcase
end
	
	assign cs = cs_r;
	assign dx = dx_r;
	
	endmodule




