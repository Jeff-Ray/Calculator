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
			/*else if((dis_flag == 1'b1) && (key_num == 4'b1110)) begin
							if(opera_flag == 4'b1010)begin
									out_a <= num_a + num_b;
									out_b <= 14'h0;
							end
							else if(opera_flag == 4'b1011) begin
									out_a <= num_a - num_b;
									out_b <= 14'h0;
							end
							else if(opera_flag == 4'b1100) begin
									out_a <= num_a * num_b;
									out_b <= 14'h0;
							end
							else if(opera_flag == 4'b1101) begin
									out_a <= num_a / num_b;
									out_b <= 14'h0;
							end
					dis_flago <= 1'b0;
			end*/
			
			out_flagd = 1'b1;
	end
	else begin
			out_flagd <= 1'b0;
	end
endmodule
				
							
							
							