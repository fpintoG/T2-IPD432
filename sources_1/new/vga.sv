`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Felipe Pinto Guzmán
// Module Name: vga

module vga #
(
    //configuration for a 1024X768 pixels resolution and 75 HZ rfresh rate
    parameter h_pulse = 96,
    parameter h_bp = 176, 
    parameter h_pixels = 1024, 
    parameter h_fp = 16,
    parameter h_pol = 1,
    parameter v_pulse = 3, 
    parameter v_bp = 28,
    parameter v_pixels = 768,
    parameter v_fp = 1,
    parameter v_pol = 1
)
(
    input logic clk,
    input logic rst,
    output logic v_sync,
    output logic h_sync,
    output logic disp_ena,
    output logic [31:0] row,
    output logic [31:0] col,
    output logic n_blank,
    output logic n_sync
);
    
    localparam h_period = h_pulse + h_bp + h_pixels + h_fp;
    localparam v_period = v_pulse + v_bp + v_pixels + v_fp;
    
    //screen counters
    logic [31:0] h_count, v_count; 
    logic [31:0] next_h_count, next_v_count, next_col, next_row; 
    
    logic next_h_sync, next_v_sync, next_disp_ena;
    
    always_ff @( posedge clk ) begin
        //always the same output for this signals
        n_blank <= 1;
        n_sync <= 0;        
        
        if ( rst ) begin
            h_count <= 32'd0;
            v_count <= 32'd0;
            h_sync <= ~h_pol;
            v_sync <= ~v_pol;
            disp_ena <= 0;
            col <= 32'd0;
            row <= 32'd0;    
        end
        else begin
            h_count <= next_h_count;
            v_count <= next_v_count;
            h_sync <= next_h_sync;
            h_sync <= next_h_sync;
            col <= next_col;
            row <= next_row;
            disp_ena <= next_disp_ena;
        end    
    end
    
    always_comb begin
        //default values
        next_h_count = h_count + 1;
        next_v_count = v_count;
        next_h_sync = h_pol;
        next_v_sync = v_pol;
        next_col = col;
        next_row = row;
        next_disp_ena = disp_ena;

        
        if ( next_h_count == (h_period - 1) ) begin
            next_h_count = 32'd0;
            next_v_count = v_count + 1;
        end    
        
        if ( next_v_count == (v_period - 1) ) begin
            next_v_count = 32'd0;
        end 
        
        if ( (h_count < (h_pixels + h_fp)) || (h_count >= (h_pixels + h_fp + h_pulse))) 
        begin
            next_h_sync = ~h_pol;    
        end
        
        if ( (v_count < (v_pixels + v_fp)) || (v_count >= (v_pixels + v_fp + v_pulse))) 
        begin
            next_v_sync = ~v_pol;    
        end
        
        //set the cursor
        if ( h_count < h_pixels ) 
            next_col = h_count;
        
        if ( v_count < v_pixels )
            next_row = v_count;    
        
        //display time    
        if ( (h_count < h_pixels) && (v_count < v_pixels) )
            next_disp_ena = 1;               
    end

endmodule
