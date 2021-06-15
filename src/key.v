module key(
	
	Clk,Rst_n,key_c,key_out,key_r,key_flag,key_state,dig_sel,dig_data
	
	);
	input Clk;
	input Rst_n;
	input [3:0]key_r;
	
	output wire [3:0]key_c;
	output wire [3:0]key_out;
	output wire key_flag;
	output wire key_state;
	output wire[7:0]dig_data;
	output wire[3:0]dig_sel;
	
	wire key_in;
	reg [3:0]key_num;

	
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
				.disp_data({4'h8,key_num[3:0],key_out[3:0],key_out[3:0]}),
				.dig_sel(dig_sel),
				.dig_data(dig_data)
				);
	always@(posedge Clk)	
		if(key_flag && (!key_state))
			key_num <= key_out;
		else 
			key_num <= key_num;
			
			
			

			
endmodule	