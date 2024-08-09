module tb_matched_filter_peak_find;
reg signed [15:0] sample_i;
reg signed [15:0] sample_q;
wire signed [31:0] sample_i_despread_async;
wire signed [31:0] sample_q_despread_async;
wire signed [31:0] sample_i_despread_sync;
wire signed [31:0] sample_q_despread_sync;
wire [15:0] out_bin_index;
wire [15:0] max_bin_index;
wire max_index_valid_out;
wire data_bit,data_valid_bit;
wire preamble_detected;
wire sfd_detected;
wire valid_out_async;
wire valid_out_sync;
reg valid_in;
reg clk;
reg reset;
wire long_preamble_detected;
wire [7:0] pkt_rate ;
wire [15:0] pkt_len;
wire pkt_header_valid;
wire pkt_header_valid_strobe;
wire [7:0] payload_data;
wire payload_data_valid;
wire crc_ok;
wire crc_ok_strobe;
integer fid_in;
integer fid_out;
integer count;
integer sample_count;
always #5 clk=~clk;
//always #25 valid_in=~valid_in;

matched_filter_despreader u0 (.sample_i(sample_i),
								.sample_q(sample_q),
								.input_sample_valid(valid_in),
								.reset(reset),
								.clk(clk), 
								.despread_sample_i(sample_i_despread_async),
								.despread_sample_q(sample_q_despread_async),
								.despread_sample_valid(valid_out_async));

matched_filter_despreader_sync u7 (.sample_i(sample_i),
								.sample_q(sample_q),
								.input_sample_valid(valid_in),
								.reset(reset),
								.clk(clk), 
								.despread_sample_i(sample_i_despread_sync),
								.despread_sample_q(sample_q_despread_sync),
								.despread_sample_valid(valid_out_sync));
								
peak_finder u1 (	.clk(clk),
							.reset(reset),
							.despread_sample_i(sample_i_despread_sync),
							.despread_sample_q(sample_q_despread_sync),
							.despread_sample_valid(valid_out_sync),
							.out_bin_index(out_bin_index),
							.max_bin_index(max_bin_index),
							.max_index_valid_out(max_index_valid_out));
demodulator u2 (.clk(clk),
				.reset(reset),
				.despread_sample_i(sample_i_despread_sync),
				.despread_sample_q(sample_q_despread_sync),
				.despread_sample_valid(valid_out_sync),
				.out_bin_index(out_bin_index),
				.max_bin_index(max_bin_index),
				.max_index_valid_out(max_index_valid_out),
				.data_bit(data_bit),
				.data_valid_bit(data_valid_bit));		

preamble_detect u3 (	.clk(clk),
						.reset(reset),
						.data_bit(data_bit),
						.data_valid(data_valid_bit),
						.preamble_detected(preamble_detected));

sfd_detect u4 (			.clk(clk),
						.reset(reset),
						.data_bit(data_bit),
						.data_valid(data_valid_bit),
						.sfd_detected(sfd_detected));

phy_header_detect u5 (	.clk(clk),
						.reset(reset),
						.data_bit(data_bit),
						.data_valid(data_valid_bit),
						.preamble_detected(preamble_detected),
						.sfd_detected(sfd_detected),
						.long_preamble_detected(long_preamble_detected),
						.pkt_rate(pkt_rate),
						.pkt_len(pkt_len),
						.pkt_header_valid(pkt_header_valid),
						.pkt_header_valid_strobe(pkt_header_valid_strobe)
						);

payload_detect u6 (		.clk(clk),
						.reset(reset),
						.data_bit(data_bit),
						.data_bit_valid(data_valid_bit),
						.preamble_detected(preamble_detected),
						.sfd_detected(sfd_detected),
						.long_preamble_detected(long_preamble_detected),
						.pkt_rate(pkt_rate),
						.pkt_len(pkt_len),
						.pkt_header_valid(pkt_header_valid),
						.pkt_header_valid_strobe(pkt_header_valid_strobe),
						.payload_data(payload_data),
						.payload_data_valid(payload_data_valid),
						.crc_ok(crc_ok),
						.crc_ok_strobe(crc_ok_strobe)
);

initial begin 
	clk = 0;
	reset = 1;
	#20 reset = 0;
	fid_in = $fopen("signal.txt","r");
	fid_out = $fopen("out_signal.txt","w");
end
	
always@(posedge clk or posedge reset)
if (reset) begin
	sample_i <= 16'd0;
	sample_q <= 16'd0;
	valid_in <= 1'b0;
	count <= 0;
	sample_count <= 0;
	end
else 
	begin
		count <= count + 1;
		if (count==4)
			if (!$feof(fid_in)) begin
				$fscanf (fid_in,"%d",sample_i);
				$fscanf (fid_in,"%d\n",sample_q);
				valid_in <= 1'b1;
				count <= 0;
				if (sample_count == 19)
					sample_count <= 0;
				else
					sample_count <= sample_count + 1;
			end
			else 
				$stop;
		else
			valid_in <= 1'b0;
			
		if (count==3) begin
			$fwrite (fid_out,"%d ",sample_i_despread_async);
			$fwrite (fid_out,"%d ",sample_i_despread_sync);
			$fwrite (fid_out,"%d ",sample_q_despread_async);
			$fwrite (fid_out,"%d\n",sample_q_despread_sync);
	end	
end
	
endmodule
