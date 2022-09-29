`include "defines.v"
`define MEM_NOMEM 2'b00
`define MEM_WAIT_ADDR_OK 2'b01
`define MEM_WAIT_DATA_OK 2'b10

module mem_stage (
    input  wire                         cpu_clk_50M,
    input  wire                         cpu_rst_n,

    // ��ִ�н׶λ�õ���Ϣ
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS       ]       mem_din_i,
    input  wire                         mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS]       mem_hilo_i,
    input  wire                         mem_whi_i,
    input  wire                         mem_wlo_i,
    //�쳣����
    input wire cp0_we_i,
    input wire[`REG_ADDR_BUS] cp0_waddr_i,
    input wire[`REG_BUS ] cp0_wdata_i,
    input wire wb2mem_cp0_we,
    input wire[`REG_ADDR_BUS] wb2mem_cp0_wa,
    input wire[`REG_BUS] wb2mem_cp0_wd,
    
    input wire[`INST_ADDR_BUS] mem_pc_i,
    input wire mem_in_delay_i,
    input wire[`EXC_CODE_BUS] mem_exccode_i,

    input wire [`WORD_BUS] cp0_status,
    input wire[`WORD_BUS] cp0_cause,

    output wire cp0_we_o,
    output wire[`REG_ADDR_BUS] cp0_waddr_o,
    output wire[`REG_BUS] cp0_wdata_o,
    output wire                         mem_msext_o,
    
    output wire[`INST_ADDR_BUS] cp0_pc,
    output wire cp0_in_delay,
    output wire[`EXC_CODE_BUS] cp0_exccode, 
    output wire [`INST_ADDR_BUS ]       cp0_addr_disalign,
    
    // ����д�ؽ׶ε���Ϣ
    output wire [`INST_ADDR_BUS ]       mem_pc_o,  
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_mreg_o,
    output wire                         mem_whilo_o,
    output wire [`DOUBLE_REG_BUS]       mem_hilo_o,
    output wire                         mem_whi_o,
    output wire                         mem_wlo_o,
    output wire [`DRESEL_BUS       ]      dre,
    
    //�������ݴ洢�����ź�
    output wire                         dce,
    output wire [`INST_ADDR_BUS ]       daddr,
    output wire [`BSEL_BUS      ]       we,
    output wire [`REG_BUS       ]       din,
    output wire                         device,
    //�������ݴ洢�����ź�
    input  wire                         data_addr_ok,
    input  wire                         data_data_ok,

    output wire                         data_req,
    output wire                         data_wr,
    output wire [1:0]                   data_size,
    output wire                         mem_mem_flag,
    output wire                         mem_stop_wb
    );

    // �����ǰ���Ƿô�ָ���ֻ��Ҫ�Ѵ�ִ�н׶λ�õ���Ϣֱ�����
    assign mem_wa_o     = (cpu_rst_n == `RST_ENABLE) ? 5'b0 : mem_wa_i;
    assign mem_wreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_wreg_i;
    assign mem_dreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_wd_i;
    assign mem_mreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_mreg_i;
    assign mem_whilo_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_whilo_i;
    assign mem_hilo_o   = (cpu_rst_n == `RST_ENABLE) ? 64'b0 : mem_hilo_i;
    assign mem_whi_o    = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_whi_i;
    assign mem_wlo_o    = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_wlo_i;
    assign cp0_we_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : cp0_we_i;
    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_waddr_i;
    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_wdata_i;
    
    //ȷ����ǰ�ķô�ָ��
    
    wire inst_lb = (mem_aluop_i == `MINIMIPS32_LB);
    wire inst_lbu =(mem_aluop_i == `MINIMIPS32_LBU);
    wire inst_lh =(mem_aluop_i == `MINIMIPS32_LH); 
    wire inst_lhu =(mem_aluop_i == `MINIMIPS32_LHU);  
    wire inst_lw = (mem_aluop_i == `MINIMIPS32_LW);
    wire inst_sb = (mem_aluop_i == `MINIMIPS32_SB);
    wire inst_sh = (mem_aluop_i == `MINIMIPS32_SH);
    wire inst_sw = (mem_aluop_i == `MINIMIPS32_SW);

    wire inst_data = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lb | inst_lw | inst_sb | inst_sw | 
                                                            inst_lbu | inst_lh | inst_lhu | inst_sh);
    assign mem_msext_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : (inst_lbu | inst_lhu);
    
    //������ݴ洢���ķ��ʵ�ַ
    assign daddr = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : mem_wd_i;
    
    //������ݴ洢�����ֽ�ʹ���ź�
    assign dre[4] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                    (inst_lbu | inst_lhu);
    assign dre[3] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                    (((inst_lb | inst_lbu) & (daddr[1:0] == 2'b00)) | ((inst_lh | inst_lhu) & (daddr[1:0] == 2'b00)) | inst_lw);
    assign dre[2] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                    (((inst_lb | inst_lbu) & (daddr[1:0] == 2'b01)) | ((inst_lh | inst_lhu) & (daddr[1:0] == 2'b00)) | inst_lw);
    assign dre[1] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                    (((inst_lb | inst_lbu) & (daddr[1:0] == 2'b10)) | ((inst_lh | inst_lhu) & (daddr[1:0] == 2'b10)) | inst_lw);
    assign dre[0] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                    (((inst_lb | inst_lbu) & (daddr[1:0] == 2'b11)) | ((inst_lh | inst_lhu) & (daddr[1:0] == 2'b10)) | inst_lw);
    
    //������ݴ洢��ʹ���ź�
    assign dce = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                 (inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw);
                 
    //������ݴ�����д�ֽ�ʹ���ź�
    assign we            = (cpu_rst_n == `RST_ENABLE) ? 4'b0  :
                          ((mem_aluop_i == `MINIMIPS32_SB) & (mem_wd_i[1:0] == 2'b00)) ? 4'b1000 :
                          ((mem_aluop_i == `MINIMIPS32_SB) & (mem_wd_i[1:0] == 2'b01)) ? 4'b0100 :
                          ((mem_aluop_i == `MINIMIPS32_SB) & (mem_wd_i[1:0] == 2'b10)) ? 4'b0010 :
                          ((mem_aluop_i == `MINIMIPS32_SB) & (mem_wd_i[1:0] == 2'b11)) ? 4'b0001 :
                          ((mem_aluop_i == `MINIMIPS32_SH) & (mem_wd_i[1:0] == 2'b00)) ? 4'b1100 :
                          ((mem_aluop_i == `MINIMIPS32_SH) & (mem_wd_i[1:0] == 2'b10)) ? 4'b0011 :
                          ((mem_aluop_i == `MINIMIPS32_SW) & (cp0_exccode != `EXC_ADES)) ? 4'b1111 : 4'b0;
                    
    //ȷ����д�����ݴ洢��������
    wire [`WORD_BUS] din_byte    = {mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0]};
    //wire [`WORD_BUS] din_hw      = {mem_din_i[7:0], mem_din_i[15:8], mem_din_i[7:0], mem_din_i[15:8]};
    wire [`WORD_BUS] din_h = {mem_din_i[15:8], mem_din_i[7:0], mem_din_i[15:8], mem_din_i[7:0]};
    
    //�������費��Ҫת����С����
    //wire confreg = ((daddr & 32'hffff_0000) == 32'h1faf_0000);
    wire[2:0]  we_select  = {inst_sw , inst_sh , inst_sb};
    assign din = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                 (we_select == 3'b100) ? mem_din_i :
                 (we_select == 3'b010) ? din_h :
                 (we_select == 2'b001) ? din_byte : `ZERO_WORD;
    //CP0��STATUS�Ĵ�����CAUSE�Ĵ���������ֵ
    wire[`WORD_BUS] status;
    wire[`WORD_BUS] cause;
    
    //�ж��Ƿ�������CP0��������أ������CP0�Ĵ�������ֵ
    assign status = (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa == `CP0_STATUS) ? wb2mem_cp0_wd : cp0_status;
    assign cause =  (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa == `CP0_CAUSE) ? wb2mem_cp0_wd : cp0_cause;    
    
    wire r_misalign = (((inst_lh | inst_lhu) & (daddr[0] != 1'b0)) | (inst_lw & (daddr[1 : 0] != 2'b00))); //���ʵ�ַʱ������
    wire w_misalign = ((inst_sh & (daddr[0] != 1'b0)) | (inst_sw & (daddr[1 : 0] != 2'b00)));
    
    //�������뵽CP0Э���������ź�
    assign cp0_in_delay = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_in_delay_i;
    assign cp0_exccode = (cpu_rst_n == `RST_ENABLE) ? `EXC_NONE :
                          (((status[15 : 8] & cause[15 : 8]) != 8'h00) && status[1] == 1'b0 && status[0] == 1'b1) ? `EXC_INT :
                          (r_misalign == `TRUE_V) ? `EXC_ADEL :
                          (w_misalign == `TRUE_V) ? `EXC_ADES :
                          mem_exccode_i;
    assign cp0_addr_disalign = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                                (r_misalign | w_misalign) ? 
                                ((cp0_exccode == `EXC_ADEL) || (cp0_exccode == `EXC_ADES)) ? (daddr | 32'h8000_0000) : `ZERO_WORD :
                                (cp0_exccode == `EXC_ADEL) ? mem_pc_i 
                                 : `ZERO_WORD;
    assign cp0_pc = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : mem_pc_i;
    assign mem_pc_o = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT: mem_pc_i;

    // assign device = (daddr >= 32'hBFAFF000 & daddr <= 32'hBFAFFFFF);
    reg [1:0]        mem_state;
    wire             read_ram;

    reg             mem_mem_flag_reg;
    reg             mem_stop_wb_reg;    
    assign read_ram = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_data & (~w_misalign) & (~r_misalign));
    assign data_req = read_ram; 
    assign data_wr = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_sb | inst_sw | inst_sh);
    
    assign data_size = (cpu_rst_n == `RST_ENABLE) ? 2'b00 :
                       (inst_lb | inst_lw | inst_lbu | inst_lh | inst_lhu) ? 2'b10 :
                       inst_sb ? 2'b00 :
                       inst_sh ? 2'b01 :
                       inst_sw ? 2'b10 : 2'b00;
    assign mem_mem_flag = mem_mem_flag_reg;
    assign mem_stop_wb  = mem_stop_wb_reg;
    
    always @(posedge cpu_clk_50M) begin
        if(cpu_rst_n == `RST_ENABLE) begin
            mem_state <= `MEM_NOMEM;
            mem_mem_flag_reg <= 1'b0;
            mem_stop_wb_reg <= 1'b0;
        end
    else begin
        case (mem_state)
        `MEM_NOMEM:begin
            if(read_ram) begin
                mem_state <= `MEM_WAIT_DATA_OK;
                mem_mem_flag_reg <= 1'b1;
                mem_stop_wb_reg  <= 1'b1;
            end
        end 
        `MEM_WAIT_DATA_OK:begin
            if(data_data_ok)begin
                mem_state <= `MEM_NOMEM;
                mem_mem_flag_reg <= 1'b0;
                mem_stop_wb_reg  <= 1'b0;
            end
        end
        default: begin
            mem_state <= `MEM_NOMEM;
            mem_mem_flag_reg <= 1'b0;
            mem_stop_wb_reg  <= 1'b0;
        end 
        endcase
    end
end
endmodule