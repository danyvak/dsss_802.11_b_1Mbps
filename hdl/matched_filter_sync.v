module matched_filter_despreader_sync (sample_i, sample_q, input_sample_valid,clk,reset,
										despread_sample_i, despread_sample_q, despread_sample_valid);
input [15:0] sample_i,sample_q;
input input_sample_valid,clk,reset;
output [31:0] despread_sample_i,despread_sample_q;
output despread_sample_valid;
reg signed [15:0] BarkerCode_array [0:19];
reg signed [15:0] sample_i_history  [0:19];
reg signed [15:0] sample_q_history  [0:19];
reg signed [31:0] correlator_i  [0:19];
reg signed [31:0] correlator_q  [0:19];
reg valid_array [0:19];
reg despread_sample_valid_d;
reg signed [31:0] temp_result_i;
reg signed [31:0] temp_result_q;
integer index_array;
initial begin
    BarkerCode_array [19] = 128;
	BarkerCode_array [18] = -5;
	BarkerCode_array [17] = -138;
	BarkerCode_array [16] = -30;
	BarkerCode_array [15] = 204;
	BarkerCode_array [14] = 218;
	BarkerCode_array [13] =  -8;
	BarkerCode_array [12] = -140;
	BarkerCode_array [11] = -25;
	BarkerCode_array [10] = 121;
	BarkerCode_array [9] = 139; 
	BarkerCode_array [8] = 129;
	BarkerCode_array [7] = 155;
	BarkerCode_array [6] = 99;
	BarkerCode_array [5] = -57;
	BarkerCode_array [4] = -157;
	BarkerCode_array [3] = -141;
	BarkerCode_array [2] = -120;
	BarkerCode_array [1] = -130;
	BarkerCode_array [0] = -87;
end

always@(posedge clk or posedge reset)
if (reset) begin
	sample_i_history[0]<= 16'd0;
	sample_q_history[0] <= 16'd0;
	correlator_i[19] <= 32'd0;
	correlator_q[19] <= 32'd0;
	end
else begin	
		despread_sample_valid_d = input_sample_valid;
		if (input_sample_valid) begin
			sample_i_history[0] <=  sample_i;
			sample_q_history[0] <=  sample_q;
			//valid_array[0] <= input_sample_valid;	
			correlator_i[19] <= $signed(sample_i)*BarkerCode_array [19];
	        correlator_q[19] <=  $signed(sample_q)*BarkerCode_array [19];

	    for (index_array=18;index_array>=0;index_array=index_array-1) begin
                correlator_i[index_array] <=  correlator_i[index_array+1] + $signed(sample_i)*BarkerCode_array [index_array];
			    correlator_q[index_array] <=  correlator_q[index_array+1] + $signed(sample_q)*BarkerCode_array [index_array];
	    end
    end
end		

assign 	despread_sample_i = correlator_i[0];
assign	despread_sample_q = correlator_q[0];
//assign 	despread_sample_i = correlator_i[19];
//assign	despread_sample_q = correlator_q[19];	
assign  despread_sample_valid = despread_sample_valid_d;
endmodule	