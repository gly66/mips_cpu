`include "defines.v"

module hilo(
    input wire                  cpu_clk_50M,
    input wire                  cpu_rst_n,
    
    //д�˿�
    input wire                  we,
    input wire              we_hi,
    input wire              we_lo,
    input wire [`REG_BUS    ]   hi_i,
    input wire [`REG_BUS    ]   lo_i,
    
    //���˿�
    output reg [`REG_BUS    ]  hi_o,
    output reg [`REG_BUS    ]  lo_o
    );
    
   always @(posedge cpu_clk_50M) begin
        if(cpu_rst_n == `RST_ENABLE) begin
            hi_o <= `ZERO_WORD;
            lo_o <= `ZERO_WORD;
        end
        else if(we == `WRITE_ENABLE) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
        else if(we_hi == `WRITE_ENABLE) begin
            hi_o <= hi_i;
        end
        else if(we_lo == `WRITE_ENABLE) begin
            lo_o <= lo_i;
        end
    end
endmodule
