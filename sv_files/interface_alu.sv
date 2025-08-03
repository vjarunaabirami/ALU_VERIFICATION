interface interface_alu #(parameter WIDTH = 8) (input bit clk, reset);
  
  // Declaring signals with width

  //input signals to ALU
  logic [WIDTH-1:0] opa;
  logic [WIDTH-1:0] opb;
  logic [3:0] cmd;
  logic ce;
  logic [1:0]inp_valid;
  logic mode;
  logic cin;

  //Output signals from ALU
  logic [WIDTH-1:0] res;
  logic oflow;
  logic cout;
  logic g;
  logic l;
  logic e;
  logic err;

  //CLOCKING BLCOK FOR DRIVER
  clocking drv_cb @(posedge clk);
    default input #0 output #0;  
    output opa, opb, cmd, inp_valid, mode, cin, ce;
    input reset;
    //input res,oflow,cout,g,l,e,err;
  endclocking
 
  //CLOCKING BLOCK FOR MONITOR
  clocking mon_cb @(posedge clk);
    default input #0 output #0;
    input opa, opb, cmd, inp_valid, mode, cin, ce, reset;
    input res, oflow, cout, g, l, e, err;
  endclocking
  
  //CLOCKING BLOCK FOR REFERENCE MODEL
  clocking ref_cb @(posedge clk);
    default input #0 output #0;
    input opa, opb, cmd, inp_valid, mode, cin, ce, reset;
    input res, oflow, cout, g, l, e, err;
  endclocking 

  //MODPORTS
  modport DRV(input clk, reset, clocking drv_cb);
  modport MON(clocking mon_cb);
  modport REF(input clk, reset, clocking ref_cb);

   property p1;
  @(posedge clk) disable iff (reset)
    !ce |=> (res === 'z);
endproperty

assert property (p1)
  $info("CE=0 Assertion-1 Passed");
else
  $error("CE=0 Assertion-1 Failed");

   property p2;
  @(posedge clk)
   reset |-> (res=='0 && e==0 && l==0 && g==0 && oflow==0 && cout==0);
  endproperty

   assert property (p2)
      $info("RST condition Assertion-5  Passed");
   else
      $error("RST condition Assertion-5 Failed");
endinterface

