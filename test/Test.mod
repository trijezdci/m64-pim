(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

MODULE Test;

IMPORT InOut, TestCARD64IO, TestINT64IO;


(* --------------------------------------------------------------------------
 * Counters
 * ----------------------------------------------------------------------- *)

VAR
  passed, failed, totalPassed, totalFailed : CARDINAL;


(* --------------------------------------------------------------------------
 * Procedure:  InitCounters
 * --------------------------------------------------------------------------
 * Initialise all counters to zero.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitCounters;
BEGIN
  passed := 0;  failed := 0;
  totalPassed := 0;  totalFailed := 0
END InitCounters;


(* --------------------------------------------------------------------------
 * Procedure:  Tally
 * --------------------------------------------------------------------------
 * Add counters to totals.
 * ----------------------------------------------------------------------- *)

PROCEDURE Tally;
BEGIN
  totalPassed := totalPassed + passed;
  totalFailed := totalFailed + failed
END Tally;


(* --------------------------------------------------------------------------
 * Procedure:  Summary
 * --------------------------------------------------------------------------
 * Print totals to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Summary;
BEGIN
  InOut.WriteString("Total tests passed: ");
  InOut.WriteCard(totalPassed, 0); InOut.WriteLn;
  InOut.WriteString("Total tests failed: ");
  InOut.WriteCard(totalFailed, 0); InOut.WriteLn
END Summary;


(* --------------------------------------------------------------------------
 * Main Program
 * ----------------------------------------------------------------------- *)

BEGIN
  InitCounters;
  
  TestCARD64IO.RunTests(passed, failed);
  Tally;
  
  TestINT64IO.RunTests(passed, failed);
  Tally;
  
  Summary
END Test.
