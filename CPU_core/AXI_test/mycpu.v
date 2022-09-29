module mycpu_top(
    input wire           [5:0] ext_int,
    input wire           aclk,
    input wire           aresetn,

    // output  wire         inst_sram_en,
    // output  wire [3:0]   inst_sram_wen,
    // output  wire [31:0]  inst_sram_addr,
    // output  wire [31:0]  inst_sram_wdata,
    // input   wire [31:0]  inst_sram_rdata,
    
    // output  wire         data_sram_en,
    // output  wire [3:0]   data_sram_wen,
    // output  wire [31:0]  data_sram_addr,
    // output  wire [31:0]  data_sram_wdata,
    // input   wire [31:0]  data_sram_rdata,
    //axi
    //ar 读请求通道 
    output wire [3 :0] arid         , //读请求ID号
    output wire [31:0] araddr       , //读请求地址
    output wire [7 :0] arlen        , //读请求控制信号，传输长度
    output wire [2 :0] arsize       , //读请求控制信号，传输大小
    output wire [1 :0] arburst      , //读请求控制信号，传输类型
    output wire [1 :0] arlock        ,//原子锁
    output wire [3 :0] arcache      , //cache属性
    output wire [2 :0] arprot       , // 保护属性
    output wire        arvalid      , // 握手信号，读请求地址有效
    input  wire        arready      , // 握手信号，slave准备好接受地址传输
    //r  读响应通道 
    input  wire [3 :0] rid          , //读请求ID 同一请求的arid与rid一致
    input  wire [31:0] rdata        , //读回数据
    input  wire [1 :0] rresp        , //读请求控制信号，读请求是否成功完成
    input  wire        rlast        , //读请求最后一拍数据的指示信号
    input  wire        rvalid       , //读请求数据有效
    output wire        rready       , //读请求握手信号，master端准备好接受数据传输
    //aw  写请求通道
    output wire [3 :0] awid         , // ID
    output wire [31:0] awaddr       , // 地址
    output wire [7 :0] awlen        , // 请求长度，拍数
    output wire [2 :0] awsize       , // 请求大小，每拍字节数
    output wire [1 :0] awburst      , // 传输类型
    output wire [1 :0] awlock       , // 原子锁
    output wire [3 :0] awcache      , // cache属性 
    output wire [2 :0] awprot       , // 保护属性
    output wire        awvalid      , // 写请求地址有效
    input  wire        awready      , // 写请求握手信号，slave端准备好接受地址传输
    //w   写数据通道
    output wire [3 :0] wid          , //ID
    output wire [31:0] wdata        , //写数据
    output wire [3 :0] wstrb        , //字节选择
    output wire        wlast        , // 最后一拍 1 
    output wire        wvalid       , // 握手信号，写请求数据有效
    input  wire        wready       , // 握手信号，slave端准备接受数据
    //b   写响应通道       
    input  wire [3 :0] bid          , //neglect
    input  wire [1 :0] bresp        , //neglect
    input  wire        bvalid       , //握手信号，写请求有效
    output wire        bready       , //握手信号，master端准备好接受写响应
    
    output  wire [31:0]  debug_wb_pc,
    output  wire [3 :0]  debug_wb_rf_wen,
    output  wire [4 :0]  debug_wb_rf_wnum,
    output  wire [31:0]  debug_wb_rf_wdata
);
// // 00d14
//     wire           ice;
//     wire           dce;
//     wire           i_stall;
//     wire           d_stall;
//     wire           longest_stall;
// //     wire timer_int;
//     wire           inst_sram_en;
//     assign         inst_sram_en = (aresetn == 1'b0) ? 1'b0 : ice;
//     wire [31:0]    inst_sram_rdata;
//     wire [31:0]    inst_sram_addr;


//     wire [3: 0]    we;
// //     assign inst_sram_wen = 4'b0000;
// //     assign inst_sram_wdata = 32'h00000000;

//     // wire [31:0] inst_sram_addr_v, data_sram_addr_v;
//     // wire [31:0] inst_sram_addr, data_sram_addr;
//     wire         data_sram_en;
//     assign       data_sram_en = (aresetn == 1'b0) ? 1'b0 : dce;
//     wire [31:0]  data_sram_rdata;
//     wire [31:0]  data_sram_addr;
//     wire [31:0]  data_sram_wdata;

    // inst sram-like
    wire        inst_req;
    wire        inst_wr; //0
    wire [1:0]  inst_size; // 10
    wire [31:0] inst_sram_addr_v; 
    wire [31:0] inst_addr;
    wire [31:0] inst_wdata; //0
    wire [31:0] inst_rdata;
    wire        inst_addr_ok;
    wire        inst_data_ok;
    // 指令存储器read only, 指令长为4 bytes, 写数据一直为0就行？
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_wdata = 32'h0000_0000;

    // data sram-like
    wire        data_req;
    wire        data_wr; 
    wire [1 :0] data_size; 
    wire [31:0] data_sram_addr_v;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        data_addr_ok;
    wire        data_data_ok;

// or use the d_sram_to_sram_like.v to avoid ok signal into MiniMIPS32
    MiniMIPS32 MiniMIPS32_0(
        .cpu_clk_50M(aclk),
        .cpu_rst_n(aresetn),
        .int(ext_int),

        // Inst 
        // input
        .inst(inst_rdata),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        // output 
        .inst_req(inst_req),
        .iaddr(inst_sram_addr_v), 

        // Data
        // Input 
        .dm(data_rdata),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        // output 
        .data_req(data_req),
        .data_wr(data_wr),
        .data_size(data_size),
        .daddr(data_sram_addr_v),
        .din(data_wdata),

        // Debug signalsda
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );
    
    mmu u0_mmu(
        .addr_i(inst_sram_addr_v),
        .addr_o(inst_addr)
    );

    mmu u1_mmu(
        .addr_i(data_sram_addr_v),
        .addr_o(data_addr)
    );

    cpu_axi_interface cpu_axi_interface0(
        .clk(aclk),
        .resetn(aresetn),

        // inst sram-like
        .inst_req(inst_req),
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr),
        .inst_wdata(inst_wdata),

        .inst_rdata(inst_rdata),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),

        // data sram-like
        .data_req(data_req),
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),
        .data_wdata(data_wdata),

        .data_rdata(data_rdata),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),

        // ar
        .arid(arid),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arlock(arlock),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),

        // r
        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),

        // aw
        .awid(awid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awlock(awlock),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),

        // w
        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),

        // b
        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );
    
endmodule