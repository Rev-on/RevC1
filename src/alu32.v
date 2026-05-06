module alu32(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,
    output reg [31:0] res,
    output wire zero,
    output reg carry
);

    reg [32:0] sum;  // 33位中间结果，用于捕获进位

    always @(*) begin
        case(alu_op)
            // 加法
            4'b0000: sum = {1'b0, a} + {1'b0, b};
            // 减法
            4'b0001: sum = {1'b0, a} - {1'b0, b};
            // 逻辑运算无进位
            default: sum = 33'd0;
        endcase
    end

    always @(*) begin
        case(alu_op)
            4'b0000: begin {carry, res} = sum; end
            4'b0001: begin {carry, res} = sum; end
            4'b0010: begin res = a & b; carry = 1'b0; end
            4'b0011: begin res = a | b; carry = 1'b0; end
            4'b0100: begin res = a ^ b; carry = 1'b0; end
            4'b0101: begin res = a << b[4:0]; carry = 1'b0; end
            4'b0110: begin res = a >> b[4:0]; carry = 1'b0; end
            4'b0111: begin res = $signed(a) >>> b[4:0]; carry = 1'b0; end
            4'b1000: begin res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; carry = 1'b0; end
            default: begin res = 32'd0; carry = 1'b0; end
        endcase
    end

    assign zero = (res == 32'd0);

endmodule
