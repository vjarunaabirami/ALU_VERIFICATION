class test_alu;

  // Virtual interfaces for ALU driver, monitor, and reference model
  virtual interface_alu.DRV drv_vif;
  virtual interface_alu.MON mon_vif;
  virtual interface_alu.REF ref_vif;

  // Environment handle
  environment_alu env;

  // Constructor - bind interfaces
  function new(virtual interface_alu.DRV drv_vif,
               virtual interface_alu.MON mon_vif,
               virtual interface_alu.REF ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  // Main task to run the test
  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    env.start();
  endtask

endclass

class test_t1 extends test_alu;
        single_logical blueprint;
       function new(virtual interface_alu.DRV drv_vif,
               virtual interface_alu.MON mon_vif,
               virtual interface_alu.REF ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

        task run();
                 env = new(drv_vif, mon_vif, ref_vif);
                env.build;

                begin
                        blueprint = new();
                        env.gen.blueprint = this.blueprint;
                end
                env.start;
        endtask
endclass

