`include "defines.v"

module memwb_reg (
    input  wire                     cpu_clk_50M,
	input  wire                     cpu_rst_n,

	// 来自访存阶段的信息
	input  wire [`INST_ADDR_BUS ] mem_pc,
	input  wire [`REG_ADDR_BUS  ]   mem_wa,
	input  wire                     mem_wreg,
	input  wire [`REG_BUS       ] 	mem_dreg,
	input  wire                        mem_mreg,
	input  wire [`DRESEL_BUS         ]   mem_dre,
	input  wire                        mem_whilo,
	input  wire [`DOUBLE_REG_BUS   ]   mem_hilo,
	
	//异常处理
	input wire mem_cp0_we,
	input wire[`REG_ADDR_BUS] mem_cp0_waddr,
	input wire[`REG_BUS] mem_cp0_wdata,
	
	input wire flush,
	
	output reg wb_cp0_we,
	output reg[`REG_ADDR_BUS] wb_cp0_waddr,
	output reg[`REG_BUS] wb_cp0_wdata,

	// 送至写回阶段的信息 
	output reg  [`INST_ADDR_BUS ] wb_pc,

	output reg  [`REG_ADDR_BUS  ]   wb_wa,
	output reg                      wb_wreg,
	output reg  [`REG_BUS       ]   wb_dreg,
	output reg                      wb_mreg,
	output reg [`DRESEL_BUS         ] wb_dre,
	output reg                      wb_whilo,
	output reg [`DOUBLE_REG_BUS   ] wb_hilo,
	input wire    				  mem_device,
	output reg 				      wb_device 
    );

    always @(posedge cpu_clk_50M) begin
		// 复位的时候将送至写回阶段的信息清0
		if (cpu_rst_n == `RST_ENABLE || flush) begin
			wb_wa       <= `REG_NOP;
			wb_wreg     <= `WRITE_DISABLE;
			wb_dreg     <= `ZERO_WORD;
			wb_mreg     <= `WRITE_DISABLE;
	        wb_dre      <= 5'b0;
	        wb_whilo    <= `WRITE_DISABLE;
            wb_hilo     <= `ZERO_DWORD;
            wb_pc         <= `PC_INIT;
            wb_cp0_we <= `FALSE_V;
            wb_cp0_waddr <= `ZERO_WORD;
            wb_cp0_wdata <= `ZERO_WORD;
			wb_device     <= 1'b0;
		end
		// 将来自访存阶段的信息寄存并送至写回阶段
		else begin
			wb_wa 	    <= mem_wa;
			wb_wreg     <= mem_wreg;
			wb_dreg     <= mem_dreg;
			wb_mreg     <= mem_mreg;
	        wb_dre      <= mem_dre;
	        wb_whilo    <= mem_whilo;
            wb_hilo     <= mem_hilo;
            wb_pc         <= mem_pc;
            wb_cp0_we <= mem_cp0_we;
            wb_cp0_waddr <= mem_cp0_waddr;
            wb_cp0_wdata <= mem_cp0_wdata;
			wb_device     <= mem_device;
		end
	end

endmodule