module peak_finder (clk,reset,despread_sample_i, despread_sample_q, despread_sample_valid,out_bin_index,max_bin_index,max_index_valid_out);
input clk,reset,despread_sample_valid;
input signed [31:0]  despread_sample_i,despread_sample_q;
output [15:0] out_bin_index,max_bin_index;
output max_index_valid_out;

parameter state_0 = 3'b000;
parameter state_1 = 3'b001;
parameter state_2 = 3'b010;
parameter state_3 = 3'b011;
parameter state_4 = 3'b100;

reg [15:0] index_counter;
reg [15:0] index_counter_next;
reg [63:0]  input_power; 
reg [63:0]  max_input_power;
reg [15:0] max_input_power_index;
reg [15:0] max_input_power_index_final;
reg max_index_valid;
reg [2:0] state, next_state;
wire [63:0] mult_result;
always@(posedge clk or posedge reset)
begin
	if (reset) begin
		index_counter <= 16'd0;
		state <= state_0;
		end
	else 
		begin
		if (despread_sample_valid) begin
			index_counter <= index_counter_next;
			input_power <= mult_result;
		end
		state <= next_state;
		end
end		
		
always@(*) begin
	case(state)
	
	state_0: if (despread_sample_valid) begin
				if (index_counter<19)
					index_counter_next = index_counter + 1;
				else
					begin
					index_counter_next = 0;
					max_index_valid = 0;
					max_input_power = 0;
					end
				input_power = mult_result;		
				next_state = state_1;
			end
			else 
				next_state = state_0;
		
	state_1:begin		
			if (max_input_power < input_power) begin
				max_input_power = input_power;
				max_input_power_index = index_counter_next;
			end
			next_state = state_2;
			end
			
	state_2:begin
			if (index_counter==19) begin
				max_input_power_index_final = max_input_power_index; 
				max_index_valid = 1;
				max_input_power = 0;
				max_input_power_index = 0;
			end
			next_state = state_3;
			end
			
	state_3:begin
				max_index_valid = 0;
				next_state = state_0;
			end
	endcase
end	

assign mult_result = despread_sample_i*despread_sample_i + despread_sample_q*despread_sample_q;
assign out_bin_index = index_counter;
assign max_bin_index = max_input_power_index_final;
assign max_index_valid_out = max_index_valid;
endmodule
		