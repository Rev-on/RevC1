module rv_uart (
    input wire clk,
    input wire rst_n,
    // AHB 接口
    input wire [31:0] wdata,
    input wire write_en,
    input wire hsel,        // 添加片选
    input wire hwrite,      // 添加读写指示
    output wire [31:0] rdata,
    output wire tx_pin,
    input wire rx_pin,
    output wire busy,
    output wire data_ready
);
    wire uart_tx_busy;
    wire [7:0] uart_rx_data;
    wire uart_rx_ready;

    // TX 模块
    rv_uart_tx u_tx (
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata), .write_en(write_en),
        .tx_pin(tx_pin), .busy(uart_tx_busy)
    );
    
    // RX 模块
    rv_uart_rx u_rx (
        .clk(clk), .rst_n(rst_n),
        .rx_pin(rx_pin),
        .rdata(uart_rx_data),
        .data_ready(uart_rx_ready)
    );

    assign busy = uart_tx_busy;
    assign data_ready = uart_rx_ready;
    
    // 读数据：当片选有效且是读操作时，返回接收到的字节
    assign rdata = (hsel && !hwrite) ? {24'd0, uart_rx_data} : 32'd0;

endmodule
