module demodulator (clk,reset,despread_sample_i, despread_sample_q, despread_sample_valid,out_bin_index,max_bin_index,max_index_valid_out, data_bit, data_valid_bit);
input clk,reset,despread_sample_valid;
input signed [31:0]  despread_sample_i,despread_sample_q;
input [15:0] out_bin_index,max_bin_index;
input max_index_valid_out;
output reg data_bit;
output reg data_valid_bit;
reg signed [31:0] s_n_i, s_n_q;
reg signed [31:0] s_n_i_1, s_n_q_1;
reg signed [63:0] demod_decision_i;
reg signed [63:0] demod_decision_q;
reg [19:0] history_demod_bit;
reg demod_bit;
reg [3:0] state, next_state; 
parameter state_0 = 3'd0; 
parameter state_1 = 3'd1;
parameter state_2 = 3'd2;
parameter state_3 = 3'd3;
parameter state_4 = 3'd4;

always@(posedge clk, posedge reset)
if (reset) begin
     state <= state_0;
end
else begin
    state <= next_state;
    //if (max_index_valid_out && out_bin_index==max_bin_index && despread_sample_valid) begin
    if (out_bin_index==max_bin_index && despread_sample_valid) begin
        s_n_i <= despread_sample_i;
        s_n_q <= despread_sample_q;
        s_n_i_1 <=  s_n_i;
        s_n_q_1 <=  s_n_q;
        history_demod_bit <= {history_demod_bit [18:0], demod_bit};
    end
end

always@(*)

case (state) 

state_0: begin //decision variable calculation
    //if (max_index_valid_out && out_bin_index==max_bin_index && despread_sample_valid) begin
    data_valid_bit = 1'b0;    
    if (out_bin_index==max_bin_index && despread_sample_valid) begin
        demod_decision_i = s_n_i*s_n_i_1 + s_n_q*s_n_q_1;
        demod_decision_q = s_n_q*s_n_i_1 + s_n_i*s_n_q_1;
        next_state = state_1;
        //demod_bit = 1'b0;
        //data_valid_bit = 1'b0;
    end
    else
      next_state = state_0;  
end

state_1: begin //actual bit detection by boundaries
    if (demod_decision_i<$signed(64'd0))
        demod_bit = 1'b1;
    else 
        demod_bit = 1'b0;
    next_state = state_2;
end

state_2: begin
    
    data_bit = demod_bit ^ history_demod_bit[3] ^ history_demod_bit[6];
    next_state = state_0;
    data_valid_bit = 1'b1;
end 
endcase

endmodule

