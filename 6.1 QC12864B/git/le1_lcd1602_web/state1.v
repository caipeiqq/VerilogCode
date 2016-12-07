//一段状态机
module fsm (clk,rst_n,A,k1,k2,State);

input clk;
input rst_n;
input A;
output k1,k2;
output [1:0] State;
reg k1;
reg k2;
reg [1:0] State;   //当前状态寄存器

parameter     Idle = 2'b00,
				  Start = 2'b01,
				  Stop = 2'b10,
				  Clear = 2'b11;            //编码 ，注意，只有在最后一句用分号，其他地方用逗号

always @(posedge clk or negedge rst_n)
	if(!rst_n) begin 
		State <= Idle;
		k1 <=1'b0;
		k2 <=1'b0;
	end 

	else begin 
		case (State)                   //状态判断与组合逻辑赋值
			Idle :if(A) begin 
				State <= Start;
				k1 <= 0;
			end
			else begin 
				State <= Idle;
				k1 <= 0;
				k2 <= 0;
			end
			 
			Start :if(!A) State <= Stop;
			else State  <=  Start;

			Stop  :if(A) begin
				State <=Clear;
				k2 <= 1;
			end
			else State <= Stop;

			Clear :if(!A) begin 
				State <= Clear;
				k2 <= 0;
				k1 <= 1;
			end	
			else State <= Clear;
			default : State <= 2'bxx;    
		endcase  
	end
endmodule 