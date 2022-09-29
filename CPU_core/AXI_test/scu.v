`include "defines.v"

module scu(
    input wire cpu_rst_n,
    input wire stallreq_id,
    input wire stallreq_exe,
    input wire i_stall,
    input wire d_stall,
    output wire[`STALL_BUS] stall
    );

    assign stall = (cpu_rst_n == `RST_ENABLE) ? 4'b0000:
                   (stallreq_exe == `STOP) ? 4'b1111 : 
                   (stallreq_id == `STOP) ? 4'b0111 :  4'b0000;
                   //(i_stall == `STOP) ? 4'b0001:
                   //(d_stall == `STOP) ? 4'b1111:
                  



endmodule
