`include "defines.sv"

class reference_model_alu;

  transaction_alu ref_trans;
  mailbox #(transaction_alu) mbx_drv2ref;
  mailbox #(transaction_alu) mbx_ref2sb;

  virtual interface_alu.REF vif;
  logic [8:0]store;
  logic e;
  logic g;
  logic l;
  logic oflow;
  logic cout;

  bit is_mul;
  bit got;
  localparam bits_req = $clog2(`WIDTH);
  bit [bits_req-1:0] shift_val;

  function new(mailbox #(transaction_alu) mbx_drv2ref,
               mailbox #(transaction_alu) mbx_ref2sb,
               virtual interface_alu.REF vif);
    this.mbx_drv2ref = mbx_drv2ref;
    this.mbx_ref2sb = mbx_ref2sb;
    this.vif = vif;
  endfunction


  task start();
    repeat(1) @(vif.ref_cb);
    for (int i = 0; i < `no_of_trans; i++) begin
      mbx_drv2ref.get(ref_trans);
      $display("[REFERENCE model] revived at %0t: CE=%0d | inp_valid=%0d | cmd=%0d | OPA =%0d | OPB =%0d  | mode=%0d ",$time,ref_trans.ce,ref_trans.inp_valid, ref_trans.cmd,ref_trans.opa,ref_trans.opb,ref_trans.mode);
      shift_val = ref_trans.opb[bits_req-1:0];
      is_mul = 0;

      ref_trans.cout  = 'z;
      ref_trans.oflow = 'z;
      ref_trans.e     = 'z;
      ref_trans.g     = 'z;
      ref_trans.l     = 'z;
      ref_trans.err   = 'z;
      //ref_trans.res   = 'z;

      if (vif.reset ) begin
  ref_trans.res   ='0;
        ref_trans.l   = 0;
        ref_trans.g     = 0;
        ref_trans.e     = 0;
        ref_trans.cout  = 0;
        ref_trans.oflow = 0;
        ref_trans.err = 0;
        got = 0;
       end

      else if ((ref_trans.mode == 1 && !(ref_trans.cmd inside {0,1,2,3,4,5,6,7,8,9,10})) ||(ref_trans.mode == 0 && !(ref_trans.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13}))) begin
        ref_trans.err = 1;
        got = 0;
      end
      else if ((ref_trans.mode  && (ref_trans.cmd inside {0,1,2,3,8,9,10}) && (ref_trans.inp_valid != 2'b11 && ref_trans.inp_valid!=2'b00)  || ((ref_trans.mode==0) && (ref_trans.cmd inside {0,1,2,3,4,5,12,13}) &&( ref_trans.inp_valid!=2'b00 && ref_trans.inp_valid != 2'b11)))) begin
        got = 0;
        $display("reference model waiting");
        repeat (16) @(posedge vif.ref_cb) begin
          mbx_drv2ref.get(ref_trans);
          if (ref_trans.inp_valid == 2'b11) begin
            got = 1;
            break;
          end
        end
      end
      else begin
        got = 1;
        $display("ref here");
  end

      if (got && (ref_trans.ce!=0))
      begin
        if (ref_trans.mode) begin
          case (ref_trans.inp_valid)
            2'b01: begin
              case (ref_trans.cmd)
                4'd4: ref_trans.res = ref_trans.opa + 1;
                4'd5: begin  ref_trans.res = ref_trans.opa - 1;end
                default: ref_trans.res = 'z;
              endcase
            end

            2'b10: begin
              case (ref_trans.cmd)
                4'd6: ref_trans.res = ref_trans.opb + 1;
                4'd7: ref_trans.res = ref_trans.opb - 1;
 default: ref_trans.res = 'z;
              endcase
            end

            2'b11: begin
              case (ref_trans.cmd)
                  4'd4:begin  ref_trans.res = ref_trans.opa + 1; ref_trans.err='z;ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; end
                  4'd5:begin  ref_trans.res = ref_trans.opa - 1;ref_trans.e='z; ref_trans.err='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; end
                  4'd6:begin ref_trans.res = ref_trans.opb + 1;ref_trans.e='z;ref_trans.l='z; ref_trans.err='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; end
                  4'd7:begin ref_trans.res = ref_trans.opb - 1;ref_trans.e='z;ref_trans.l='z;ref_trans.g='z; ref_trans.err='z;ref_trans.oflow='z;ref_trans.cout='z; end
                4'd0: begin
                  ref_trans.res = ref_trans.opa + ref_trans.opb;
                  ref_trans.cout = ref_trans.res[`WIDTH]; ref_trans.err='z;
                   ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;
                end
                4'd1: begin
                  ref_trans.res = ref_trans.opa - ref_trans.opb;
                  ref_trans.cout = (ref_trans.opa < ref_trans.opb); ref_trans.err='z;
                  ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;
                end
                4'd2: begin
                  ref_trans.res = ref_trans.opa + ref_trans.opb + ref_trans.cin;
                  ref_trans.cout = ref_trans.res[`WIDTH]; ref_trans.err='z;
                  ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;
                end
                4'd3: begin
                  ref_trans.res = ref_trans.opa - ref_trans.opb - ref_trans.cin;
                  ref_trans.cout = (ref_trans.opa >= (ref_trans.opb + ref_trans.cin));
                  ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z; ref_trans.err='z;
                end
                4'd8: begin

                    if (ref_trans.opa > ref_trans.opb) begin
                        ref_trans.g = 1;
                        ref_trans.e ='z;
                        ref_trans.l ='z;
                        ref_trans.res='z;
                        ref_trans.err='z;
                        ref_trans.oflow='z;ref_trans.cout='z;
                    end
                    else if(ref_trans.opa < ref_trans.opb) begin
                        ref_trans.l = 1;
                        ref_trans.g ='z;
                        ref_trans.e ='z;
                        ref_trans.res='z;
                        ref_trans.err='z;
                        ref_trans.oflow='z;ref_trans.cout='z;
                    end
 else begin
                        ref_trans.e = 1;
                        ref_trans.g ='z;
                        ref_trans.l ='z;
                        ref_trans.res='z;
                        ref_trans.err='z;
                        ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z;
                    end
                end
                4'd9: begin
                  ref_trans.res = (ref_trans.opa + 1) * (ref_trans.opb + 1);
                  is_mul = 1;
                  ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                  ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z;
                end
                4'd10: begin
                  ref_trans.res = (ref_trans.opa << 1) * ref_trans.opb;
                  is_mul = 1;
                  ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                  ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z;
                end
                default: ref_trans.res = 'z;
              endcase
            end
            2'b00: begin
                   ref_trans.err=1;
                   ref_trans.res=store;
                   ref_trans.e=e;
                   ref_trans.g=g;
                   ref_trans.l=l;
                   end
            default: ref_trans.res = 'z;
          endcase

        end else begin : mode0_block
          case (ref_trans.inp_valid)
            2'b01: begin
              case (ref_trans.cmd)
                4'd6: ref_trans.res ={1'b0, ~ref_trans.opa};
                4'd8: ref_trans.res ={1'b0, ref_trans.opa >> 1};
                4'd9: ref_trans.res ={1'b0, ref_trans.opa << 1};
                default: ref_trans.res = 'z;
              endcase
            end

            2'b10: begin
              case (ref_trans.cmd)
                4'd7: ref_trans.res ={1'b0, ~ref_trans.opb};
  4'd10: ref_trans.res = {1'b0,ref_trans.opb >> 1};
                4'd11: ref_trans.res = {1'b0,ref_trans.opb << 1};
                default: ref_trans.res = 'z;
              endcase
            end

            2'b11: begin
              case (ref_trans.cmd)
                  4'd6:begin  ref_trans.res = {1'b0,~ref_trans.opa};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z;
                          end
                  4'd8:begin  ref_trans.res = {1'b0,ref_trans.opa >> 1};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                          end
                  4'd9:begin  ref_trans.res = {1'b0,ref_trans.opa << 1};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                          end
                  4'd7:begin  ref_trans.res = {1'b0,~ref_trans.opb};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                          end
                  4'd10:begin ref_trans.res = {1'b0,ref_trans.opb >> 1};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                          end
                  4'd11:begin ref_trans.res = {1'b0,ref_trans.opb << 1};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                             ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                          end
                  4'd0:begin ref_trans.res = {1'b0,ref_trans.opa & ref_trans.opb};
                             ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                             ref_trans.oflow='z;ref_trans.cout='z;  ref_trans.err='z;
                         end
                  4'd1:begin  ref_trans.res = {1'b0, ~(ref_trans.opa & ref_trans.opb)};
                              ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                              ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z;
                          end
                  4'd2:begin ref_trans.res = {1'b0,ref_trans.opa | ref_trans.opb};ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z; end
                  4'd3:begin ref_trans.res = {1'b0,~(ref_trans.opa | ref_trans.opb)};ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z; end
                  4'd4:begin ref_trans.res = {1'b0,ref_trans.opa ^ ref_trans.opb};ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z; end
                  4'd5:begin ref_trans.res = {1'b0,~(ref_trans.opa ^ ref_trans.opb)};ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;ref_trans.oflow='z;ref_trans.cout='z; ref_trans.err='z; end
                4'd12:begin
                  if (|ref_trans.opb[`WIDTH-1:bits_req]) begin
                    ref_trans.err = 1;
                    ref_trans.res = 0;
 ref_trans.e='z;ref_trans.l='z;ref_trans.g='z;
                  end else begin
                    ref_trans.res ={1'b0, (ref_trans.opa << shift_val) | (ref_trans.opa >> (`WIDTH - shift_val))};ref_trans.e='z;ref_trans.l='z;ref_trans.g='z; ref_trans.err='z;
                  end
                end
                4'd13: begin
                  if (|ref_trans.opb[`WIDTH-1:bits_req]) begin
                    ref_trans.err = 1;
                    ref_trans.res = 0;
                    ref_trans.e='z;ref_trans.l='z;ref_trans.g='z; ref_trans.err='z;
                  end else begin
                    ref_trans.res = {1'b0,(ref_trans.opa >> shift_val) | (ref_trans.opa << (`WIDTH - shift_val))};
                    ref_trans.e='z;ref_trans.l='z;ref_trans.g='z; ref_trans.err='z;
                  end
                end
                default:begin
                ref_trans.res = 'z;
                ref_trans.e = 'z;
                ref_trans.g ='z;
                ref_trans.l ='z;
                ref_trans.err='z;
                ref_trans.oflow='z;
                ref_trans.cout='z;
              end
              endcase
            end
          2'b00: begin
                 ref_trans.err=1;
                 ref_trans.res=store;
                 ref_trans.e=e;
     ref_trans.g=g;
                 ref_trans.l=l;
                 ref_trans.oflow=oflow;
                 ref_trans.cout=cout;
             end
          default:begin
                ref_trans.res = 'z;
                ref_trans.e='z;
                ref_trans.g='z;
                ref_trans.l='z;
           end
          endcase
        end

      end
      else
      begin
        if(ref_trans.ce==0)
 begin
          ref_trans.res=store;
          ref_trans.g=g;
          ref_trans.e=e;
          ref_trans.l=l;
          ref_trans.oflow=oflow;
          ref_trans.cout=cout;
        end
        else
        begin

        ref_trans.err   = 1;
        ref_trans.oflow = 'z;
        ref_trans.cout  = 'z;
        ref_trans.g     = 'z;
        ref_trans.e     = 'z;
        ref_trans.l     = 'z;
        ref_trans.res   = 'z;
       end
      end

      // Final delay block happens after got
      if (is_mul)
      begin
        repeat (2) @(posedge vif.ref_cb);
        store=ref_trans.res;
        g=ref_trans.g;
        e=ref_trans.e;
        l=ref_trans.l;
      end
      else
      begin
        repeat (1) @(posedge vif.ref_cb);
        store=ref_trans.res;
        g=ref_trans.g;
        e=ref_trans.e;
        l=ref_trans.l;
      end


     if(ref_trans.cmd !=8 && ref_trans.mode)
      begin
          ref_trans.e='z;
          ref_trans.g='z;
          ref_trans.l='z;
      end
    mbx_ref2sb.put(ref_trans);

      $display("REF INPUTS  : %0t CE=%0d | inp_valid=%0d |  cmd=%0d | mode=%0d | OPA=%0d | OPB=%0d | CIN=%0d", $time, ref_trans.ce,ref_trans.inp_valid, ref_trans.cmd, ref_trans.mode,ref_trans.opa,ref_trans.opb,ref_trans.cin );
               $display("REF OUTPUTS :  RES=%0d | OFLOW=%0d | COUT=%0d | ERR=%0d | OFLOW=%0d | g=%0d | E=%0d | L=%0b",  ref_trans.res,ref_trans.oflow,ref_trans.cout,ref_trans.err, ref_trans.cout, ref_trans.oflow, ref_trans.g, ref_trans.e, ref_trans.l,$time);

    end
  endtask
endclass

