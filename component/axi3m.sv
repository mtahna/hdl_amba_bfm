`timescale 1ps/1ps
//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module axi3m #(
  string str_tag_header = "[axi3m]",
  parameter id_width = 4
)(
  input  logic                aclk     ,
  input  logic                aresetn  ,
  output logic [id_width-1:0] awid     ,
  output logic [31:0]         awaddr   ,
  output logic [3:0]          awlen    ,
  output logic [2:0]          awsize   ,
  output logic [1:0]          awburst  ,
  output logic [1:0]          awlock   ,
  output logic [3:0]          awcache  ,
  output logic [3:0]          awprot   ,
  output logic                awvalid  ,
  input  logic                awready  ,
  output logic [id_width-1:0] wid      ,
  output logic [31:0]         wdata    ,
  output logic [4:0]          wstrb    ,
  output logic                wlast    ,
  output logic                wvalid   ,
  input  logic                wready   ,
  input  logic [id_width-1:0] bid      ,
  input  logic [1:0]          bresp    ,
  input  logic                bvalid   ,
  output logic                bready   ,
  output logic [id_width-1:0] arid     ,
  output logic [31:0]         araddr   ,
  output logic [3:0]          arlen    ,
  output logic [2:0]          arsize   ,
  output logic [1:0]          arburst  ,
  output logic [1:0]          arlock   ,
  output logic [3:0]          arcache  ,
  output logic [3:0]          arprot   ,
  output logic                arvalid  ,
  input  logic                arready  ,
  input  logic [id_width-1:0] rid      ,
  input  logic [1:0]          rresp    ,
  input  logic [31:0]         rdata    ,
  input  logic                rlast    ,
  input  logic                rvalid   ,
  output logic                rready    
);

//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
localparam prm_DELAY = 1;

localparam AxSIZE_BYTE1     = 3'b000;
localparam AxSIZE_BYTE2     = 3'b001;
localparam AxSIZE_BYTE4     = 3'b010;
localparam AxSIZE_BYTE8     = 3'b011;
localparam AxSIZE_BYTE16    = 3'b100;
localparam AxSIZE_BYTE32    = 3'b101;
localparam AxSIZE_BYTE64    = 3'b110;
localparam AxSIZE_BYTE128   = 3'b111;

localparam AxBURST_FIXED    = 2'b00;
localparam AxBURST_INCR     = 2'b01;
localparam AxBURST_WRAP     = 2'b10;
localparam AxBURST_Reserved = 2'b11;

localparam AxLOCK_NORMAL    = 1'b0;
localparam AxLOCK_EXCLUSIVE = 1'b1;

localparam xRESP_OKAY       = 2'b00;
localparam xRESP_EXOKAY     = 2'b01;
localparam xRESP_SLVERR     = 2'b10;
localparam xRESP_DECERR     = 2'b11;

const string str_tag_write = {str_tag_header,"[write]"};
const string str_tag_read  = {str_tag_header,"[read ]"};
const string str_tag_rdmwr = {str_tag_header,"[rdmwr]"};
const string str_ok = "[OK]";
const string str_ng = "[NG]";
string state;

logic [id_width-1:0] id_write_num; 
logic [id_width-1:0] id_read_num; 
logic [31:0]         tmp_wdata;
logic [31:0]         tmp_rdata;

//------------------------------------------------------------------------------
// Init
//------------------------------------------------------------------------------
always @(posedge aclk or negedge aresetn) begin
  if (~aresetn) begin
    state = "";
    id_write_num <= {id_width{1'b0}};
    awlock  <= 2'b00;
    awcache <= 4'b000;
    awprot  <= 4'b000;
    awvalid <= 1'b0;
    wlast   <= 1'b0;
    wvalid  <= 1'b0;
    bready  <= 1'b0;
    id_read_num  <= {id_width{1'b0}};
    arlock  <= 2'b00;
    arcache <= 4'b000;
    arprot  <= 4'b000;
    arvalid <= 1'b0;
    rready  <= 1'b0;
  end
end

//------------------------------------------------------------------------------
// Tasks
//------------------------------------------------------------------------------
task set_write_param(
  input logic [id_width-1:0] i_id_write,
  input logic [1:0]          i_awlock  ,
  input logic [3:0]          i_awcache ,
  input logic [3:0]          i_awprot    
);
begin
  id_write_num <= i_id_write;
  awlock  <= i_awlock;
  awcache <= i_awcache;
  awprot  <= i_awprot;
end
endtask

task set_read_param(
  input logic [id_width-1:0] i_id_read,
  input logic [1:0]          i_arlock ,
  input logic [3:0]          i_arcache,
  input logic [3:0]          i_arprot   
);
begin
  id_read_num <= i_id_read;
  arlock  <= i_arlock;
  arcache <= i_arcache;
  arprot  <= i_arprot;
end
endtask

task write32(
  input logic [31:0] i_addr ,
  input logic [31:0] i_wdata
);
begin
  @(posedge aclk);
  state = "aw"; // awch
  awid    <= #(prm_DELAY) id_write_num;
  awaddr  <= #(prm_DELAY) i_addr;
  awlen   <= #(prm_DELAY) 4'h0;
  awsize  <= #(prm_DELAY) AxSIZE_BYTE4;
  awburst <= #(prm_DELAY) AxBURST_INCR;
  awvalid <= #(prm_DELAY) 1'b1;

  do @(posedge aclk); while ( !((awvalid == 1'b1) && (awready == 1'b1)) );
  awvalid <= #(prm_DELAY) 1'b0;
  state = "w"; // wch
  wid     <= #(prm_DELAY) id_write_num;
  wdata   <= #(prm_DELAY) i_wdata;
  wstrb   <= #(prm_DELAY) {4{1'b1}};
  wlast   <= #(prm_DELAY) 1'b1;
  wvalid  <= #(prm_DELAY) 1'b1;

  do @(posedge aclk); while ( !((wvalid == 1'b1) && (wready == 1'b1)) );
  wlast   <= #(prm_DELAY) 1'b0;
  wvalid  <= #(prm_DELAY) 1'b0;
  state = "b"; // bch
  bready  <= #(prm_DELAY) 1'b1;

  do @(posedge aclk); while ( !((bready == 1'b1) && (bvalid == 1'b1)) );
  if(bid != id_write_num) $display("%t ps, %s : detect!!! id_num=%0d[exp=%0d]", $time, str_tag_write, bid, id_write_num);
  if(bresp != xRESP_OKAY) $display("%t ps, %s : detect!!! bresp=%0d", $time, str_tag_write, bresp);
  bready  <= #(prm_DELAY) 1'b0;
  state = "";
end
endtask

task read32(
  input  logic [31:0] i_addr ,
  output logic [31:0] o_rdata
);
begin
  @(posedge aclk);
  state = "ar"; // arch
  arid    <= #(prm_DELAY) id_read_num;
  araddr  <= #(prm_DELAY) i_addr;
  arlen   <= #(prm_DELAY) 4'h0;
  arsize  <= #(prm_DELAY) AxSIZE_BYTE4;
  arburst <= #(prm_DELAY) AxBURST_INCR;
  arvalid <= #(prm_DELAY) 1'b1;

  do @(posedge aclk); while ( !((arvalid == 1'b1) && (arready == 1'b1)) );
  arvalid <= #(prm_DELAY) 1'b0;
  state = "r"; // rch
  rready  <= #(prm_DELAY) 1'b1;

  do @(posedge aclk); while ( !((rready == 1'b1) && (rvalid == 1'b1)) );
  o_rdata = rdata;
  if(rlast != 1'b1)       $display("%t ps, %s : detect!!! rlast error.", $time, str_tag_read);
  if(rid != id_read_num)  $display("%t ps, %s : detect!!! id_num=%0d[exp=%0d]", $time, str_tag_read, rid, id_read_num);
  if(rresp != xRESP_OKAY) $display("%t ps, %s : detect!!! rresp=%0d", $time, str_tag_read, rresp);
  rready  <= #(prm_DELAY) 1'b0;
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
