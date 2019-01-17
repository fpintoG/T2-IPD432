`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Felipe Pinto Guzmán
// Module Name: color_scrambler



module color_scrambler(
    
    input logic [5:0] SW_cs,
    
    input logic [3:0] R_in,
    input logic [3:0] G_in,
    input logic [3:0] B_in,
    
    output logic [3:0] R_out,
    output logic [3:0] G_out,
    output logic [3:0] B_out
    
    );
    
    always_comb begin
        //set B output   
        case (SW_cs[1:0])
            2'b00: begin
                B_out = R_in;    
            end
            2'b01: begin
                B_out = G_in;
            end 
            2'b10: begin
                B_out = B_in;
            end
            default: begin
                B_out = 0;
            end 
        endcase 
 
         //set G output   
         case (SW_cs[3:2])
            2'b00: begin
                G_out = R_in;    
            end
            2'b01: begin
                G_out = G_in;
            end 
            2'b10: begin
                G_out = B_in;
            end
            default: begin
                G_out = 0;
            end 
        endcase 
         
         //set R output   
         case (SW_cs[5:4])
            2'b00: begin
                R_out = R_in;    
            end
            2'b01: begin
                R_out = G_in;
            end 
            2'b10: begin
                R_out = B_in;
            end
            default: begin
                R_out = 0;
            end 
        endcase                                             
    end
endmodule
