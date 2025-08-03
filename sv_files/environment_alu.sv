`include "defines.sv"
class environment_alu;
  //VIRTUAL INTERFACES FOR DRIVER , MONITOR , REFERENCE MODEL
  virtual interface_alu.DRV drv_vif;
  virtual interface_alu.MON mon_vif;
  virtual interface_alu.REF ref_vif;


  //MAILBOXES
  mailbox #(transaction_alu) mbx_gen2drv;
  mailbox #(transaction_alu) mbx_drv2ref;
  mailbox #(transaction_alu) mbx_ref2sb;
  mailbox #(transaction_alu) mbx_mon2sb;

  //DECLARING HANDLES FOR COMPONENTS
  generator_alu         gen;
  driver_alu            drv;
  monitor_alu           mon;
  reference_model_alu   ref_model;
  scoreboard_alu        sb;

  //METHODS EXPLICITLY OVERRIDING THE CONSTRUCTOR TO CONNECT THE VIRTUAL INTERFACES
  function new(virtual interface_alu.DRV drv_vif,
               virtual interface_alu.MON mon_vif,
               virtual interface_alu.REF ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  //TASK WHICH CREATES OBJECTS FOR ALL MAILBOXES AND COMPONENTS
  task build();
    mbx_gen2drv = new();
    mbx_drv2ref = new();
    mbx_ref2sb  = new();
    mbx_mon2sb  = new();

    //CREATING OBJECTS FOR COMPONENTS AND PASSIGN THE ARGUMENTS
    gen = new(mbx_gen2drv);
    drv = new(mbx_gen2drv, mbx_drv2ref, drv_vif);
    mon = new(mon_vif, mbx_mon2sb);
    ref_model = new(mbx_drv2ref, mbx_ref2sb, ref_vif);
    sb  = new(mbx_ref2sb, mbx_mon2sb);
  endtask

  //TASK WHICH CALLS AND STARTS EACH COMPNENT
  task start();
    fork
   gen.start();
      drv.start();
      mon.start();
      ref_model.start();
      sb.start();
    join
  endtask

endclass

