`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2018 09:56:15
// Design Name: 
// Module Name: mcp
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



parameter DATA_LEN = 40;


//---------------------------------------------------------pulse_generator---------------


module pulse_gen(pulse,q,d,clk,n_reset);

input  logic clk,n_reset;
input  logic d;

logic d1,d2;
output logic pulse,q;

always_ff @ (posedge clk or negedge n_reset)

begin
 if(!n_reset)
    { q, d1, d2} <= 0;
 else
    {d1,d2,q} <= {d,d1,d2}; 

end
  
assign pulse = q ^ d2;


endmodule



//-----------------------------------------------asend_fsm---------------------

module asend_fsm(aready, asend, aack, a_clk, a_reset);

input logic a_clk,a_reset;
input logic asend,aack;
output logic aready;

enum logic {BUSY,READY} state,n_state;

always @ (posedge a_clk or negedge a_reset)
begin

 if(!a_reset)
 begin
   state <= READY;
   aready <= 1;
 end
 else
   begin
     
      case(state)
         READY: begin
              if(asend)
              begin
                state <= BUSY;
                aready <= 0;
              end
               else
               begin
               state <= READY;
               aready <= 1;
               end
               end
         BUSY:
             begin
               if(aack)
                begin
                  state <= READY;
                  aready <= 1;
                end
              else
                 begin
                   state <= BUSY;
                   aready <= 0;
                end
             end
     endcase 
     
   end   // begin of else
end      // always


//assign aready = state;

endmodule


//---------------------------Transmit DATA Sample Register--------------------------------------


module mcp_send ( adata, a_en, aready, b_ack, aclk, arst, asend, adatain);


input logic aclk, arst, asend;
input logic [DATA_LEN-1:0] adatain;
output logic aready, a_en;
output logic [DATA_LEN-1:0] adata;
input logic b_ack;

logic anxt_data;
logic aack,q;

// IMPORTANT :- Design used ACTIVE LOW reset 

//pulse_gen(pulse,q,d,clk,n_reset)

pulse_gen p1 (.pulse(aack), .q(q) , .d(b_ack), .clk(aclk), .n_reset(arst));


//asend_fsm(aready, asend, aack, a_clk, a_reset);

asend_fsm f1 (.aready(aready), .asend(asend), .aack(aack), .a_clk(aclk), .a_reset(arst));



//-------------------------------------------------------

assign anxt_data = aready & asend;

//--------------------------PULSE TOGGLING---------------
always_ff @ (posedge aclk or negedge arst)
begin
   if(!arst)
   a_en <= 0;
   else
     if(anxt_data)
        a_en <= ~ a_en;
end

//---------------------------------------------------------
always_ff @ (posedge aclk or negedge arst)
 begin
  if(!arst)
    adata <= 0;
  else
    if(anxt_data)
    adata <= adatain;
    
 end
 
 
endmodule 



///////////////////////////////////////////////////////----RECIEVING SIDE----////////////////////////////////////////////////////////////






module bload_fsm ( bvalid, b_en, bload, b_clk, b_reset);

input b_clk, b_reset;
input logic b_en,bload;

output logic bvalid;

enum logic { WAIT, READY} state;


always_ff @ (posedge b_clk or negedge b_reset)
begin

if(!b_reset)
begin
  state <= WAIT;
  bvalid <= 0;
 end
  else 
     begin 
        case(state) 
         
          WAIT: 
               if(b_en)
               begin
                 state <= READY;
                 bvalid <= 1 ; 
                end
                else
                begin
                 state <= WAIT;
                 bvalid <= 0;
                end
          READY:
               if(bload)
                  begin
                  state <= WAIT;
                  bvalid <= 0;
                  end
               else
                 begin
                 state <= READY;
                 bvalid = 1;
                 end             
         endcase
     
      end
          
end  // always

//assign bvalid = state;

endmodule



//------------------------------------------------------------RECIEVE DATA SAMPLE REGISTER---------------------------------------------------------------------------------

module mcp_recieve( bdata, bvalid, b_ack, a_en, adata, bload, bclk, brst);

input logic bclk,brst;
input logic a_en, bload;
input logic [DATA_LEN-1:0]adata;

output logic bvalid,b_ack;
output logic [DATA_LEN-1:0]bdata;

logic bload_data, b_en, q;

//------------------------------------------------------------------------------------

pulse_gen p2 (.pulse(b_en), .q(q) , .d(a_en), .clk(bclk), .n_reset(brst));

bload_fsm f2( .bvalid(bvalid), .b_en(b_en), .bload(bload), .b_clk(bclk), .b_reset(brst));

//-------------------------------------------------------------------------------------------

assign bload_data = bvalid & bload;

//------------------------------------------------------------------------------------------
 
 always_ff @ (posedge bclk or negedge brst)
 begin
 
 if(!brst)
    bdata <= 0;
 else
   if(bload_data)
     bdata <= adata;
     
 end

//--------------------------------------------------------------------------------------------
     
always_ff @ (posedge bclk or negedge brst)
begin
    if(!brst)
      b_ack <= 0;
    
    else
       if(bload_data)
         b_ack <= ~b_ack;
 
end         
       
endmodule



//========================================TOP MODULE========================================


