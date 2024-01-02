module spi (
    input wire i_clk,
    input wire i_rst,

    input [7:0] i_tx_byte,
    input wire i_tx_start,
    output reg o_tx_ready,

    output [7:0] o_rx_byte,
    
    output wire o_sclk,
    input reg i_poci,
    output reg o_pico,
    output reg o_cs
);  


    localparam IDLE = 1'b0;
    localparam TRANS = 1'b1;
    reg state;
    reg next_state;
    reg [7:0] shift_out;
    reg [7:0] shift_in;
    reg [2:0] bit_count;

    always @(posedge i_clk)
        if(i_rst) state = IDLE;
        else state = next_state;
    
    always  @(posedge i_clk) begin
        case(state)
            IDLE: begin
                if(i_tx_start) begin
                    o_cs = 0;
                    shift_out = i_tx_byte;
                    o_rx_byte = {o_rx_byte[6:0],i_poci};
                    o_pico = shift_out[7];
                    next_state = TRANS;
                end
                else begin
                    o_pico = 0;
                    o_cs = 1;
                    shift_out = 0;
                    next_state = IDLE;
                end
                o_tx_ready = 0;
            end
            TRANS: begin
                shift_out = {shift_out[6:0], 1'b0};
                o_sclk = ~o_sclk;
                if(bit_count == 3'b111) begin
                    if(i_tx_start) begin
                        o_cs = 0;
                        shift_out = i_tx_byte;
                        next_state = TRANS;
                    end
                    else begin
                        o_cs = 1;
                        next_state = IDLE;
                    end
                    o_rx_byte = 0;
                    o_tx_ready = 1;
                    bit_count = 0;
                end
                else begin
                    o_tx_ready = 0;
                    o_pico = shift_out[7];
                    o_rx_byte = {o_rx_byte[6:0],i_poci};
                    bit_count = bit_count + 1;
                end
            end
        endcase
    end 





endmodule
