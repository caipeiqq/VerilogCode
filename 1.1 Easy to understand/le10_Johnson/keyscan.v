//��������ģ��
module keyscan(
		clk,rst_n,key,
		key_en
);
input 	clk		; //50MHz
input 	rst_n		; //�͵�ƽ��Ч
input 	key		; //����ֵ
output 	key_en	; //���ʹ���ź�

parameter T20MS = 20'd1000_000; 	//100ms����ֵ	

//Ѱ������
reg key_rst;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) key_rst <= 1'b1;
	else	key_rst <= key;
end

reg key_rst_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) key_rst_r <= 1'b1;
	else	key_rst_r <= key_rst;
end

wire key_rst_en = key_rst_r&(~key_rst);

//��ʱ20ms
reg[19:0] cnt;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt <= 20'd0;
	else if(key_rst_en) cnt <= 20'd0;
	else	cnt <= cnt+20'd1;
end

//��ʱ������
reg low_rst;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) low_rst <= 1'b1;
	else if(cnt == T20MS) low_rst <= key;
end

reg low_rst_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) low_rst_r <= 1'b1;
	else low_rst_r <= low_rst;
end
 
wire low_rst_en = low_rst_r&(~low_rst);

reg key_en;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) key_en <= 1'b0;
	else	if(low_rst_en) key_en <= ~key_en;
end
 
endmodule