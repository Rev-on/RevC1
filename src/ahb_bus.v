module ahb_bus (
    input  wire        HCLK,
    input  wire        HRESETn,
    
    // ===== 主设备接口 =====
    // 主设备0 (CPU)
    input  wire [31:0] CPU_HADDR,
    input  wire [31:0] CPU_HWDATA,
    output wire [31:0] CPU_HRDATA,
    input  wire        CPU_HWRITE,
    input  wire [2:0]  CPU_HSIZE,
    input  wire [2:0]  CPU_HBURST,
    input  wire        CPU_HBUSREQ,
    output wire        CPU_HREADY,
    output wire [1:0]  CPU_HRESP,
    
    // ===== 从设备接口 =====
    // 内存
    output wire [31:0] MEM_HADDR,
    output wire [31:0] MEM_HWDATA,
    input  wire [31:0] MEM_HRDATA,
    output wire        MEM_HWRITE,
    output wire        MEM_HSEL,
    input  wire        MEM_HREADY,
    
    // GPIO
    output wire [31:0] GPIO_HADDR,
    output wire [31:0] GPIO_HWDATA,
    input  wire [31:0] GPIO_HRDATA,
    output wire        GPIO_HWRITE,
    output wire        GPIO_HSEL,
    input  wire        GPIO_HREADY,
    
    // UART
    output wire [31:0] UART_HADDR,
    output wire [31:0] UART_HWDATA,
    input  wire [31:0] UART_HRDATA,
    output wire        UART_HWRITE,
    output wire        UART_HSEL,
    input  wire        UART_HREADY,
    
    // I2C
    output wire [31:0] I2C_HADDR,
    output wire [31:0] I2C_HWDATA,
    input  wire [31:0] I2C_HRDATA,
    output wire        I2C_HWRITE,
    output wire        I2C_HSEL,
    input  wire        I2C_HREADY,
    
    // Timer
    output wire [31:0] TIMER_HADDR,
    output wire [31:0] TIMER_HWDATA,
    input  wire [31:0] TIMER_HRDATA,
    output wire        TIMER_HWRITE,
    output wire        TIMER_HSEL,
    input  wire        TIMER_HREADY
);
    // 内部信号
    wire [3:0]  HMASTER;
    wire [31:0] HADDR, HWDATA;
    wire        HWRITE;
    wire [2:0]  HSIZE, HBURST;
    wire        HSEL_MEM, HSEL_GPIO, HSEL_UART, HSEL_I2C, HSEL_TIMER;
    
    // 仲裁器
    ahb_arbiter u_arbiter (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .M0_HBUSREQ(CPU_HBUSREQ), .M0_HGRANT(),
        .M1_HBUSREQ(1'b0),        .M1_HGRANT(),
        .HMASTER(HMASTER)
    );
    
    // 主设备多路选择器
    ahb_master_mux u_mux (
        .HMASTER(HMASTER),
        .M0_HADDR(CPU_HADDR), .M0_HWDATA(CPU_HWDATA),
        .M0_HWRITE(CPU_HWRITE), .M0_HSIZE(CPU_HSIZE), .M0_HBURST(CPU_HBURST),
        .M1_HADDR(32'h0), .M1_HWDATA(32'h0),
        .M1_HWRITE(1'b0), .M1_HSIZE(3'b010), .M1_HBURST(3'b000),
        .HADDR(HADDR), .HWDATA(HWDATA),
        .HWRITE(HWRITE), .HSIZE(HSIZE), .HBURST(HBURST)
    );
    
    // 地址译码器
    ahb_decoder u_decoder (
        .HADDR(HADDR),
        .HSEL_MEM(HSEL_MEM), .HSEL_GPIO(HSEL_GPIO),
        .HSEL_UART(HSEL_UART), .HSEL_I2C(HSEL_I2C), .HSEL_TIMER(HSEL_TIMER)
    );
    
    // 从设备信号分配
    assign MEM_HADDR   = HADDR;  assign MEM_HWDATA  = HWDATA;
    assign MEM_HWRITE  = HWRITE; assign MEM_HSEL    = HSEL_MEM;
    assign GPIO_HADDR  = HADDR;  assign GPIO_HWDATA = HWDATA;
    assign GPIO_HWRITE = HWRITE; assign GPIO_HSEL   = HSEL_GPIO;
    assign UART_HADDR  = HADDR;  assign UART_HWDATA = HWDATA;
    assign UART_HWRITE = HWRITE; assign UART_HSEL   = HSEL_UART;
    assign I2C_HADDR   = HADDR;  assign I2C_HWDATA  = HWDATA;
    assign I2C_HWRITE  = HWRITE; assign I2C_HSEL    = HSEL_I2C;
    assign TIMER_HADDR = HADDR;  assign TIMER_HWDATA= HWDATA;
    assign TIMER_HWRITE= HWRITE; assign TIMER_HSEL  = HSEL_TIMER;
    
    // 从设备读数据多路选择（带等待状态）
    assign CPU_HRDATA = HSEL_MEM   ? MEM_HRDATA   :
                        HSEL_GPIO  ? GPIO_HRDATA  :
                        HSEL_UART  ? UART_HRDATA  :
                        HSEL_I2C   ? I2C_HRDATA   :
                        HSEL_TIMER ? TIMER_HRDATA : 32'h0;
    
    assign CPU_HREADY = HSEL_MEM   ? MEM_HREADY   :
                        HSEL_GPIO  ? GPIO_HREADY  :
                        HSEL_UART  ? UART_HREADY  :
                        HSEL_I2C   ? I2C_HREADY   :
                        HSEL_TIMER ? TIMER_HREADY : 1'b1;
    
    assign CPU_HRESP = 2'b00; // OKAY

endmodule