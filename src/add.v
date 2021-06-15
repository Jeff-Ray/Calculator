module add (

	input wire [13:0]num_a,
	input wire en,
	input wire[3:0]key_num,
	output reg[13:0]out_a,
	output reg num_flag
	
	);
	always@(*)
	if(en && (key_num < 4'b1010)) begin
		out_a <= num_a * 10 + key_num;
		num_flag <= 1'b1;
		end
	else
		num_flag <= 1'b0;
			
endmodule 