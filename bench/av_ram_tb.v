/*
 * Copyright (C) 2019  Charley Picker <charleypicker@yahoo.com>
 * Copyright (c) 2014, 2016 Olof Kindgren <olof.kindgren@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and non-source forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in non-source form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS WORK IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * WORK, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module av_ram_tb;

   localparam MEMORY_SIZE = 1024;

   vlog_tb_utils vlog_tb_utils0();
   vlog_tap_generator #("av_ram.tap", 1) vtg();


   reg	   av_clk = 1'b1;
   reg	   av_rst = 1'b1;

   always #5 av_clk <= ~av_clk;
   initial  #100 av_rst <= 1'b0;

   wire    done;

   wire [aw-1:0]     av_address_i;
   wire [dw-1:0]     av_writedata_i;
   wire [(dw/8)-1:0] av_byteenable_i;
   wire [2:0]        av_burstcount_i;
   wire              av_write_i;
   wire              av_read_i;
   
   wire              av_waitrequest_o;
   wire [1:0]        av_response_o;
   wire [dw-1:0]     av_readdata_o;
   
   av_bfm_transactor
     #(.MEM_HIGH (MEMORY_SIZE-1),
       .AUTORUN (0),
       .VERBOSE (0))
   master
     (.av_clk_i (av_clk),
      .av_rst_i (av_rst),
      
      // Avalon Master interface
      .av_address_o    (av_address),
      .av_writedata_o  (av_writedata),
      .av_byteenable_o (av_byteenable),
      .av_burstcount_o (av_burstcount),
      .av_write_o      (av_write),
      .av_read_o       (av_read),
   
      .av_waitrequest_i(av_waitrequest),
      .av_response_i(av_response),
      .av_readdata_i(av_readdata),
      
      //Test Control
      .done     (done));

   av_ram
     #(.depth (MEMORY_SIZE))
   dut
     (.av_clk_i (av_clk),
      .av_rst_i (av_rst),
      
      // Avalon slave interface
      .av_address_i     (av_address[$clog2(MEMORY_SIZE)-1:0]),
      .av_writedata_i   (av_writedata),
      .av_byteenable_i  (av_byteenable),
      .av_burstcount_i  (av_burstcount),
      .av_write_i       (av_write),
      .av_read_i        (av_read),
   
      .av_waitrequest_o (av_waitrequest),
      .av_response_o    (av_response),
      .av_readdata_o    (av_readdata));

   integer 	 TRANSACTIONS;
   integer 	 SUBTRANSACTIONS;
   integer 	 SEED;

   initial begin
      //Grab CLI parameters
      if($value$plusargs("transactions=%d", TRANSACTIONS))
	master.set_transactions(TRANSACTIONS);
      if($value$plusargs("subtransactions=%d", SUBTRANSACTIONS))
	master.set_subtransactions(SUBTRANSACTIONS);
      if($value$plusargs("seed=%d", SEED))
	master.SEED = SEED;

      master.display_settings;
      master.run;
      master.display_stats;
   end

   always @(posedge done) begin
      vtg.ok("All tests complete");
      $display("All tests complete");
      $finish;
   end

endmodule
