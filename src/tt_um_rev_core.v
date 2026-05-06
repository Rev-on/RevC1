// Tiny Tapeout 顶层包装器
// 将 Tiny Tapeout 固定引脚映射到 CPU 核心

module tt_um_rev_core (
    input  wire [7:0] ui_in,      // 8位输入
    output wire [7:0] uo_out,     // 8位输出
    input  wire [7:0] uio_in,     // 双向输入
    output wire [7:0] uio_out,    // 双向输出
    output wire [7:0] uio_oe,     // 双向方向控制
    input  wire       ena,        // 使能（不用就置1）
    input  wire       clk,        // 时钟
    input  wire       rst_n       // 复位
);

    // 内部信号
    wire [7:0] gpio_pins_internal;
    wire [7:0] gpio_pins_dir;
    
    // =============================================
    // 例化你的 CPU 核心
    // =============================================
    cpu_core u_cpu (
        .clk(clk),
        .rst_n(rst_n),
        
        // UART → 映射到 Tiny Tapeout 引脚
        .uart_tx(uo_out[0]),           // TX 输出到 uo_out[0]
        .uart_rx(ui_in[0]),            // RX 从 ui_in[0] 输入
        
        // GPIO (8位双向) → 映射到 uio
        .gpio_pins({
            uio_out[7], uio_out[6], uio_out[5], uio_out[4],
            uio_out[3], uio_out[2], uio_out[1], uio_out[0]
        }),
        
        // I2C → 映射到 uio
        .i2c_scl(uio_out[1]),
        .i2c_sda(uio_out[2]),
        
        // PWM → 输出到 uo_out[1]
        .pwm_out(uo_out[1]),
        
        // 调试接口 → 输出到 uo_out 高几位
        .debug_sel(uo_out[4:2]),
        .debug_data(uo_out[5])
    );
    
    // 配置双向引脚：全部作为输出（无输入功能）
    // uio_oe 的位为1表示输出，0表示输入
    assign uio_oe = 8'b11111111;  // 所有uio引脚都设为输出
    
    // 未使用的 uo_out 位设为0
    assign uo_out[6] = 1'b0;
    assign uo_out[7] = 1'b0;

endmodule
