module sfd_detect (data_bit,data_valid,clk,reset,sfd_detected);
input data_bit;
input data_valid;
input clk;
input reset;
output sfd_detected;
parameter state_0 = 3'b000;
parameter state_1 = 3'b001;
parameter state_2 = 3'b010;
parameter state_3 = 3'b011;
reg [2:0] state;
reg [2:0] next_state;
reg [15:0] history_data_bit;
reg sfd_detected_reg;
reg sfd_detected_reg_d;

always@(posedge clk, posedge reset)
if (reset) begin
     //state <= state_0;
    sfd_detected_reg <= 0;
    sfd_detected_reg_d <= 0;
end
else begin
    //state <= next_state;
    sfd_detected_reg_d <= sfd_detected_reg; 
    if (data_valid) begin
       history_data_bit <= {data_bit,history_data_bit [15:1]};
    end
end

always@(*)
if (history_data_bit == 16'hF3A0) 
    sfd_detected_reg = 1;
else 
    sfd_detected_reg = 0;

assign sfd_detected = sfd_detected_reg &  (!sfd_detected_reg_d); 

endmodule