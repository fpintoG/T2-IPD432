`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Felipe Pinto Guzmán
// Module Name: dithering_module



module dithering_module #
    (
        bit_in = 8,        
        bit_out = 4
    )
    
    (
    //8 bit RGB pixels
    input logic [bit_in-1:0] R_in,
    input logic [bit_in-1:0] G_in,
    input logic [bit_in-1:0] B_in,
    
    input logic [2:0] pixel_col,
    input logic [2:0] pixel_row,
    
    //4 bits output    
    output logic [bit_out-1:0] R_out,
    output logic [bit_out-1:0] G_out,
    output logic [bit_out-1:0] B_out
    );
    
    //gets threshold value for 8x8 matix
    logic [5:0] thr_val;
    assign thr_val = {pixel_col[0] ^ pixel_row[0], pixel_row[0], pixel_col[1] ^ pixel_row[1], 
                      pixel_row[1], pixel_col[2] ^ pixel_row[2], pixel_row[2]};
    
    assign R_out = (R_in>>3 > thr_val) ? (R_in[7:4] + 4'd1) : R_in[7:4]; 
    assign G_out = (G_in>>3 > thr_val) ? (G_in[7:4] + 4'd1) : G_in[7:4]; 
    assign B_out = (B_in>>3 > thr_val) ? (B_in[7:4] + 4'd1) : B_in[7:4];                 
    
   
endmodule
