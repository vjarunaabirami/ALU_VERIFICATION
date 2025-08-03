`include "defines.sv"

class scoreboard_alu;
  transaction_alu ref2sb_trans, mon2sb_trans;

  mailbox #(transaction_alu) mbx_ref2sb;
  mailbox #(transaction_alu) mbx_mon2sb;

  int MATCH = 0, MISMATCH = 0;

  function new(mailbox #(transaction_alu) mbx_ref2sb,
               mailbox #(transaction_alu) mbx_mon2sb);
    this.mbx_ref2sb = mbx_ref2sb;
    this.mbx_mon2sb = mbx_mon2sb;
  endfunction

task start();
  for (int i = 0; i < `no_of_trans; i++)
  begin
    fork
      begin
      mbx_ref2sb.get(ref2sb_trans);
      $display("SCOREBOARD[%0t] RECIVED REFERENCE MODEL OUTPUT [%0t]",i+1,$time);
      $display("REF MODEL OUTPUT  SCOREBOARD => RES = %0d | E = %0b | G = %0b | L = %0b | COUT = %0b | ERR = %0b | OFLOW = %0b",ref2sb_trans.res, ref2sb_trans.e, ref2sb_trans.g, ref2sb_trans.l, ref2sb_trans.cout, ref2sb_trans.err, ref2sb_trans.oflow);
      end

      begin
      mbx_mon2sb.get(mon2sb_trans);
      $display("SCOREBOARD-%0d RECIVED MONITOR OUTPUT [%0t]",i+1,$time);
      $display("MONITOR OUTPUT SCOREBOARD  => RES = %0d | E = %0b | G = %0b | L = %0b | COUT = %0b | ERR = %0b | OFLOW = %0b",
                         mon2sb_trans.res, mon2sb_trans.e, mon2sb_trans.g, mon2sb_trans.l, mon2sb_trans.cout, mon2sb_trans.err, mon2sb_trans.oflow);
      end
    join
    if ((ref2sb_trans.res   === mon2sb_trans.res)   && (ref2sb_trans.e    ===   mon2sb_trans.e)     &&   (ref2sb_trans.g    ===   mon2sb_trans.g)     && (ref2sb_trans.l    ===   mon2sb_trans.l)     &&
       (ref2sb_trans.cout  ===   mon2sb_trans.cout)  &&(ref2sb_trans.err   ===   mon2sb_trans.err)   && (ref2sb_trans.oflow ===   mon2sb_trans.oflow))
   begin
      MATCH++;  $display("EXPECTED RESULT MATCHES ACTUAL RESULT FOR TRANSACTION - %0d",i+1);
      $display("----------completion of transaction  %0d  at %0t----------",i+1,$time);
    end
    else begin
      MISMATCH++;
      $display("EXPECTED RESULT DOES NOT MATCH ACTUAL RESULT FOR TRANSACTION - %0d",i+1);
     $display("----------completion of transaction  %0d  at %0t----------",i+1,$time);
    end
  end
  $display("TOTAL MATCH    = %0d", MATCH);
$display("TOTAL MISMATCH = %0d", MISMATCH);
endtask
endclass


