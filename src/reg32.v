module reg32(
    input wire clk,
    input wire rst_n,
    input wire [31:0] D,
    output reg [31:0] Q
);

    always @(posedge clk) begin
        if (!rst_n)
            Q <= 32'd0;
        else
            Q <= D;
    end

endmodule