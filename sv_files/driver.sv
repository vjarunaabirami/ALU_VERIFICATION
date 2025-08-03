/*`include "defines.sv"

class driver_alu;

  //ALU TRANSACTION CLASS HANDLE
  transaction_alu drv_trans;

  //MAILBOX FOR GENERATOR TO DRIVER CONNECTION
  mailbox #(transaction_alu)mbx_gen2drv;

  //MAILBOX FOR DRIVER TO REFERENCE MODEL CONNECTION
  mailbox #(transaction_alu)mbx_drv2ref;

  //VIRTUAL INTERFACE WITH DRIVER MODPORT AND IT'S INSTANCE
  virtual interface_alu.DRV vif;

  //FUNCTIONAL COVERAGE FOR INPUTS
  covergroup drv_cg;

    //BASIC FUNCTIONAL COVERAGE
    MODE : coverpoint drv_trans.mode { bins mode_bin[] = {0,1}; }
    CMD : coverpoint drv_trans.cmd { bins cmd_bin[] = {[0:13]}; }
    CIN : coverpoint drv_trans.cin { bins cin_bin[] = {0,1}; }
    INP_VALID : coverpoint drv_trans.inp_valid { bins inp_valid_bin[] = {2'b00, 2'b01, 2'b10, 2'b11}; }
    OPA : coverpoint drv_trans.opa;
    OPB : coverpoint drv_trans.opb;
    RST : coverpoint vif.drv_cb.reset { bins rst_bin[]={1}; }
    //ERR : coverpoint vif.drv_cb.err { bins no_err = {0}; bins err = {1}; }
    //G : coverpoint vif.drv_cb.g { bins g_bin = {1}; }
    //L : coverpoint vif.drv_cb.l { bins l_bin = {1}; }
    //E : coverpoint vif.drv_cb.e { bins e_bin = {1}; }
    CE : coverpoint drv_trans.ce { bins ce_bin[] = {0,1}; }

    //CROSS COVERAGE
    CMD_X_MODE : cross CMD, MODE;
    CMD_X_INP_VALID : cross CMD, INP_VALID;
    CMD_X_CE  : cross CMD, CE;
    //CMD_X_ERR : cross CMD, ERR;
    //CMD_X_CMP_OUT : cross CMD, G, L, E;
  endgroup

  function new(mailbox #(transaction_alu) mbx_gen2drv,
               mailbox #(transaction_alu) mbx_drv2ref,
               virtual interface_alu.DRV vif);

    this.mbx_gen2drv = mbx_gen2drv;
    this.mbx_drv2ref = mbx_drv2ref;
    this.vif = vif;
    drv_cg = new();
  endfunction

  //TASK TO DRIVE THE STIMULIT TO THE INTERFACE
  task start();
    repeat(3) @(vif.drv_cb);  //WAIT FOR RELEASE/STABILIZATION
    for(int i = 0; i < `no_of_trans; i++) begin
      drv_trans = new();
      //GETTING THE TRANSACTION FROM GENERATOR
      mbx_gen2drv.get(drv_trans);
      if(vif.drv_cb.reset == 0) begin
        repeat(1) @(vif.drv_cb);
          vif.drv_cb.ce <= drv_trans.ce;
          vif.drv_cb.mode <= drv_trans.mode;
          vif.drv_cb.cmd <= drv_trans.cmd;
          vif.drv_cb.cin <= drv_trans.cin;
          vif.drv_cb.inp_valid <= drv_trans.inp_valid;
          vif.drv_cb.opa <= drv_trans.opa;
          vif.drv_cb.opb <= drv_trans.opb;
          $display("[DRIVER]  mode = %d, cmd = %d, cin=%d, inp_valid = %d, opa = %d, opb=%d, ce = %d", vif.drv_cb.mode, vif.drv_cb.cmd, vif.drv_cb.cin, vif.drv_cb.inp_valid, vif.drv_cb.opa, vif.drv_cb.opb, vif.drv_cb.ce, $time);

          //SAMPLE COVERAGE
          drv_cg.sample();

          //SEND TO REFERENCE MODEL
          mbx_drv2ref.put(drv_trans);

          repeat(3) @(vif.drv_cb);

          $display("INPUT FUNCTIONAiL COVERAGE = %0d", drv_cg.get_coverage());

      end
    end
  endtask
endclass*/

