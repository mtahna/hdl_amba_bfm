//------------------------------------------------------------------------------
// Title
// Header
//------------------------------------------------------------------------------
`timescale 1ps/1ps

//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module APB3REG (
  input  wire        PCLK             ,
  input  wire        PRESETn          ,
  input  wire [31:0] PADDR            ,
  input  wire [31:0] PWDATA           ,
  input  wire        PWRITE           ,
  input  wire        PENABLE          ,
  input  wire        PSEL             ,
  output wire [31:0] PRDATA           ,
  output wire        PSLVERR          ,
  output wire        PREADY           ,
  output wire [15:0] SETSIG_15_0      ,
  input  wire [15:0] MONSIG_15_0      
);


//------------------------------------------------------------------------------
// Parameter Definition
//------------------------------------------------------------------------------
  localparam FF_DELAY = 1;

  localparam ADDR_SETREG            = 10'h000; /* 12'h000 */
  localparam ADDR_MONREG            = 10'h001; /* 12'h004 */

  localparam INIT_SETSIG_15_0       = 1'b0;

//------------------------------------------------------------------------------
// Register and Wire Declarations
//------------------------------------------------------------------------------
  wire        ren;
  wire        wen;
  wire        set_SETREG;

  reg  [31:0] r_RDATA;
  reg  [15:0] r_SETSIG_15_0;


//------------------------------------------------------------------------------
// Sequential, Combinatiorial Logic
//------------------------------------------------------------------------------
  assign PSLVERR = 1'b0;
  assign PREADY = 1'b1;

  assign ren = PSEL & (~PWRITE);
  assign wen = PSEL & PENABLE & PWRITE;
  assign set_SETREG = (wen & (PADDR[11:2] == ADDR_SETREG)) ? 1'b1 : 1'b0;

  always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
      r_RDATA <= {32{1'b0}};
    end else begin
      if (ren) begin
        case (PADDR[11:2])
          ADDR_SETREG     : r_RDATA <= #(FF_DELAY) {{16{1'b0}}, r_SETSIG_15_0};
          ADDR_MONREG     : r_RDATA <= #(FF_DELAY) {{16{1'b0}}, MONSIG_15_0};
          default         : r_RDATA <= #(FF_DELAY) {32{1'b0}};
        endcase
      end
    end
  end
  assign PRDATA = r_RDATA;

  /* SETREG[0x000] : [15:0]:SETSIG_15_0  */
  always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
      r_SETSIG_15_0 <= INIT_SETSIG_15_0;
    end else begin
      if (set_SETREG) begin
        r_SETSIG_15_0 <= #(FF_DELAY) PWDATA[15:0];
      end
    end
  end
  assign SETSIG_15_0 = r_SETSIG_15_0;

  /* MONREG[0x004] [15:0]:MONSIG_15_0  */
  // none


endmodule
