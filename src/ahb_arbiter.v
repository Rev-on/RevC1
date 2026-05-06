module ahb_arbiter (
    input wire        HCLK,
    input wire        HRESETn,
    input wire        M0_HBUSREQ,
    output wire       M0_HGRANT,
    input wire        M1_HBUSREQ,
    output wire       M1_HGRANT,
    output wire [3:0] HMASTER
);

    reg [1:0] current_master;

    assign HMASTER = {2'b00, current_master};

    // 固定优先级：M0 > M1
    assign M0_HGRANT = (current_master == 2'b00) || (current_master == 2'b11);
    assign M1_HGRANT = (current_master == 2'b01);

    always @(posedge HCLK) begin
        if (!HRESETn) begin
            current_master <= 2'b00;
        end else begin
            case (current_master)
                2'b00: if (!M0_HBUSREQ && M1_HBUSREQ) current_master <= 2'b01;
                2'b01: if (!M1_HBUSREQ && M0_HBUSREQ) current_master <= 2'b00;
                default: current_master <= 2'b00;
            endcase
        end
    end

endmodule
