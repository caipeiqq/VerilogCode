module uart_top(
		clk,rst_n,
		rs232_rx,rs232_tx
);

input clk;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input rs232_rx;		// RS232���������ź�
output rs232_tx;	//	RS232���������ź�

