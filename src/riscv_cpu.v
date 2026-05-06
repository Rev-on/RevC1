// ============================================================
// Rev.on RISC-V CPU 内核 (riscv_cpu.v)
// 纯CPU逻辑：取指 + 译码 + 执行 + 写回
// 对外提供独立的取指接口和数据总线接口
// ============================================================

module riscv_cpu(
    input  wire        clk,
    input  wire        rst_n,
    
    // ===== 取指接口（独立于数据总线） =====
    output wire [31:0] pc_addr,
    input  wire [31:0] inst,
    
    // ===== 数据总线接口（原生，接入AHB适配器） =====
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    input  wire [31:0] mem_rdata,
    output wire        mem_write,
    output wire        mem_req,
    input  wire        mem_ready
);

    // =======================================================
    // PC 模块
    // =======================================================
    wire [31:0] pc_next;
    wire        jump_valid;
    wire [31:0] jump_addr;

    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .jump_valid(jump_valid),
        .jump_addr(jump_addr),
        .pc_addr(pc_addr)
    );

    // =======================================================
    // 立即数生成器
    // =======================================================
    wire [31:0] imm_val;

    imm_gen u_imm_gen (
        .p0(inst),
        .p1(imm_val)
    );

    // =======================================================
    // 控制器
    // =======================================================
    wire [3:0] alu_op;
    wire       reg_write;
    wire       alu_src;
    wire       mem_read;
    wire       mem_write_internal;
    wire       branch;
    wire       jump;
    wire       mem_to_reg;

    control u_control (
        .inst(inst),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write_internal),
        .branch(branch),
        .jump(jump),
        .mem_to_reg(mem_to_reg)
    );

    // =======================================================
    // 寄存器组
    // =======================================================
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] wb_data;

    register u_register (
        .clk(clk),
        .rst_n(rst_n),
        .inst(inst),
        .rd_data(wb_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // =======================================================
    // ALU 操作数选择
    // =======================================================
    wire [31:0] alu_b;

    mux32 u_mux_alu (
        .a(rs2_data),
        .b(imm_val),
        .en(alu_src),
        .out(alu_b)
    );

    // =======================================================
    // ALU
    // =======================================================
    wire [31:0] alu_result;
    wire        alu_zero;
    wire        alu_carry;

    alu32 u_alu (
        .a(rs1_data),
        .b(alu_b),
        .alu_op(alu_op),
        .res(alu_result),
        .zero(alu_zero),
        .carry(alu_carry)
    );

    // =======================================================
    // 写回数据选择（ALU结果 或 内存读数据）
    // =======================================================
    wire [31:0] mem_rdata_reg;
    
    // 暂存内存读回的数据
    reg [31:0] mem_rdata_buf;
    always @(posedge clk) begin
        if (!rst_n)
            mem_rdata_buf <= 32'd0;
        else if (mem_ready && mem_read)
            mem_rdata_buf <= mem_rdata;
    end

    // 修复：lui 指令写回立即数
    wire is_lui = (inst[6:0] == 7'b0110111);
    wire [31:0] lui_imm = {inst[31:12], 12'b0};
    wire [31:0] wb_data_fixed = is_lui ? lui_imm : 
                                (mem_to_reg ? mem_rdata_buf : alu_result);
    assign wb_data = wb_data_fixed;

    // =======================================================
    // 跳转控制
    // =======================================================
    // 简单的跳转逻辑：
    //   - JUMP:  总是跳转 (JAL, JALR)
    //   - BRANCH: 条件跳转，目前只支持 BEQ (等于时跳转)
    wire branch_taken = branch && alu_zero;

    assign jump_valid = jump || branch_taken;
    assign jump_addr  = pc_addr + imm_val;

    // =======================================================
    // 数据总线接口（内存访问）
    // =======================================================
    assign mem_addr  = alu_result;
    assign mem_wdata = rs2_data;
    assign mem_write = mem_write_internal;
    assign mem_req   = mem_read || mem_write_internal;

endmodule