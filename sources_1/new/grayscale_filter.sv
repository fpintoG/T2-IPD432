`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Felipe Pinto Guzmán
// Module Name: grayscale_filter


//average filter implementation
//out = (max(r,g,b) - min(r,g,b))/2
module grayscale_filter(
    input logic [3:0] R_in,
    input logic [3:0] G_in,
    input logic [3:0] B_in,
    output logic [3:0] R_out,
    output logic [3:0] G_out,
    output logic [3:0] B_out
    );
    
    logic [3:0] max1, max2, min1, min2;
    
    assign max1 = (R_in > G_in) ? R_in : G_in;
    assign max2 = (max1 > B_in) ? max1 : B_in; 
     
    assign min1 = (R_in < G_in) ? R_in : G_in;
    assign min2 = (min1 < B_in) ? min1 : B_in;  
        
    assign R_out = (max2 + min2)>>1;
    assign G_out = (max2 + min2)>>1;
    assign B_out = (max2 + min2)>>1;
endmodule
