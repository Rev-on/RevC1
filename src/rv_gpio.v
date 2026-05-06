module rv_gpio(
    input wire clk,
    input wire rst_n,
    input wire [7:0] addr,
    input wire [31:0] wdata,
    input wire write_en,
    output wire [31:0] rdata,
    inout wire [7:0] gpio_pins
);

    reg [7:0] gpio_out;
    reg [7:0] gpio_dir;

    always @(posedge clk) begin
        if (!rst_n) begin
            gpio_out <= 8'd0;
            gpio_dir <= 8'hFF;
        end else if (write_en) begin
            if (addr[2:0] == 3'd0) gpio_out <= wdata[7:0];
            if (addr[2:0] == 3'd1) gpio_dir <= wdata[7:0];
        end
    end

    assign rdata = (addr[2:0] == 3'd0) ? {24'd0, gpio_out} :
                   (addr[2:0] == 3'd1) ? {24'd0, gpio_dir}  : 32'd0;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign gpio_pins[i] = gpio_dir[i] ? gpio_out[i] : 1'bz;
        end
    endgenerate

endmodule
