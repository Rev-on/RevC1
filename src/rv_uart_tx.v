module rv_uart_tx(
    input wire clk,
    input wire rst_n,
    input wire [31:0] wdata,
    input wire write_en,
    output wire tx_pin,
    output wire busy
);

    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115_200;
    localparam BAUD_CYCLE = CLK_FREQ / BAUD_RATE;   // 434
    localparam IDLE_BITS = 10'b11_1111_1111;        // 停止位+空闲

    reg [15:0] baud_cnt;
    reg [3:0]  bit_cnt;
    reg [9:0]  shift_reg;
    reg        tx_state;

    assign busy = tx_state;
    assign tx_pin = shift_reg[0];

    always @(posedge clk) begin
        if (!rst_n) begin
            tx_state  <= 1'b0;
            baud_cnt  <= 16'd0;
            bit_cnt   <= 4'd0;
            shift_reg <= IDLE_BITS;
        end else if (!tx_state) begin
            if (write_en) begin
                shift_reg <= {1'b0, wdata[7:0], 1'b1};
                tx_state  <= 1'b1;
                baud_cnt  <= 16'd0;
                bit_cnt   <= 4'd0;
            end
        end else begin
            if (baud_cnt == BAUD_CYCLE - 1) begin
                baud_cnt <= 16'd0;
                if (bit_cnt == 4'd9) begin
                    tx_state <= 1'b0;
                    shift_reg <= IDLE_BITS;
                end else begin
                    shift_reg <= {1'b1, shift_reg[9:1]};
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end else begin
                baud_cnt <= baud_cnt + 1'b1;
            end
        end
    end

endmodule
