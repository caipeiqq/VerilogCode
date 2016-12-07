//三段状态机
module fsm3 (clk,rst_n,A,k1,k2,state);
input clk,rst_n;
input A;
output k1,k2;
output [1:0] state;
reg k1,k2;
reg [1:0] state;
reg [1:0] nextstate;
parameter  Idle =  2'b00,
			  start = 2'b01,
			  stop =  2'b10,
			  clear = 2'b11;
			  
//每一个时钟产生一个可能的变化，即时序逻辑部分						  
always @ (posedge clk or negedge rst_n)    
       if(!rst_n) state <= Idle;
		else state <= nextstate;      

//组合逻辑部分
always @ (state or A)      
	begin 
		case (state)
			 Idle : if(A) nextstate = start;
						else  nextstate = Idle;
						
			start : if(!A)nextstate = stop;
						else nextstate = start;
						
			stop  : if(A)nextstate = clear;
						else nextstate = stop;
						
			clear : if(!A) nextstate =Idle;
						else nextstate = clear;

//告诉综合器case语句已经指定了所有状态，这样综合器就会删除不需要的译码电路，使生成的电路简单			
			default : nextstate = 2'bxx;
		endcase 
	end
	
//产生输出k1的组合逻辑	
always @ (state or A or rst_n)    
      if(!rst_n) k1=0;
		else if(state ==clear && !A)
			k1=1;
		else k1=0;

//产生输出k2的组合逻辑		
always @(state or A or rst_n)      
      if(!rst_n) k2=0;
		else if(state ==stop && A)
				k2=1;
		else k2=0;


endmodule  