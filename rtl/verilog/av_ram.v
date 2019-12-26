/* ISC License
 *
 * Copyright (C) 2019  Charley Picker <charleypicker@yahoo.com>
 * Copyright (C) 2014, 2016 Olof Kindgren <olof.kindgren@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

module av_ram
 #(//Wishbone parameters
   parameter dw = 32,
   parameter burstw = 8,
   //Memory parameters
   parameter depth = 256,
   parameter aw    = $clog2(depth),
   parameter memfile = "")
  (input 	           av_clk_i,
   input 	           av_rst_i,

   input [aw-1:0]      av_address_i,
   input [dw-1:0]      av_writedata_i,
   input [(dw/8)-1:0]  av_byteenable_i,
   input [burstw-1:0]  av_burstcount_i,
   input               av_write_i,
   input               av_read_i,
   
   output reg 	       av_waitrequest_o,
   output [1:0]        av_response_o,
   output [dw-1:0]     av_readdata_o);

   `include "av_common.v"

    // Is there a valid request?
    wire valid = av_write_i | av_read_i;
    
    // Register valid request
    reg valid_r;
    always @(posedge av_clk_i) begin
        if (av_rst_i)
            valid_r <= 1'b0;
        else
            valid_r <= valid;
    end
    
    // Burst counter
    reg [2:0] burstcount;
    reg is_last_r;
    always @(posedge av_clk_i) begin
        if (av_rst_i) begin
            burstcount <= 2'b00;
            is_last_r <= 1'b0;
        end
        else begin
            // These are the only conditions when we load new burst request:
            // valid
            // burst count is zero
            // burst request greater than zero
            if (valid & (burstcount == 0) & (av_burstcount_i > 0) ) begin
                // In this case, we are the first and last cycle
                is_last_r <= 1'b1;
                
                burstcount <= av_burstcount_i;
            end
            else begin
                
            end
            
            
            else begin
                if (valid 
            end
            else begin
                // if count zero
                if ( (burstcount == 0) | (av_curstcount_i == 0) ) begin
                    is_last_r <= 1'b1;
                end 
                else begin
                    burstcount <= (burstcount - 1);
                end
            end
            // Last only occurs when classic or count
            if 
        end
    end
    
    // Is this a new cycle request?
    wire new_cycle = ( (valid & !valid_r) | is_last_r );
    
    // Was this a Classic or Burst cycle requested?
    wire [2:0] av_cti;
    assign av_cti = (|av_burstcount_i) ? CTI_INC_BURST : CTI_CLASSIC;
    
    
    // Calculate registered address
    // We only support linear burst type extension
    wire av_bte [1:0];
    assign av_bte = BTE_LINEAR; 
    reg [aw-1:0] adr_r; 
    assign next_adr = av_next_adr(adr_r, av_cti, BTE_LINEAR, dw);
    
    // Get current address
    wire [aw-1:0]  adr = new_cycle ? av_address_i : next_adr;
    
    // Register current address
    always@(posedge av_clk_i) begin
      adr_r   <= adr;     
      
      if(av_rst_i) begin
         adr_r <= {aw{1'b0}};
      end
    end
    
   // Acknowledge master
   always @(posedge av_clk_i) begin
        if (av_rst_i) av_waitrequest_o <= 1'b1;
        else          av_waitrequest_o <= 1'b0;

        // Only when starting a new cycle
        if (new_cycle)
            av_waitrequest_o <= 1'b0;
        else
            av_waitrequest_o <= 1'b1;
    end

   //TODO:ck for burst address errors
   assign av_response_o =  2'b0;

   // Commit results to and from generic ram memory
   wire ram_we = av_write_i & valid & (!av_waitrequest_o);
   
   av_ram_generic
     #(.depth(depth/4),
       .memfile (memfile))
   ram0
     (.clk (av_clk_i),
      .we  ({4{ram_we}} & av_byteenable_i),
      .din (av_writedata_i),
      .waddr(adr_r[aw-1:2]),
      .raddr (adr[aw-1:2]),
      .dout (av_readdata_o));

endmodule
