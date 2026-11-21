(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

MODULE TestConv;

IMPORT InOut, TestCard64Conv, TestInt64Conv;


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
  totalFailed := totalFailed + failed;
  passed := 0; failed := 0
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
  
  TestCard64Conv.RunTests(passed, failed);
  Tally;
  
  TestInt64Conv.RunTests(passed, failed);
  Tally;
  
  Summary
END TestConv.
