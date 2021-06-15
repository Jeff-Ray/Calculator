/********************************************************************
*					基于Verilog的简易计算器
*	说明：由于MAX II芯片资源有限，所以只采用4位共阴数码管显示，
*		 可以正常进行4位数的加减以及两位数的乘除运算
*	功能：采用4*4矩阵键盘输入，4位共阴数码管显示
*	作者：Ray
*	起始时间：2021-4-24
*	完成时间：2021-5-26
********************************************************************/
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