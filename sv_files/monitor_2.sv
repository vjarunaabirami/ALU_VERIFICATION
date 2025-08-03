`include"defines.sv"
class monitor_alu;
  transaction_alu mon_trans;
  mailbox #(transaction_alu) mbx_mon2sb;

  virtual interface_alu.MON vif;

  bit flag;
  covergroup mon_cg;
    RES    : coverpoint mon_trans.res;
    ERR    : coverpoint mon_trans.err { bins err_bin[] = {0,1}; }
    OFLOW  : coverpoint mon_trans.oflow { bins of_bin[] = {0,1}; }
    COUT   : coverpoint mon_trans.cout { bins cout_bin[] = {0,1}; }
    G      : coverpoint mon_trans.g { bins g_bin[] = {0,1}; }
    L      : coverpoint mon_trans.l { bins l_bin[] = {0,1}; }
    E      : coverpoint mon_trans.e { bins e_bin[] = {0,1}; }

    CMP_OUT_X_ERR : cross G, L, E, ERR;
    RES_X_ERR     : cross RES, ERR;
  endgroup

  function new(virtual interface_alu.MON vif,
               mailbox #(transaction_alu) mbx_mon2sb);
    this.vif = vif;
    this.mbx_mon2sb = mbx_mon2sb;
    mon_cg = new();
  endfunction

  task start();
    repeat(2) @(vif.mon_cb);
    for (int i = 0; i < `no_of_trans; i++) begin
      mon_trans = new();

      flag = 0;
      repeat(1) @(vif.mon_cb);
      if ((vif.mon_cb.mode &&( vif.mon_cb.inp_valid != 3 && vif.mon_cb.inp_valid !=0)  && vif.mon_cb.cmd inside {0,1,2,3,8,9,10}) || (!vif.mon_cb.mode && (vif.mon_cb.inp_valid != 3 && vif.mon_cb.inp_valid !=0) && vif.mon_cb.cmd inside {0,1,2,3,4,5,12,13})) begin
        repeat (16) @(posedge vif.mon_cb) begin
          if (vif.mon_cb.inp_valid == 3) begin
             flag = 1;
             break;
            end
        end
      end
    else begin
        flag = 1;
    end
  if (flag) begin
      if (vif.mon_cb.mode && vif.mon_cb.cmd inside {9,10} && vif.mon_cb.inp_valid==3)
       begin
          repeat (2) @(posedge vif.mon_cb);
        end
       else begin
          repeat (1) @(posedge vif.mon_cb);
      end
    end
    else
    begin

      repeat (2) @(posedge vif.mon_cb);
    end


      mon_trans.opa = vif.mon_cb.opa;
      mon_trans.opb = vif.mon_cb.opb;
      mon_trans.cin = vif.mon_cb.cin;
      mon_trans.inp_valid = vif.mon_cb.inp_valid;
      mon_trans.mode = vif.mon_cb.mode;
      mon_trans.cmd = vif.mon_cb.cmd;

      mon_trans.res    = vif.mon_cb.res;
      mon_trans.cout   = vif.mon_cb.cout;
      mon_trans.oflow  = vif.mon_cb.oflow;
      mon_trans.g      = vif.mon_cb.g;
      mon_trans.l      = vif.mon_cb.l;
      mon_trans.e      = vif.mon_cb.e;
      mon_trans.err    = vif.mon_cb.err;


        $display("[MONITOR] = opa = %0d, opb = %0d, cin = %0d, inp_valid = %0d, mode = %0d, cmd = %0d", mon_trans.opa, mon_trans.opb, mon_trans.cin, mon_trans.inp_valid, mon_trans.mode, mon_trans.cmd);

      $display("[MONITOR] %0t res=%0d, cout=%0d, oflow=%0d, g=%0d, l=%0d, e=%0d, err=%0d ", $time, mon_trans.res, mon_trans.cout, mon_trans.oflow, mon_trans.g, mon_trans.l, mon_trans.e, mon_trans.err );

      mbx_mon2sb.put(mon_trans);
      mon_cg.sample();
      //repeat(5) @(vif.mon_cb);
      $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f %%", mon_cg.get_coverage());
    end
  endtask

endclass

