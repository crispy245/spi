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

    initial begin
        o_cs = 1;
    end

    localparam IDLE = 1'b0;
    localparam TRANS = 1'b1;
    reg state;
    reg [7:0] data_in;
    reg [7:0] data_out;
    reg [2:0] bit_count;

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            o_pico <= 0;
            o_cs <= 1;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    o_cs <= 1;
                    o_pico <= 0;
                    o_sclk <= 0;
                    if(tx_start) begin
                        o_cs <= 0;
                        state <= TRANS;
                        data_out <= 8'b0;
                        data_in <= i_tx_byte;
                    end 
                end
                TRANS: begin
                    o_cs <= 0;
                    o_pico <= data_in[7];
                    o_sclk <= ~o_sclk;
                    data_in <= {data_in[6:0],i_poci};
                    if(bit_count == 3'b111) begin
                        if(tx_start) begin
                            o_cs <= 0;
                            data_in <= i_tx_byte;
                            data_out <= 8'b0;
                            state <= TRANS;
                        end
                        else begin
                        o_cs <= 1;
                        state <= IDLE;
                        end
                        bit_count <= 0;
                    end
                    else begin
                        bit_count <= bit_count + 1; 
                    end
                end
            endcase    
        end
    end



endmodule
