module rv_uart_rx (
    input wire clk,
    input wire rst_n,
    input wire rx_pin,
    output reg [7:0] rdata,
    output reg data_ready
);

    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115_200;
    localparam BAUD_CYCLE = CLK_FREQ / BAUD_RATE;   // 434
    localparam HALF_CYCLE = BAUD_CYCLE / 2;         // 217

    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] baud_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            baud_cnt <= 16'd0;
            bit_cnt <= 3'd0;
            shift_reg <= 8'd0;
            rdata <= 8'd0;
            data_ready <= 1'b0;
        end else begin
            data_ready <= 1'b0;

            case (state)
                IDLE: begin
                    if (!rx_pin) begin
                        state <= START;
                        baud_cnt <= 16'd0;
                    end
                end

                START: begin
                    if (baud_cnt == HALF_CYCLE - 1) begin
                        baud_cnt <= 16'd0;
                        bit_cnt <= 3'd0;
                        state <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_cnt == BAUD_CYCLE - 1) begin
                        baud_cnt <= 16'd0;
                        shift_reg[bit_cnt] <= rx_pin;
                        if (bit_cnt == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_cnt == BAUD_CYCLE - 1) begin
                        state <= IDLE;
                        rdata <= shift_reg;
                        data_ready <= 1'b1;
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end
            endcase
        end
    end

endmodule
