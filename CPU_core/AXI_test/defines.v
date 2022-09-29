`timescale 1ns / 1ps

/*------------------- ȫ�ֲ��� -------------------*/
`define RST_ENABLE      1'b0                // ��λ�ź���Ч  RST_ENABLE
`define RST_DISABLE     1'b1                // ��λ�ź���Ч
`define ZERO_WORD       32'h00000000        // 32λ����ֵ0
`define ZERO_DWORD      64'b0               // 64λ����ֵ0
`define WRITE_ENABLE    1'b1                // ʹ��д
`define WRITE_DISABLE   1'b0                // ��ֹд
`define READ_ENABLE     1'b1                // ʹ�ܶ�
`define READ_DISABLE    1'b0                // ��ֹ��
`define ALUOP_BUS       7 : 0               // ����׶ε����aluop_o�Ŀ���
`define SHIFT_ENABLE    1'b1                // ��λָ��ʹ�� 
`define ALUTYPE_BUS     2 : 0               // ����׶ε����alutype_o�Ŀ���  
`define TRUE_V          1'b1                // �߼�"��"  
`define FALSE_V         1'b0                // �߼�"��"  
`define CHIP_ENABLE     1'b1                // оƬʹ��  
`define CHIP_DISABLE    1'b0                // оƬ��ֹ  
`define WORD_BUS        31: 0               // 32λ��
`define DOUBLE_REG_BUS  63: 0               // ������ͨ�üĴ����������߿���
`define RT_ENABLE       1'b1                // rtѡ��ʹ��
`define SIGNED_EXT      1'b1                // ������չʹ��
`define IMM_ENABLE      1'b1                // ������ѡ��ʹ��
`define UPPER_ENABLE    1'b1                // ��������λʹ��
`define MREG_ENABLE     1'b1                // д�ؽ׶δ洢�����ѡ���ź�
`define BSEL_BUS        3 : 0               // ���ݴ洢���ֽ�ѡ���źſ���
`define PC_INIT         32'hBFC00000        // PC��ʼֵ
`define DRESEL_BUS      4:0                 //���洢�������źſ���

/*------------------- ָ���ֲ��� -------------------*/
`define INST_ADDR_BUS   31: 0               // ָ��ĵ�ַ����
`define INST_BUS        31: 0               // ָ������ݿ���

// ��������alutype
`define NOP             3'b000
`define ARITH           3'b001
`define LOGIC           3'b010
`define MOVE            3'b011
`define SHIFT           3'b100
`define JUMP            3'b101
`define PRIVILEGE       3'b110


// �ڲ�������aluop
`define MINIMIPS32_ADD             8'h01
`define MINIMIPS32_ADDI            8'h02
`define MINIMIPS32_ADDU            8'h03
`define MINIMIPS32_ADDIU           8'h04
`define MINIMIPS32_SUB             8'h05
`define MINIMIPS32_SUBU            8'h06
`define MINIMIPS32_SLT             8'h07
`define MINIMIPS32_SLTI            8'h08
`define MINIMIPS32_SLTU            8'h09
`define MINIMIPS32_SLTIU           8'h0A
`define MINIMIPS32_MULT            8'h0B
`define MINIMIPS32_MULTU           8'h0C
`define MINIMIPS32_AND             8'h0D
`define MINIMIPS32_ANDI            8'h0E
`define MINIMIPS32_LUI             8'h0F
`define MINIMIPS32_NOR             8'h10
`define MINIMIPS32_OR              8'h11
`define MINIMIPS32_ORI             8'h12
`define MINIMIPS32_XOR             8'h13
`define MINIMIPS32_XORI            8'h14
`define MINIMIPS32_SLL             8'h15
`define MINIMIPS32_SLLV            8'h16
`define MINIMIPS32_SRA             8'h17
`define MINIMIPS32_SRAV            8'h18
`define MINIMIPS32_SRL             8'h19
`define MINIMIPS32_SRLV            8'h1A
`define MINIMIPS32_MFHI            8'h1B
`define MINIMIPS32_MFLO            8'h1C
`define MINIMIPS32_MTHI            8'h1D
`define MINIMIPS32_MTLO            8'h1E
`define MINIMIPS32_LB              8'h1F
`define MINIMIPS32_LBU             8'h20
`define MINIMIPS32_LH              8'h21
`define MINIMIPS32_LHU             8'h22
`define MINIMIPS32_LW              8'h23
`define MINIMIPS32_SB              8'h24
`define MINIMIPS32_SH              8'h25
`define MINIMIPS32_SW              8'h26

`define MINIMIPS32_J               8'h27 //0010 0111
`define MINIMIPS32_JR              8'h28 //0010 1000
`define MINIMIPS32_JAL             8'h29 //0010 1001
`define MINIMIPS32_BEQ             8'h2A //0010 1010
`define MINIMIPS32_BNE             8'h2B //0010 1011


