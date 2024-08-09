module payload_detect (data_bit,data_bit_valid,clk,reset,sfd_detected, preamble_detected, long_preamble_detected, pkt_rate,pkt_len,pkt_header_valid,pkt_header_valid_strobe,payload_data,payload_data_valid,crc_ok,crc_ok_strobe);
input data_bit;
input data_bit_valid;
input clk;
input reset;
input sfd_detected;
input preamble_detected;
input long_preamble_detected;
input pkt_header_valid;
input pkt_header_valid_strobe;
input [7:0] pkt_rate;
input [15:0] pkt_len;
output reg [7:0] payload_data;
output reg payload_data_valid;
output reg crc_ok;
output reg crc_ok_strobe;

wire [7:0] payload_data_reversed;
reg [31:0] history_data_bit;
reg [15:0] frame_bit_counter;
reg [15:0] frame_bit_counter_next;
reg [7:0] bit_counter;
reg [7:0] bit_counter_next;
reg crc_enable;
reg crc_enable_next;
wire [31:0] calculated_crc;
reg crc_reset;

assign payload_data_reversed[0] = payload_data[7];
assign payload_data_reversed[1] = payload_data[6];
assign payload_data_reversed[2] = payload_data[5];
assign payload_data_reversed[3] = payload_data[4];
assign payload_data_reversed[4] = payload_data[3];
assign payload_data_reversed[5] = payload_data[2];
assign payload_data_reversed[6] = payload_data[1];
assign payload_data_reversed[7] = payload_data[0];

crc_32 payload_crc(
    .data_in(payload_data_reversed),
    .crc_en(payload_data_valid&crc_enable),
    .crc_out(calculated_crc),
    .rst(crc_reset),
    .clk(clk));

parameter state_0 = 3'b000;
parameter state_1 = 3'b001;
parameter state_2 = 3'b010;
parameter state_3 = 3'b011;
parameter state_4 = 3'b100;

reg [2:0] state;
reg [2:0] next_state;


always@(posedge clk, posedge reset)
if (reset) begin
    state <= state_0;
    history_data_bit <= 16'd0;
    frame_bit_counter <= 16'd0;
    bit_counter <= 16'd0;
    crc_enable <= 1'd1;
end
else begin
        state <= next_state;
        crc_enable <= crc_enable_next;
        if ((data_bit_valid) && (pkt_rate == 7'h0A)) begin       //moving forward only in 1Mbps rate header was read
            //state <= next_state;
            history_data_bit <= history_data_bit >> 1;
            history_data_bit [31] <= data_bit;
            bit_counter <= bit_counter_next; 
            if (frame_bit_counter == pkt_len)
                frame_bit_counter <= 16'd0;
            else
                frame_bit_counter <= frame_bit_counter_next;
        end
end

always@(*)
begin
    crc_enable_next = crc_enable;
    bit_counter_next = bit_counter;
    frame_bit_counter_next = frame_bit_counter;
    next_state = state_0;
    payload_data_valid = 1'b0;
    crc_ok = 1'b0;
    crc_ok_strobe = 1'b0;
    crc_reset = 1'b0;
    //bit_counter_next = 8'd0;
    //frame_bit_counter_next = 16'd0;
    case (state)
        //state_0 waiting for the valid header 
        state_0:if (pkt_rate == 8'h0A) begin 
                    next_state = state_1;
                    crc_reset = 1'b1;
                    //frame_bit_counter_next = 16'd0;
        end
                else 
                    next_state = state_0;
        //waiting to read an 8 bit 
        state_1:if ((data_bit_valid) && (pkt_rate == 7'h0A)) 
                begin  
                    //bit_counter_next = bit_counter + 8'd1;
                    frame_bit_counter_next = frame_bit_counter + 16'd1;
                    if (bit_counter == 8'd7) begin
                        bit_counter_next = 8'd0;
                        next_state = state_2;
                    end
                    else begin 
                            bit_counter_next = bit_counter + 8'd1; 
                            next_state = state_1;
                    end
                end
                else begin
                    next_state = state_1;
                    bit_counter_next = bit_counter;
                    frame_bit_counter_next = frame_bit_counter;
                end
        //sending a byte of data out and checking if frame is finished
        state_2:begin
                    payload_data = history_data_bit[31:24];
                    payload_data_valid = 1'b1; 
                    //bit_counter <= 8'd0;
                    if (frame_bit_counter < (pkt_len - 16'd32)) begin
                        crc_enable_next = 1'b1;
                        next_state = state_1;
                    end
                    else if ((frame_bit_counter >= (pkt_len - 16'd32))&&(frame_bit_counter < pkt_len )) begin
                        crc_enable_next = 1'b0;
                        next_state = state_1;
                    end
                    else if (frame_bit_counter == pkt_len ) begin
                        crc_ok_strobe = 1'b1;
                        next_state = state_0;
                    end
                    else begin
                        crc_enable_next = 1'b1;
                        next_state = state_0;
                        //frame_bit_counter_next = 16'd0;
                    end

                    if (calculated_crc ==  history_data_bit) 
                            crc_ok = 1'b1;
                        else
                            crc_ok = 1'b0;
        end
        //checking for crc valid
    endcase
end
endmodule
                



