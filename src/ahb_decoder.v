module ahb_decoder (
    input  wire [31:0] HADDR,
    output wire        HSEL_MEM,    // 内存 (0x0000_0000 - 0x0FFF_FFFF)
    output wire        HSEL_GPIO,   // GPIO  (0x1000_0000 - 0x1000_0FFF)
    output wire        HSEL_UART,   // UART  (0x1000_1000 - 0x1000_1FFF)
    output wire        HSEL_I2C,    // I2C   (0x1000_2000 - 0x1000_2FFF)
    output wire        HSEL_TIMER   // Timer (0x1000_3000 - 0x1000_3FFF)
);
    // 高12位作为设备选择码
    assign HSEL_MEM   = (HADDR[31:20] == 12'h000);  // 0x000xxxxx
    assign HSEL_GPIO  = (HADDR[31:12] == 20'h10000); // 0x10000xxx
    assign HSEL_UART  = (HADDR[31:12] == 20'h10001); // 0x10001xxx
    assign HSEL_I2C   = (HADDR[31:12] == 20'h10002); // 0x10002xxx
    assign HSEL_TIMER = (HADDR[31:12] == 20'h10003); // 0x10003xxx
endmodule