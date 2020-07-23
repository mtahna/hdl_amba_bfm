`timescale 1ps/1ps

//------------------------------------------------------------------------------
// Module Definition
//------------------------------------------------------------------------------
module tbench ();

//------------------------------------------------------------------------------
// Definition
//------------------------------------------------------------------------------
logic        clk    ;
logic        reset  ;

localparam id_width = 4;
localparam addr_width = 32;
localparam data_width = 32;

logic                      aclk     ;
logic                      aresetn  ;
logic [id_width-1:0]       awid     ;
logic [addr_width-1:0]     awaddr   ;
logic [3:0]                awlen    ;
logic [2:0]                awsize   ;
logic [1:0]                awburst  ;
logic [1:0]                awlock   ;
logic [3:0]                awcache  ;
logic [3:0]                awprot   ;
logic                      awvalid  ;
logic                      awready  ;
logic [id_width-1:0]       wid      ;
logic [data_width-1:0]     wdata    ;
logic [(data_width/8)-1:0] wstrb    ;
logic                      wlast    ;
logic                      wvalid   ;
logic                      wready   ;
logic [id_width-1:0]       bid      ;
logic [1:0]                bresp    ;
logic                      bvalid   ;
logic                      bready   ;
logic [id_width-1:0]       arid     ;
logic [addr_width-1:0]     araddr   ;
logic [3:0]                arlen    ;
logic [2:0]                arsize   ;
logic [1:0]                arburst  ;
logic [1:0]                arlock   ;
logic [3:0]                arcache  ;
logic [3:0]                arprot   ;
logic                      arvalid  ;
logic                      arready  ;
logic [id_width-1:0]       rid      ;
logic [1:0]                rresp    ;
logic [data_width-1:0]     rdata    ;
logic                      rlast    ;
logic                      rvalid   ;
logic                      rready   ;

logic                  hclk     ;
logic                  hresetn  ;
logic                  hselx    ;
logic [addr_width-1:0] haddr    ;
logic [1:0]            htrans   ;
logic                  hwrite   ;
logic [2:0]            hsize    ;
logic [2:0]            hburst   ;
logic [3:0]            hprot    ;
logic                  hmastlock;
logic [data_width-1:0] hwdata   ;
logic [data_width-1:0] hrdata   ;
logic                  hready   ;
logic                  hreadyout;
logic                  hresp    ;

logic        psel   ;  
logic        penable; 
logic        pwrite ;
logic [31:0] paddr  ;
logic [31:0] pwdata ;
logic [31:0] prdata ;
logic        pready ;
logic        pslverr;  

logic [15:0] SETSIG_15_0;
logic [15:0] MONSIG_15_0;

//------------------------------------------------------------------------------
// -- Instance -- crg
//------------------------------------------------------------------------------
crg ucrg (
  .clken            ( 1'b1             ), // input  logic        
  .clk              ( clk              ), // output logic        
  .resetn           ( resetn           )  // output logic        
);

//------------------------------------------------------------------------------
// -- Instance -- AXI3 Master
//------------------------------------------------------------------------------
axi3m #(
  .str_tag_header("[axi3m]")
) uaxi3m (
  .aclk              ( clk             ), // input  logic                      
  .aresetn           ( resetn          ), // input  logic                      
  .awid              ( awid            ), // output logic [id_width-1:0]       
  .awaddr            ( awaddr          ), // output logic [addr_width-1:0]     
  .awlen             ( awlen           ), // output logic [3:0]                
  .awsize            ( awsize          ), // output logic [2:0]                
  .awburst           ( awburst         ), // output logic [1:0]                
  .awlock            ( awlock          ), // output logic [1:0]                
  .awcache           ( awcache         ), // output logic [3:0]                
  .awprot            ( awprot          ), // output logic [3:0]                
  .awvalid           ( awvalid         ), // output logic                      
  .awready           ( awready         ), // input  logic                      
  .wid               ( wid             ), // output logic [id_width-1:0]       
  .wdata             ( wdata           ), // output logic [data_width-1:0]     
  .wstrb             ( wstrb           ), // output logic [(data_width/8)-1:0] 
  .wlast             ( wlast           ), // output logic                      
  .wvalid            ( wvalid          ), // output logic                      
  .wready            ( wready          ), // input  logic                      
  .bid               ( bid             ), // input  logic [id_width-1:0]       
  .bresp             ( bresp           ), // input  logic [1:0]                
  .bvalid            ( bvalid          ), // input  logic                      
  .bready            ( bready          ), // output logic                      
  .arid              ( arid            ), // output logic [id_width-1:0]       
  .araddr            ( araddr          ), // output logic [addr_width-1:0]     
  .arlen             ( arlen           ), // output logic [3:0]                
  .arsize            ( arsize          ), // output logic [2:0]                
  .arburst           ( arburst         ), // output logic [1:0]                
  .arlock            ( arlock          ), // output logic [1:0]                
  .arcache           ( arcache         ), // output logic [3:0]                
  .arprot            ( arprot          ), // output logic [3:0]                
  .arvalid           ( arvalid         ), // output logic                      
  .arready           ( arready         ), // input  logic                      
  .rid               ( rid             ), // input  logic [id_width-1:0]       
  .rresp             ( rresp           ), // input  logic [1:0]                
  .rdata             ( rdata           ), // input  logic [data_width-1:0]     
  .rlast             ( rlast           ), // input  logic                      
  .rvalid            ( rvalid          ), // input  logic                      
  .rready            ( rready          )  // output logic                      
);

//------------------------------------------------------------------------------
// -- Instance -- AHB3 Master
//------------------------------------------------------------------------------
ahblm #(
  .str_tag_header("[ahblm]")
) uahblm (
  .hclk              ( clk             ), // input  logic                  
  .hresetn           ( resetn          ), // input  logic                  
  .hselx             ( hselx           ), // output logic                  
  .haddr             ( haddr           ), // output logic [addr_width-1:0] 
  .htrans            ( htrans          ), // output logic [1:0]            
  .hwrite            ( hwrite          ), // output logic                  
  .hsize             ( hsize           ), // output logic [2:0]            
  .hburst            ( hburst          ), // output logic [2:0]            
  .hprot             ( hprot           ), // output logic [3:0]            
  .hmastlock         ( hmastlock       ), // output logic                  
  .hwdata            ( hwdata          ), // output logic [data_width-1:0] 
  .hrdata            ( hrdata          ), // input  logic [data_width-1:0] 
  .hready            ( hready          ), // output logic                  
  .hreadyout         ( hreadyout       ), // input  logic                  
  .hresp             ( hresp           )  // input  logic                  
);

//------------------------------------------------------------------------------
// -- Instance -- APB3 Master
//------------------------------------------------------------------------------
abp3m #(
  .str_tag_header("[apb3m]")
) uapb3m (
  .pclk             ( clk              ), // input  logic        
  .presetn          ( resetn           ), // input  logic        
  .psel             ( psel             ), // output logic        
  .penable          ( penable          ), // output logic        
  .pwrite           ( pwrite           ), // output logic        
  .paddr            ( paddr            ), // output logic [31:0] 
  .pwdata           ( pwdata           ), // output logic [31:0] 
  .prdata           ( prdata           ), // input  logic [31:0] 
  .pready           ( pready           ), // input  logic            
  .pslverr          ( pslverr          )  // input  logic           
);

//------------------------------------------------------------------------------
// -- Instance -- APB3 Slave (DUT)
//------------------------------------------------------------------------------
APB3REG uAPB3REG (
  .PCLK             ( clk              ), // input  wire        
  .PRESETn          ( resetn           ), // input  wire        
  .PADDR            ( paddr            ), // input  wire [31:0] 
  .PWDATA           ( pwdata           ), // input  wire [31:0] 
  .PWRITE           ( pwrite           ), // input  wire        
  .PENABLE          ( penable          ), // input  wire        
  .PSEL             ( psel             ), // input  wire        
  .PRDATA           ( prdata           ), // output wire [31:0] 
  .PSLVERR          ( pslverr          ), // output wire        
  .PREADY           ( pready           ), // output wire        
  .SETSIG_15_0      ( SETSIG_15_0      ), // output wire [15:0] 
  .MONSIG_15_0      ( MONSIG_15_0      )  // input  wire [15:0] 
);


endmodule