`define MINIMIPS32_DIV             8'h2C //0010 1100


`define MINIMIPS32_SYSCALL         8'h2D //0010 1101
`define MINIMIPS32_ERET            8'h2E //0010 1110
`define MINIMIPS32_MFC0            8'h2F //0010 1111
`define MINIMIPS32_MTC0            8'h30 //0011 0000

`define MINIMIPS32_BGTZ            8'h31
`define MINIMIPS32_BLEZ            8'h32
`define MINIMIPS32_BLTZ            8'h33
`define MINIMIPS32_BGEZ            8'h34
`define MINIMIPS32_BLTZAL          8'h35
`define MINIMIPS32_BGEZAL          8'h36
`define MINIMIPS32_JALR            8'h37

`define MINIMIPS32_DIVU            8'h38
`define MINIMIPS32_BREAK           8'h39


/*------------------- ͨ�üĴ����Ѳ��� -------------------*/
`define REG_BUS         31: 0               // �Ĵ������ݿ���
`define REG_ADDR_BUS    4 : 0               // �Ĵ����ĵ�ַ����
`define REG_NUM         32                  // �Ĵ�������32��
`define REG_NOP         5'b00000            // ��żĴ���

// Jump and Branch inst's define

`define JUMP_BUS 25:0 //J inst's index width
`define JTSEL_BUS 1:0 //select transfer addr

// STALL
`define STALL_BUS 3:0
`define STOP 1'b1
`define NOSTOP 1'b0

// DIV's parameters
`define DIV_FREE      2'b00
`define DIV_BY_ZERO   2'b01
`define DIV_ON        2'b10
`define DIV_END       2'b11
`define DIV_READY     1'b1
`define DIV_NOT_READY 1'b0
`define DIV_START     1'b1
`define DIV_STOP      1'b0


/*------------------- �쳣�������� -------------------*/
//CP0Э����������
`define CP0_INT_BUS   7:0
`define CP0_BADVADDR  8
`define CP0_STATUS     12
`define CP0_CAUSE     13
`define CP0_EPC       14
`define CP0_COUNT        9
`define CP0_COMPARE      11

//�쳣��������
`define EXC_CODE_BUS  4:0
`define EXC_INT       5'b00
`define EXC_SYS       5'h08
`define EXC_OV        5'h0c
`define EXC_NONE      5'h00010
`define EXC_ERET      5'h11
`define EXC_BREAK     5'h09           // Break�쳣�ı���
`define EXC_RI        5'h0a           // ����ָ���쳣�ı���
`define EXC_ADDR      32'hBFC00380
`define EXC_INT_ADDR  32'hBFC00380

`define NOFLUSH       1'b0
`define FLUSH         1'b1

`define InterruptAssert     1'b1
`define InterruptNotAssert  1'b0

`define EXC_ADEL            5'h04           // ���ػ�ȡָ��ַ���쳣�ı���
`define EXC_ADES            5'h05           // �洢��ַ���쳣�ı���


`define AXI_IDLE 3'b000
`define ARREADY  3'b001   // wait for arready
`define RVALID   3'b010   // wait for rvalid
`define RLAST    3'b011   // wait for rlast
`define AWREADY  3'b100   // wait for awready
`define WREADY   3'b101   // wair for wready     
`define BVALID   3'b110   // wait for bvalid

`define IF_READY 3'b000
`define IF_WAIT_ADDROK 3'b001
`define IF_WAIT_DATAOK 3'b010
`define IF_WAIT_ID  3'b011 
`define IF_WAIT_EXE  3'b100
`define IF_WAIT_MEM  3'b101 //当前取到指令后不立即取消阻塞，而是等到指令执行到mem阶段时
                             //如果指令不是访存指令，则继续取消阻塞，让流水线读入下一条指令

`define PC_NO_DELAY    2'b01
`define PC_IN_DELAY    2'b10