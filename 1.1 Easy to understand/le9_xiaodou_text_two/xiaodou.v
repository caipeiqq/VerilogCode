//��������ģ�黯���
module xiaodou(
	clk,rst_n,
	key_in,led0
);

input clk;
input rst_n;
input key_in;
output led0;

//һ������
wire key_en;
scanf U1(
	.clk(clk),
	.rst_n(rst_n),
	.key_in(key_in),
	.key_out(key_en)

);

assign led0 = key_en;

//�������scanfAll






endmodule