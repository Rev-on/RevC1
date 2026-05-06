module rv_i2c_master(
    input wire clk,
    input wire rst_n,
    input wire [7:0] dev_addr,
    input wire [7:0] reg_addr,
    input wire [7:0] wdata,
    input wire start,
    input wire rw,
    output reg [7:0] rdata,
    output reg done,
    output wire scl,
    inout wire sda
);

    // -------- SCL 时钟生成 --------
    parameter CLK_DIV = 5;
    reg [15:0] scl_cnt;
    reg scl_reg;
    assign scl = scl_reg ? 1'bz : 1'b0;

    wire scl_rise, scl_fall;
    assign scl_rise  = (scl_cnt == CLK_DIV - 1) && (scl_reg == 1'b0);
    assign scl_fall  = (scl_cnt == CLK_DIV - 1) && (scl_reg == 1'b1);

    // -------- SDA 开漏控制 --------
    reg sda_out;
    wire sda_in;
    assign sda = sda_out ? 1'bz : 1'b0;
    assign sda_in = sda;

    // -------- 状态机定义 --------
    localparam IDLE = 0, START_C = 1, SEND = 2, WAIT_ACK = 3, STOP_C = 4, DONE_C = 5;
    reg [3:0] state, next_state;
    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;

    // SCL 计数器
    always @(posedge clk) begin
        if (!rst_n) begin
            scl_cnt <= 0;
            scl_reg <= 1'b1;
        end else if (state == IDLE || state == DONE_C) begin
            scl_cnt <= 0;
            scl_reg <= 1'b1;
        end else begin
            if (scl_cnt == CLK_DIV - 1) begin
                scl_cnt <= 0;
                scl_reg <= ~scl_reg;
            end else begin
                scl_cnt <= scl_cnt + 1;
            end
        end
    end

    // 状态机
    always @(posedge clk) begin
        if (!rst_n) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = START_C;
            START_C: if (scl_fall) next_state = SEND;
            SEND: if (bit_cnt == 8 && scl_fall) next_state = WAIT_ACK;
            WAIT_ACK: if (scl_rise) next_state = STOP_C;
            STOP_C: if (scl_rise) next_state = DONE_C;
            DONE_C: next_state = IDLE;
        endcase
    end

    // 输出逻辑
    always @(posedge clk) begin
        if (!rst_n) begin
            sda_out <= 1'b1;
            done <= 1'b0;
            shift_reg <= 8'h00;
            bit_cnt <= 4'd0;
            rdata <= 8'h00;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    sda_out <= 1'b1;
                    shift_reg <= {dev_addr[7:1], 1'b0};
                    bit_cnt <= 4'd0;
                end
                START_C: begin
                    if (scl_fall) sda_out <= 1'b0;
                end
                SEND: begin
                    if (scl_fall) begin
                        if (bit_cnt < 8) begin
                            sda_out <= shift_reg[7];
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;
                        end else begin
                            sda_out <= 1'bz;
                        end
                    end
                end
                WAIT_ACK, STOP_C: begin
                    if (scl_rise) sda_out <= 1'b0;
                end
                DONE_C: begin
                    done <= 1'b1;
                    sda_out <= 1'b1;
                end
            endcase
        end
    end

endmodule