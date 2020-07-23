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
// -- Instance -- Master
//------------------------------------------------------------------------------
abp3m uapb3m (
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
// -- Instance -- Slave (DUT)
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
