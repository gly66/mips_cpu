`include "defines.v"

module MiniMIPS32(

    // 之前就有的信号
    input  wire                  cpu_clk_50M,
    input  wire                  cpu_rst_n,
    input  wire  [7:0]           int,
    
    // inst_rom
    input  wire [`INST_BUS]      inst, //inst读入的数据
    // TODO: 新加入的接口还没有在内部赋值
    input  wire                  inst_addr_ok, //TODO:
    input  wire                  inst_data_ok, //TODO:
    output wire [`INST_ADDR_BUS] iaddr, //指令存储器地址
    output wire                  inst_req, //指令申请

    //data_ram 
    input  wire [`WORD_BUS      ]   dm, //从存储器读出的数据
    input  wire                     data_addr_ok, //TODO:
    input  wire                     data_data_ok, //TODO:

    output wire                     data_req,//数据存储器申请
    output wire                     data_wr, //new 读or写
    output wire [1: 0]              data_size,//TODO: 将we信号替换为data_size信号
    // output wire [`BSEL_BUS      ]   we, //写存储器使能
    
    output wire [`INST_ADDR_BUS ]   daddr,//存储器访问地址
    output wire [`WORD_BUS      ]   din,//写入存储器的数据

    // Signals for debug
    output wire [31: 0] debug_wb_pc,
    output wire [3: 0]  debug_wb_rf_wen,
    output wire [4: 0]  debug_wb_rf_wnum,
    output wire [31: 0] debug_wb_rf_wdata
    );

    wire [`WORD_BUS      ] pc;
    wire [`EXC_CODE_BUS  ] if_exccode_o;
    wire [31:0]mem2wb_rdata;

    // ??????IF/ID????????????????D?????????? 
    wire [`WORD_BUS      ] id_pc_i;
    
    // ?????????Regfile?????????? 
    wire 				   re1;
    wire [`REG_ADDR_BUS  ] ra1;
    wire [`REG_BUS       ] rd1;
    wire 				   re2;
    wire [`REG_ADDR_BUS  ] ra2;
    wire [`REG_BUS       ] rd2; 
    
    //id stage ???????????????
    wire [`ALUOP_BUS     ] id_aluop_o;
    wire [`ALUTYPE_BUS   ] id_alutype_o;
    wire [`REG_BUS 	     ] id_src1_o;
    wire [`REG_BUS 	     ] id_src2_o;
    wire 				   id_wreg_o;
    wire [`REG_ADDR_BUS  ] id_wa_o;
    wire                   id_whilo_o;
    wire                   id_mreg_o;
    wire [`REG_BUS      ]  id_din_o;
    
    wire[`REG_ADDR_BUS] cp0_addr;
    wire[`INST_ADDR_BUS] id_pc_o;
    wire [`INST_ADDR_BUS ]       addr_misalign;
    wire id_in_delay_o;
    wire next_delay_o;
    wire[`EXC_CODE_BUS] id_exccode_o;
    
    //idexe_reg
    wire[`REG_ADDR_BUS] exe_cp0_addr;
    wire [`INST_ADDR_BUS] exe_pc;
    wire exe_in_delay;
    wire next_delay_o1;
    wire [`EXC_CODE_BUS] exe_exccode;
    
    
    // exe stage
    wire cp0_re_o;
    wire[`REG_ADDR_BUS] cp0_raddr_o;
    wire cp0_we_o;
    wire[`REG_ADDR_BUS] cp0_waddr_o;
    wire[`REG_BUS] cp0_wdata_o;  
    wire[`INST_ADDR_BUS] exe_pc_o; 
    wire exe_in_delay_o;
    wire[`EXC_CODE_BUS] exe_exccode_o;
    
    wire [`ALUOP_BUS     ] exe_aluop_i;
    wire [`ALUTYPE_BUS   ] exe_alutype_i;
    wire [`REG_BUS 	     ] exe_src1_i;
    wire [`REG_BUS 	     ] exe_src2_i;
    wire 				   exe_wreg_i;
    wire [`REG_ADDR_BUS  ] exe_wa_i;
    wire                   exe_whilo_i;
    wire                   exe_mreg_i;
    wire [`REG_BUS      ]  exe_din_i;


    wire [`REG_BUS 	     ] exe_hi_i;
    wire [`REG_BUS 	     ] exe_lo_i;
    
    wire [`ALUOP_BUS     ] exe_aluop_o;
    wire 				   exe_wreg_o;
    wire [`REG_ADDR_BUS  ] exe_wa_o;
    wire [`REG_BUS 	     ] exe_wd_o;
    wire                   exe_mreg_o;
    wire [`REG_BUS 		]  exe_din_o;
    wire                   exe_whilo_o;
    wire [`DOUBLE_REG_BUS]  exe_hilo_o;

    //exemem_reg
    wire mem_cp0_we;
    wire[`REG_ADDR_BUS] mem_cp0_waddr;
    wire[`REG_BUS] mem_cp0_wdata;
    wire[`INST_ADDR_BUS] mem_pc;
    wire mem_in_delay;
    wire[`EXC_CODE_BUS] mem_exccode;

    // mem stage
    wire cp0_we_o1;
    wire[`REG_ADDR_BUS] cp0_waddr_o1;
    wire[`REG_BUS] cp0_wdata_o1;
    wire[`REG_BUS] cp0_wdata_o2;
    wire[`INST_ADDR_BUS] cp0_pc;
    wire cp0_in_delay;
    wire[`EXC_CODE_BUS] cp0_exccode; 
    wire [`REG_BUS        ] badvaddr_i;
    
    
    wire [`ALUOP_BUS     ] mem_aluop_i;
    wire 				   mem_wreg_i;
    wire [`REG_ADDR_BUS  ] mem_wa_i;
    wire [`REG_BUS 	     ] mem_wd_i;
    wire                    mem_mreg_i;
    wire [`REG_BUS      ]   mem_din_i;
    wire                    mem_whilo_i;
    wire [`DOUBLE_REG_BUS]  mem_hilo_i;

    wire 				   mem_wreg_o;
    wire [`REG_ADDR_BUS  ] mem_wa_o;
    wire [`REG_BUS 	     ] mem_dreg_o;
    wire                    mem_mreg_o;
    wire [`DRESEL_BUS      ]  mem_dre_o;
    wire                    mem_whilo_o;
    wire [`DOUBLE_REG_BUS]  mem_hilo_o;
    
    wire 				   wb_wreg_i;
    wire [`REG_ADDR_BUS  ] wb_wa_i;
    wire [`REG_BUS       ] wb_dreg_i;
    wire                   wb_mreg_i;
    wire [`DRESEL_BUS      ] wb_dre_i;
    wire                   wb_whilo_i;
    wire [`DOUBLE_REG_BUS] wb_hilo_i;

    wire 				   wb_wreg_o;
    wire [`REG_ADDR_BUS  ] wb_wa_o;
    wire [`REG_BUS       ] wb_wd_o;
    wire                   wb_whilo_o;
    wire [`DOUBLE_REG_BUS] wb_hilo_o;
    
    //memwb_reg
    wire [`INST_ADDR_BUS ] mem_pc_o;
    wire wb_cp0_we;
	wire[`REG_ADDR_BUS] wb_cp0_waddr;
	wire[`REG_BUS] wb_cp0_wdata;
	
	//wb_stage
    wire cp0_we_o2;
    wire[`REG_ADDR_BUS] cp0_waddr_o2;
    // wire[`REG_BUS] cp_wdata_o2;
    wire [`INST_ADDR_BUS ] wb_pc_o;
    
    // //CP0
    // wire[`CP0_INT_BUS] int_i;
    
    wire flush;
    wire flush_im;
    wire[`REG_BUS] cp0_excaddr;
    wire[`REG_BUS] data_o;
    wire[`REG_BUS] status_o;
    wire[`REG_BUS] cause_o;
    
     // TODO: Declare the varieties between if&id
    // 4 or 5 need to be declared.
    wire [`INST_ADDR_BUS] jump_addr_1;
    wire [`INST_ADDR_BUS] jump_addr_2;
    wire [`INST_ADDR_BUS] jump_addr_3;
    wire [`JTSEL_BUS] jtsel;
    wire[`INST_ADDR_BUS] pc_plus_4;
    wire[`INST_ADDR_BUS] id_pc_plus_4;
    wire[`INST_ADDR_BUS] ret_addr;
    wire[`REG_BUS] exe_ret_addr;
    wire [`INST_ADDR_BUS ] wb_pc_i;

    // Add Stall signals
    wire             stallreq_id;
    wire             stallreq_exe;
    wire[`STALL_BUS] stall;
    wire                    mem_device;
    wire                    wb_device;
    wire                    mem_mem_flag;
    // wire                    timer_int_o;
    
    wire    ifid_inst_data_ok; 
    wire    idexe_inst_data_ok;
    wire    exemem_inst_data_ok; 
    wire    memcp0_inst_data_ok;
    wire [`EXC_CODE_BUS  ] id_exccode_i;
    wire                    mem_stop_wb;
    wire                   mem_msext_o;  //从存储器中取出的数据进行符号扩展or0扩展
    wire                   wb_msext_i;
    wire                   id_whi_o;
    wire                   id_wlo_o;
    wire                   mem_whi_o;
        wire                   mem_wlo_o;
       wire                   wb_whi_o;
    wire                   wb_wlo_o;

    if_stage if_stage0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .flush(flush), .cp0_excaddr(cp0_excaddr),
        .jump_addr_1(jump_addr_1),.jump_addr_2(jump_addr_2),
        .inst_addr_ok(inst_addr_ok), .inst_data_ok(inst_data_ok), .mem_mem_flag(mem_mem_flag),
        .jump_addr_3(jump_addr_3), .jtsel(jtsel),
        .pc_o(pc), .iaddr(iaddr), .pc_plus_4(pc_plus_4),
        .if_exccode_o(if_exccode_o),.inst_req(inst_req),
        .stall(stall),.inst_data_ok_o(ifid_inst_data_ok)
    );
    
    ifid_reg ifid_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .flush(flush),
        .if_pc(pc), .if_pc_plus_4(pc_plus_4),.if_exccode(if_exccode_o),
        .id_pc(id_pc_i), .id_pc_plus_4(id_pc_plus_4),
        .stall(stall),.id_exccode(id_exccode_i),
        .if_inst_data_ok(ifid_inst_data_ok), .id_inst_data_ok(idexe_inst_data_ok)
    );
// TODO: HERE!
    id_stage id_stage0(.cpu_rst_n(cpu_rst_n),
        .flush_im(flush_im),
        .id_in_delay_i(next_delay_o1),
        .id_pc_i(id_pc_i),
        .pc_plus_4(id_pc_plus_4), 
        .id_inst_i(inst),
        .rd1(rd1), .rd2(rd2),
        .exe2id_wa(exe_wa_o),
        .exe2id_wreg(exe_wreg_o),
        .exe2id_wd(exe_wd_o),
        .mem2id_wa(mem_wa_o),
        .mem2id_wreg(mem_wreg_o),
        .mem2id_wd(mem_dreg_o),
        .ret_addr(ret_addr),
        .exe2id_mreg(exe_mreg_o),
        .mem2id_mreg(mem_mreg_o),
        .stallreq_id(stallreq_id),
        .jump_addr_1(jump_addr_1),
        .jump_addr_2(jump_addr_2),
        .jump_addr_3(jump_addr_3),
        .jtsel(jtsel),
        .rreg1(re1), .rreg2(re2), 	  
        .ra1(ra1), .ra2(ra2), 
        
        .id_exccode_o(id_exccode_o),
        .id_pc_o(id_pc_o),
        .next_delay_o(next_delay_o),
        .cp0_addr(cp0_addr),
        .id_in_delay_o(id_in_delay_o),
        .id_aluop_o(id_aluop_o), .id_alutype_o(id_alutype_o),
        .id_src1_o(id_src1_o), .id_src2_o(id_src2_o),
        .id_wa_o(id_wa_o), .id_wreg_o(id_wreg_o),
        .id_whilo_o(id_whilo_o),.id_mreg_o(id_mreg_o),
        .id_din_o(id_din_o),
        .mem_mem_flag(mem_mem_flag),
        .id_exccode_i(id_exccode_i),
        .id_whi_o(id_whi_o), .id_wlo_o(id_wlo_o)
    );
    
    regfile regfile0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .we(wb_wreg_o), .wa(wb_wa_o), .wd(wb_wd_o),
        .re1(re1), .ra1(ra1), .rd1(rd1),
        .re2(re2), .ra2(ra2), .rd2(rd2)
    );
    wire                   exe_whi_i;
    wire                   exe_wlo_i;
    idexe_reg idexe_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n), 
        .flush(flush),
        .id_exccode(id_exccode_o), .id_pc(id_pc_o),
        .next_delay_i(next_delay_o), .id_cp0_addr(cp0_addr),
        .id_in_delay(id_in_delay_o),
        .id_alutype(id_alutype_o), .id_aluop(id_aluop_o),
        .id_src1(id_src1_o), .id_src2(id_src2_o),
        .id_wa(id_wa_o), .id_wreg(id_wreg_o),
        .id_whilo(id_whilo_o), .id_mreg(id_mreg_o),
        .id_din(id_din_o),
        .id_ret_addr(ret_addr),
        .stall(stall),
        .id_whi(id_whi_o), .id_wlo(id_wlo_o),
       
        .exe_exccode(exe_exccode), .exe_pc(exe_pc),
        .next_delay_o(next_delay_o1), .exe_cp0_addr(exe_cp0_addr),
        .exe_in_delay(exe_in_delay),
        .exe_alutype(exe_alutype_i), .exe_aluop(exe_aluop_i),
        .exe_src1(exe_src1_i), .exe_src2(exe_src2_i), 
        .exe_wa(exe_wa_i), .exe_wreg(exe_wreg_i),
        .exe_whilo(exe_whilo_i), .exe_mreg(exe_mreg_i),
        .exe_din(exe_din_i), .exe_ret_addr(exe_ret_addr),
        .exe_whi(exe_whi_i), .exe_wlo(exe_wlo_i),
        .id_inst_data_ok(idexe_inst_data_ok), .exe_inst_data_ok(exemem_inst_data_ok)
    );
    wire                   exe_whi_o;
    wire                   exe_wlo_o;
    exe_stage exe_stage0(.cpu_rst_n(cpu_rst_n), .cpu_clk_50M(cpu_clk_50M),
        .mem2exe_cp0_we(cp0_we_o1), .mem2exe_cp0_wa(cp0_waddr_o1), .mem2exe_cp0_wd(cp0_wdata_o1),
        .wb2exe_cp0_we(cp0_we_o2), .wb2exe_cp0_wa(cp0_waddr_o2), .wb2exe_cp0_wd(cp0_wdata_o2),
        .exe_exccode_i(exe_exccode), .exe_pc_i(exe_pc),
        .cp0_data_i(data_o),
        .cp0_addr_i(exe_cp0_addr), .exe_in_delay_i(exe_in_delay),
        .exe_alutype_i(exe_alutype_i), .exe_aluop_i(exe_aluop_i),
        .exe_src1_i(exe_src1_i), .exe_src2_i(exe_src2_i),
        .ret_addr(exe_ret_addr),
        .exe_wa_i(exe_wa_i), .exe_wreg_i(exe_wreg_i),
        .exe_mreg_i(exe_mreg_i), .exe_din_i(exe_din_i),
        .exe_whilo_i(exe_whilo_i),
        .exe_whi_i(exe_whi_i), .exe_wlo_i(exe_wlo_i),
        .hi_i(exe_hi_i), .lo_i(exe_lo_i),
        .mem2exe_whilo(mem_whilo_o),
        .mem2exe_hilo(mem_hilo_o),
        .wb2exe_whilo(wb_whilo_o),
        .wb2exe_hilo(wb_hilo_o),
        .stallreq_exe(stallreq_exe),
       .mem2exe_whi(mem_whi_o), .wb2exe_whi(wb_whi_o), .mem2exe_wlo(mem_wlo_o), .wb2exe_wlo(wb_wlo_o),
        .exe_exccode_o(exe_exccode_o), .exe_pc_o(exe_pc_o),
        .exe_in_delay_o(exe_in_delay_o),
        .cp0_re_o(cp0_re_o), .cp0_raddr_o(cp0_raddr_o),
        .cp0_we_o(cp0_we_o), .cp0_waddr_o(cp0_waddr_o),
        .cp0_wdata_o(cp0_wdata_o),
        .exe_aluop_o(exe_aluop_o),
        .exe_whi_o(exe_whi_o), .exe_wlo_o(exe_wlo_o),
        .exe_wa_o(exe_wa_o), .exe_wreg_o(exe_wreg_o), .exe_wd_o(exe_wd_o),
        .exe_mreg_o(exe_mreg_o), .exe_din_o(exe_din_o),
        .exe_whilo_o(exe_whilo_o), .exe_hilo_o(exe_hilo_o)
    );
        wire                   mem_whi_i;
        wire                   mem_wlo_i;
    exemem_reg exemem_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .flush(flush),
        .exe_exccode(exe_exccode_o), .exe_pc(exe_pc_o),
        .exe_in_delay(exe_in_delay_o),
        .exe_cp0_we(cp0_we_o), .exe_cp0_waddr(cp0_waddr_o),
        .exe_cp0_wdata(cp0_wdata_o),
        .exe_aluop(exe_aluop_o),
        .exe_wa(exe_wa_o), .exe_wreg(exe_wreg_o), .exe_wd(exe_wd_o),
        .exe_mreg(exe_mreg_o), .exe_din(exe_din_o),
        .exe_whilo(exe_whilo_o), .exe_hilo(exe_hilo_o),
        .exe_whi(exe_whi_o), .exe_wlo(exe_wlo_o),
       
        .mem_exccode(mem_exccode),
        .mem_pc(mem_pc),
        .mem_in_delay(mem_in_delay),
        .mem_cp0_we(mem_cp0_we),
        .mem_cp0_waddr(mem_cp0_waddr),
        .mem_cp0_wdata(mem_cp0_wdata),
        .mem_aluop(mem_aluop_i),
        .stall(stall),
        .mem_whi(mem_whi_i), .mem_wlo(mem_wlo_i),
        .mem_wa(mem_wa_i), .mem_wreg(mem_wreg_i), .mem_wd(mem_wd_i),
        .mem_mreg(mem_mreg_i), .mem_din(mem_din_i),
        .mem_whilo(mem_whilo_i), .mem_hilo(mem_hilo_i),
        .exe_inst_data_ok(exemem_inst_data_ok), .mem_inst_data_ok(memcp0_inst_data_ok)
    );
        
    mem_stage mem_stage0(.cpu_clk_50M(cpu_clk_50M),.cpu_rst_n(cpu_rst_n), .mem_aluop_i(mem_aluop_i),
        .mem_exccode_i(mem_exccode),
        .mem_pc_i(mem_pc),
        .mem_in_delay_i(mem_in_delay),
        .cp0_we_i(mem_cp0_we),
        .cp0_waddr_i(mem_cp0_waddr),
        .cp0_wdata_i(mem_cp0_wdata),
        .wb2mem_cp0_we(cp0_we_o2), .wb2mem_cp0_wa(cp0_waddr_o2), .wb2mem_cp0_wd(cp0_wdata_o2),
        .cp0_status(status_o), .cp0_cause(cause_o),
        .mem_wa_i(mem_wa_i), .mem_wreg_i(mem_wreg_i), .mem_wd_i(mem_wd_i),
        .mem_mreg_i(mem_mreg_i), .mem_din_i(mem_din_i),
        .mem_whilo_i(mem_whilo_i), .mem_hilo_i(mem_hilo_i),
        .mem_whi_i(mem_whi_i), .mem_wlo_i(mem_wlo_i),
        .data_addr_ok       (data_addr_ok   ),
        .data_data_ok       (data_data_ok   ),
        .data_req           (data_req       ),
        .data_wr            (data_wr        ),
        .data_size          (data_size      ),
        .mem_mem_flag       (mem_mem_flag   ),
        .mem_stop_wb        (mem_stop_wb    ),
        .cp0_exccode(cp0_exccode),
        .cp0_pc(cp0_pc),
        .cp0_in_delay(cp0_in_delay),
        .mem_msext_o(mem_msext_o),
        .cp0_we_o(cp0_we_o1),
        .cp0_waddr_o(cp0_waddr_o1),
        .cp0_wdata_o(cp0_wdata_o1),   
        .mem_whi_o(mem_whi_o), .mem_wlo_o(mem_wlo_o),    
        .mem_wa_o(mem_wa_o), .mem_wreg_o(mem_wreg_o), .mem_dreg_o(mem_dreg_o),
        .mem_mreg_o(mem_mreg_o), .dre(mem_dre_o),
        .mem_whilo_o(mem_whilo_o), .mem_hilo_o(mem_hilo_o),
        .dce(dce), .daddr(daddr), .we(we), .mem_pc_o(mem_pc_o), .din(din),.cp0_addr_disalign(addr_misalign)
    );
    wire                   wb_whi_i;
    wire                   wb_wlo_i;
    memwb_reg memwb_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .flush(flush),
        .mem_cp0_we(cp0_we_o1), .mem_cp0_waddr(cp0_waddr_o1), .mem_cp0_wdata(cp0_wdata_o1),
        .mem_wa(mem_wa_o), .mem_wreg(mem_wreg_o), .mem_dreg(mem_dreg_o),
        .mem_mreg(mem_mreg_o), .mem_dre(mem_dre_o), .mem_pc(mem_pc_o),
        .mem_stop_wb(mem_stop_wb),
        .mem_whi(mem_whi_o), .mem_wlo(mem_wlo_o),
        .dm(dm), 
        .wb_cp0_we(wb_cp0_we), .wb_cp0_waddr(wb_cp0_waddr), .wb_cp0_wdata(wb_cp0_wdata),
        .mem_whilo(mem_whilo_o), .mem_hilo(mem_hilo_o),
        .wb_wa(wb_wa_i), .wb_wreg(wb_wreg_i), .wb_dreg(wb_dreg_i),
        .wb_mreg(wb_mreg_i), .wb_dre(wb_dre_i),
         .wb_whi(wb_whi_i), .wb_wlo(wb_wlo_i),
        .wb_whilo(wb_whilo_i), .wb_hilo(wb_hilo_i),.wb_pc(wb_pc_i),
        .mem_msext(mem_msext_o),.wb_msext(wb_msext_i),.wb_rdata(mem2wb_rdata)
    );

    wb_stage wb_stage0(.cpu_rst_n(cpu_rst_n),
        .cp0_we_i(wb_cp0_we), .cp0_waddr_i(wb_cp0_waddr), .cp0_wdata_i(wb_cp0_wdata),
        .wb_wa_i(wb_wa_i), .wb_wreg_i(wb_wreg_i), .wb_dreg_i(wb_dreg_i),
        .wb_mreg_i(wb_mreg_i), .wb_dre_i(wb_dre_i),
        .wb_whilo_i(wb_whilo_i), .wb_hilo_i(wb_hilo_i), .dm(mem2wb_rdata),
        .wb_whi_i(wb_whi_i), .wb_wlo_i(wb_wlo_i),
        .wb_whi_o(wb_whi_o), .wb_wlo_o(wb_wlo_o), 
        .wb_msext_i(wb_msext_i),
        .cp0_we_o(cp0_we_o2), .cp0_waddr_o(cp0_waddr_o2), .cp0_wdata_o(cp0_wdata_o2),
        .wb_wa_o(wb_wa_o), .wb_wreg_o(wb_wreg_o), .wb_wd_o(wb_wd_o),
        .wb_whilo_o(wb_whilo_o), .wb_hilo_o(wb_hilo_o), .wb_pc_i(wb_pc_i), .wb_pc_o(wb_pc_o)
    );
    
    hilo hilo0(
        .cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .we_hi(wb_whi_o), .we_lo(wb_wlo_o),
        .we(wb_whilo_o), .hi_i(wb_hilo_o[63:32]),
        .lo_i(wb_hilo_o[31:0]), 
        .hi_o(exe_hi_i), .lo_o(exe_lo_i)
    );

    scu scu0(
        .cpu_rst_n(cpu_rst_n),
        .stallreq_id(stallreq_id),
        .stallreq_exe(stallreq_exe),
        .stall(stall),
        .i_stall(i_stall),
        .d_stall(d_stall)
    );
    
    cp0_reg cp0_reg0( .cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
      .exccode_i(cp0_exccode), .pc_i(cp0_pc), .in_delay_i(cp0_in_delay), 
      .re(cp0_re_o), .raddr(cp0_raddr_o),
      .we(cp0_we_o2), .waddr(cp0_waddr_o2), .wdata(cp0_wdata_o2),
      .int_i(int),
      .misalign_addr(addr_misalign),
      .inst_data_ok(memcp0_inst_data_ok),
      .flush(flush),
      .flush_im(flush_im),
      .cp0_excaddr(cp0_excaddr),
      .data_o(data_o),
      .status_o(status_o),
      .cause_o(cause_o)
    );

    assign debug_wb_pc = wb_pc_o;
    assign debug_wb_rf_wen = {{4{wb_wreg_o}}};
    assign debug_wb_rf_wnum = wb_wa_o;
    assign debug_wb_rf_wdata = wb_wd_o;
endmodule
