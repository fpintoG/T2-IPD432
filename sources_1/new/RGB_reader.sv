`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Felipe Pinto Guzmán
// Module Name: RGB_reader


module RGB_reader #(
    
    IMG_WIDTH = 500,
    IMG_HEIGHT = 400,
    SCREEN_WIDTH = 1024,
    SCREEN_HEIGHT = 768
   )    
    
    (
    input logic clk,
    input logic rst,
    input logic [23:0] ram_dout,
    input logic [10:0] ver_cnt,
    input logic [10:0] hor_cnt,
    output logic[17:0] ram_addr,
    output logic [7:0] R_out,
    output logic [7:0] G_out,
    output logic [7:0] B_out
    );

    typedef enum logic [2:0] {BACKGROUND, SYNC, DISPLAY_IMG, WAITING, NX_ADDR_IMG} state;
    state pr_state, nx_state; 
    
    logic [7:0] R_out_reg, G_out_reg, B_out_reg; 
    
    logic disp_en;
    assign disp_en =((hor_cnt>0) && (ver_cnt>0))? 1'd1 : 1'd0;
    
    always_ff @(posedge clk) begin
        if (rst) pr_state <= SYNC;
        else pr_state <= nx_state;
    end
    
    always_comb begin
        case (pr_state)
            SYNC : begin
                if (ver_cnt==11'd0 && hor_cnt==11'd0) nx_state = DISPLAY_IMG;
                else nx_state = SYNC;
            end
            DISPLAY_IMG : begin
                if (disp_en && ((hor_cnt < IMG_WIDTH+1) && (ver_cnt < IMG_HEIGHT+1))) nx_state = DISPLAY_IMG;
                else if (disp_en) nx_state = BACKGROUND;
                else nx_state = WAITING;
            end
            BACKGROUND : begin
                 if ((hor_cnt == SCREEN_WIDTH-1) && (ver_cnt == SCREEN_HEIGHT-1)) nx_state = SYNC;
                 else if (disp_en && (hor_cnt < IMG_WIDTH+1) && (ver_cnt < IMG_HEIGHT+1)) nx_state = DISPLAY_IMG;
                 else if (disp_en) nx_state = BACKGROUND;
                 else nx_state = WAITING;               
            end
            WAITING : if ((hor_cnt == SCREEN_WIDTH-1) && (ver_cnt == SCREEN_HEIGHT-1)) nx_state = SYNC;
                      else if (disp_en && (hor_cnt < IMG_WIDTH+1) && (ver_cnt < IMG_HEIGHT+1)) nx_state = DISPLAY_IMG;
                      else if (disp_en) nx_state = BACKGROUND; 
                      else nx_state = WAITING;  
            default : nx_state = SYNC;
        endcase           
    end
    
    always_ff @(posedge clk) begin
        
        R_out_reg <= 8'd255;
        G_out_reg <= 8'd255; 
        B_out_reg <= 8'd255;
        ram_addr <= ram_addr;
             
        case (nx_state)
            SYNC : begin
                ram_addr <= '0;
            end
            DISPLAY_IMG : begin
                R_out_reg <= ram_dout[7:0];
                G_out_reg <= ram_dout[15:8]; 
                B_out_reg <= ram_dout[23:16];
                ram_addr <= ram_addr + 18'd1;      
            end
        endcase      
    end
    
    assign {R_out, G_out, B_out} = (disp_en)? {R_out_reg, G_out_reg, B_out_reg}: {8'd0, 8'd0, 8'd0};   
endmodule
