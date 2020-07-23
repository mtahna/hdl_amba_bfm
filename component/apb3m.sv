`timescale 1ps/1ps
//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module abp3m #(
  string str_tag_header = "[apb3m]"
)(
  input  logic        pclk     ,
  input  logic        presetn  ,
  output logic        psel     ,
  output logic        penable  ,
  output logic        pwrite   ,
  output logic [31:0] paddr    ,
  output logic [31:0] pwdata   ,
  input  logic [31:0] prdata   ,
  input  logic        pready   ,
  input  logic        pslverr   
);

//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
localparam prm_DELAY = 1;

const string str_tag_write = {str_tag_header,"[write]"};
const string str_tag_read  = {str_tag_header,"[read ]"};
const string str_tag_rdmwr = {str_tag_header,"[rdmwr]"};
const string str_ok = "[OK]";
const string str_ng = "[NG]";
string state;

logic [31:0] tmp_wdata;
logic [31:0] tmp_rdata;

//------------------------------------------------------------------------------
// Init
//------------------------------------------------------------------------------
always @(posedge pclk or negedge presetn) begin
  if (~presetn) begin
    state = "";
    psel    <= 1'b0;
    penable <= 1'b0;
    pwrite  <= 1'b0;
    paddr   <= {32{1'b0}};
    pwdata  <= {32{1'b0}};
  end
end

//------------------------------------------------------------------------------
// Tasks
//------------------------------------------------------------------------------
task write32(
  input logic [31:0] i_addr ,
  input logic [31:0] i_wdata
);
begin
  @(posedge pclk);
  state = "w";
  psel    <= #(prm_DELAY) 1'b1;
  penable <= #(prm_DELAY) 1'b0;
  pwrite  <= #(prm_DELAY) 1'b1;
  paddr   <= #(prm_DELAY) i_addr;
  pwdata  <= #(prm_DELAY) i_wdata;

  @(posedge pclk);
  penable <= #(prm_DELAY) 1'b1;

  do @(posedge pclk); while (pready != 1'b1);
  if(pslverr != 1'b0) $display("%t ps, %s : detect!!! pslverr=%d", $time, str_tag_write, pslverr);
  psel    <= #(prm_DELAY) 1'b0;
  penable <= #(prm_DELAY) 1'b0;
  state = "";
end
endtask

task read32(
  input  logic [31:0] i_addr ,
  output logic [31:0] o_rdata
);
begin
  @(posedge pclk);
  state = "r";
  psel    <= #(prm_DELAY) 1'b1;
  penable <= #(prm_DELAY) 1'b0;
  pwrite  <= #(prm_DELAY) 1'b0;
  paddr   <= #(prm_DELAY) i_addr;

  @(posedge pclk);
  penable <= #(prm_DELAY) 1'b1;
  
  do @(posedge pclk); while (pready != 1'b1);
  o_rdata = prdata;
  if(pslverr != 1'b0) $display("%t ps, %s : detect!!! pslverr=%d", $time, str_tag_read, pslverr);
  psel    <= #(prm_DELAY) 1'b0;
  penable <= #(prm_DELAY) 1'b0;
  state = "";
end
endtask

task write32_display(
  input  logic [31:0] i_addr ,
  input  logic [31:0] i_wdata
);
begin
  write32(i_addr, i_wdata);
  $display("%t ps, %s : addr=0x%08x, wdata=0x%08x", $time, str_tag_write, i_addr ,i_wdata);
end
endtask

task read32_display(
  input  logic [31:0] i_addr
);
begin
  read32(i_addr, tmp_rdata);
  $display("%t ps, %s : addr=0x%08x, rdata=0x%08x", $time, str_tag_read, i_addr, tmp_rdata);
end
endtask

task read32_verify(
  input  logic [31:0] i_addr     ,
  input  logic [31:0] i_rdata_exp,
  input  logic [31:0] i_rdata_en  
);
begin
  string       str_sts;
  read32(i_addr, tmp_rdata);  
  if ((tmp_rdata & i_rdata_en) !== (i_rdata_exp & i_rdata_en))
    str_sts = str_ng; 
  else
    str_sts = str_ok;  
  $display("%t ps, %s : %s addr=0x%08x, rdata=0x%08x [exp=0x%08x, en=0x%08x]", $time, str_tag_read, str_sts, i_addr, tmp_rdata, i_rdata_exp, i_rdata_en);
end
endtask

task write32_rdmwr(
  input  logic [31:0] i_addr    ,
  input  logic [31:0] i_wdata   ,
  input  logic [31:0] i_wdata_en
);
begin
  read32(i_addr, tmp_rdata);
  tmp_wdata = (i_wdata & i_wdata_en) | (tmp_rdata & (~i_wdata_en));
  write32(i_addr, tmp_wdata);
  $display("%t ps, %s : addr=0x%08x, wdata=0x%08x [rdata=0x%08x, en=0x%08x]", $time, str_tag_rdmwr, i_addr ,tmp_wdata, tmp_rdata, i_wdata_en);
end
endtask

task read32_polling(
  input  logic [31:0] i_addr    ,
  input  logic [31:0] i_rdata   ,
  input  logic [31:0] i_rdata_en
);
begin
  $write("%t ps, %s : polling ! addr=0x%08x [rdata=0x%08x, en=0x%08x] ", $time, str_tag_rdmwr, i_addr ,i_rdata, i_rdata_en);
  do 
    begin 
      read32(i_addr, tmp_rdata);
      $write(".");
    end
  while ((tmp_rdata & i_rdata_en) != (i_rdata & i_rdata_en));
  $display(" done!");
end
endtask

endmodule
