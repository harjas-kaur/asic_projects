`timescale 1ns/1ps

module bridge_assertions(

    input logic clk,
    input logic res_n,

    // AXI Read Address Channel
    input logic arvalid,
    input logic arready,

    // AXI Write Address Channel
    input logic awvalid,
    input logic awready,

    // AXI Write Data Channel
    input logic wvalid,
    input logic wready,

    // AXI Write Response Channel
    input logic bvalid,
    input logic bready,

    // APB Interface
    input logic PENABLE,
    input logic PREADY,

    input logic PSEL1,
    input logic PSEL2,
    input logic PSEL3,
    input logic PSEL4

);

 
//  assertion1 : APB should remain idle during reset
 

property p_reset_idle;
    @(posedge clk)
    !res_n |-> !(PSEL1 || PSEL2 || PSEL3 || PSEL4);
endproperty

assert property(p_reset_idle)
else
    $error("APB active during reset");

 
//  assertion2 : Read Address Handshake
 

property p_ar_handshake;
    @(posedge clk)
    disable iff(!res_n)
    arvalid |-> ##[0:$] arready;
endproperty

assert property(p_ar_handshake)
else
    $error("ARVALID asserted but ARREADY never received");

 
//  assertion3 : Write Address Handshake
 

property p_aw_handshake;
    @(posedge clk)
    disable iff(!res_n)
    awvalid |-> ##[0:$] awready;
endproperty

assert property(p_aw_handshake)
else
    $error("AWVALID asserted but AWREADY never received");

 
//  assertion4 : Write Data Handshake
 

property p_w_handshake;
    @(posedge clk)
    disable iff(!res_n)
    wvalid |-> ##[0:$] wready;
endproperty

assert property(p_w_handshake)
else
    $error("WVALID asserted but WREADY never received");

 
//  assertion5 : APB Protocol Sequencing
 

property p_penable_requires_psel;
    @(posedge clk)
    disable iff(!res_n)
    PENABLE |-> (PSEL1 || PSEL2 || PSEL3 || PSEL4);
endproperty

assert property(p_penable_requires_psel)
else
    $error("PENABLE asserted without PSEL");

endmodule