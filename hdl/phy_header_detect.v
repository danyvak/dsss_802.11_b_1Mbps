module phy_header_detect (data_bit,data_valid,clk,reset,sfd_detected, preamble_detected, long_preamble_detected, pkt_rate,pkt_len,pkt_header_valid,pkt_header_valid_strobe);
input data_bit;
input data_valid;
input clk;
input reset;
input sfd_detected;
input preamble_detected;
output wire long_preamble_detected;
output reg pkt_header_valid;
output reg pkt_header_valid_strobe;
output reg [7:0] pkt_rate;
output reg [15:0] pkt_len;



parameter state_0 = 3'b000;
parameter state_1 = 3'b001;
parameter state_2 = 3'b010;
parameter state_3 = 3'b011;
parameter state_4 = 3'b100;

reg [2:0] state;
reg [2:0] next_state;
reg [47:0] history_data_bit;
reg [7:0] phy_header_bit_counter;
reg [7:0] phy_header_bit_counter_next;
reg [7:0] sfd_attempts_counter;
reg [7:0] sfd_attempts_counter_next;
reg long_preamble_detected_reg;
reg crc_enable;
wire [15:0] calculated_crc;

crc_16 u2 (.clk(clk),
                        .rst(sfd_detected),
                        .data_in(data_bit),
                        .crc_en(data_valid&&crc_enable),
                        .crc_out(calculated_crc)
);
						
always@(posedge clk, posedge reset)
if (reset) begin
    state <= state_0;
    history_data_bit <= 48'd0;
    pkt_rate = 8'd0;
    pkt_len = 16'd0;
end
else begin
        state <= next_state; 
        if (data_valid) begin       
            history_data_bit <= history_data_bit << 1;
            history_data_bit [0] <= data_bit;
            phy_header_bit_counter <= phy_header_bit_counter_next; 
            sfd_attempts_counter <= sfd_attempts_counter_next;
        end
        if ((phy_header_bit_counter == 48) ) begin
            pkt_rate <= bitOrder({history_data_bit[47:40], 8'b0});
            pkt_len <=  bitOrder(history_data_bit [32:16]);
        end
end

always@(*)
begin
sfd_attempts_counter_next = 7'd0;
phy_header_bit_counter_next = 7'd0;
pkt_header_valid = 1'b0;
pkt_header_valid_strobe = 1'b0;
crc_enable = 1'b0;
    case (state) 

        state_0: if (preamble_detected) next_state = state_1;   //preamble detection 
                    else next_state = state_0;

        state_1: if (sfd_detected) begin
                        next_state = state_2;         //waiting for SFD detection
                        crc_enable = 1'b1;
                    end
                else 
                    if  (sfd_attempts_counter < 128) begin
                            next_state = state_1;
                           sfd_attempts_counter_next = sfd_attempts_counter + 1'b1;
                    end
                    else
                    begin
                        next_state = state_0;
                        sfd_attempts_counter_next = 7'd0;
                    end
                    
        state_2:if ((phy_header_bit_counter == 48) && (history_data_bit [15:0] == calculated_crc)) //actually starting receive a phy header 0f 802.11b
                        next_state = state_3;

                else if ((phy_header_bit_counter == 48) && (history_data_bit [15:0]!= calculated_crc))
                        next_state = state_4;    

                else if (phy_header_bit_counter > 31) 
                        begin
                            crc_enable = 1'b0;
                            next_state = state_2;
                            phy_header_bit_counter_next = phy_header_bit_counter + 1'b1; 
                        end
                else
                        begin
                            crc_enable = 1'b1;
                            next_state = state_2;
                            phy_header_bit_counter_next = phy_header_bit_counter + 1'b1; 
                        end
        state_3:begin
                    pkt_header_valid = 1'b1;
                    pkt_header_valid_strobe = 1'b1;    
                    next_state = state_0;
        end

        state_4:begin
                    pkt_header_valid = 1'b0;
                    pkt_header_valid_strobe = 1'b1;    
                    next_state = state_0;
        end
    endcase
end
assign long_preamble_detected = preamble_detected;

function [16-1:0] bitOrder (
    input [16-1:0] data
);
integer i;
begin
    for (i=0; i < 16; i=i+1) begin : reverse
        bitOrder[16-1-i] = data[i]; //Note how the vectors get swapped around here by the index. For i=0, i_out=15, and vice versa.
    end
end
endfunction
endmodule


