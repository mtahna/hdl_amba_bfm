`timescale 1ps/1ps
//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module ahblm #(
  string str_tag_header = "[ahblm]"
)(
  input  logic        hclk      ,
  input  logic        hresetn   ,
  output logic        hselx     ,
  output logic [31:0] haddr     ,
  output logic [1:0]  htrans    ,
  output logic        hwrite    ,
  output logic [2:0]  hsize     ,
  output logic [2:0]  hburst    ,
  output logic [3:0]  hprot     ,
  output logic        hmastlock ,
  output logic [31:0] hwdata    ,
  input  logic [31:0] hrdata    ,
  output logic        hready    ,
  input  logic        hreadyout ,
  input  logic        hresp      
);

//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
localparam prm_DELAY = 1;

localparam HTRANS_IDLE   = 2'b00;
localparam HTRANS_BUSY   = 2'b01;
localparam HTRANS_NOSEQ  = 2'b10;
localparam HTRANS_SEQ    = 2'b11;

localparam HSIZE_BIT8    = 3'b000;
localparam HSIZE_BIT16   = 3'b001;
localparam HSIZE_BIT32   = 3'b010;
localparam HSIZE_BIT64   = 3'b011;
localparam HSIZE_BIT128  = 3'b100;
localparam HSIZE_BIT256  = 3'b101;
localparam HSIZE_BIT512  = 3'b110;
localparam HSIZE_BIT1024 = 3'b111;

localparam HBURST_SINGLE = 3'b000;
localparam HBURST_INCR   = 3'b001;
localparam HBURST_WRAP4  = 3'b010;
localparam HBURST_INCR4  = 3'b011;
localparam HBURST_WRAP8  = 3'b100;
localparam HBURST_INCR8  = 3'b101;
localparam HBURST_WRAP16 = 3'b110;
localparam HBURST_INCR16 = 3'b111;

localparam HRESP_OKAY    = 1'b0;
localparam HRESP_ERROR   = 1'b1;

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
always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    state = "";
    hselx     <= 1'b0;
    haddr     <= {32{1'b0}};
    htrans    <= HTRANS_IDLE;
    hwrite    <= 1'b0;
    hsize     <= {3{1'b0}};
    hburst    <= {3{1'b0}};
    hprot     <= {4{1'b0}};
    hmastlock <= 1'b0;
    hwdata    <= {32{1'b0}};
    hready    <= 1'b1;
  end
end

//------------------------------------------------------------------------------
// Tasks
//------------------------------------------------------------------------------
task set_param(
  input logic [3:0] i_hprot    ,
  input logic       i_hmastlock
);
begin
  hprot     <= i_hprot;
  hmastlock <= i_hmastlock;
end
endtask

task write32(
  input logic [31:0] i_addr ,
  input logic [31:0] i_wdata
);
begin
  @(posedge hclk);
  state = "aw"; // addr phase 
  hselx   <= #(prm_DELAY) 1'b1;
  haddr   <= #(prm_DELAY) i_addr;
  htrans  <= #(prm_DELAY) HTRANS_NOSEQ;
  hwrite  <= #(prm_DELAY) 1'b1;
  hsize   <= #(prm_DELAY) HSIZE_BIT32;
  hburst  <= #(prm_DELAY) HBURST_SINGLE;

  do @(posedge hclk); while (hreadyout != 1'b1);
  state = "dw"; // data phase 
  hwdata  <= #(prm_DELAY) i_wdata;
  htrans  <= #(prm_DELAY) HTRANS_IDLE;
  if(hresp != HRESP_OKAY) $display("%t ps, %s : detect!!! hresp=%d", $time, str_tag_write, hresp);

  do @(posedge hclk); while (hreadyout != 1'b1);
  if(hresp != HRESP_OKAY) $display("%t ps, %s : detect!!! hresp=%d", $time, str_tag_write, hresp);
  hselx   <= #(prm_DELAY) 1'b0;
  state = "";
end
endtask

task read32(
  input  logic [31:0] i_addr ,
  output logic [31:0] o_rdata
);
begin
  @(posedge hclk);
  state = "ar"; // addr phase 
  hselx   <= #(prm_DELAY) 1'b1;
  haddr   <= #(prm_DELAY) i_addr;
  htrans  <= #(prm_DELAY) HTRANS_NOSEQ;
  hwrite  <= #(prm_DELAY) 1'b0;
  hsize   <= #(prm_DELAY) HSIZE_BIT32;
  hburst  <= #(prm_DELAY) HBURST_SINGLE;

  do @(posedge hclk); while (hreadyout != 1'b1);
  htrans  <= #(prm_DELAY) HTRANS_IDLE;
  state = "dr"; // data phase

  do @(posedge hclk); while (hreadyout != 1'b1);
  o_rdata = hrdata;
  if(hresp != HRESP_OKAY) $display("%t ps, %s : detect!!! hresp=%d", $time, str_tag_read, hresp);
  hselx   <= #(prm_DELAY) 1'b0;
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
