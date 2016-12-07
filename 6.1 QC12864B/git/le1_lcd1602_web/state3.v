//����״̬��
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
			  
//ÿһ��ʱ�Ӳ���һ�����ܵı仯����ʱ���߼�����						  
always @ (posedge clk or negedge rst_n)    
       if(!rst_n) state <= Idle;
		else state <= nextstate;      

//����߼�����
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

//�����ۺ���case����Ѿ�ָ��������״̬�������ۺ����ͻ�ɾ������Ҫ�������·��ʹ���ɵĵ�·��			
			default : nextstate = 2'bxx;
		endcase 
	end
	
//�������k1������߼�	
always @ (state or A or rst_n)    
      if(!rst_n) k1=0;
		else if(state ==clear && !A)
			k1=1;
		else k1=0;

//�������k2������߼�		
always @(state or A or rst_n)      
      if(!rst_n) k2=0;
		else if(state ==stop && A)
				k2=1;
		else k2=0;


endmodule  