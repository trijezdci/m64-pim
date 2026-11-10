(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE Test64BitConv;

(* Test Suite for 64-bit Whole Number Type Conversions *)


IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT INT64;

FROM INT64 IMPORT INT64T;

IMPORT InOut, CARD64IO, INT64IO;


(* --------------------------------------------------------------------------
 * Procedure:  RunTests(passed, failed)
 * --------------------------------------------------------------------------
 * Data widening, narrowing, constant assignment, and transfer tests.
 * ----------------------------------------------------------------------- *)

PROCEDURE RunTests ( VAR passed, failed : CARDINAL );
BEGIN
  (* clear counters *)
  passed := 0; failed := 0;
  
  InOut.WriteString("Conversion Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  FOR index := 0 TO CardTestCount-1 DO
    CardTest(cardTest[index], passed, failed);
  END; (* FOR *)

  InOut.WriteString("Conversion Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  FOR index := 0 TO IntTestCount-1 DO
    IntTest(intTest[index], passed, failed);
  END (* FOR *)
END RunTests;


(* --------------------------------------------------------------------------
 * Function:  testCount()
 * --------------------------------------------------------------------------
 * Returns the number of tests in this test suite.
 * ----------------------------------------------------------------------- *)

PROCEDURE testCount () : CARDINAL;
BEGIN
  RETURN CardTestCount + IntTestCount
END testCount;


(* --------------------------------------------------------------------------
 * Module initialisation
 * ----------------------------------------------------------------------- *)

BEGIN (* Test64BitConv *)
  InitCardTests;
  InitIntTests
END Test64BitConv.


