(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestCard64RelOps;

(* Test Suite for CARD64 Relational Operations *)


IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT InOut;


(* --------------------------------------------------------------------------
 * Summary labels
 * ----------------------------------------------------------------------- *)

CONST TestsRunLabel    = " tests run   : ";

CONST TestsPassedLabel = " tests passed: ";

CONST TestsFailedLabel = " tests failed: ";


(* --------------------------------------------------------------------------
 * Procedure:  RunTests(passed, failed)
 * --------------------------------------------------------------------------
 * Data widening, narrowing, constant assignment, and transfer tests.
 * ----------------------------------------------------------------------- *)

PROCEDURE RunTests ( VAR passed, failed : CARDINAL );
BEGIN
  (* clear counters *)
  passed := 0; failed := 0;
  
  InOut.WriteString("Constant Comparison Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all constant comparison tests *)
  RunConstCompTests(passed, failed);
  
  InOut.WriteString("Odd/Even Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all odd/even tests *)
  RunOddEvenTests(passed, failed);
  
  InOut.WriteString("Relational Operation Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all conversion tests *)
  RunRelOpTests(passed, failed);
  
  (* print summary *)
  
  InOut.WriteString(TestsRunLabel);
  InOut.WriteCard(testCount(), 0);
  InOut.WriteLn;

  InOut.WriteString(TestsPassedLabel);
  InOut.WriteCard(passed, 0);
  InOut.WriteLn;

  InOut.WriteString(TestsFailedLabel);
  InOut.WriteCard(failed, 0);
  InOut.WriteLn;

  InOut.WriteLn
END RunTests;


(* --------------------------------------------------------------------------
 * Function:  testCount()
 * --------------------------------------------------------------------------
 * Returns the number of tests in this test suite.
 * ----------------------------------------------------------------------- *)

PROCEDURE testCount () : CARDINAL;
BEGIN
  RETURN ConstCompTestCount + OddEvenTestCount + RelOpTestCount;
END testCount;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Pass and fail notices
 * ----------------------------------------------------------------------- *)

CONST PassNotice = " passed";

CONST FailNotice = " failed";


(* --------------------------------------------------------------------------
 * Maximum test label length
 * ----------------------------------------------------------------------- *)

CONST MaxLabelLength = 63;


(* --------------------------------------------------------------------------
 * Test label string type
 * ----------------------------------------------------------------------- *)

TYPE LabelString = ARRAY [0..MaxLabelLength] OF CHAR;


(* --------------------------------------------------------------------------
 * Maximum number string length
 * ----------------------------------------------------------------------- *)

CONST MaxNumberLength = 31;


(* --------------------------------------------------------------------------
 * Number string type
 * ----------------------------------------------------------------------- *)

TYPE NumberString = ARRAY [0..MaxNumberLength] OF CHAR;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64 isZero, isOne and isMax
 * ----------------------------------------------------------------------- *)

TYPE ConstCompProc = PROCEDURE ( VAR CARD64T ) : BOOLEAN;

TYPE ConstCompTest = RECORD
  proc : ConstCompProc;
  operand : CARD64T;
  expected : BOOLEAN;
  label : LabelString
END; (* ConstCompTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitConstCompTests
 * --------------------------------------------------------------------------
 * Initialises tests for SetZero, SetOne, SetMax.
 * ----------------------------------------------------------------------- *)

CONST ConstCompTestCount = 9;

VAR constCompTest : ARRAY [0..ConstCompTestCount-1] OF ConstCompTest;

PROCEDURE InitConstCompTests;
BEGIN
  constCompTest[0].label := "CARD64.isZero(0:0)";
  constCompTest[0].proc := CARD64.isZero;
  constCompTest[0].operand.highBits := 0;
  constCompTest[0].operand.lowBits := 0;
  constCompTest[0].expected := TRUE;
  
  constCompTest[1].label := "CARD64.isZero(0:1)";
  constCompTest[1].proc := CARD64.isZero;
  constCompTest[1].operand.highBits := 0;
  constCompTest[1].operand.lowBits := 1;
  constCompTest[1].expected := FALSE;
  
  constCompTest[2].label := "CARD64.isZero(1:0)";
  constCompTest[2].proc := CARD64.isZero;
  constCompTest[2].operand.highBits := 1;
  constCompTest[2].operand.lowBits := 0;
  constCompTest[2].expected := FALSE;
  
  constCompTest[3].label := "CARD64.isOne(0:0)";
  constCompTest[3].proc := CARD64.isOne;
  constCompTest[3].operand.highBits := 0;
  constCompTest[3].operand.lowBits := 0;
  constCompTest[3].expected := FALSE;
  
  constCompTest[4].label := "CARD64.isOne(0:1)";
  constCompTest[4].proc := CARD64.isOne;
  constCompTest[4].operand.highBits := 0;
  constCompTest[4].operand.lowBits := 1;
  constCompTest[4].expected := TRUE;
  
  constCompTest[5].label := "CARD64.isOne(1:0)";
  constCompTest[5].proc := CARD64.isOne;
  constCompTest[5].operand.highBits := 1;
  constCompTest[5].operand.lowBits := 0;
  constCompTest[5].expected := FALSE;
  
  constCompTest[6].label := "CARD64.isMax(0:0FFFFFFFF)";
  constCompTest[6].proc := CARD64.isMax;
  constCompTest[6].operand.highBits := 0;
  constCompTest[6].operand.lowBits := 0FFFFFFFFH;
  constCompTest[6].expected := FALSE;
  
  constCompTest[7].label := "CARD64.isMax(0FFFFFFFF:0)";
  constCompTest[7].proc := CARD64.isMax;
  constCompTest[7].operand.highBits := 0FFFFFFFFH;
  constCompTest[7].operand.lowBits := 0;
  constCompTest[7].expected := FALSE;
  
  constCompTest[8].label := "CARD64.isMax(0FFFFFFFF:0FFFFFFFF)";
  constCompTest[8].proc := CARD64.isMax;
  constCompTest[8].operand.highBits := 0FFFFFFFFH;
  constCompTest[8].operand.lowBits := 0FFFFFFFFH;
  constCompTest[8].expected := TRUE
END InitConstCompTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunConstCompTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunConstCompTest
  ( test : ConstCompTest; VAR passed, failed : CARDINAL );
VAR
  res : BOOLEAN;
BEGIN
  PrintLabel(test.label);
  
  res := test.proc(test.operand);
  PrintBoolResult(res);
  IF (res = test.expected) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunConstCompTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunConstCompTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ConstCompTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunConstCompTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ConstCompTestCount-1 DO
    RunConstCompTest(constCompTest[index], passed, failed)
  END (* FOR *)
END RunConstCompTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.odd()
 * ----------------------------------------------------------------------- *)

TYPE OddEvenTest = RECORD
  operand : CARD64T;
  expected : BOOLEAN;
  label : LabelString
END; (* OddEvenTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitOddEvenTests
 * --------------------------------------------------------------------------
 * Initialises tests for odd.
 * ----------------------------------------------------------------------- *)

CONST OddEvenTestCount = 11;

VAR oddEvenTest : ARRAY [0..OddEvenTestCount-1] OF OddEvenTest;

PROCEDURE InitOddEvenTests;
BEGIN
  oddEvenTest[0].label := "CARD64.odd(0:0)";
  oddEvenTest[0].operand.highBits := 0;
  oddEvenTest[0].operand.lowBits := 0;
  oddEvenTest[0].expected := FALSE;
  
  oddEvenTest[1].label := "CARD64.odd(0:1)";
  oddEvenTest[1].operand.highBits := 0;
  oddEvenTest[1].operand.lowBits := 1;
  oddEvenTest[1].expected := TRUE;
  
  oddEvenTest[2].label := "CARD64.odd(0:2)";
  oddEvenTest[2].operand.highBits := 0;
  oddEvenTest[2].operand.lowBits := 2;
  oddEvenTest[2].expected := FALSE;
  
  oddEvenTest[3].label := "CARD64.odd(0:3)";
  oddEvenTest[3].operand.highBits := 0;
  oddEvenTest[3].operand.lowBits := 3;
  oddEvenTest[3].expected := TRUE;
  
  oddEvenTest[4].label := "CARD64.odd(0:4)";
  oddEvenTest[4].operand.highBits := 0;
  oddEvenTest[4].operand.lowBits := 4;
  oddEvenTest[4].expected := FALSE;
  
  oddEvenTest[5].label := "CARD64.odd(0:5)";
  oddEvenTest[5].operand.highBits := 0;
  oddEvenTest[5].operand.lowBits := 5;
  oddEvenTest[5].expected := TRUE;
  
  oddEvenTest[6].label := "CARD64.odd(1:0)";
  oddEvenTest[6].operand.highBits := 1;
  oddEvenTest[6].operand.lowBits := 0;
  oddEvenTest[6].expected := FALSE;
  
  oddEvenTest[7].label := "CARD64.odd(1:1)";
  oddEvenTest[7].operand.highBits := 1;
  oddEvenTest[7].operand.lowBits := 1;
  oddEvenTest[7].expected := TRUE;
  
  oddEvenTest[8].label := "CARD64.odd(0FFFFFFFF:0)";
  oddEvenTest[8].operand.highBits := 0FFFFFFFFH;
  oddEvenTest[8].operand.lowBits := 0;
  oddEvenTest[8].expected := FALSE;
  
  oddEvenTest[9].label := "CARD64.odd(0FFFFFFFF:1)";
  oddEvenTest[9].operand.highBits := 0FFFFFFFFH;
  oddEvenTest[9].operand.lowBits := 1;
  oddEvenTest[9].expected := TRUE;

  oddEvenTest[10].label := "CARD64.odd(0FFFFFFFF:0FFFFFFFF)";
  oddEvenTest[10].operand.highBits := 0FFFFFFFFH;
  oddEvenTest[10].operand.lowBits := 0FFFFFFFFH;
  oddEvenTest[10].expected := TRUE
END InitOddEvenTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunOddEvenTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunOddEvenTest
  ( test : OddEvenTest; VAR passed, failed : CARDINAL );
VAR
  res : BOOLEAN;
BEGIN
  PrintLabel(test.label);
  
  res := CARD64.odd(test.operand);
  PrintBoolResult(res);
  IF (res = test.expected) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunOddEvenTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunOddEvenTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all OddEvenTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunOddEvenTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO OddEvenTestCount-1 DO
    RunOddEvenTest(oddEvenTest[index], passed, failed)
  END (* FOR *)
END RunOddEvenTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64 eq, neq, gt, gteq, lt and lteq
 * ----------------------------------------------------------------------- *)

