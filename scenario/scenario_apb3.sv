`timescale 1ps/1ps

//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module scenario_apb3 ();


//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
//logic [2^12-1] VERI_TABLE;
//logic [2^12-1] REG_PORT_IO [31:0];


//------------------------------------------------------------------------------
// -- Instance -- DUT
//------------------------------------------------------------------------------
tbench_apb3 tb();


//------------------------------------------------------------------------------
// Reg Bit Field Map
//------------------------------------------------------------------------------
//assign REG_PORT_IO[][0]                    = uAPB3REG.SETSIG_16                ; // output        
//assign REG_PORT_IO[][0]                    = uAPB3REG.SETSIG_0                 ; // output        
//assign REG_PORT_IO[][0]                    = uAPB3REG.MONSIG_16                ; // output        
//assign REG_PORT_IO[][0]                    = uAPB3REG.MONSIG_0                 ; // output        
//assign REG_PORT_IO[][ 7:0]                 = uAPB3REG.SETMONREG0_32_24         ; // output [ 7:0] 
//assign REG_PORT_IO[][ 7:0]                 = uAPB3REG.uAPB3REG.SETMONREG0_23_16; // output [ 7:0] 
//assign uAPB3REG.uAPB3REG.SETMONREG0_15_8   = REG_PORT_IO[][ 7:0]               ; // input  [ 7:0] 
//assign uAPB3REG.SETMONREG0_7_0             = REG_PORT_IO[][ 7:0]               ; // input  [ 7:0] 
//assign REG_PORT_IO[][ 7:0]                 = uAPB3REG.SETMONREG1_32_24         ; // output [ 7:0] 
//assign REG_PORT_IO[][ 7:0]                 = uAPB3REG.SETMONREG1_23_16         ; // output [ 7:0] 
//assign uAPB3REG.SETMONREG1_15_8            = REG_PORT_IO[][ 7:0]               ; // input  [ 7:0] 
//assign uAPB3REG.SETMONREG1_7_0             = REG_PORT_IO[][ 7:0]               ; // input  [ 7:0] 

//------------------------------------------------------------------------------
// TestScenario
//------------------------------------------------------------------------------
initial begin
  tb.uclkrst.reset_assert();
  repeat(10) @(posedge tb.uclkrst.clk);
  tb.uclkrst.reset_deassert();
  repeat(10) @(posedge tb.uclkrst.clk);

  tb.uapb3m.write32_display(32'h00000000, 32'h0000AAAA);
  tb.uapb3m.read32_display (32'h00000000);
  tb.uapb3m.read32_verify  (32'h00000000, 32'h0000AAAA, 32'hFFFFFFFF);

  tb.uapb3m.write32_display(32'h00000000, 32'h00005555);
  tb.uapb3m.read32_display (32'h00000000);
  tb.uapb3m.read32_verify  (32'h00000000, 32'h00005555, 32'hFFFFFFFF);

  tb.uapb3m.write32_display(32'h00000004, 32'h00005555);
  tb.uapb3m.read32_display (32'h00000000);
  tb.uapb3m.read32_verify  (32'h00000004, 32'h00000000, 32'hFFFFFFFF);

  tb.uapb3m.write32_rdmwr  (32'h00000000, 32'h00000000, 32'h0000FFFF);
  tb.uapb3m.write32_rdmwr  (32'h00000000, 32'h0000FFFF, 32'h0000F0F0);
  tb.uapb3m.write32_rdmwr  (32'h00000000, 32'h0000FFFF, 32'h00000F0F);
  tb.uapb3m.write32_rdmwr  (32'h00000000, 32'h00005555, 32'h0000FF00);

  $finish();
end

endmodule
