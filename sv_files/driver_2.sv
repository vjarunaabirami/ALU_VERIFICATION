`include"defines.sv"
class driver_alu;
  transaction_alu drv_trans;
  mailbox #(transaction_alu) mbx_gen2drv;
  mailbox #(transaction_alu) mbx_drv2ref;
  virtual interface_alu.DRV vif;
  bit done;

  function new(mailbox #(transaction_alu) mbx_gen2drv,
               mailbox #(transaction_alu) mbx_drv2ref,
               virtual interface_alu.DRV vif);
    this.mbx_gen2drv = mbx_gen2drv;
    this.mbx_drv2ref = mbx_drv2ref;
    this.vif = vif;
  endfunction

  task start();
    repeat(2) @(vif.drv_cb);
    for (int i = 0; i < `no_of_trans; i++) begin
  $display("----------------DRIVER-%0d DRIVING AT %0t------------------",i+1, $time);
      drv_trans = new();
      mbx_gen2drv.get(drv_trans);
     $display("[DRIVER] sent to dut : mode = %0d, cmd = %0d, cin = %0d, inp_valid = %0d, opa = %0d, opb = %0d, ce = %0d @[%0t]",
             drv_trans.mode,drv_trans.cmd, drv_trans.cin, drv_trans.inp_valid,
             drv_trans.opa, drv_trans.opb, drv_trans.ce, $time);

      drive_input();
      repeat(1) @(vif.drv_cb);
      mbx_drv2ref.put(drv_trans);
      done = 0;

      if (( drv_trans.cmd inside {0,1,2,3,8,9,10} && drv_trans.mode==1 && (drv_trans.inp_valid!=3 && drv_trans.inp_valid!=0)) ||
          ( drv_trans.cmd inside {0,1,2,3,4,5,12,13} && drv_trans.mode==0 && (drv_trans.inp_valid!=3 && drv_trans.inp_valid!=0))) begin
        $display("drvier inside loop");
        drv_trans.cmd.rand_mode(0);
        drv_trans.ce.rand_mode(0);
        drv_trans.mode.rand_mode(0);

        repeat(16) begin
          @(posedge vif.drv_cb);
          $display("looping");
          drv_trans.randomize();
          drive_input();
          if (drv_trans.inp_valid == 2'b11) begin
            done = 1;
            $display("[DRIVER] got inp_valid 3 : mode = %0d, cmd = %0d, cin = %0d,  opa = %0d, opb = %0d, ce = %0d @[%0t]",
             drv_trans.mode,drv_trans.cmd, drv_trans.cin,drv_trans.opa, drv_trans.opb, drv_trans.ce, $time);
            repeat(1) @(vif.drv_cb);
 mbx_drv2ref.put(drv_trans);
            break;
          end
        end
      end else begin
        done = 1;
      end

      if (done) begin
        if (drv_trans.mode == 1 && drv_trans.cmd inside {9,10})
          repeat(2) @(vif.drv_cb);
        else
          repeat(1) @(vif.drv_cb);
      end else begin
        repeat(1) @(vif.drv_cb);
      end
    end // for
    drv_trans.cmd.rand_mode(1);
    drv_trans.ce.rand_mode(1);
    drv_trans.mode.rand_mode(1);
  endtask
  task drive_input();
    vif.drv_cb.ce <= drv_trans.ce;
    vif.drv_cb.mode <= drv_trans.mode;
    vif.drv_cb.cmd <= drv_trans.cmd;
    vif.drv_cb.cin <= drv_trans.cin;
    vif.drv_cb.inp_valid <= drv_trans.inp_valid;
    vif.drv_cb.opa <= drv_trans.opa;
    vif.drv_cb.opb <= drv_trans.opb;
  endtask
endclass