TYPE RelOpProc = PROCEDURE ( VAR CARD64T, VAR CARD64T ) : BOOLEAN;

TYPE RelOpTest = RECORD
  proc : RelOpProc;
  left, right : CARD64T;
  expected : BOOLEAN;
  label : LabelString
END; (* RelOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitRelOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for  eq, neq, gt, gteq, lt and lteq
 * ----------------------------------------------------------------------- *)

CONST RelOpTestCount = 46;

VAR relOpTest : ARRAY [0..RelOpTestCount-1] OF RelOpTest;

PROCEDURE InitRelOpTests;
BEGIN
  relOpTest[0].label := "CARD64.eq(0, 0)";
  relOpTest[0].proc := CARD64.eq;
  relOpTest[0].left.highBits := 0;
  relOpTest[0].left.lowBits := 0;
  relOpTest[0].right.highBits := 0;
  relOpTest[0].right.lowBits := 0;
  relOpTest[0].expected := TRUE;
  
  relOpTest[1].label := "CARD64.eq(0, 1)";
  relOpTest[1].proc := CARD64.eq;
  relOpTest[1].left.highBits := 0;
  relOpTest[1].left.lowBits := 0;
  relOpTest[1].right.highBits := 0;
  relOpTest[1].right.lowBits := 1;
  relOpTest[1].expected := FALSE;
  
  relOpTest[2].label := "CARD64.eq(1, 0)";
  relOpTest[2].proc := CARD64.eq;
  relOpTest[2].left.highBits := 0;
  relOpTest[2].left.lowBits := 1;
  relOpTest[2].right.highBits := 0;
  relOpTest[2].right.lowBits := 0;
  relOpTest[2].expected := FALSE;
  
  relOpTest[3].label := "CARD64.eq(MAX(LONGCARD)+1, 0)";
  relOpTest[3].proc := CARD64.eq;
  relOpTest[3].left.highBits := 1;
  relOpTest[3].left.lowBits := 0;
  relOpTest[3].right.highBits := 0;
  relOpTest[3].right.lowBits := 0;
  relOpTest[3].expected := FALSE;
  
  relOpTest[4].label := "CARD64.eq(MAX(LONGCARD)+2, 1)";
  relOpTest[4].proc := CARD64.eq;
  relOpTest[4].left.highBits := 1;
  relOpTest[4].left.lowBits := 1;
  relOpTest[4].right.highBits := 0;
  relOpTest[4].right.lowBits := 1;
  relOpTest[4].expected := FALSE;
  
  relOpTest[5].label := "CARD64.neq(0, 0)";
  relOpTest[5].proc := CARD64.neq;
  relOpTest[5].left.highBits := 0;
  relOpTest[5].left.lowBits := 0;
  relOpTest[5].right.highBits := 0;
  relOpTest[5].right.lowBits := 0;
  relOpTest[5].expected := FALSE;
  
  relOpTest[6].label := "CARD64.neq(0, 1)";
  relOpTest[6].proc := CARD64.neq;
  relOpTest[6].left.highBits := 0;
  relOpTest[6].left.lowBits := 0;
  relOpTest[6].right.highBits := 0;
  relOpTest[6].right.lowBits := 1;
  relOpTest[6].expected := TRUE;
  
  relOpTest[7].label := "CARD64.neq(1, 0)";
  relOpTest[7].proc := CARD64.neq;
  relOpTest[7].left.highBits := 0;
  relOpTest[7].left.lowBits := 1;
  relOpTest[7].right.highBits := 0;
  relOpTest[7].right.lowBits := 0;
  relOpTest[7].expected := TRUE;
  
  relOpTest[8].label := "CARD64.neq(MAX(LONGCARD)+1, 0)";
  relOpTest[8].proc := CARD64.neq;
  relOpTest[8].left.highBits := 1;
  relOpTest[8].left.lowBits := 0;
  relOpTest[8].right.highBits := 0;
  relOpTest[8].right.lowBits := 0;
  relOpTest[8].expected := TRUE;
  
  relOpTest[9].label := "CARD64.neq(MAX(LONGCARD)+2, 1)";
  relOpTest[9].proc := CARD64.neq;
  relOpTest[9].left.highBits := 1;
  relOpTest[9].left.lowBits := 1;
  relOpTest[9].right.highBits := 0;
  relOpTest[9].right.lowBits := 1;
  relOpTest[9].expected := TRUE;
  
  relOpTest[10].label := "CARD64.lt(0, 0)";
  relOpTest[10].proc := CARD64.lt;
  relOpTest[10].left.highBits := 0;
  relOpTest[10].left.lowBits := 0;
  relOpTest[10].right.highBits := 0;
  relOpTest[10].right.lowBits := 0;
  relOpTest[10].expected := FALSE;
  
  relOpTest[11].label := "CARD64.lt(0, 1)";
  relOpTest[11].proc := CARD64.lt;
  relOpTest[11].left.highBits := 0;
  relOpTest[11].left.lowBits := 0;
  relOpTest[11].right.highBits := 0;
  relOpTest[11].right.lowBits := 1;
  relOpTest[11].expected := TRUE;
  
  relOpTest[12].label := "CARD64.lt(1, 0)";
  relOpTest[12].proc := CARD64.lt;
  relOpTest[12].left.highBits := 0;
  relOpTest[12].left.lowBits := 1;
  relOpTest[12].right.highBits := 0;
  relOpTest[12].right.lowBits := 0;
  relOpTest[12].expected := FALSE;
  
  relOpTest[13].label := "CARD64.lt(1, MAX(LONGCARD)+2)";
  relOpTest[13].proc := CARD64.lt;
  relOpTest[13].left.highBits := 0;
  relOpTest[13].left.lowBits := 1;
  relOpTest[13].right.highBits := 1;
  relOpTest[13].right.lowBits := 1;
  relOpTest[13].expected := TRUE;
  
  relOpTest[14].label := "CARD64.lt(MAX(LONGCARD)+2, 1)";
  relOpTest[14].proc := CARD64.lt;
  relOpTest[14].left.highBits := 1;
  relOpTest[14].left.lowBits := 1;
  relOpTest[14].right.highBits := 0;
  relOpTest[14].right.lowBits := 1;
  relOpTest[14].expected := FALSE;
  
  relOpTest[15].label := "CARD64.lt(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[15].proc := CARD64.lt;
  relOpTest[15].left.highBits := 0;
  relOpTest[15].left.lowBits := 0FFFFFFFFH;
  relOpTest[15].right.highBits := 1;
  relOpTest[15].right.lowBits := 0;
  relOpTest[15].expected := TRUE;
  
  relOpTest[16].label := "CARD64.lt(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[16].proc := CARD64.lt;
  relOpTest[16].left.highBits := 1;
  relOpTest[16].left.lowBits := 0;
  relOpTest[16].right.highBits := 0;
  relOpTest[16].right.lowBits := 0FFFFFFFFH;
  relOpTest[16].expected := FALSE;
  
  relOpTest[17].label := "CARD64.lt(MAX(CARD64T)-1, MAX(CARD64T))";
  relOpTest[17].proc := CARD64.lt;
  relOpTest[17].left.highBits := 0FFFFFFFFH;
  relOpTest[17].left.lowBits := 0FFFFFFFEH;
  relOpTest[17].right.highBits := 0FFFFFFFFH;
  relOpTest[17].right.lowBits := 0FFFFFFFFH;
  relOpTest[17].expected := TRUE;
  
  relOpTest[18].label := "CARD64.lt(MAX(CARD64T), MAX(CARD64T))";
  relOpTest[18].proc := CARD64.lt;
  relOpTest[18].left.highBits := 0FFFFFFFFH;
  relOpTest[18].left.lowBits := 0FFFFFFFFH;
  relOpTest[18].right.highBits := 0FFFFFFFFH;
  relOpTest[18].right.lowBits := 0FFFFFFFFH;
  relOpTest[18].expected := FALSE;
  
  relOpTest[19].label := "CARD64.lteq(0, 0)";
  relOpTest[19].proc := CARD64.lteq;
  relOpTest[19].left.highBits := 0;
  relOpTest[19].left.lowBits := 0;
  relOpTest[19].right.highBits := 0;
  relOpTest[19].right.lowBits := 0;
  relOpTest[19].expected := TRUE;
  
  relOpTest[20].label := "CARD64.lteq(0, 1)";
  relOpTest[20].proc := CARD64.lteq;
  relOpTest[20].left.highBits := 0;
  relOpTest[20].left.lowBits := 0;
  relOpTest[20].right.highBits := 0;
  relOpTest[20].right.lowBits := 1;
  relOpTest[20].expected := TRUE;
  
  relOpTest[21].label := "CARD64.lteq(1, 0)";
  relOpTest[21].proc := CARD64.lteq;
  relOpTest[21].left.highBits := 0;
  relOpTest[21].left.lowBits := 1;
  relOpTest[21].right.highBits := 0;
  relOpTest[21].right.lowBits := 0;
  relOpTest[21].expected := FALSE;
  
  relOpTest[22].label := "CARD64.lteq(1, MAX(LONGCARD)+2)";
  relOpTest[22].proc := CARD64.lteq;
  relOpTest[22].left.highBits := 0;
  relOpTest[22].left.lowBits := 1;
  relOpTest[22].right.highBits := 1;
  relOpTest[22].right.lowBits := 1;
  relOpTest[22].expected := TRUE;
  
  relOpTest[23].label := "CARD64.lteq(MAX(LONGCARD)+2, 1)";
  relOpTest[23].proc := CARD64.lteq;
  relOpTest[23].left.highBits := 1;
  relOpTest[23].left.lowBits := 1;
  relOpTest[23].right.highBits := 0;
  relOpTest[23].right.lowBits := 1;
  relOpTest[23].expected := FALSE;
  
  relOpTest[24].label := "CARD64.lteq(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[24].proc := CARD64.lteq;
  relOpTest[24].left.highBits := 0;
  relOpTest[24].left.lowBits := 0FFFFFFFFH;
  relOpTest[24].right.highBits := 1;
  relOpTest[24].right.lowBits := 0;
  relOpTest[24].expected := TRUE;
  
  relOpTest[25].label := "CARD64.lteq(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[25].proc := CARD64.lteq;
  relOpTest[25].left.highBits := 1;
  relOpTest[25].left.lowBits := 0;
  relOpTest[25].right.highBits := 0;
  relOpTest[25].right.lowBits := 0FFFFFFFFH;
  relOpTest[25].expected := FALSE;
  
  relOpTest[26].label := "CARD64.lteq(MAX(CARD64T)-1, MAX(CARD64T))";
  relOpTest[26].proc := CARD64.lteq;
  relOpTest[26].left.highBits := 0FFFFFFFFH;
  relOpTest[26].left.lowBits := 0FFFFFFFEH;
  relOpTest[26].right.highBits := 0FFFFFFFFH;
  relOpTest[26].right.lowBits := 0FFFFFFFFH;
  relOpTest[26].expected := TRUE;
  
  relOpTest[27].label := "CARD64.lteq(MAX(CARD64T), MAX(CARD64T))";
  relOpTest[27].proc := CARD64.lteq;
  relOpTest[27].left.highBits := 0FFFFFFFFH;
  relOpTest[27].left.lowBits := 0FFFFFFFFH;
  relOpTest[27].right.highBits := 0FFFFFFFFH;
  relOpTest[27].right.lowBits := 0FFFFFFFFH;
  relOpTest[27].expected := TRUE;
  
  relOpTest[28].label := "CARD64.gt(0, 0)";
  relOpTest[28].proc := CARD64.gt;
  relOpTest[28].left.highBits := 0;
  relOpTest[28].left.lowBits := 0;
  relOpTest[28].right.highBits := 0;
  relOpTest[28].right.lowBits := 0;
  relOpTest[28].expected := FALSE;
  
  relOpTest[29].label := "CARD64.gt(0, 1)";
  relOpTest[29].proc := CARD64.gt;
  relOpTest[29].left.highBits := 0;
  relOpTest[29].left.lowBits := 0;
  relOpTest[29].right.highBits := 0;
  relOpTest[29].right.lowBits := 1;
  relOpTest[29].expected := FALSE;
  
  relOpTest[30].label := "CARD64.gt(1, 0)";
  relOpTest[30].proc := CARD64.gt;
  relOpTest[30].left.highBits := 0;
  relOpTest[30].left.lowBits := 1;
  relOpTest[30].right.highBits := 0;
  relOpTest[30].right.lowBits := 0;
  relOpTest[30].expected := TRUE;
  
  relOpTest[31].label := "CARD64.gt(1, MAX(LONGCARD)+2)";
  relOpTest[31].proc := CARD64.gt;
  relOpTest[31].left.highBits := 0;
  relOpTest[31].left.lowBits := 1;
  relOpTest[31].right.highBits := 1;
  relOpTest[31].right.lowBits := 1;
  relOpTest[31].expected := FALSE;
  
  relOpTest[32].label := "CARD64.gt(MAX(LONGCARD)+2, 1)";
  relOpTest[32].proc := CARD64.gt;
  relOpTest[32].left.highBits := 1;
  relOpTest[32].left.lowBits := 1;
  relOpTest[32].right.highBits := 0;
  relOpTest[32].right.lowBits := 1;
  relOpTest[32].expected := TRUE;
  
  relOpTest[33].label := "CARD64.gt(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[33].proc := CARD64.gt;
  relOpTest[33].left.highBits := 0;
  relOpTest[33].left.lowBits := 0FFFFFFFFH;
  relOpTest[33].right.highBits := 1;
  relOpTest[33].right.lowBits := 0;
  relOpTest[33].expected := FALSE;
  
  relOpTest[34].label := "CARD64.gt(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[34].proc := CARD64.gt;
  relOpTest[34].left.highBits := 1;
  relOpTest[34].left.lowBits := 0;
  relOpTest[34].right.highBits := 0;
  relOpTest[34].right.lowBits := 0FFFFFFFFH;
  relOpTest[34].expected := TRUE;
  
  relOpTest[35].label := "CARD64.gt(MAX(CARD64T)-1, MAX(CARD64T))";
  relOpTest[35].proc := CARD64.gt;
  relOpTest[35].left.highBits := 0FFFFFFFFH;
  relOpTest[35].left.lowBits := 0FFFFFFFEH;
  relOpTest[35].right.highBits := 0FFFFFFFFH;
  relOpTest[35].right.lowBits := 0FFFFFFFFH;
  relOpTest[35].expected := FALSE;

  relOpTest[36].label := "CARD64.gt(MAX(CARD64T), MAX(CARD64T))";
  relOpTest[36].proc := CARD64.gt;
  relOpTest[36].left.highBits := 0FFFFFFFFH;
  relOpTest[36].left.lowBits := 0FFFFFFFFH;
  relOpTest[36].right.highBits := 0FFFFFFFFH;
  relOpTest[36].right.lowBits := 0FFFFFFFFH;
  relOpTest[36].expected := FALSE;
  
  relOpTest[37].label := "CARD64.gteq(0, 0)";
  relOpTest[37].proc := CARD64.gteq;
  relOpTest[37].left.highBits := 0;
  relOpTest[37].left.lowBits := 0;
  relOpTest[37].right.highBits := 0;
  relOpTest[37].right.lowBits := 0;
  relOpTest[37].expected := TRUE;
  
  relOpTest[38].label := "CARD64.gteq(0, 1)";
  relOpTest[38].proc := CARD64.gteq;
  relOpTest[38].left.highBits := 0;
  relOpTest[38].left.lowBits := 0;
  relOpTest[38].right.highBits := 0;
  relOpTest[38].right.lowBits := 1;
  relOpTest[38].expected := FALSE;
  
  relOpTest[39].label := "CARD64.gteq(1, 0)";
  relOpTest[39].proc := CARD64.gteq;
  relOpTest[39].left.highBits := 0;
  relOpTest[39].left.lowBits := 1;
  relOpTest[39].right.highBits := 0;
  relOpTest[39].right.lowBits := 0;
  relOpTest[39].expected := TRUE;
  
  relOpTest[40].label := "CARD64.gteq(1, MAX(LONGCARD)+2)";
  relOpTest[40].proc := CARD64.gteq;
  relOpTest[40].left.highBits := 0;
  relOpTest[40].left.lowBits := 1;
  relOpTest[40].right.highBits := 1;
  relOpTest[40].right.lowBits := 1;
  relOpTest[40].expected := FALSE;
  
  relOpTest[41].label := "CARD64.gteq(MAX(LONGCARD)+2, 1)";
  relOpTest[41].proc := CARD64.gteq;
  relOpTest[41].left.highBits := 1;
  relOpTest[41].left.lowBits := 1;
  relOpTest[41].right.highBits := 0;
  relOpTest[41].right.lowBits := 1;
  relOpTest[41].expected := TRUE;
  
  relOpTest[42].label := "CARD64.gteq(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[42].proc := CARD64.gteq;
  relOpTest[42].left.highBits := 0;
  relOpTest[42].left.lowBits := 0FFFFFFFFH;
  relOpTest[42].right.highBits := 1;
  relOpTest[42].right.lowBits := 0;
  relOpTest[42].expected := FALSE;
  
  relOpTest[43].label := "CARD64.gteq(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[43].proc := CARD64.gteq;
  relOpTest[43].left.highBits := 1;
  relOpTest[43].left.lowBits := 0;
  relOpTest[43].right.highBits := 0;
  relOpTest[43].right.lowBits := 0FFFFFFFFH;
  relOpTest[43].expected := TRUE;
  
  relOpTest[44].label := "CARD64.gteq(MAX(CARD64T)-1, MAX(CARD64T))";
  relOpTest[44].proc := CARD64.gteq;
  relOpTest[44].left.highBits := 0FFFFFFFFH;
  relOpTest[44].left.lowBits := 0FFFFFFFEH;
  relOpTest[44].right.highBits := 0FFFFFFFFH;
  relOpTest[44].right.lowBits := 0FFFFFFFFH;
  relOpTest[44].expected := FALSE;
  
  relOpTest[45].label := "CARD64.gteq(MAX(CARD64T), MAX(CARD64T))";
  relOpTest[45].proc := CARD64.gteq;
  relOpTest[45].left.highBits := 0FFFFFFFFH;
  relOpTest[45].left.lowBits := 0FFFFFFFFH;
  relOpTest[45].right.highBits := 0FFFFFFFFH;
  relOpTest[45].right.lowBits := 0FFFFFFFFH;
  relOpTest[45].expected := TRUE
END InitRelOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunRelOpTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunRelOpTest
  ( test : RelOpTest; VAR passed, failed : CARDINAL );
VAR
  res : BOOLEAN;
BEGIN
  PrintLabel(test.label);
  
  res := test.proc(test.left, test.right);
  PrintBoolResult(res);
  IF (res = test.expected) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunRelOpTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunRelOpTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all RelOpTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunRelOpTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO RelOpTestCount-1 DO
    RunRelOpTest(relOpTest[index], passed, failed)
  END (* FOR *)
END RunRelOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLabel(label)
 * --------------------------------------------------------------------------
 * Prints test label string. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabel ( label : LabelString );
BEGIN
  InOut.WriteString("*** ");
  InOut.WriteString(label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabel;


(* --------------------------------------------------------------------------
 * Procedure:  PrintBoolResult(bool)
 * --------------------------------------------------------------------------
 * Prints result label followed by value bool. 
 * ----------------------------------------------------------------------- *)

CONST ResultLabel = " result: ";

PROCEDURE PrintBoolResult ( bool : BOOLEAN );
BEGIN
  InOut.WriteString(ResultLabel);
  IF bool THEN
    InOut.WriteString("TRUE")
  ELSE
    InOut.WriteString("FALSE")
  END; (* IF *)
  InOut.WriteLn
END PrintBoolResult;


(* --------------------------------------------------------------------------
 * Module initialisation
 * ----------------------------------------------------------------------- *)

BEGIN (* TestCard64RelOps *)
  InitConstCompTests;
  InitOddEvenTests;
  InitRelOpTests
END TestCard64RelOps.
