// ============================================================
// Rev.on RISC-V MCU 顶层模块 (cpu_core.v)
// 集成：CPU核心 + CPU-to-AHB适配器 + AHB总线 + 所有外设
// ============================================================

module cpu_core(
    // ===== 时钟与复位 =====
    input  wire        clk,
    input  wire        rst_n,
    
    // ===== UART =====
    output wire        uart_tx,
    input  wire        uart_rx,
    
    // ===== GPIO (8位双向) =====
    inout  wire [7:0]  gpio_pins,
    
    // ===== I2C =====
    inout  wire        i2c_scl,
    inout  wire        i2c_sda,
    
    // ===== Timer/PWM =====
    output wire        pwm_out,
    
    // ===== 调试接口 =====
    output wire [2:0]  debug_sel,
    output wire        debug_data
);

    // =======================================================
    // 信号声明
    // =======================================================
    
    wire [31:0] cpu_native_addr;
    wire [31:0] cpu_native_wdata;
    wire [31:0] cpu_native_rdata;
    wire        cpu_native_write;
    wire        cpu_native_req;
    wire        cpu_native_ready;
    
    wire [31:0] cpu_pc_addr;
    wire [31:0] cpu_inst;
    
    wire [31:0] cpu_haddr;
    wire [31:0] cpu_hwdata;
    wire [31:0] cpu_hrdata;
    wire        cpu_hwrite;
    wire [2:0]  cpu_hsize;
    wire [2:0]  cpu_hburst;
    wire        cpu_hbusreq;
    wire        cpu_hready;
    wire [1:0]  cpu_hresp;
    
    // AHB 总线各从设备信号
    wire [31:0] mem_haddr,  mem_hwdata,  mem_hrdata;
    wire        mem_hwrite, mem_hsel,    mem_hready;
    
    wire [31:0] gpio_haddr, gpio_hwdata, gpio_hrdata;
    wire        gpio_hwrite, gpio_hsel,  gpio_hready;
    
    wire [31:0] uart_haddr, uart_hwdata, uart_hrdata;
    wire        uart_hwrite, uart_hsel,  uart_hready;
    
    wire [31:0] i2c_haddr,  i2c_hwdata;
    reg  [31:0] i2c_hrdata;           // ✅ 只声明，不初始化
    wire        i2c_hwrite, i2c_hsel,    i2c_hready;
    
    wire [31:0] timer_haddr, timer_hwdata, timer_hrdata;
    wire        timer_hwrite, timer_hsel,  timer_hready;

    // UART/Timer 内部信号
    wire uart_busy, uart_data_ready;
    wire timer_intr;
    
    // GPIO 内部信号（低有效）
    wire [7:0] gpio_dout;
    wire [7:0] gpio_din;
    wire [7:0] gpio_dir;

    // =======================================================
    // 指令存储器
    // =======================================================
    inst_mem u_inst_mem (
        .clk(clk),
        .addr(cpu_pc_addr),
        .inst(cpu_inst)
    );

    // =======================================================
    // RISC-V CPU 核心
    // =======================================================
    riscv_cpu u_riscv_cpu (
        .clk(clk),
        .rst_n(rst_n),
        .pc_addr(cpu_pc_addr),
        .inst(cpu_inst),
        .mem_addr(cpu_native_addr),
        .mem_wdata(cpu_native_wdata),
        .mem_rdata(cpu_native_rdata),
        .mem_write(cpu_native_write),
        .mem_req(cpu_native_req),
        .mem_ready(cpu_native_ready)
    );

    // =======================================================
    // CPU-to-AHB 适配器
    // =======================================================
    cpu_to_ahb u_adaptor (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_addr(cpu_native_addr),
        .cpu_wdata(cpu_native_wdata),
        .cpu_rdata(cpu_native_rdata),
        .cpu_write(cpu_native_write),
        .cpu_req(cpu_native_req),
        .cpu_ready(cpu_native_ready),
        .HADDR(cpu_haddr),
        .HWDATA(cpu_hwdata),
        .HRDATA(cpu_hrdata),
        .HWRITE(cpu_hwrite),
        .HSIZE(cpu_hsize),
        .HBURST(cpu_hburst),
        .HBUSREQ(cpu_hbusreq),
        .HREADY(cpu_hready),
        .HRESP(cpu_hresp)
    );

    // =======================================================
    // AHB 总线
    // =======================================================
    ahb_bus u_ahb_bus (
        .HCLK(clk),
        .HRESETn(rst_n),
        .CPU_HADDR(cpu_haddr),
        .CPU_HWDATA(cpu_hwdata),
        .CPU_HRDATA(cpu_hrdata),
        .CPU_HWRITE(cpu_hwrite),
        .CPU_HSIZE(cpu_hsize),
        .CPU_HBURST(cpu_hburst),
        .CPU_HBUSREQ(cpu_hbusreq),
        .CPU_HREADY(cpu_hready),
        .CPU_HRESP(cpu_hresp),
        .MEM_HRDATA(mem_hrdata),
        .MEM_HREADY(mem_hready),
        .GPIO_HADDR(gpio_haddr),
        .GPIO_HWDATA(gpio_hwdata),
        .GPIO_HRDATA(gpio_hrdata),
        .GPIO_HWRITE(gpio_hwrite),
        .GPIO_HSEL(gpio_hsel),
        .GPIO_HREADY(gpio_hready),
        .UART_HADDR(uart_haddr),
        .UART_HWDATA(uart_hwdata),
        .UART_HRDATA(uart_hrdata),
        .UART_HWRITE(uart_hwrite),
        .UART_HSEL(uart_hsel),
        .UART_HREADY(uart_hready),
        .I2C_HADDR(i2c_haddr),
        .I2C_HWDATA(i2c_hwdata),
        .I2C_HRDATA(i2c_hrdata),
        .I2C_HWRITE(i2c_hwrite),
        .I2C_HSEL(i2c_hsel),
        .I2C_HREADY(i2c_hready),
        .TIMER_HADDR(timer_haddr),
        .TIMER_HWDATA(timer_hwdata),
        .TIMER_HRDATA(timer_hrdata),
        .TIMER_HWRITE(timer_hwrite),
        .TIMER_HSEL(timer_hsel),
        .TIMER_HREADY(timer_hready)
    );

    // =======================================================
    // 内存（简单RAM）
    // =======================================================
    // 这里可以例化一个简单的 RAM 模块
    // 暂时用 dummy，需要实际 RAM 的话我帮你写
    assign mem_hrdata = 32'h0;
    assign mem_hready = 1'b1;

    // =======================================================
    // GPIO 外设
    // =======================================================
    rv_gpio u_gpio (
        .clk(clk),
        .rst_n(rst_n),
        .addr(gpio_haddr[7:0]),
        .wdata(gpio_hwdata),
        .write_en(gpio_hwrite && gpio_hsel),
        .rdata(gpio_hrdata),
        .gpio_pins(gpio_pins)
    );
    assign gpio_hready = 1'b1;

    // =======================================================
    // UART 外设
    // =======================================================
    rv_uart u_uart (
        .clk(clk), 
        .rst_n(rst_n),
        .wdata(uart_hwdata),
        .write_en(uart_hwrite && uart_hsel),
        .hsel(uart_hsel),
        .hwrite(uart_hwrite),
        .rdata(uart_hrdata),
        .tx_pin(uart_tx),
        .rx_pin(uart_rx),
        .busy(uart_busy),
        .data_ready(uart_data_ready)
    );
    assign uart_hready = 1'b1;

    // =======================================================
    // I2C 外设
    // =======================================================
    wire [7:0] i2c_rdata_int; 
    rv_i2c_master u_i2c (
        .clk(clk),
        .rst_n(rst_n),
        .dev_addr(i2c_hwdata[7:0]),
        .reg_addr(i2c_hwdata[15:8]),
        .wdata(i2c_hwdata[23:16]),
        .start(i2c_hwrite && i2c_hsel),
        .rw(i2c_hwrite),
        .rdata(i2c_rdata_int),
        .done(),
        .scl(i2c_scl),
        .sda(i2c_sda)
    );
    assign i2c_hrdata = {24'd0, i2c_hrdata[7:0]};
    assign i2c_hready = 1'b1;
    always @(*) begin
    	i2c_hrdata = {24'd0, i2c_rdata_int};
    end
    assign i2c_hready = 1'b1;

    // =======================================================
    // Timer 外设（带 PWM）
    // =======================================================
    rv_timer u_timer (
        .clk(clk), 
        .rst_n(rst_n),
        .wdata(timer_hwdata),
        .write_en(timer_hwrite && timer_hsel),
        .addr(timer_haddr[3:0]),
        .rdata(timer_hrdata),
        .pwm_out(pwm_out),
        .intr(timer_intr),
        .dbg_counter(),
        .dbg_enable(),
        .dbg_write_en()
    );
    assign timer_hready = 1'b1;
    
    // =======================================================
    // 调试输出
    // =======================================================
    assign debug_sel = cpu_pc_addr[4:2];
    assign debug_data = cpu_hready;

endmodule
