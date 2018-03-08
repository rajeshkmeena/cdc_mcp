`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2018 15:24:37
// Design Name: 
// Module Name: mcp_top
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

parameter BUS_LEN = 40; // BUS_LEN and DATA_LEN is same

module mcp_top( adatain, aclk, arst, asend, aready, bdata, bclk, brst, bvalid, bload);


input logic aclk, arst;
input logic [BUS_LEN-1:0] adatain;
input logic asend;
output aready;

//------------------------------------------------------------------------------------
  logic [BUS_LEN-1:0] adata;
  logic a_en, b_ack;
//-------------------------------------------------------------------------------------

input logic bclk,brst;
input logic bload;
output logic bvalid;
output logic [BUS_LEN-1:0]bdata;







mcp_send mcp1( adata, a_en, aready, b_ack, aclk, arst, asend, adatain);

mcp_recieve mcp2( bdata, bvalid, b_ack, a_en, adata, bload, bclk, brst);




endmodule
