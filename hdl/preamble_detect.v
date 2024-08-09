module preamble_detect (data_bit,data_valid,clk,reset,preamble_detected);
input data_bit;
input data_valid;
input clk;
input reset;
output preamble_detected;

reg [2:0] state;
reg [2:0] next_state;
reg [5:0] consequtive_ones_counter;
reg [5:0] consequtive_ones_counter_next;
reg data_valid_d;
reg preamble_detected_reg;
parameter state_0 = 3'b000;
parameter state_1 = 3'b001;
parameter state_2 = 3'b010;
parameter state_3 = 3'b011;

always @(posedge clk or posedge reset)
if (reset) begin 
    state <= state_0;
    consequtive_ones_counter <= 6'b000000;
    data_valid_d <= 0;
end
else
    begin
        state <= next_state;
        consequtive_ones_counter <= consequtive_ones_counter_next;
        data_valid_d <= data_valid;
    end

always @(*) begin
preamble_detected_reg = 0;
//consequtive_ones_counter_next = 6'b000000;

case (state) 
state_0:
    if (data_bit && data_valid) begin
        next_state = state_1;
    end
    else begin
        next_state = state_0;
        consequtive_ones_counter_next = 6'b000000;
    end

state_1:
    if (data_bit && data_valid_d && !data_valid ) begin
            consequtive_ones_counter_next = consequtive_ones_counter + 6'd1;
             if (consequtive_ones_counter > 6'd32) next_state = state_2;   
             else next_state = state_1;
    end

    else if (!data_bit && data_valid_d && !data_valid) begin 
        next_state = state_0;
    end

    else next_state = state_1;

state_2:
    begin
    preamble_detected_reg = 1;
    next_state = state_0;
    end
endcase
end 

assign preamble_detected = preamble_detected_reg;

endmodule 



