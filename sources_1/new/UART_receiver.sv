`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2019 05:39:23 AM
// Design Name: 
// Module Name: UART_receiver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_receiver(
    input logic clk,
    input logic rst,
    input logic data_valid,
    input logic [7:0] uart_data,
    output logic weA,
    output logic [23:0] output_data,
    output logic [17:0] addr
    );
    
    typedef enum logic [2:0] {IDLE, BYTE_R, BYTE_G, BYTE_B, NX_ADDR, WAITING, WRITE} state;
    state pr_state, nx_state;
    
    logic [23:0] output_data_reg;
    logic [1:0] byte_cnt;
    
    always_ff @(posedge clk) begin
        if (rst) pr_state <= IDLE;
        else pr_state <= nx_state;
    end
    
    always_comb begin
    
        nx_state = IDLE;
        case(pr_state)
            IDLE : if (data_valid) nx_state = BYTE_R;
                   else nx_state = IDLE;
            BYTE_R : nx_state =  WAITING;
            BYTE_G : nx_state =  WAITING;
            BYTE_B : nx_state = WRITE;
            WAITING : if ((byte_cnt == 2'd1) && data_valid) nx_state = BYTE_R;
                      else if ((byte_cnt == 2'd2) && data_valid) nx_state = BYTE_G;
                      else if ((byte_cnt == 2'd3) && data_valid) nx_state = BYTE_B;
                      else nx_state = WAITING;                          
            WRITE : if(addr == 18'd199999) nx_state = IDLE;
                    else nx_state =  NX_ADDR;
            NX_ADDR : nx_state = WAITING;
         endcase
            
    end   
    
    always_ff @(posedge clk) begin
        if (rst) begin
            addr <= '0;
            weA <= 0;
            byte_cnt <= '0;
            output_data_reg <= '0; 
        end
        else begin
            addr <= '0;
            weA <= 0;
            byte_cnt <= '0;
            output_data_reg <= output_data_reg;
            case (nx_state)
                BYTE_R : begin
                    output_data_reg[7:0] <= uart_data;    
                    byte_cnt <= 2'd2;
                    addr <= addr;
                end    
                BYTE_G : begin
                    output_data_reg[15:8] <= uart_data;    
                    byte_cnt <= 2'd3;
                    addr <= addr;
                end
                BYTE_B : begin
                    output_data_reg[23:16] <= uart_data;    
                    byte_cnt <= 2'd1;
                    addr <= addr;
                end
                WRITE : begin
                    weA <= 1'd1;
                    byte_cnt <= byte_cnt;
                    addr <= addr;
                end
                NX_ADDR : begin
                    addr <= addr + 18'd1;
                    byte_cnt <= byte_cnt;
                end 
                WAITING : begin
                    byte_cnt <= byte_cnt; 
                    addr <= addr;
                end                              
            endcase
        end
    end
        
    assign output_data = output_data_reg;
    
endmodule
