module uart(
		clk,rst_n,
		rs232_rx,rs232_tx,
		cs,dx
);

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input rs232_rx;		// RS232���������ź�
output rs232_tx;		//	RS232���������ź�

output[1:0] cs;  	//Ƭѡ
output[7:0] dx;	//��ѡ









endmodule