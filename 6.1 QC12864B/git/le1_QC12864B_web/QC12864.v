
/*************************************************************
*************************************************************/
module QC12864(
     clk, //系统时钟输入
     rst_n, //系统复位输入
     //in_data,  //输入的要显示的数据
     RS, //LCD的寄存器选择输出信号
     RW, //LCD的读、写操作选择输出信号
     EN, //LCD使能信号
     DB, //LCD的数据总线（不进行读操作，故为输出）
     //CS,
      );
  input clk;
  input rst_n; 
  //input in_data;
  output reg RS; //LCD的寄存器选择输出信号
  output RW; //LCD的读、写操作选择输出信号
  output EN; //LCD使能信号
  //output REST ;      //复位-低有效  
  output reg [7:0]DB; //LCD的数据总线（不进行读操作，故为输出）
  //output[1:0] CS;
    
        reg [31:0] in_data = 32'd2294967296;
       // wire [31:0] in_data;
        reg clk_lcd; //LCD时钟信号
        reg [15:0]cnt;            // CLK频率为50MHz, 产生LCD时钟信号, 10Hz
		  //wire[1:0] CS;
                
always @(posedge clk or negedge rst_n)
begin
	 if (!rst_n)
		  begin 
				cnt <= 16'b0;clk_lcd <= 0;
		  end   
	 else if(cnt == 49999)
		  begin 
				cnt <= 0;clk_lcd <= ~clk_lcd;
		  end   
	 else cnt <= cnt +1'b1;
end
/*******************************************************************
 

*********************************************************************/                           
 reg [8:0] state; //State Machine code
 parameter IDLE  = 9'b00000000;                    //初始状态，下一个状态为CLEAR
 parameter SETFUNCTION = 9'b00000001;              //功能设置：8位数据接口
 parameter SETFUNCTION2 = 9'b00000010;
 parameter SWITCHMODE = 9'b00000100;               //显示开关控制：开显示，光标和闪烁关闭
 parameter CLEAR = 9'b00001000;                    //清屏
 parameter SETMODE      = 9'b00010000;             //输入方式设置：数据读写操作后，地址自动加一/画面不动
 parameter SETDDRAM     = 9'b00100000;             //设置DDRAM的地址：第一行起始为0x80/第二行为0x90
 parameter WRITERAM     = 9'b01000000;             //数据写入DDRAM相应的地址
 parameter STOP = 9'b10000000;                     //LCD操作完毕，释放其控制
    
     wire[7:0] disp_1,disp_2,disp_3,disp_4,disp_5,disp_6,disp_7,disp_8,disp_9,disp_10;
  
   //+8'h30为转换为ASCII
	/*
   assign  disp_1 =in_data/32'd1000000000+8'h30;
   assign  disp_2 =in_data%32'd1000000000/32'd100000000+8'h30; //1011 1110 1011 1100 0010 0000 000
   assign  disp_3 =in_data%32'd100000000/32'd10000000+8'h30;  //1001 1000 1001 0110 1000 0000
   assign  disp_4 =in_data%32'd10000000/32'd1000000+8'h30;  //1111 0100 0010 0100 0000
   assign  disp_5 =in_data%32'd1000000/32'd100000+8'h30;  //1100 0011 0101 0000 0
   assign  disp_6 =in_data%32'd100000/32'd10000+8'h30;  //1001 1100 0100 00
   assign  disp_7 =in_data%32'd10000/32'd1000+8'h30;
   assign  disp_8 =in_data%32'd1000/32'd100+8'h30;
   assign  disp_9 =in_data%32'd100/32'd10+8'h30;
   assign  disp_10 =in_data%32'd10+8'h30;
   */
	
 reg flag; //标志位，LCD操作完毕为0
 reg [5:0] char_cnt;
 reg [7:0] data_disp;
 assign RW = 1'b0; //没有读操作，R/W信号始终为低电平
 assign EN  = (flag == 1)?clk_lcd:1'b0; //E信号出现高电平以及下降沿的时刻与LCD时钟相同
 //assign CS = 2'b11;
always @(posedge clk_lcd or negedge rst_n) //只有在写数据操作时，RS信号才为高电平，其余为低电平
    begin
  if(!rst_n)
            RS <= 1'b0;
  else if(state == WRITERAM)   //写数据
            RS <= 1'b1;
  else
            RS <= 1'b0;          //写指令
    end
    
