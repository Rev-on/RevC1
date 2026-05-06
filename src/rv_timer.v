module rv_timer(
    input wire clk,
    input wire rst_n,
    input wire [31:0] wdata,
    input wire write_en,
    input wire [3:0] addr,
    output wire [31:0] rdata,
    output wire pwm_out,
    output wire intr,
    output wire [31:0] dbg_counter,
    output wire dbg_enable,
    output wire dbg_write_en
);

    reg [31:0] counter;
    reg [31:0] compare;
    reg [15:0] prescaler;
    reg enable, pwm_en;

    assign intr = enable && (counter == compare);
    assign pwm_out = pwm_en && (counter < compare);
    assign dbg_counter = counter;
    assign dbg_enable   = enable;
    assign dbg_write_en = write_en;

    always @(posedge clk) begin
        if (!rst_n) begin
            counter   <= 32'd0;
            compare   <= 32'd10;
            prescaler <= 16'd0;
            enable    <= 1'b1;
            pwm_en    <= 1'b1;
        end else begin
            if (write_en) begin
                case(addr)
                    4'd0: {pwm_en, enable} <= wdata[1:0];
                    4'd1: prescaler <= wdata[15:0];
                    4'd2: compare <= wdata;
                endcase
            end
            if (enable) begin
                if (counter >= compare)
                    counter <= 32'd0;
                else
                    counter <= counter + 1'b1;
            end
        end
    end

    assign rdata = (addr == 4'd3) ? counter : 32'd0;

endmodule
