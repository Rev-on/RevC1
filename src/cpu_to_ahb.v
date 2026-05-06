module cpu_to_ahb(
    input wire        clk,
    input wire        rst_n,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_wdata,
    output reg  [31:0] cpu_rdata,
    input wire        cpu_write,
    input wire        cpu_req,
    output reg        cpu_ready,
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    input wire [31:0] HRDATA,
    output reg        HWRITE,
    output reg [2:0]  HSIZE,
    output reg [2:0]  HBURST,
    output reg        HBUSREQ,
    input wire        HREADY,
    input wire [1:0]  HRESP
);

    localparam IDLE = 2'd0,
               REQ  = 2'd1,
               DONE = 2'd2;

    reg [1:0] state, next_state;
    reg [31:0] addr_reg, wdata_reg;
    reg write_reg;

    always @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (cpu_req) next_state = REQ;
            REQ:  if (HREADY)  next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            addr_reg  <= 32'd0;
            wdata_reg <= 32'd0;
            write_reg <= 1'b0;
        end else if (state == IDLE && cpu_req) begin
            addr_reg  <= cpu_addr;
            wdata_reg <= cpu_wdata;
            write_reg <= cpu_write;
        end
    end

    // AHB 输出
    always @(posedge clk) begin
        if (!rst_n) begin
            HBUSREQ <= 1'b0;
            HADDR   <= 32'd0;
            HWDATA  <= 32'd0;
            HWRITE  <= 1'b0;
            HSIZE   <= 3'b010;
            HBURST  <= 3'b000;
        end else begin
            HBUSREQ <= (state == REQ);
            HADDR   <= addr_reg;
            HWDATA  <= wdata_reg;
            HWRITE  <= write_reg;
        end
    end

    // CPU 回读与就绪
    always @(posedge clk) begin
        if (!rst_n) begin
            cpu_ready <= 1'b0;
            cpu_rdata <= 32'd0;
        end else begin
            cpu_ready <= (state == DONE);
            if (state == DONE)
                cpu_rdata <= HRDATA;
        end
    end

endmodule
