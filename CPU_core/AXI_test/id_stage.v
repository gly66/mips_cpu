`include "defines.v"

module id_stage(
    input  wire                     cpu_rst_n,
    // ��ȡָ�׶λ�õ�PCֵ
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // ��ָ��洢��������ָ����
    input  wire [`INST_BUS     ]    id_inst_i,

    // ��ͨ�üĴ����Ѷ��������� 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
    // ����ǰ�Ʋ��������ź�
    // ����ִ�����
    input wire exe2id_wreg,
    input wire[`REG_ADDR_BUS] exe2id_wa,
    input wire[`INST_BUS] exe2id_wd,
    // ����ô����
    input wire mem2id_wreg,
    input wire[`REG_ADDR_BUS] mem2id_wa,
    input wire[`INST_BUS] mem2id_wd,
    // SUPPORT J&B
    input wire[`INST_ADDR_BUS] pc_plus_4,

    // ADD stall signal
    input wire exe2id_mreg,
    input wire mem2id_mreg, // deal with the load suituation
    
    //�쳣����
    input wire id_in_delay_i,
    input wire flush_im,
    // ADD axi SIGNALS
    input  wire                     mem_mem_flag,
    input  wire [`EXC_CODE_BUS ]    id_exccode_i,
    
    output wire[`REG_ADDR_BUS] cp0_addr,
    output wire[`INST_ADDR_BUS] id_pc_o,
    output wire id_in_delay_o,
    output wire next_delay_o,
    output wire[`EXC_CODE_BUS] id_exccode_o,
    
    output wire stallreq_id, //stall request signal

    // SUPPORT J&B
    output wire[`INST_ADDR_BUS] jump_addr_1,
    output wire[`INST_ADDR_BUS] jump_addr_2,
    output wire[`INST_ADDR_BUS] jump_addr_3,
    output wire[`JTSEL_BUS] jtsel,
    output wire[`INST_ADDR_BUS] ret_addr,

    // ����ִ�н׶ε�������Ϣ
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire                     id_whilo_o,
    output wire                     id_mreg_o,
    output wire [`REG_BUS      ]    id_din_o,        
    output wire                     id_whi_o, //写hi寄存器（mthi）
    output wire                     id_wlo_o, //写lo寄存器（mtlo）     

    // ����ִ�н׶ε�Դ������1��Դ������2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // ������ͨ�üĴ����Ѷ˿ڵ�ʹ�ܺ͵�ַ
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2
    );
    
    //ֱ��������һ�׶ε��ź�
    assign id_pc_o = (cpu_rst_n == `RST_ENABLE)?`PC_INIT : id_pc_i;
    assign id_in_delay_o = (cpu_rst_n == `RST_ENABLE)?`FALSE_V : id_in_delay_i;
    
    
    // ����С��ģʽ��ָ֯����, ������Ѷ��flush_imΪ1����ȡ����ָ��Ϊ��ָ��
    //wire [`INST_BUS] id_inst = (flush_im == `FLUSH || mem_mem_flag == 1'b1)?`ZERO_WORD : {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};
wire [`INST_BUS] id_inst = (flush_im == `FLUSH || mem_mem_flag == 1'b1) ? `ZERO_WORD : id_inst_i;
    // ��ȡָ�����и����ֶε���Ϣ
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 
    
    //������Ѷ��flush_imΪ1����ȡ����ָ��Ϊ��ָ��

    /*-------------------- ��һ�������߼���ȷ����ǰ��Ҫ�����ָ�� --------------------*/
    wire inst_reg  =  ~|op;
    wire inst_regimm  = ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]& op[0];
    wire inst_add  = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_addi =  ~op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]& func[0];
    wire inst_addiu =  ~op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
    wire inst_sub = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_slt = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0];
    wire inst_slti =  ~op[5]&~op[4]& op[3]&~op[2]& op[1]&~op[0];
    wire inst_sltu = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]& func[0];
    wire inst_sltiu =  ~op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    wire inst_mult = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]&~func[0];
    wire inst_multu = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]& func[0];
    wire inst_and = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_andi =  ~op[5]&~op[4]& op[3]& op[2]&~op[1]&~op[0];
    wire inst_lui = ~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0];
    wire inst_nor = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]& func[0];
    wire inst_or = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0];
    wire inst_ori = ~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0];
    wire inst_xor = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
    wire inst_xori = ~op[5]&~op[4]& op[3]& op[2]& op[1]&~op[0];
    wire inst_sll = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];//��ʱ����nop
    wire inst_sllv = inst_reg&~func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_sra = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_srav = inst_reg&~func[5]&~func[4]&~func[3]& func[2]& func[1]& func[0];
    wire inst_srl = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_srlv = inst_reg&~func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_mthi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]& func[0];
    wire inst_mtlo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_lb =  op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lbu =  op[5]&~op[4]&~op[3]& op[2]&~op[1]&~op[0];
    wire inst_lh =  op[5]&~op[4]&~op[3]&~op[2]&~op[1]& op[0];
    wire inst_lhu =  op[5]&~op[4]&~op[3]& op[2]&~op[1]& op[0];
    wire inst_lw =  op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0];
    wire inst_sb =  op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sh =  op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
    wire inst_sw =  op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];

    wire inst_j = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
    wire inst_jal = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    wire inst_jr = inst_reg & ~func[5] & ~func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
    wire inst_beq= ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    wire inst_bne= ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
    wire inst_bgtz    = ~op[5]&~op[4]&~op[3]& op[2]& op[1]& op[0];
    wire inst_blez    = ~op[5]&~op[4]&~op[3]& op[2]& op[1]&~op[0];
    wire inst_bltz    = inst_regimm&~rt[4]&~rt[3]&~rt[2]&~rt[1]&~rt[0];
    wire inst_bgez    = inst_regimm&~rt[4]&~rt[3]&~rt[2]&~rt[1]& rt[0];
    wire inst_bltzal  = inst_regimm& rt[4]&~rt[3]&~rt[2]&~rt[1]&~rt[0];
    wire inst_bgezal  = inst_regimm& rt[4]&~rt[3]&~rt[2]&~rt[1]& rt[0];
    wire inst_jalr    = inst_reg&~func[5]&~func[4]& func[3]&~func[2]&~func[1]& func[0];

    wire inst_div = inst_reg & ~func[5] & func[4] & func[3] & ~func[2] & func[1] & ~func[0] ;
    wire inst_divu = inst_reg&~func[5]& func[4]& func[3]&~func[2]& func[1]& func[0];
    
    wire inst_syscall = inst_reg & ~func[5] & ~func[4] & func[3] & func[2] & ~func[1] & ~func[0];
    wire inst_eret = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & ~func[5] & func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
    wire inst_mfc0 =  ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & ~id_inst[23];
    wire inst_mtc0 = ~op[5] & op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] & id_inst[23];
    wire inst_break   = inst_reg&~func[5]&~func[4]& func[3]& func[2]&~func[1]& func[0];  
    /*------------------------------------------------------------------------------*/


    /*-------------------- �ڶ��������߼������ɾ�������ź� --------------------*/
        // ��������alutype
    assign id_alutype_o[2] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_sll | inst_sllv |
                             inst_sra | inst_srav | inst_srl | inst_srlv | inst_j | inst_jal | inst_jr | inst_beq | 
                             inst_bne | inst_syscall | inst_eret | inst_mtc0 |  inst_bgez | inst_bgtz | inst_blez | 
                             inst_bltz | inst_bltzal | inst_bgezal | inst_jalr);
    assign id_alutype_o[1] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_and | inst_andi |
                             inst_lui | inst_nor | inst_or | inst_ori | inst_xor |
                             inst_xori | inst_mfhi | inst_mflo | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0 | inst_break);
    assign id_alutype_o[0] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_add | inst_addi |
                             inst_addu | inst_addiu | inst_sub | inst_subu | inst_slt |
                             inst_slti | inst_sltu | inst_sltiu | inst_mfhi | inst_mflo |
                             inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw |
                             inst_sb | inst_sh | inst_sw | inst_j | inst_jal | inst_jr |
                              inst_beq | inst_bne | inst_mfc0 |  inst_bgez | inst_bgtz | inst_blez | 
                              inst_bltz | inst_bltzal | inst_bgezal | inst_jalr);

    // �ڲ�������aluop
    assign id_aluop_o[7]   = 1'b0;
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lbu | inst_lh | inst_lhu | inst_bgtz | inst_blez |
                             inst_lw | inst_sb | inst_sh | inst_sw | inst_j | inst_jal | inst_jr | inst_beq | inst_bne | 
                             inst_div | inst_syscall| inst_eret| inst_mfc0| inst_mtc0 | inst_bltz | inst_bgez | inst_bltzal | 
                             inst_bgezal | inst_jalr | inst_divu | inst_break);
    assign id_aluop_o[4]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_nor | inst_or | inst_ori |
                             inst_xor | inst_xori | inst_sll | inst_sllv | inst_sra | inst_srav |
                             inst_srl | inst_srlv | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo |
                             inst_lb| inst_mtc0 | inst_bgtz | inst_blez | inst_bltz | inst_bgez | 
                             inst_bltzal | inst_bgezal | inst_jalr | inst_divu);
    assign id_aluop_o[3]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_slti | inst_sltu | inst_sltiu |
                             inst_mult | inst_multu | inst_and | inst_andi | inst_lui | inst_srav |
                             inst_srl | inst_srlv | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo |
                             inst_lb | inst_jr | inst_jal | inst_beq | inst_bne | inst_div| inst_syscall| 
                             inst_eret| inst_mfc0 | inst_divu);
    assign id_aluop_o[2]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_addiu | inst_sub | inst_subu |
                             inst_slt | inst_multu | inst_and | inst_andi | inst_lui | inst_xori |
                             inst_sll | inst_sllv | inst_sra | inst_mflo | inst_mthi | inst_mtlo |
                             inst_lb | inst_sb | inst_sh | inst_sw | inst_j | inst_div| inst_syscall| 
                             inst_eret| inst_mfc0 | inst_bgez | inst_bltzal | inst_bgezal | inst_jalr | inst_break);
    assign id_aluop_o[1]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_addi | inst_addu | inst_subu |
                             inst_slt | inst_sltiu | inst_mult | inst_andi | inst_lui | inst_ori |
                             inst_xor | inst_sllv | inst_sra | inst_srlv | inst_mfhi | inst_mtlo |
                             inst_lb | inst_lhu | inst_lw | inst_sw | inst_j | inst_beq | inst_bne| 
                             inst_eret| inst_mfc0 | inst_blez | inst_bltz | inst_bgezal | inst_jalr | inst_break);
    assign id_aluop_o[0]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_add | inst_addu | inst_sub |
                             inst_slt | inst_sltu | inst_mult | inst_and | inst_lui | inst_or |
                             inst_xor | inst_sll | inst_sra | inst_srl | inst_mfhi | inst_mthi |
                             inst_lb | inst_lh | inst_lw | inst_sh | inst_j | inst_jal | inst_bne| 
                             inst_syscall| inst_mfc0 | inst_bgtz | inst_bltz | inst_bltzal | inst_jalr | inst_break);


    // child program call enable signal
    wire jal = (inst_jal | inst_bgezal | inst_bltzal);
    
    // дHILO�Ĵ���ʹ���ź�
    assign id_whilo_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_mult | inst_multu | inst_mthi | inst_mtlo | inst_div | inst_divu);
    // �洢�����Ĵ���ʹ���ź�
    assign id_mreg_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw);
    // дͨ�üĴ���ʹ���ź�
    assign id_wreg_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                       (inst_add | inst_addu| inst_addiu | inst_addi | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll | inst_or| inst_xor |
                       inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_jal | inst_mfc0 | inst_sltu | inst_slti | inst_sub | inst_andi |
                       inst_nor | inst_xori | inst_sllv | inst_sra | inst_srav | inst_srl | inst_srlv | inst_bgezal | inst_bltzal | inst_jalr | inst_lbu | inst_lh |
                       inst_lhu);
    // ��λʹ��ָ��
    wire shift = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_sll | inst_sra | inst_srl);
    // ������ʹ���ź�
    wire immsel = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_addi | inst_addiu | inst_slti | inst_sltiu |
                   inst_andi | inst_lui | inst_ori | inst_xori | inst_lb | inst_lbu | inst_lh |
                   inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw);
    // Ŀ�ļĴ���ѡ���ź�
    wire rtsel = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_addi | inst_addiu | inst_slti | inst_sltiu |
                  inst_andi | inst_lui | inst_ori | inst_xori | inst_lb | inst_lbu | inst_lh |
                  inst_lhu | inst_lw);
    // ������չʹ���ź�
    wire sext = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_addi | inst_addiu | inst_slti | inst_sltiu |
                 inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw);    
                                    
    // ���ظ߰���ʹ���ź�
    wire upper = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lui);
    
    // ���ָ����������������
    wire [31:0] imm_ext = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                           (upper == `UPPER_ENABLE ) ? (imm << 16):
                           (sext == `SIGNED_EXT    ) ? {{16{imm[15]}},imm} : {{16{1'b0}},imm}; 

    // ��ͨ�üĴ����Ѷ˿�1ʹ���ź�
    assign rreg1 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add |inst_addu| inst_slti | inst_addi | inst_subu | inst_slt | inst_and | inst_mult | inst_or|
                   inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_sub | inst_andi |
                   inst_jr | inst_beq | inst_bne | inst_div | inst_nor | inst_xor | inst_xori | inst_sllv |
                   inst_srav | inst_srlv | inst_sltu | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | 
                   inst_bgezal | inst_jalr | inst_divu | inst_multu | inst_mthi | inst_mtlo | inst_lbu | inst_lh | inst_lhu | inst_sh);
    // ��ͨ�üĴ����Ѷ��˿�2ʹ���ź�
    assign rreg2 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add | inst_addu |inst_subu | inst_slt | inst_and | inst_mult | inst_sll | inst_or| inst_sltu |
                   inst_sb | inst_sw | inst_beq | inst_bne | inst_div | inst_mtc0 | inst_sub | inst_nor | inst_xor | inst_sllv |
                   inst_srav | inst_srlv | inst_sra | inst_srl | inst_divu | inst_multu | inst_sh);

    wire [1:0] fwrd1;
    assign fwrd1 =(cpu_rst_n==`RST_ENABLE) ? 2'b00 :
                     (exe2id_wreg==`WRITE_ENABLE && exe2id_wa==ra1 && rreg1==`READ_ENABLE) ? 2'b01 :
                     (mem2id_wreg==`WRITE_ENABLE && mem2id_wa==ra1 && rreg1==`READ_ENABLE) ? 2'b10 :
                     (rreg1==`READ_ENABLE) ? 2'b11 : 2'b00;

    //只写hi寄存器和lo寄存器的使能
    assign id_whi_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : inst_mthi;
    assign id_wlo_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : inst_mtlo;

    wire [1:0] fwrd2;
    assign fwrd2 =(cpu_rst_n==`RST_ENABLE) ? 2'b00 : 
                     (exe2id_wreg==`WRITE_ENABLE && exe2id_wa==ra2 && rreg2==`READ_ENABLE) ? 2'b01 : 
                     (mem2id_wreg==`WRITE_ENABLE && mem2id_wa==ra2 && rreg2==`READ_ENABLE) ? 2'b10 :
                     (rreg2==`READ_ENABLE) ? 2'b11 : 2'b00; 
    /*------------------------------------------------------------------------------*/

    // ��ͨ�üĴ����Ѷ˿�1�ĵ�ַΪrs�ֶΣ����˿�2�ĵ�ַΪrt�ֶ�
    assign ra1   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rs;
    assign ra2   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rt;

    // ��ô�д��Ŀ�ļĴ����ĵ�ַ��rt��rd��
    assign id_wa_o      = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                          (rtsel == `RT_ENABLE || inst_mfc0 ) ? rt : 
                          (jal == `TRUE_V) ? 5'b11111 : rd;
                      
    // ���Դ������1�����shift�ź���Ч����Դ������1Ϊ��λλ��������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�1��õ�����
    // PLUS: ǰ������
    assign id_src1_o = (cpu_rst_n == `RST_ENABLE   ) ? `ZERO_WORD :
                       (shift == `SHIFT_ENABLE      ) ? {27'b0,sa} :
                       (fwrd1 == 2'b01) ? exe2id_wd :
                       (fwrd1 == 2'b10) ? mem2id_wd :
                       (fwrd1 == 2'b11) ? rd1 : `ZERO_WORD;

    // ���Դ������2�����immsel�ź���Ч����Դ������1Ϊ������������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�2��õ�����
    // PLUS: ǰ������
    assign id_src2_o = (cpu_rst_n == `RST_ENABLE   ) ? `ZERO_WORD :
                       (immsel == `IMM_ENABLE       ) ? imm_ext :
                       (fwrd2 == 2'b01) ? exe2id_wd : 
                       (fwrd2 == 2'b10) ? mem2id_wd :
                       (fwrd2 == 2'b11) ? rd2 : `ZERO_WORD;

    //��÷ô�׶�Ҫ�������ݴ洢�������ݣ�����ͨ�üĴ��������ݶ˿�2��
    // ���ڴ洢ָ��
    // ��Ϊ�洢ָ�������Ҳ����id�׶��õģ�����ҲҪ����ǰ��
    assign id_din_o  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                       (fwrd2 == 2'b01) ? exe2id_wd : 
                       (fwrd2 == 2'b10) ? mem2id_wd :
                       (fwrd2 == 2'b11) ? rd2 : `ZERO_WORD;

    wire equ = (cpu_rst_n==`RST_ENABLE) ? 1'b0 :
               (inst_beq) ? (id_src1_o == id_src2_o) :
               (inst_bne) ? (id_src1_o != id_src2_o) : 
               inst_bgtz ? $signed(id_src1_o) > $signed(0) :
                inst_blez ? $signed(id_src1_o) <= $signed(0) :
                 (inst_bgez | inst_bgezal) ? ~id_src1_o[31] :
                 (inst_bltz | inst_bltzal) ?  id_src1_o[31] : 1'b0;
               

    // generate jump address select signal
    assign jtsel[1] = inst_jalr | inst_jr | inst_beq & equ | inst_bne & equ | inst_bgez & equ | inst_bgtz & equ | inst_blez & equ | inst_bltz & equ | inst_bltzal & equ | inst_bgezal & equ;
    assign jtsel[0] = inst_j | inst_jal | inst_beq & equ | inst_bne & equ | inst_bgez & equ | inst_bgtz & equ | inst_blez & equ | inst_bltz & equ | inst_bltzal & equ | inst_bgezal & equ;

    // Those for transfer instructions
    wire [`INST_ADDR_BUS] pc_plus_8 = pc_plus_4 + 4;
    wire [`JUMP_BUS] instr_index = id_inst[25:0];
    wire [`INST_ADDR_BUS] imm_jump = {{14{imm[15]}},imm, 2'b00};

    // Get the final address
    assign jump_addr_1 = {pc_plus_4[31:28], instr_index, 2'b00};
    assign jump_addr_2 = pc_plus_4 + imm_jump;
    assign jump_addr_3 = id_src1_o;

    // Child program's return address
    assign ret_addr = pc_plus_8;
    
    assign stallreq_id = (cpu_rst_n == `RST_ENABLE ) ? `NOSTOP :
                         (((exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra1 && rreg1 == `READ_ENABLE) || 
                         (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra2 && rreg2 == `READ_ENABLE)) && (exe2id_mreg == `TRUE_V) ? `STOP :
                         (((mem2id_wreg == `WRITE_ENABLE &&mem2id_wa == ra1 && rreg1 == `READ_ENABLE)) ||
                         (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra2 &&  rreg2 == `READ_ENABLE)) && (mem2id_mreg == `TRUE_V)) ? `STOP : `NOSTOP;
                         
    //�ж���һ��ָ���Ƿ�Ϊ��֧��
    assign next_delay_o = (cpu_rst_n == `RST_ENABLE )?`FALSE_V:
                          (inst_j | inst_jr | inst_jal | inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal | inst_jalr);
    //�ж�����׶�ָ���Ƿ�����쳣���������쳣����
    assign id_exccode_o = (cpu_rst_n == `RST_ENABLE ) ?`EXC_NONE:
                            (id_aluop_o == 8'h00) ? `EXC_RI :
                          (inst_syscall == `TRUE_V)?`EXC_SYS:
                          (inst_break == `TRUE_V) ? `EXC_BREAK :
                          (inst_eret == `TRUE_V)?`EXC_ERET : id_exccode_i;
    //���cp0�Ĵ������ʵ�ַ
    assign cp0_addr = (cpu_rst_n == `RST_ENABLE )?`REG_NOP : rd;

endmodule
