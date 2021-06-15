/********************************************************************
*					数码管动态显示
*	功能：将按键的值以及运算后的值通过数码管显示出来
*	作者：Ray
*	起始时间：2021-4-24
*	完成时间：2021-5-26
********************************************************************/
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
