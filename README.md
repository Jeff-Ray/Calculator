## 基于Verilog的简易计算器
### 1.任务
设计一个四位数简易计算器，数字键由矩阵键盘输入，显示由用四位数码管输出，能够正确实现+、-、*、/ 四种运算（不考虑小数的运算）。
### 2.系统框图
主要由五个模块组成，分别是矩阵键盘扫描模块、数码管显示模块、二进制转BCD模块、运算模块，框图如下图所示：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210615180352571.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)

### 3.模块化设计
#### 3.1顶层模块编写
顶层模块作为程序的入口处，分别去调用每个模块，实现各个模块的功能。源码如下：

```verilog
module cal_top(
	
	Clk,Rst_n,key_c,key_r,dig_sel,dig_data
	
	);

// 输入
	input Clk;						//50MHz
	input Rst_n;					//复位 低电平有效
	input [3:0]key_r;				//矩阵键盘 行
	
// 输出
	output wire [3:0]key_c;			//矩阵键盘 列
	output wire[7:0]dig_data;		//数码管段码
	output wire[3:0]dig_sel;		//4位数码管位选
	
	wire key_in;
	wire [3:0]key_out;				
	wire key_flag;					//按键按下标志位
	wire key_state;					//按键状态

	reg [4:0]key_num;				//按键按下的键值

	reg [13:0]num_a;				//操作数 a
	reg [13:0]num_b;				//操作数 b
	
	reg dis_flag;					
	reg [3:0]opera_flag;
	wire [13:0]out_a;
	wire [13:0]out_b;
	wire dis_flago;
	wire [3:0]opera_flago;
	wire out_flagd;
	
	reg [13:0]num_sel;
	wire [3:0]data_q;			//千位
	wire [3:0]data_b;			//百位
	wire [3:0]data_s;			//十位
	wire [3:0]data_g;			//个位
		
	reg en;
	wire [13:0]out_num;
	wire num_flag;
	
	key_filter my_key_filter(
			.Clk(Clk),
			.Rst_n(Rst_n),
			.key_in(key_in),
			.key_flag(key_flag),
			.key_state(key_state)
			);
	key_array my_array(
			.Clk(Clk),
			.Rst_n(Rst_n),
			.key_c(key_c),
			.key_out(key_out),
			.key_r(key_r),
			.key_in(key_in)
			);
			
	dig_dynamic my_dig_dynamic(
				.Clk(Clk),
				.Rst_n(Rst_n),
				.En(1'b1),
				.disp_data({data_q[3:0],data_b[3:0],data_s[3:0],data_g[3:0]}),
				.dig_sel(dig_sel),
				.dig_data(dig_data)
				);
				
	bcd_d my_bcd_d(
			.binary(num_sel),
			.g(data_g),
			.s(data_s),
			.b(data_b),
			.q(data_q)
		);	
		
	add  my_add(
			.num_a(num_sel),
			.en(en),
			.key_num(key_num),
			.out_a(out_num),
			.num_flag(num_flag)
		);
	
	opera my_opera(
			.num_a(num_a),
			.num_b(num_b),
			.en(en),
			.dis_flag(dis_flag),
			.opera_flag(opera_flag),
			.key_num(key_num),
			.out_a(out_a),
			.out_b(out_b),
			.dis_flago(dis_flago),
			.opera_flago(opera_flago),
			.out_flagd(out_flagd)
		);		
	 
	/********选择数******/	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n) begin
			num_a <= 14'd0;
			num_b <= 14'd0;
			dis_flag <= 1'b0;
	end
	else if(out_flagd == 1'b1) begin
			num_a <= out_a;
			num_b <= out_b;
			dis_flag <= dis_flago;
			opera_flag <= opera_flago; 
	end			
	else if(dis_flag == 1'b0) begin
			num_sel <= num_a;
			if(num_flag == 1'b1)
					num_a <= out_num;
			
			else
					num_a <= num_a;
	end
	else if(dis_flag == 1'b1) begin
			num_sel <= num_b;
			if(num_flag == 1'b1)				
					num_b <= out_num;
			else
					num_b <= num_b;
	end
			
	/*************数操作en************/		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		en <= 1'b0;
	else if(key_flag && (!key_state)) begin
			key_num <= key_out;
			en <= 1'b1;
		end
		else
			en <= 1'b0;
endmodule

```
#### 3.2 数码管动态显示模块
数码管这里选择的是**共阴数码管**，虽然原理图中有8位，但实际上只使用了四位数码管，有需要的可以自己更改为共阳的数码管或者增加数码管显示的位数。然后数码管是直接连接的IO，没有经过其他芯片，有些其他开发板可能会经过138译码器，大家下载了的话，请自行修改。原理图如下：
![数码管原理图](https://img-blog.csdnimg.cn/20210615180419299.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)


```verilog
module dig_dynamic(
	Clk,
	Rst_n,
	En,
	disp_data,
	dig_sel,
	dig_data	
	);
	
	// 输入
	input		Clk;//时钟，50MHz
	input		Rst_n;//异步复位信号，低电平有效
	input		En; //使能端，高电平有效，有效时数码管正常显示，非能
						//时数码管全部熄灭
	input	[15:0]disp_data;//16位宽的待显示数据

	// 输出
	output	[3:0]dig_sel;   //数码管的位选驱动端口
	output	[7:0]dig_data;//数码管的段选驱动端口
	
	reg		[7:0]dig_data;
	
	reg		[14:0]Cnt;			//分频计数器
	reg		Clk_1k;				//1kHz的扫频信号
	reg		[3:0]dig_sel_r;	//位选数据的临时寄存器
	reg		[3:0]dig_data_temp;//需要显示的数据的暂存寄存器
	
	//扫描周期计数器，计数到25000后返回零，并控制产生1KHz的扫频信号
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Cnt <= 15'h0;
	else if(En) begin
		if(Cnt == 15'd25000)
			Cnt <= 15'h0;
		else
			Cnt <= Cnt + 15'h1;
	end
	else
		Cnt <= Cnt;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Clk_1k <= 1'h0;
	else if(Cnt == 15'd25000)
		Clk_1k <= ~Clk_1k;
	else
		Clk_1k <= Clk_1k;
		
	//产生不断变化的位选信号，更新频率1KHz	
	always@(posedge Clk_1k or negedge Rst_n)
	if(!Rst_n)
		dig_sel_r <= 4'b1110;
	else if(En)
		dig_sel_r <= {dig_sel_r[2:0],dig_sel_r[3]};
	else
		dig_sel_r <= dig_sel_r;
	
	//使能时正常输出位选数据，非能时输出全0，即数码管全部熄灭
	assign	dig_sel = (En)?dig_sel_r:4'b0000;
		
	always@(*)
		case(dig_sel_r)
			4'b1110:dig_data_temp <= disp_data[3:0];		//最低位数码管
			4'b1101:dig_data_temp <= disp_data[7:4];
			4'b1011:dig_data_temp <= disp_data[11:8];
			4'b0111:dig_data_temp <= disp_data[15:12];
			default:dig_data_temp <= 4'b0000;
		endcase
		
	// 共阴数码管
	always@(*)
		case(dig_data_temp)
			0: dig_data <= 8'h3F;		// 0
			1: dig_data <= 8'h06;
			2: dig_data <= 8'h5B;
			3: dig_data <= 8'h4F;
			4: dig_data <= 8'h66;
			5: dig_data <= 8'h6D;
			6: dig_data <= 8'h7D;
			7: dig_data <= 8'h07;
			8: dig_data <= 8'h7F;
			9: dig_data <= 8'h6F;
			10: dig_data <= 8'h77;
			11: dig_data <= 8'h7C;
			12: dig_data <= 8'h39;
			13: dig_data <= 8'h5E;
			14: dig_data <= 8'h79;
			15: dig_data <= 8'h71;
			default:;
		endcase		

endmodule

```
#### 3.3 矩阵键盘扫描
矩阵键盘选的是4*4行列式键盘；矩阵键盘的扫描原理为，先让四个横行或者四个竖列输出高电平，另外四个为输入模式，若扫描到高电平，则表示该行或该列有按键按下，接着切换输入输出，扫描另外四个，得到另外的坐标，由此确定按键按下的位置，原理图如下图所示：
![矩阵键盘](https://img-blog.csdnimg.cn/20210615180444443.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)
```verilog
/********************************************************************
*					矩阵键盘扫描
*	功能：采用扫描法来检测矩阵键盘
*	作者：Ray
*	起始时间：2021-4-24
*	完成时间：2021-5-26
********************************************************************/
module key_array(
	
	Clk,Rst_n,key_r,key_c,key_out,key_in
	
	);
	input Clk;
	input Rst_n;
	input [3:0]key_r; 			//行
	
	output reg [3:0]key_c;		//列
	output reg [3:0]key_out;
	output reg key_in;
	
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		key_c <= 4'b1110;
	else if (key_r == 4'b1111) begin
		if (key_c == 4'b0111)
			key_c <= 4'b1110;
		else begin
			key_c <= {key_c[2:0],key_c[3]};
			
		end
	end
	

	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		key_out <= 4'h6;
	else if (key_r == 4'b1111)
		key_in<=1'b1;
	else
		case(key_c)
			4'b1110 :
				case(key_r)
					4'b1110 : 	begin
									key_out <= 4'h1;
									key_in <= key_r[0];
									end
					
					4'b1101 : 	begin
									key_out <= 4'h4;
									key_in <= key_r[1];
									end
					
					4'b1011 : 	begin
									key_out <= 4'h7;
									key_in <= key_r[2];
									end
					
					4'b0111 : 	begin
									key_out <= 4'ha;
									key_in <= key_r[3];
									end
				endcase
			4'b1101 :
				case(key_r)	
					4'b1110 : 	begin
									key_out <= 4'h2;
									key_in <= key_r[0];
									end
					
					4'b1101 : 	begin
									key_out <= 4'h5;
									key_in <= key_r[1];
									end
					
					4'b1011 : 	begin
									key_out <= 4'h8;
									key_in <= key_r[2];
									end
					
					4'b0111 : 	begin
									key_out <= 4'hb;
									key_in <= key_r[3];
									end
				endcase
			4'b1011 :
				case(key_r)
					4'b1110 : 	begin
									key_out <= 4'h3;
									key_in <= key_r[0];
									end
					
					4'b1101 : 	begin
									key_out <= 4'h6;
									key_in <= key_r[1];
									end
					
					4'b1011 : 	begin
									key_out <= 4'h9;
									key_in <= key_r[2];
									end
					
					4'b0111 : 	begin
									key_out <= 4'hc;
									key_in <= key_r[3];
									end
				endcase
				
			4'b0111 :
				case(key_r)
					4'b1110 : 	begin
									key_out <= 4'hf;
									key_in <= key_r[0];
									end
					
					4'b1101 : 	begin
									key_out <= 4'h0;
									key_in <= key_r[1];
									end
					
					4'b1011 : 	begin
									key_out <= 4'he;
									key_in <= key_r[2];
									end
					
					4'b0111 : 	begin
									key_out <= 4'hd;
									key_in <= key_r[3];
									end
				endcase
		endcase
endmodule	
```
#### 3.4运算模块
该模块是本次设计的核心部分，用于实现四则运算，两位十进制数num_a，num_b作为计算器的输入值；1010代表加法运算，1011代表减法运算，1100代表乘法运算，1101代表除法运算。输出14位二进制数out_a，因为输出的是二进制数，而我们在数码管看见的数是十进制，所以需要将二进制数再转换为BCD码（需调用二进制转BCD模块），经过转换后的数据，再输出到数码管显示，程序如下：

```verilog
/********************************************************************
*					运算模块
*	功能：对输入的两个数进行运算
*	作者：Ray
*	起始时间：2021-4-24
*	完成时间：2021-5-26
********************************************************************/
module opera(

	// 输入
	input wire [13:0]num_a,
	input wire [13:0]num_b,
	input wire dis_flag,
	input wire [3:0]opera_flag,
	input wire en,
	input wire[3:0]key_num,
	
	// 输出
	output reg[13:0]out_a,
	output reg[13:0]out_b,
	output reg dis_flago,
	output reg [3:0]opera_flago,
	output reg out_flagd
	);
	
	always@(*)
	if(en && (key_num > 4'b1001)) begin
			if(key_num < 4'b1110)
					if(dis_flag == 1'b0) begin
							opera_flago <= key_num;
							
							out_a <= num_a;
							out_b <= num_b;
							dis_flago <= 1'b1;
					end
					else if(dis_flag == 1'b1) begin
							// 加法
							if(opera_flag == 4'b1010)begin
									out_a <= num_a + num_b;
									out_b <= 14'h0;
							end
							// 减法
							else if(opera_flag == 4'b1011) begin
									out_a <= num_a - num_b;
									out_b <= 14'h0;
							end
							// 乘法
							else if(opera_flag == 4'b1100) begin
									out_a <= num_a * num_b;
									out_b <= 14'h0;
							end
							// 除法
							else if(opera_flag == 4'b1101) begin
									out_a <= num_a / num_b;
									out_b <= 14'h0;
							end	
							
									opera_flago <= key_num;	
									dis_flago <= 1'b0;
					end
			
			out_flagd = 1'b1;
	end
	else begin
			out_flagd <= 1'b0;
	end
endmodule
```
### 4 总体功能调试
在实际调试中需要进行波形仿真，这里主要是偷懒，并没有写测试文件，大家可以自己写下；调试过程如下，首先用按键按下“12”（图4-1），然后按下运算符“/”号，按下运算符后，数码管会显示“0000”，随后再按下数字按键“3”（图4-2），再按下运算符“/”号即可显示运算结果（图上4-3）。
![输入12](https://img-blog.csdnimg.cn/20210615180513722.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)
![除3](https://img-blog.csdnimg.cn/20210615180605318.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)
![结果](https://img-blog.csdnimg.cn/20210615180605325.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)
