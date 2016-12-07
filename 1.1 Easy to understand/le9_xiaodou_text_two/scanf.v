//��������ģ��
//����㣺��������Ч
module scanf(
	clk,rst_n,
	key_in,key_out
);

input clk;
input rst_n;
input key_in;
output key_out;

parameter T40MS = 30'd1_999_999;
//��ʼʱ�̵�ƽ����
reg fEdge;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) fEdge <= 1'b1;
	else fEdge <= key_in;
end

reg fEdge_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) fEdge_r <= 1'b1;
	else fEdge_r <= fEdge;
	//�����
//	else fEdge_r <= key_in;
end

wire fEdge_en = (~fEdge)&fEdge_r;

//��ʱ
reg[29:0] cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 30'd0;
	else if(fEdge_en) cnt <= 30'd0;
	else cnt<= cnt + 30'd1;
end

//����ʱ�̵�ƽ����
reg sEdge;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) sEdge <= 1'b1;
	else if(cnt == T40MS) sEdge <= key_in;
	else sEdge <= 1'b1;
//	//�����
//	else sEdge <= 1'b0;
end

reg sEdge_r;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) sEdge_r <= 1'b1;
	else sEdge_r <= sEdge;
end

wire sEdge_en = (~sEdge)& sEdge_r;

assign key_en = sEdge_en;


reg led;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) led <= 1'b0;
	else if(key_en) led <= ~led;
end

assign key_out = led;

endmodule