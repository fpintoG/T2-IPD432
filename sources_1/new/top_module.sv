`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by Felipe Pinto Guzmán
// felipe.pinto.12@sansano.usm.cl
// UTFSM/ Module Name: top_module


module top_module(
    //100 MHZ clock
    input logic MCLK,
    input logic rst,
    
    input logic [1:0] SW_filt,
    input logic [5:0] SW_scram,
    
    input logic uart_rxd,
    //output logic uart_txd,
    
    //vga driver
    output logic v_sync,
    output logic h_sync,
    
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    
    output logic [15:0] LED
    
    );
    
    logic [7:0] uart_rx_axis_tdata;
    logic uart_rx_axis_tvalid;
    
    //clock signals
    logic VGA_CLK;
    logic locked;
    
    //dual port BRAM signals
    logic [17:0] BRAM_PORTA_addr, BRAM_PORTB_addr;
    logic [23:0] BRAM_PORTA_din, BRAM_PORTB_din;
    logic [23:0] BRAM_PORTA_dout, BRAM_PORTB_dout;
    logic BRAM_PORTA_we, BRAM_PORTB_we;
    
    //vga driver outputs
    logic [10:0] hc_visible, vc_visible;
    
    //read RGB signals from memory
    logic [7:0] R_read, G_read, B_read;
    //truncate RGB pixels with no dithering
    logic [3:0] R_trunc, G_trunc, B_trunc;
    //truncate RGB pixels using ordered dithering
    logic [3:0] R_dith, G_dith, B_dith;
    //apply grayscale filter
    logic [3:0] R_gray_in, G_gray_in, B_gray_in;
    logic [3:0] R_gray_out, G_gray_out, B_gray_out;
    //apply color scrambler
    logic [3:0] R_scram, G_scram, B_scram;
    
    //clock manager for the UART and VGA drivers        
  clk_wiz_0 instance_name
     (
      // Clock out ports
      .clk_out1(VGA_CLK),     // output clk_out1
      // Status and control signals
      .reset(!rst), // input reset
      .locked(locked),       // output locked
     // Clock in ports
      .clk_in1(MCLK));      // input clk_in1
    
    //UART RX
    rUART rUART_inst(
        .data_out( uart_rx_axis_tdata),   
        .data_valid(uart_rx_axis_tvalid),         
        .data_in(uart_rxd),                
        .reset(rst),              
        .clk(MCLK)      
    );
    
   //writes data from UART to Dual Port RAM
    UART_receiver(
    .clk(MCLK),
    .rst(!rst),
    .data_valid(uart_rx_axis_tvalid),
    .uart_data(uart_rx_axis_tdata),
    .weA(BRAM_PORTA_we),
    .output_data(BRAM_PORTA_din),
    .addr(BRAM_PORTA_addr)
    ); 
    
   
  assign BRAM_PORTB_we = 0;
  assign BRAM_PORTB_din = '0;
  //assign BRAM_PORTA_dout = '0;
  blk_mem_gen_0 dual_port_BRAM (
          .clka(MCLK),    // input wire clka
          .wea(BRAM_PORTA_we),      // input wire [0 : 0] wea
          .addra(BRAM_PORTA_addr),  // input wire [17 : 0] addra
          .dina(BRAM_PORTA_din),    // input wire [23 : 0] dina
          .douta(BRAM_PORTA_dout),  // output wire [23 : 0] douta
          
          .clkb(VGA_CLK),    // input wire clkb
          .web(BRAM_PORTB_we),      // input wire [0 : 0] web
          .addrb(BRAM_PORTB_addr),  // input wire [17 : 0] addrb
          .dinb(BRAM_PORTB_din),    // input wire [23 : 0] dinb
          .doutb(BRAM_PORTB_dout)  // output wire [23 : 0] doutb
  );
  //assign LED = BRAM_PORTA_dout[15:0];
  
  RGB_reader rgb_reader(
        .clk(VGA_CLK),
        .rst(!rst),
        .ram_dout(BRAM_PORTB_dout),
        .ver_cnt(vc_visible),
        .hor_cnt(hc_visible),
        .ram_addr(BRAM_PORTB_addr),
        .R_out(R_read),
        .G_out(G_read),
        .B_out(B_read)
   );
   
   
   dithering_module dithering_module       
   (
       //8 bit RGB pixels
       .R_in(R_read),
       .G_in(G_read),
       .B_in(B_read),
       
       .pixel_col(hc_visible[2:0]),
       .pixel_row(vc_visible[2:0]),
      
       .R_out(R_dith),
       .G_out(G_dith),
       .B_out(B_dith)
    );
  
   assign R_gray_in =  SW_filt[0] ?  R_dith : R_read[7:4];
   assign G_gray_in =  SW_filt[0] ?  G_dith : G_read[7:4];
   assign B_gray_in =  SW_filt[0] ?  B_dith : B_read[7:4];
   
   grayscale_filter grayscale_filter(
      .R_in(R_gray_in),
      .G_in(G_gray_in),
      .B_in(B_gray_in),
      .R_out(R_gray_out),
      .G_out(G_gray_out),
      .B_out(B_gray_out)
    );
    
  assign R_scram = SW_filt[1] ?  R_gray_out: R_gray_in;
  assign G_scram = SW_filt[1] ?  G_gray_out: G_gray_in;
  assign B_scram = SW_filt[1] ?  B_gray_out: B_gray_in;
  
  color_scrambler color_scrambler(
      .SW_cs(SW_scram),
      .R_in(R_scram),
      .G_in(G_scram),
      .B_in(B_scram),
      .R_out(VGA_R),
      .G_out(VGA_G),
      .B_out(VGA_B)
  );
  
  driver_vga(
      .clk_vga(VGA_CLK),  // 78.8 MHz !
      .hs(h_sync), 
      .vs(v_sync), 
      .hc_visible(hc_visible),
      .vc_visible(vc_visible) 
      );
    
endmodule
