
`include "interface_alu.sv"
`include "alu_design.sv"
`include "pkg.sv"

module top_alu();
  //IMPORTING THE ALU PACKAGE
  import alu_pkg::*;

  //DECLARING VARIABLES FOR CLOCK AND RESET
  bit clk = 0;
  bit reset = 0;

  //CLOCK GENERATION
  initial begin
    forever #5 clk = ~clk;
  end

  //ASSERTING AND DE-ASSERTING THE RESET
  initial begin
    reset = 1;
    repeat(1) @(posedge clk);
    reset = 0;
  end

  //INSTANTIATING THE INTERFACE
  interface_alu intrf(clk,reset);

  //INSTANTIATING THE DUV
  ALU_DESIGN DUV(
    .OPA(intrf.opa),
    .OPB(intrf.opb),
    .CIN(intrf.cin),
    .CLK(clk),
    .RST(reset),
    .CE(intrf.ce),
    .MODE(intrf.mode),
    .CMD(intrf.cmd),
    .INP_VALID(intrf.inp_valid),
    .RES(intrf.res),
    .COUT(intrf.cout),
    .OFLOW(intrf.oflow),
    .G(intrf.g),
    .E(intrf.e),
    .L(intrf.l),
    .ERR(intrf.err)
  );

  //INSTANTIATING THE TEST
  test_t1 tb = new(intrf.DRV, intrf.MON, intrf.REF);
  //test_t2 tb = new(intrf.DRV, intrf.MON, intrf.REF);
  //test_t3 tb = new(intrf.DRV, intrf.MON, intrf.REF);
  //test_t4 tb = new(intrf.DRV, intrf.MON, intrf.REF);
  //test_regression_alu tb = new(intrf.DRV, intrf.MON, intrf.REF);

  //CALLINF THE TEST'S RUN
  initial
  begin
    tb.run();
    $finish;
  end

endmodule

