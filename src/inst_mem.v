module inst_mem(
    input wire clk,
    input wire [31:0] addr,
    output reg [31:0] inst
);

    reg [31:0] mem [0:1023];

    // 综合时忽略初始化，仿真时才读
    // synthesis translate_off
    initial begin
        $readmemh("firmware.hex", mem);
    end
    // synthesis translate_on

    always @(posedge clk) begin
        inst <= mem[addr[31:2]];
    end

endmodule
