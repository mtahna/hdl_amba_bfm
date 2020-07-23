`timescale 1ps/1ps

//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module scenario ();


//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// -- Instance -- DUT
//------------------------------------------------------------------------------
tbench tb();

//------------------------------------------------------------------------------
// TestScenario
//------------------------------------------------------------------------------
initial begin
  force tb.uaxi3m.awready    = 1;
  force tb.uaxi3m.wready     = 1;
  force tb.uaxi3m.bid        = 1;
  force tb.uaxi3m.bresp      = 1;
  force tb.uaxi3m.bvalid     = 1;
  force tb.uaxi3m.arready    = 1;
  force tb.uaxi3m.rid        = 1;
  force tb.uaxi3m.rresp      = 1;
  force tb.uaxi3m.rdata      = 32'h55555555;
  force tb.uaxi3m.rlast      = 1;
  force tb.uaxi3m.rvalid     = 1;
  force tb.uahblm.hrdata     = 32'hCCCCCCCC;
  force tb.uahblm.hreadyout  = 1;
  force tb.uahblm.hresp      = 1;
end

initial begin
  tb.ucrg.reset_assert();
  repeat(10) @(posedge tb.ucrg.clk);
  tb.ucrg.reset_deassert();
  repeat(10) @(posedge tb.ucrg.clk);

  tb.ucrg.set_clk_freq(100);
  repeat(10) @(posedge tb.ucrg.clk);


  tb.uaxi3m.write32_display(32'h00000000, 32'h55555555);
  tb.uaxi3m.read32_display (32'h00000000);
  tb.uaxi3m.read32_verify  (32'h00000000, 32'h55555555, 32'hFFFFFFFF);

  tb.uahblm.write32_display(32'h00000000, 32'h0000AAAA);
  tb.uahblm.read32_display (32'h00000000);
  tb.uahblm.read32_verify  (32'h00000000, 32'hCCCCCCCC, 32'hFFFFFFFF);

  tb.uapb3m.write32_display(32'h00000000, 32'h0000AAAA);
  tb.uapb3m.read32_display (32'h00000000);
  tb.uapb3m.read32_verify  (32'h00000000, 32'h0000AAAA, 32'hFFFFFFFF);

  $finish();
end

endmodule
