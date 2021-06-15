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