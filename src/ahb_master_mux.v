module ahb_master_mux (
    input  wire [3:0]  HMASTER,
    
    // 主设备0
    input  wire [31:0] M0_HADDR,
    input  wire [31:0] M0_HWDATA,
    input  wire        M0_HWRITE,
    input  wire [2:0]  M0_HSIZE,
    input  wire [2:0]  M0_HBURST,
    
    // 主设备1
    input  wire [31:0] M1_HADDR,
    input  wire [31:0] M1_HWDATA,
    input  wire        M1_HWRITE,
    input  wire [2:0]  M1_HSIZE,
    input  wire [2:0]  M1_HBURST,
    
    // 输出到从设备
    output wire [31:0] HADDR,
    output wire [31:0] HWDATA,
    output wire        HWRITE,
    output wire [2:0]  HSIZE,
    output wire [2:0]  HBURST
);
    assign HADDR   = (HMASTER[1:0] == 2'b00) ? M0_HADDR   : M1_HADDR;
    assign HWDATA  = (HMASTER[1:0] == 2'b00) ? M0_HWDATA  : M1_HWDATA;
    assign HWRITE  = (HMASTER[1:0] == 2'b00) ? M0_HWRITE  : M1_HWRITE;
    assign HSIZE   = (HMASTER[1:0] == 2'b00) ? M0_HSIZE   : M1_HSIZE;
    assign HBURST  = (HMASTER[1:0] == 2'b00) ? M0_HBURST  : M1_HBURST;
endmodule