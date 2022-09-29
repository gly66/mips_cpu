`include "defines.v"

module wb_stage(
    input  wire                   cpu_rst_n,

    // �ӷô�׶λ�õ���Ϣ
	input  wire [`REG_ADDR_BUS  ] wb_wa_i,
	input  wire                   wb_wreg_i,
	input  wire [`REG_BUS       ] wb_dreg_i,
	input  wire                    wb_mreg_i,
	input  wire [`DRESEL_BUS     ]   wb_dre_i,
	input  wire                    wb_whilo_i,
	input  wire [`DOUBLE_REG_BUS]  wb_hilo_i,

    //�����ݴ洢������������
    input  wire [`WORD_BUS      ]   dm,
    input  wire                     device, 
    
    //�쳣����
    input wire cp0_we_i,
    input wire[`REG_ADDR_BUS] cp0_waddr_i,
    input wire[`REG_BUS] cp0_wdata_i,
    input  wire [`INST_ADDR_BUS ] wb_pc_i,
    
    output wire cp0_we_o,
    output wire[`REG_ADDR_BUS] cp0_waddr_o,
    output wire[`REG_BUS] cp0_wdata_o,
    
    // д��Ŀ�ļĴ���������
    output wire [`REG_ADDR_BUS  ] wb_wa_o,
	output wire                   wb_wreg_o,
    output wire [`WORD_BUS      ] wb_wd_o,
    output wire                     wb_whilo_o,
    output wire [`DOUBLE_REG_BUS]   wb_hilo_o,
    output wire [`INST_ADDR_BUS] wb_pc_o
    );
    
    //ֱ������CP0Э���������ź�
    assign cp0_we_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : cp0_we_i;
    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_waddr_i;
    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_wdata_i;
    
    assign wb_wa_o      = (cpu_rst_n == `RST_ENABLE) ? 5'b0 : wb_wa_i;
    assign wb_wreg_o    = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_wreg_i;
    assign wb_whilo_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_whilo_i;
    assign wb_hilo_o    = (cpu_rst_n == `RST_ENABLE) ? 64'b0 : wb_hilo_i;

    assign wb_pc_o = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT: wb_pc_i;
    
    //���ݶ��ֽ�ʹ���źţ������ݴ洢��������������ѡ���Ӧ���ֽ�
    wire [`WORD_BUS ] data = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                             (wb_dre_i == 5'b01111 & device) ? dm :
                             (wb_dre_i == 5'b01111 & !device ) ? {dm[7:0],dm[15:8],dm[23:16],dm[31:24]} :
                             (wb_dre_i == 5'b01000   ) ? {{24{dm[31]}},dm[31:24]} :
                             (wb_dre_i == 5'b11000   ) ? {24'b0,dm[31:24]} :
                             (wb_dre_i == 5'b00100   ) ? {{24{dm[23]}},dm[23:16]} :
                             (wb_dre_i == 5'b10100   ) ? {24'b0,dm[23:16]} :
                             (wb_dre_i == 5'b00010   ) ? {{24{dm[15]}},dm[15:8]} :
                             (wb_dre_i == 5'b10010   ) ? {24'b0,dm[15:8]} :
                             (wb_dre_i == 5'b00001   ) ? {{24{dm[7]}},dm[7:0]} :
                             (wb_dre_i == 5'b10001   ) ? {24'b0,dm[7:0]} :
                             (wb_dre_i == 5'b01100   ) ? {{16{dm[23]}},dm[23:16],dm[31:24]} :
                             (wb_dre_i == 5'b11100   ) ? {16'b0,dm[23:16],dm[31:24]}:
                             (wb_dre_i == 5'b00011   ) ? {{16{dm[7]}},dm[7:0],dm[15:8]} :
                             (wb_dre_i == 5'b10011   ) ? {16'b0,dm[7:0],dm[15:8]}: `ZERO_WORD;
                             
    //���ݴ洢�����Ĵ���ʹ���ź�mreg,ѡ�����մ�д��ͨ�üĴ���������
    assign wb_wd_o      = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                          (wb_mreg_i == `MREG_ENABLE) ? data : wb_dreg_i;
    
endmodule
