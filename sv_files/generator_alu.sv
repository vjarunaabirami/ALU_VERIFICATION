`include "defines.sv"

class generator_alu;

  transaction_alu blueprint;

  mailbox #(transaction_alu)mbx_gen2drv;

  function new(mailbox #(transaction_alu)mbx_gen2drv);
    this.mbx_gen2drv = mbx_gen2drv;
    blueprint = new();
  endfunction

  task start();
    for(int i = 0; i < `no_of_trans; i++) begin
      blueprint.randomize();
      mbx_gen2drv.put(blueprint.copy());
      $display("GENERATOR RANDOMIZED TRANSACTION ce = %b input_valid = %0d mode = %b command = %0d opa = %0d, opb = %0d cin = %b",blueprint.ce, blueprint.inp_valid, blueprint.mode, blueprint.cmd, blueprint.opa, blueprint.opb, blueprint.cin, $time);
    end
  endtask
endclass 
  
