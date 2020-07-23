`timescale 1ps/1ps
//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module crg  #(
  string str_tag_header = "[crg]"
)(
  input  logic        clken    ,
  output logic        clk      ,
  output logic        resetn   
);

//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
localparam prm_DELAY = 1;
real clk_freq;
real clk_cycle;

//------------------------------------------------------------------------------
// Init
//------------------------------------------------------------------------------
initial begin
  if (! $value$plusargs("clk_freq=%d", clk_freq)) clk_freq = 100/*MHz*/;
  $display("%t ps, %s : set clock frequency -> clk_freq=%0d[MHz]", $time, str_tag_header, clk_freq);
  clk_cycle = (1/(clk_freq * 10e6/*Hz*/)) * 10e12/*ps*/;

  clk = 1'b1;
  forever begin
    #(clk_cycle/2) if (clken) clk = ~clk;
  end
end

initial resetn = 1'b1;

//------------------------------------------------------------------------------
// Tasks
//------------------------------------------------------------------------------
task set_clk_freq(input real i_clk_freq);
begin
  clk_freq = i_clk_freq;
  $display("%t ps, %s : set clock frequency -> clk_freq=%0d[MHz]", $time, str_tag_header, clk_freq);
  clk_cycle = (1/(clk_freq * 10e6/*Hz*/)) * 10e12/*ps*/;
end
endtask

task reset_assert();
begin
  @(negedge clk);
  resetn = 1'b0;
  $display("%t ps, %s : reset assert.", $time, str_tag_header);
end
endtask

task reset_deassert();
begin
  @(negedge clk);
  resetn = 1'b1;
  $display("%t ps, %s : reset deassert.", $time, str_tag_header);
end
endtask


endmodule