/**************************************************************************
// State Machine
**************************************************************************/
always @(posedge clk_lcd or negedge rst_n)
 begin
  if(!rst_n)
  begin
		state <= IDLE;
		DB <= 8'bzzzzzzzz;
		char_cnt <= 5'd0;
		flag <= 1'b1;
  end
  
  else 
  begin
   case(state)
   IDLE:  
       begin  
     state <= SETFUNCTION;
     DB <= 8'bzzzzzzzz; 
	  char_cnt <= 5'd5; 
    end
	 
   SETFUNCTION:
    begin
     state <= SETFUNCTION2;
     DB <= 8'h30; // 8-bit 控制界面，基本指令集动作
    end
	 
   SETFUNCTION2:
    begin
     state <= SWITCHMODE;
     DB <= 8'h30; // 清屏
    end
	 
   SWITCHMODE:
    begin
     state <= CLEAR;
     DB <= 8'h0c; // 显示开关：开显示，光标和闪烁关闭
    end
	 
   CLEAR:
    begin
     state <= SETMODE;
     DB <= 8'h01;
    end
	 
   SETMODE:
    begin
     state <= SETDDRAM;
     DB <= 8'h06; // 输入方式设置: 数据读写后，地址自动加1，画面不动
    end
	 
   SETDDRAM:
    begin
     state <= WRITERAM;
      if(char_cnt == 0) //如果显示的是第一个字符，则设置第一行的首字符地址
      begin
       DB <= 8'h80; //Line1
      end
      else if(char_cnt ==16)//第二次设置时，是设置第二行的首字符地址 
      begin
       DB <= 8'h90; 
      end
      
      else if(char_cnt == 32)
      begin
                DB <= 8'h88;
		end
		
		else if(char_cnt == 48)
			begin
                DB <= 8'h98;
			end         
		end
	 
   WRITERAM:
       begin
     if(char_cnt <= 15)
     begin
      char_cnt <= char_cnt + 1'b1;
      DB <= data_disp;
      
        if( char_cnt == 15 )
            state <= SETDDRAM;
        else
         state <= WRITERAM;
         
      end
      
      else if( char_cnt >= 16 && char_cnt <= 31)
      begin
       DB <= data_disp;
       state <= WRITERAM;
       char_cnt <= char_cnt + 1'b1;
       if( char_cnt == 31 )   //返回SETDDRAM修改写地址
            state <= SETDDRAM;
        else
         state <= WRITERAM;   //
      end 
              
      else if(char_cnt >= 32 && char_cnt <= 47)
      begin
                DB <= data_disp;
                state <= WRITERAM;
                char_cnt <= char_cnt + 1'b1;
                if( char_cnt == 47 )
            state <= SETDDRAM;
        else
         state <= WRITERAM;
            end
            
            else if(char_cnt >= 48 && char_cnt <= 63)
      begin
                DB <= data_disp;
                state <= WRITERAM;
                char_cnt <= char_cnt + 1'b1;
                if( char_cnt == 63 )
            state <= SETDDRAM;
        else
         state <= WRITERAM;
            end
           
       end
       
   STOP: state <= STOP;
    
   default: state <= IDLE;
   endcase
        end
    end
always @(char_cnt) //输出的字符
 begin
  case (char_cnt)
   6'd0:  data_disp <= 8'h20;
   6'd1:  data_disp <= 8'h20; //
   6'd2:  data_disp <= 8'hB5;
   6'd3:  data_disp <= 8'hE7;  //
   6'd4:  data_disp <= 8'hD7;
   6'd5:  data_disp <= 8'hD3;  //
   6'd6:  data_disp <= 8'hB9;
   6'd7:  data_disp <= 8'hA4;  //
   6'd8:  data_disp <= 8'hB3;
   6'd9:  data_disp <= 8'hCC;
   6'd10:  data_disp <= 8'hCA;
   6'd11:  data_disp <= 8'hC0;
   6'd12:  data_disp <= 8'hBD;
   6'd13:  data_disp <= 8'hE7;
   6'd14:  data_disp <= 8'h20;
   6'd15:  data_disp <= 8'h20;
   
   6'd16:  data_disp <= 1;
   6'd17:  data_disp <= 1;
   6'd18:  data_disp <= 1;
   6'd19:  data_disp <= 1;
   6'd20:  data_disp <= "h";
   6'd21:  data_disp <= "e";
   6'd22:  data_disp <= "l";
   6'd23:  data_disp <= "l";
   6'd24:  data_disp <= "o";
   6'd25:  data_disp <= "L";
   6'd26:  data_disp <= "D";
   6'd27:  data_disp <= 1;
   6'd28:  data_disp <= 1;
   6'd29:  data_disp <= 1;
   6'd30:  data_disp <= 1;
   6'd31:  data_disp <= 1;
   
   6'd32:  data_disp <= "F";
   6'd33:  data_disp <= "P";
   6'd34:  data_disp <= "G";
   6'd35:  data_disp <= "A";
   6'd36:  data_disp <= 8'hD6;
   6'd37:  data_disp <= 8'hFA;
   6'd38:  data_disp <= 8'hD1;
   6'd39:  data_disp <= 8'hA7;                                       
   6'd40:  data_disp <= 8'hCF;
   6'd41:  data_disp <= 8'hB5;
   6'd42:  data_disp <= 8'hC1;
   6'd43:  data_disp <= 8'hD0; 
   6'd44:  data_disp <= 8'h20;
   6'd45:  data_disp <= 8'h20;
   6'd46:  data_disp <= 8'h20;
   6'd47:  data_disp <= 8'h20;
   
   6'd48:  data_disp <= disp_1;
   6'd49:  data_disp <= disp_2; //
   6'd50:  data_disp <= disp_3;
   6'd51:  data_disp <= disp_4;                                       
   6'd52:  data_disp <= disp_5;
   6'd53:  data_disp <= disp_6;
   6'd54:  data_disp <= disp_7;
   6'd55:  data_disp <= disp_8; 
   6'd56:  data_disp <= disp_9;
   6'd57:  data_disp <= disp_10;
   6'd58:  data_disp <= 8'h20;
   6'd59:  data_disp <= 8'h20;
   6'd60:  data_disp <= 8'h20;
   6'd61:  data_disp <= 8'h20;
   6'd62:  data_disp <= 8'h20;
   6'd63:  data_disp <= 8'h20;
                                                                  
   //default :   data_disp <= 8'd20;
  endcase
 end
endmodule 