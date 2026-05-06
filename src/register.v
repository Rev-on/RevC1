module register(
    input wire clk,
    input wire rst_n,
    input wire [31:0] inst,
    input wire [31:0] rd_data,
    input wire reg_write,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] regs [0:31];

    wire [4:0] rs1_addr = inst[19:15];
    wire [4:0] rs2_addr = inst[24:20];
    wire [4:0] rd_addr  = inst[11:7];

    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else if (reg_write && rd_addr != 5'd0) begin
            regs[rd_addr] <= rd_data;
        end
    end

endmodule
