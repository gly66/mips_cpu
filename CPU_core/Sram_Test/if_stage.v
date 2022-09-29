`include "defines.v"

module if_stage ( 
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,

    // Inorder to support J and Branch inst
    input wire[`INST_ADDR_BUS] jump_addr_1,
    input wire[`INST_ADDR_BUS] jump_addr_2,
    input wire[`INST_ADDR_BUS] jump_addr_3,
    input wire[`JTSEL_BUS] jtsel,

    // ADD stall signal
    input wire[`STALL_BUS] stall,
    
    //异常处理
    input wire  flush,
    input wire[`INST_ADDR_BUS]  cp0_excaddr,
    
    output wire[`INST_ADDR_BUS] pc_plus_4,
    
    output  wire                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr
    );
    
    assign pc_plus_4=(cpu_rst_n==`RST_ENABLE) ? `PC_INIT : pc+4;

    wire [`INST_ADDR_BUS] pc_next; 

    assign pc_next=(jtsel==2'b00) ? pc_plus_4 :
                   (jtsel==2'b01) ? jump_addr_1 : //J,JAR
                   (jtsel==2'b10) ? jump_addr_3 : //JR
                   (jtsel==2'b11) ? jump_addr_2 : `PC_INIT; //BEQ, BNE

    reg ce;
    always @(posedge cpu_clk_50M) begin
        if(cpu_rst_n == `RST_ENABLE) begin
            ce <= `CHIP_DISABLE; 
        end else begin
            ce <= `CHIP_ENABLE;
        end
    end

    assign ice = (stall[1] == `TRUE_V || flush) ? 0 : ce; // when stall[1]!=0, can assess instr_rom


    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // ??????????????PC?????????MiniMIPS32???????0x00000000??
        else if (flush == `FLUSH) begin
            pc <= cp0_excaddr;                    // ??????????PC??????????4 	
        end
        // else begin
        //     if(flush == `TRUE_V)            //发生异常时，PC等于异常处理程序入口地址
        //         pc <= cp0_excaddr;
        else if(stall[0] == `NOSTOP) begin
            pc <= pc_next;
        end
        // end
    end
    
    // TODO???????????????????????????????????????????????????!!!
    assign iaddr = (ice == `CHIP_DISABLE) ? `PC_INIT : pc;    // ??锟??????????????


endmodule
