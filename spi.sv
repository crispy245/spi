module spi (
    input wire i_clk,
    input wire i_rst,

    input [7:0] i_tx_byte,
    input wire tx_start,

    output [7:0] o_rx_byte,

    
    input reg i_poci,

    output wire o_sclk,
    output reg o_pico,
    output reg o_cs
);  


    localparam IDLE = 1'b0;
    localparam TRANS = 1'b1;
    reg state;
    reg next_state;
    reg [7:0] data_in;
    reg [7:0] data_out;
    reg [2:0] bit_count;

    always @(posedge i_clk)
        if(i_rst) state = IDLE;
        else state = next_state;
    
    always  @(posedge i_clk) begin
        case(state)
            IDLE: begin
                if(tx_start) begin
                    o_cs = 0;
                    data_in = i_tx_byte;
                    o_pico = data_in[7];
                    next_state = TRANS;
                end
                else begin
                    o_pico = 0;
                    o_cs = 1;
                    data_in = 0;
                    next_state = IDLE;
                end
            end
            TRANS: begin
                data_in = {data_in[6:0], 1'b0};
                o_sclk = ~o_sclk;
                if(bit_count == 3'b111) begin
                    if(tx_start) begin
                        o_cs = 0;
                        data_in = i_tx_byte;
                        next_state = TRANS;
                    end
                    else begin
                        o_cs = 1;
                        next_state = IDLE;
                    end
                    bit_count = 0;
                end
                else begin
                    o_pico = data_in[7];
                    bit_count = bit_count + 1;
                end
            end
        endcase
    end 





endmodule
