`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	// ����ȡָ�׶ε���Ϣ  
	input  wire [`INST_ADDR_BUS]       if_pc,

	input wire[`INST_ADDR_BUS] if_pc_plus_4,

	// ADD stall signal
	input wire[`STALL_BUS] stall,
	
	input wire flush,

	output reg[`INST_ADDR_BUS] id_pc_plus_4,
	
	// ��������׶ε���Ϣ  
	output reg  [`INST_ADDR_BUS]       id_pc
	);

	always @(posedge cpu_clk_50M) begin
	    // ��λ�������ˮ��ʱ����������׶ε���Ϣ��0
		if (cpu_rst_n == `RST_ENABLE || flush) begin
			id_pc 	<= `PC_INIT;
			id_pc_plus_4 <= `PC_INIT;
		end 
		
		else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
			id_pc <= `ZERO_WORD;
			id_pc_plus_4 <= `ZERO_WORD;
		end
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
		else if(stall[1] == `NOSTOP) begin
			id_pc	<= if_pc;		
			id_pc_plus_4 <= if_pc_plus_4;
		end
		
	end

endmodule