`include "defines.sv"

class driver_alu;

  transaction_alu drv_trans, partial_trans;

  mailbox #(transaction_alu) mbx_gen2drv;

  mailbox #(transaction_alu) mbx_drv2ref;

  virtual interface_alu.DRV vif;

  event dr_ref;

  covergroup drv_cg;
    MODE : coverpoint drv_trans.mode { bins mode_bin[] = {0,1}; }
    CMD  : coverpoint drv_trans.cmd { bins cmd_bin[] = {[0:13]}; }
    CIN  : coverpoint drv_trans.cin { bins cin_bin[] = {0,1}; }
    INP_VALID : coverpoint drv_trans.inp_valid { bins inp_valid_bin[] = {2'b00, 2'b01, 2'b10, 2'b11}; }
    OPA : coverpoint drv_trans.opa;
    OPB : coverpoint drv_trans.opb;
    RST : coverpoint vif.drv_cb.reset { bins rst_bin[] = {1}; }
    CE  : coverpoint drv_trans.ce { bins ce_bin[] = {0,1}; }

    // CROSS COVERAGE
    CMD_X_MODE      : cross CMD, MODE;
    CMD_X_INP_VALID : cross CMD, INP_VALID;
    CMD_X_CE        : cross CMD, CE;
  endgroup

  function new(mailbox #(transaction_alu) mbx_gen2drv,
               mailbox #(transaction_alu) mbx_drv2ref,
               virtual interface_alu.DRV vif,
	       event dr_ref);
    this.mbx_gen2drv = mbx_gen2drv;
    this.mbx_drv2ref = mbx_drv2ref;
    this.vif = vif;
    this.dr_ref = dr_ref;
    drv_cg = new();
  endfunction

  task start();
    int wait_counter;
    repeat(3) @(vif.drv_cb);  // WAIT FOR RESET TO STABILIZE

    for (int i = 0; i < `no_of_trans; i++) begin
      drv_trans = new();
      //$display("11");
      mbx_gen2drv.get(drv_trans); // GET FROM GENERATOR
      //$display("22");
      // Handle cases where only partial operand is valid (e.g. 2’b01 or 2’b10)
      if (drv_trans.inp_valid == 2'b01 || drv_trans.inp_valid == 2'b10) begin
        partial_trans = drv_trans;
        wait_counter = 0;

        // Wait for the other operand to arrive
        do begin
          wait_counter++;
          if (wait_counter > 16) begin
            $display("[DRIVER][ERROR] Second operand not received within 16 cycles.");
            break;
          end
          //repeat(1) @(vif.drv_cb);
          mbx_gen2drv.get(drv_trans);
        end while (drv_trans.inp_valid != 2'b11);

        // Merge operands based on previous and current input
        if (partial_trans.inp_valid == 2'b01) begin
          drv_trans.opa = partial_trans.opa;
        end else begin
          drv_trans.opb = partial_trans.opb;
        end

        // Combine CE and CIN from first transaction if needed
        drv_trans.ce  = partial_trans.ce;
        drv_trans.cin = partial_trans.cin;
      end

      // DRIVING TO INTERFACE
      if (vif.drv_cb.reset == 0) begin
        @(vif.drv_cb);
        vif.drv_cb.ce        <= drv_trans.ce;
        vif.drv_cb.mode      <= drv_trans.mode;
        vif.drv_cb.cmd       <= drv_trans.cmd;
        vif.drv_cb.cin       <= drv_trans.cin;
        vif.drv_cb.inp_valid <= drv_trans.inp_valid;
        vif.drv_cb.opa       <= drv_trans.opa;
        vif.drv_cb.opb       <= drv_trans.opb;

        $display("[DRIVER] mode=%0d, cmd=%0d, cin=%0d, inp_valid=%b, opa=%0d, opb=%0d, ce=%b @%0t",
                  vif.drv_cb.mode, vif.drv_cb.cmd, vif.drv_cb.cin,
                  vif.drv_cb.inp_valid, vif.drv_cb.opa, vif.drv_cb.opb,
                  vif.drv_cb.ce, $time);

        drv_cg.sample(); // SAMPLE COVERAGE
	$display("33");
        mbx_drv2ref.put(drv_trans); // SEND TO REF MODEL
       
        //TRIGGERING THE EVENT TO REF_MODEL
     
	->dr_ref;
        repeat(3) @(vif.drv_cb); // Allow interface to settle
        $display("INPUT FUNCTIONAL COVERAGE = %0.2f %%", drv_cg.get_coverage());
      end
    end
  endtask

endclass

