class transaction_alu;

  parameter int WIDTH = 8;
  rand bit ce;
  rand bit [1:0]inp_valid;
  rand bit mode;
  rand bit [3:0] cmd;
  rand bit [WIDTH-1:0] opa;
  rand bit [WIDTH-1:0] opb;
  rand bit cin;
  rand bit inject_err;
       bit err;
       bit [WIDTH-1:0] res;
       bit oflow;
       bit cout;
       bit g;
       bit l;
       bit e;

  /*constraint cmd_range { cmd inside {[0:13]}; }

  constraint ce_range { ce == 1; }

  constraint cin_constr {
    if (cmd inside {2,3})
      cin inside {[0:1]};
    else
      cin == 0;
  }

  constraint rotate_range {
    if (cmd inside {12,13}) {
      opb[($clog2(WIDTH)):0] inside {[0:WIDTH]};
    }
  }

      constraint inp_valid_contr{ inp_valid inside {[0:3]} ; }

  constraint inject_err_constr{
    if (inject_err) {
      if (mode == 1 && (cmd inside {0,1,2,3,8,9,10}))
        inp_valid == 2'b00;
      if (mode == 0 && (cmd inside {0,1,2,3,4,5,12,13}))
        inp_valid == 2'b00;
      if((cmd inside {12,13}) && (mode == 0)) {
        (|opb[WIDTH-1:$clog2(WIDTH)]) == 1;
      }
    }
    else {
      if (mode == 1 && (cmd inside {0,1,2,3,8,9,10}))
        inp_valid inside { 2'b11};
      if (mode == 0 && (cmd inside {0,1,2,3,4,5,12,13}))
        inp_valid inside {2'b11};
      if (mode == 0) {
        if (cmd == 6)  inp_valid == 2'b01; // NOT_A
        if (cmd == 7)  inp_valid == 2'b10; // NOT_B
        if (cmd inside {8,9})  inp_valid == 2'b01; // SHR1_A, SHL1_A
        if (cmd inside {10,11}) inp_valid == 2'b10; // SHR1_B, SHL1_B
      }

      if ((cmd inside {12,13}) && (mode == 0)){
        opb[WIDTH-1:($clog2(WIDTH))] == '0;
      }
    }
  }i*/

  constraint ce_range { soft ce == 1; }
  constraint mode_ran { soft mode inside {[0:1]};}

  virtual function transaction_alu copy();
    transaction_alu c = new();
    c.ce           = this.ce;
    c.inp_valid    = this.inp_valid;
    c.mode         = this.mode;
    c.cmd          = this.cmd;
    c.opa          = this.opa;
    c.opb          = this.opb;
    c.cin          = this.cin;
    c.inject_err   = this.inject_err;
    c.res          = this.res;
    c.err          = this.err;
    c.oflow        = this.oflow;
    c.cout         = this.cout;
    c.g            = this.g;
    c.l            = this.l;
    c.e            = this.e;
    return c;
  endfunction

/*  function void display();
    $display(" CMD=%0d MODE=%0b INP_VALID=%b CIN=%b | OPA=0x%h OPB=0x%h | RES=0x%h ERR=%b OFLOW=%b COUT=%b G=%b L=%b E=%b",
               cmd, mode, inp_valid, cin, opa, opb, res, err, oflow, cout, g, l, e);
 
	endfunction */
endclass

class single_logical extends transaction_alu;
        constraint CMD {cmd inside {[6:11]};}
        constraint MODE {mode == 0;}
  		constraint ce_range { ce == 1; }
  constraint NP_VALID {inp_valid inside {[0:3]};}
        virtual function single_logical copy();
                single_logical c;
                c = new();
          		c.ce = this.ce;
                c.opa = this.opa;
                c.opb = this.opb;
                c.cin = this.cin;
                c.mode = this.mode;
                c.inp_valid = this.inp_valid;
                c.cmd = this.cmd;
                return c;
        endfunction
endclass

class single_arithmetic extends transaction_alu;
        constraint CMD {cmd inside {[4:7]};}
        constraint MODE {mode == 1;}
  		constraint ce_range { ce == 1; }
  		constraint NP_VALID {inp_valid inside {[0:3]};}
        virtual function single_arithmetic copy();
               single_arithmetic c = new();
          		c.ce = this.ce;
                c.opa = this.opa;
                c.opb = this.opb;
                c.cin = this.cin;
                c.mode = this.mode;
                c.inp_valid = this.inp_valid;
                c.cmd = this.cmd;
                return c;
        endfunction
endclass

class two_logical extends transaction_alu;
        constraint CMD {cmd inside {0,1,2,3,4,5,12,13};}
        constraint MODE {mode == 0;}
  		constraint ce_range { ce == 1; }
  constraint NP_VALID {inp_valid inside {[0:3]};}
        virtual function two_logical copy();
                two_logical c = new();
          		c.ce = this.ce;
                c.opa = this.opa;
                c.opb = this.opb;
                c.cin = this.cin;
                c.mode = this.mode;
                c.inp_valid = this.inp_valid;
                c.cmd = this.cmd;
                return c;
        endfunction
endclass

class two_arithmetic extends transaction_alu;
        constraint CMD {cmd inside {0,1,2,3,8,9,10};}
        constraint MODE {mode == 1;}
  		constraint ce_range { ce == 1; }
  constraint NP_VALID {inp_valid inside {[0:3]};}
        virtual function two_arithmetic copy();
                 two_arithmetic c = new();
          		c.ce = this.ce;
                c.opa = this.opa;
                c.opb = this.opb;
                c.cin = this.cin;
                c.mode = this.mode;
                c.inp_valid = this.inp_valid;
                c.cmd = this.cmd;
                return c;
        endfunction
endclass

