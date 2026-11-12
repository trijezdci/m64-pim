(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestInt64RelOps;

(* Test Suite for INT64 Relational Operations *)


IMPORT INT64;

FROM INT64 IMPORT INT64T;

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
  
  InOut.WriteString("Constant Comparison Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all constant comparison tests *)
  RunConstCompTests(passed, failed);
  
  InOut.WriteString("Odd/Even Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all odd/even tests *)
  RunOddEvenTests(passed, failed);
  
  InOut.WriteString("Relational Operation Tests for INT64");
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
 * Test parameter type for INT64 isZero, isOne and isMax
 * ----------------------------------------------------------------------- *)

TYPE ConstCompProc = PROCEDURE ( VAR INT64T ) : BOOLEAN;

TYPE ConstCompTest = RECORD
  proc : ConstCompProc;
  operand : INT64T;
  expected : BOOLEAN;
  label : LabelString
END; (* ConstCompTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitConstCompTests
 * --------------------------------------------------------------------------
 * Initialises tests for SetZero, SetOne, SetMin, SetMax.
 * ----------------------------------------------------------------------- *)

CONST ConstCompTestCount = 12;

VAR constCompTest : ARRAY [0..ConstCompTestCount-1] OF ConstCompTest;

PROCEDURE InitConstCompTests;
BEGIN
  constCompTest[0].label := "INT64.isZero(0:0)";
  constCompTest[0].proc := INT64.isZero;
  constCompTest[0].operand.highBits := 0;
  constCompTest[0].operand.lowBits := 0;
  constCompTest[0].expected := TRUE;
  
  constCompTest[1].label := "INT64.isZero(0:1)";
  constCompTest[1].proc := INT64.isZero;
  constCompTest[1].operand.highBits := 0;
  constCompTest[1].operand.lowBits := 1;
  constCompTest[1].expected := FALSE;
  
  constCompTest[2].label := "INT64.isZero(1:0)";
  constCompTest[2].proc := INT64.isZero;
  constCompTest[2].operand.highBits := 1;
  constCompTest[2].operand.lowBits := 0;
  constCompTest[2].expected := FALSE;
  
  constCompTest[3].label := "INT64.isOne(0:0)";
  constCompTest[3].proc := INT64.isOne;
  constCompTest[3].operand.highBits := 0;
  constCompTest[3].operand.lowBits := 0;
  constCompTest[3].expected := FALSE;
  
  constCompTest[4].label := "INT64.isOne(0:1)";
  constCompTest[4].proc := INT64.isOne;
  constCompTest[4].operand.highBits := 0;
  constCompTest[4].operand.lowBits := 1;
  constCompTest[4].expected := TRUE;
  
  constCompTest[5].label := "INT64.isOne(1:0)";
  constCompTest[5].proc := INT64.isOne;
  constCompTest[5].operand.highBits := 1;
  constCompTest[5].operand.lowBits := 0;
  constCompTest[5].expected := FALSE;
  
  constCompTest[6].label := "INT64.isMin(0:0)";
  constCompTest[6].proc := INT64.isMin;
  constCompTest[6].operand.highBits := 0;
  constCompTest[6].operand.lowBits := 0;
  constCompTest[6].expected := FALSE;
  
  constCompTest[7].label := "INT64.isMin(080000000:1)";
  constCompTest[7].proc := INT64.isMin;
  constCompTest[7].operand.highBits := -2147483648;
  constCompTest[7].operand.lowBits := 1;
  constCompTest[7].expected := FALSE;
  
  constCompTest[8].label := "INT64.isMin(080000000:0)";
  constCompTest[8].proc := INT64.isMin;
  constCompTest[8].operand.highBits := -2147483648;
  constCompTest[8].operand.lowBits := 0;
  constCompTest[8].expected := TRUE;
  
  constCompTest[9].label := "INT64.isMax(0:0FFFFFFFF)";
  constCompTest[9].proc := INT64.isMax;
  constCompTest[9].operand.highBits := 0;
  constCompTest[9].operand.lowBits := 0FFFFFFFFH;
  constCompTest[9].expected := FALSE;
  
  constCompTest[10].label := "INT64.isMax(07FFFFFFF:0FFFFFFFE)";
  constCompTest[10].proc := INT64.isMax;
  constCompTest[10].operand.highBits := 2147483647;
  constCompTest[10].operand.lowBits := 0FFFFFFFEH;
  constCompTest[10].expected := FALSE;
  
  constCompTest[11].label := "INT64.isMax(07FFFFFFF:0FFFFFFFF)";
  constCompTest[11].proc := INT64.isMax;
  constCompTest[11].operand.highBits := 2147483647;
  constCompTest[11].operand.lowBits := 0FFFFFFFFH;
  constCompTest[11].expected := TRUE
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
 * Test parameter type for INT64.odd()
 * ----------------------------------------------------------------------- *)

TYPE OddEvenTest = RECORD
  operand : INT64T;
  expected : BOOLEAN;
  label : LabelString
END; (* OddEvenTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitOddEvenTests
 * --------------------------------------------------------------------------
 * Initialises tests for odd.
 * ----------------------------------------------------------------------- *)

CONST OddEvenTestCount = 13;

VAR oddEvenTest : ARRAY [0..OddEvenTestCount-1] OF OddEvenTest;

PROCEDURE InitOddEvenTests;
BEGIN
  oddEvenTest[0].label := "INT64.odd(0:0)";
  oddEvenTest[0].operand.highBits := 0;
  oddEvenTest[0].operand.lowBits := 0;
  oddEvenTest[0].expected := FALSE;
  
  oddEvenTest[1].label := "INT64.odd(0:1)";
  oddEvenTest[1].operand.highBits := 0;
  oddEvenTest[1].operand.lowBits := 1;
  oddEvenTest[1].expected := TRUE;
  
  oddEvenTest[2].label := "INT64.odd(0:2)";
  oddEvenTest[2].operand.highBits := 0;
  oddEvenTest[2].operand.lowBits := 2;
  oddEvenTest[2].expected := FALSE;
  
  oddEvenTest[3].label := "INT64.odd(0:3)";
  oddEvenTest[3].operand.highBits := 0;
  oddEvenTest[3].operand.lowBits := 3;
  oddEvenTest[3].expected := TRUE;
  
  oddEvenTest[4].label := "INT64.odd(0:4)";
  oddEvenTest[4].operand.highBits := 0;
  oddEvenTest[4].operand.lowBits := 4;
  oddEvenTest[4].expected := FALSE;
  
  oddEvenTest[5].label := "INT64.odd(0:5)";
  oddEvenTest[5].operand.highBits := 0;
  oddEvenTest[5].operand.lowBits := 5;
  oddEvenTest[5].expected := TRUE;
  
  oddEvenTest[6].label := "INT64.odd(1:0)";
  oddEvenTest[6].operand.highBits := 1;
  oddEvenTest[6].operand.lowBits := 0;
  oddEvenTest[6].expected := FALSE;
  
  oddEvenTest[7].label := "INT64.odd(1:1)";
  oddEvenTest[7].operand.highBits := 1;
  oddEvenTest[7].operand.lowBits := 1;
  oddEvenTest[7].expected := TRUE;
  
  oddEvenTest[8].label := "INT64.odd(-1:0)";
  oddEvenTest[8].operand.highBits := -1;
  oddEvenTest[8].operand.lowBits := 0;
  oddEvenTest[8].expected := FALSE;
  
  oddEvenTest[9].label := "INT64.odd(-1:1)";
  oddEvenTest[9].operand.highBits := -1;
  oddEvenTest[9].operand.lowBits := 1;
  oddEvenTest[9].expected := TRUE;

  oddEvenTest[10].label := "INT64.odd(-1:0FFFFFFFE)";
  oddEvenTest[10].operand.highBits := -1;
  oddEvenTest[10].operand.lowBits := 0FFFFFFFEH;
  oddEvenTest[10].expected := FALSE;

  oddEvenTest[11].label := "INT64.odd(-1:0FFFFFFFF)";
  oddEvenTest[11].operand.highBits := -1;
  oddEvenTest[11].operand.lowBits := 0FFFFFFFFH;
  oddEvenTest[11].expected := TRUE;

  oddEvenTest[12].label := "INT64.odd(080000000:0)";
  oddEvenTest[12].operand.highBits := -2147483648;
  oddEvenTest[12].operand.lowBits := 0;
  oddEvenTest[12].expected := FALSE
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
  
  res := INT64.odd(test.operand);
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
 * Test parameter type for INT64 eq, neq, gt, gteq, lt and lteq
 * ----------------------------------------------------------------------- *)

TYPE RelOpProc = PROCEDURE ( VAR INT64T, VAR INT64T ) : BOOLEAN;

TYPE RelOpTest = RECORD
  proc : RelOpProc;
  left, right : INT64T;
  expected : BOOLEAN;
  label : LabelString
END; (* RelOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitRelOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for  eq, neq, gt, gteq, lt and lteq
 * ----------------------------------------------------------------------- *)

CONST RelOpTestCount = 50;

VAR relOpTest : ARRAY [0..RelOpTestCount-1] OF RelOpTest;

PROCEDURE InitRelOpTests;
BEGIN
  relOpTest[0].label := "INT64.eq(0, 0)";
  relOpTest[0].proc := INT64.eq;
  relOpTest[0].left.highBits := 0;
  relOpTest[0].left.lowBits := 0;
  relOpTest[0].right.highBits := 0;
  relOpTest[0].right.lowBits := 0;
  relOpTest[0].expected := TRUE;
  
  relOpTest[1].label := "INT64.eq(0, 1)";
  relOpTest[1].proc := INT64.eq;
  relOpTest[1].left.highBits := 0;
  relOpTest[1].left.lowBits := 0;
  relOpTest[1].right.highBits := 0;
  relOpTest[1].right.lowBits := 1;
  relOpTest[1].expected := FALSE;
  
  relOpTest[2].label := "INT64.eq(1, 0)";
  relOpTest[2].proc := INT64.eq;
  relOpTest[2].left.highBits := 0;
  relOpTest[2].left.lowBits := 1;
  relOpTest[2].right.highBits := 0;
  relOpTest[2].right.lowBits := 0;
  relOpTest[2].expected := FALSE;
  
  relOpTest[3].label := "INT64.eq(MAX(LONGCARD)+1, 0)";
  relOpTest[3].proc := INT64.eq;
  relOpTest[3].left.highBits := 1;
  relOpTest[3].left.lowBits := 0;
  relOpTest[3].right.highBits := 0;
  relOpTest[3].right.lowBits := 0;
  relOpTest[3].expected := FALSE;
  
  relOpTest[4].label := "INT64.eq(MAX(LONGCARD)+2, 1)";
  relOpTest[4].proc := INT64.eq;
  relOpTest[4].left.highBits := 1;
  relOpTest[4].left.lowBits := 1;
  relOpTest[4].right.highBits := 0;
  relOpTest[4].right.lowBits := 1;
  relOpTest[4].expected := FALSE;
  
  relOpTest[5].label := "INT64.eq(-1, -1)";
  relOpTest[5].proc := INT64.eq;
  relOpTest[5].left.highBits := -1;
  relOpTest[5].left.lowBits := 0FFFFFFFFH;
  relOpTest[5].right.highBits := -1;
  relOpTest[5].right.lowBits := 0FFFFFFFFH;
  relOpTest[5].expected := TRUE;

  relOpTest[6].label := "INT64.eq(-1, 0)";
  relOpTest[6].proc := INT64.eq;
  relOpTest[6].left.highBits := -1;
  relOpTest[6].left.lowBits := 0FFFFFFFFH;
  relOpTest[6].right.highBits := 0;
  relOpTest[6].right.lowBits := 0;
  relOpTest[6].expected := FALSE;

  relOpTest[7].label := "INT64.neq(0, 0)";
  relOpTest[7].proc := INT64.neq;
  relOpTest[7].left.highBits := 0;
  relOpTest[7].left.lowBits := 0;
  relOpTest[7].right.highBits := 0;
  relOpTest[7].right.lowBits := 0;
  relOpTest[7].expected := FALSE;
  
  relOpTest[8].label := "INT64.neq(0, 1)";
  relOpTest[8].proc := INT64.neq;
  relOpTest[8].left.highBits := 0;
  relOpTest[8].left.lowBits := 0;
  relOpTest[8].right.highBits := 0;
  relOpTest[8].right.lowBits := 1;
  relOpTest[8].expected := TRUE;
  
  relOpTest[9].label := "INT64.neq(1, 0)";
  relOpTest[9].proc := INT64.neq;
  relOpTest[9].left.highBits := 0;
  relOpTest[9].left.lowBits := 1;
  relOpTest[9].right.highBits := 0;
  relOpTest[9].right.lowBits := 0;
  relOpTest[9].expected := TRUE;
  
  relOpTest[10].label := "INT64.neq(MAX(LONGCARD)+1, 0)";
  relOpTest[10].proc := INT64.neq;
  relOpTest[10].left.highBits := 1;
  relOpTest[10].left.lowBits := 0;
  relOpTest[10].right.highBits := 0;
  relOpTest[10].right.lowBits := 0;
  relOpTest[10].expected := TRUE;
  
  relOpTest[11].label := "INT64.neq(MAX(LONGCARD)+2, 1)";
  relOpTest[11].proc := INT64.neq;
  relOpTest[11].left.highBits := 1;
  relOpTest[11].left.lowBits := 1;
  relOpTest[11].right.highBits := 0;
  relOpTest[11].right.lowBits := 1;
  relOpTest[11].expected := TRUE;
  
  relOpTest[12].label := "INT64.neq(-1, -1)";
  relOpTest[12].proc := INT64.neq;
  relOpTest[12].left.highBits := -1;
  relOpTest[12].left.lowBits := 0FFFFFFFFH;
  relOpTest[12].right.highBits := -1;
  relOpTest[12].right.lowBits := 0FFFFFFFFH;
  relOpTest[12].expected := FALSE;

  relOpTest[13].label := "INT64.neq(-1, 0)";
  relOpTest[13].proc := INT64.neq;
  relOpTest[13].left.highBits := -1;
  relOpTest[13].left.lowBits := 0FFFFFFFFH;
  relOpTest[13].right.highBits := 0;
  relOpTest[13].right.lowBits := 0;
  relOpTest[13].expected := TRUE;

  relOpTest[14].label := "INT64.lt(0, 0)";
  relOpTest[14].proc := INT64.lt;
  relOpTest[14].left.highBits := 0;
  relOpTest[14].left.lowBits := 0;
  relOpTest[14].right.highBits := 0;
  relOpTest[14].right.lowBits := 0;
  relOpTest[14].expected := FALSE;
  
  relOpTest[15].label := "INT64.lt(0, 1)";
  relOpTest[15].proc := INT64.lt;
  relOpTest[15].left.highBits := 0;
  relOpTest[15].left.lowBits := 0;
  relOpTest[15].right.highBits := 0;
  relOpTest[15].right.lowBits := 1;
  relOpTest[15].expected := TRUE;
  
  relOpTest[16].label := "INT64.lt(1, 0)";
  relOpTest[16].proc := INT64.lt;
  relOpTest[16].left.highBits := 0;
  relOpTest[16].left.lowBits := 1;
  relOpTest[16].right.highBits := 0;
  relOpTest[16].right.lowBits := 0;
  relOpTest[16].expected := FALSE;
  
  relOpTest[17].label := "INT64.lt(1, MAX(LONGCARD)+2)";
  relOpTest[17].proc := INT64.lt;
  relOpTest[17].left.highBits := 0;
  relOpTest[17].left.lowBits := 1;
  relOpTest[17].right.highBits := 1;
  relOpTest[17].right.lowBits := 1;
  relOpTest[17].expected := TRUE;
  
  relOpTest[18].label := "INT64.lt(MAX(LONGCARD)+2, 1)";
  relOpTest[18].proc := INT64.lt;
  relOpTest[18].left.highBits := 1;
  relOpTest[18].left.lowBits := 1;
  relOpTest[18].right.highBits := 0;
  relOpTest[18].right.lowBits := 1;
  relOpTest[18].expected := FALSE;
  
  relOpTest[19].label := "INT64.lt(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[19].proc := INT64.lt;
  relOpTest[19].left.highBits := 0;
  relOpTest[19].left.lowBits := 0FFFFFFFFH;
  relOpTest[19].right.highBits := 1;
  relOpTest[19].right.lowBits := 0;
  relOpTest[19].expected := TRUE;
  
  relOpTest[20].label := "INT64.lt(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[20].proc := INT64.lt;
  relOpTest[20].left.highBits := 1;
  relOpTest[20].left.lowBits := 0;
  relOpTest[20].right.highBits := 0;
  relOpTest[20].right.lowBits := 0FFFFFFFFH;
  relOpTest[20].expected := FALSE;
  
  relOpTest[21].label := "INT64.lt(MAX(INT64T)-1, MAX(INT64T))";
  relOpTest[21].proc := INT64.lt;
  relOpTest[21].left.highBits := 2147483647;
  relOpTest[21].left.lowBits := 0FFFFFFFEH;
  relOpTest[21].right.highBits := 2147483647;
  relOpTest[21].right.lowBits := 0FFFFFFFFH;
  relOpTest[21].expected := TRUE;
  
  relOpTest[22].label := "INT64.lt(MAX(INT64T), MAX(INT64T))";
  relOpTest[22].proc := INT64.lt;
  relOpTest[22].left.highBits := 2147483647;
  relOpTest[22].left.lowBits := 0FFFFFFFFH;
  relOpTest[22].right.highBits := 2147483647;
  relOpTest[22].right.lowBits := 0FFFFFFFFH;
  relOpTest[22].expected := FALSE;

  relOpTest[23].label := "INT64.lteq(0, 0)";
  relOpTest[23].proc := INT64.lteq;
  relOpTest[23].left.highBits := 0;
  relOpTest[23].left.lowBits := 0;
  relOpTest[23].right.highBits := 0;
  relOpTest[23].right.lowBits := 0;
  relOpTest[23].expected := TRUE;
  
  relOpTest[24].label := "INT64.lteq(0, 1)";
  relOpTest[24].proc := INT64.lteq;
  relOpTest[24].left.highBits := 0;
  relOpTest[24].left.lowBits := 0;
  relOpTest[24].right.highBits := 0;
  relOpTest[24].right.lowBits := 1;
  relOpTest[24].expected := TRUE;
  
  relOpTest[25].label := "INT64.lteq(1, 0)";
  relOpTest[25].proc := INT64.lteq;
  relOpTest[25].left.highBits := 0;
  relOpTest[25].left.lowBits := 1;
  relOpTest[25].right.highBits := 0;
  relOpTest[25].right.lowBits := 0;
  relOpTest[25].expected := FALSE;
  
  relOpTest[26].label := "INT64.lteq(1, MAX(LONGCARD)+2)";
  relOpTest[26].proc := INT64.lteq;
  relOpTest[26].left.highBits := 0;
  relOpTest[26].left.lowBits := 1;
  relOpTest[26].right.highBits := 1;
  relOpTest[26].right.lowBits := 1;
  relOpTest[26].expected := TRUE;
  
  relOpTest[27].label := "INT64.lteq(MAX(LONGCARD)+2, 1)";
  relOpTest[27].proc := INT64.lteq;
  relOpTest[27].left.highBits := 1;
  relOpTest[27].left.lowBits := 1;
  relOpTest[27].right.highBits := 0;
  relOpTest[27].right.lowBits := 1;
  relOpTest[27].expected := FALSE;
  
  relOpTest[28].label := "INT64.lteq(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[28].proc := INT64.lteq;
  relOpTest[28].left.highBits := 0;
  relOpTest[28].left.lowBits := 0FFFFFFFFH;
  relOpTest[28].right.highBits := 1;
  relOpTest[28].right.lowBits := 0;
  relOpTest[28].expected := TRUE;
  
  relOpTest[29].label := "INT64.lteq(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[29].proc := INT64.lteq;
  relOpTest[29].left.highBits := 1;
  relOpTest[29].left.lowBits := 0;
  relOpTest[29].right.highBits := 0;
  relOpTest[29].right.lowBits := 0FFFFFFFFH;
  relOpTest[29].expected := FALSE;
  
  relOpTest[30].label := "INT64.lteq(MAX(INT64T)-1, MAX(INT64T))";
  relOpTest[30].proc := INT64.lteq;
  relOpTest[30].left.highBits := 2147483647;
  relOpTest[30].left.lowBits := 0FFFFFFFEH;
  relOpTest[30].right.highBits := 2147483647;
  relOpTest[30].right.lowBits := 0FFFFFFFFH;
  relOpTest[30].expected := TRUE;
  
  relOpTest[31].label := "INT64.lteq(MAX(INT64T), MAX(INT64T))";
  relOpTest[31].proc := INT64.lteq;
  relOpTest[31].left.highBits := 2147483647;
  relOpTest[31].left.lowBits := 0FFFFFFFFH;
  relOpTest[31].right.highBits := 2147483647;
  relOpTest[31].right.lowBits := 0FFFFFFFFH;
  relOpTest[31].expected := TRUE;

  relOpTest[32].label := "INT64.gt(0, 0)";
  relOpTest[32].proc := INT64.gt;
  relOpTest[32].left.highBits := 0;
  relOpTest[32].left.lowBits := 0;
  relOpTest[32].right.highBits := 0;
  relOpTest[32].right.lowBits := 0;
  relOpTest[32].expected := FALSE;
  
  relOpTest[33].label := "INT64.gt(0, 1)";
  relOpTest[33].proc := INT64.gt;
  relOpTest[33].left.highBits := 0;
  relOpTest[33].left.lowBits := 0;
  relOpTest[33].right.highBits := 0;
  relOpTest[33].right.lowBits := 1;
  relOpTest[33].expected := FALSE;
  
  relOpTest[34].label := "INT64.gt(1, 0)";
  relOpTest[34].proc := INT64.gt;
  relOpTest[34].left.highBits := 0;
  relOpTest[34].left.lowBits := 1;
  relOpTest[34].right.highBits := 0;
  relOpTest[34].right.lowBits := 0;
  relOpTest[34].expected := TRUE;
  
  relOpTest[35].label := "INT64.gt(1, MAX(LONGCARD)+2)";
  relOpTest[35].proc := INT64.gt;
  relOpTest[35].left.highBits := 0;
  relOpTest[35].left.lowBits := 1;
  relOpTest[35].right.highBits := 1;
  relOpTest[35].right.lowBits := 1;
  relOpTest[35].expected := FALSE;
  
  relOpTest[36].label := "INT64.gt(MAX(LONGCARD)+2, 1)";
  relOpTest[36].proc := INT64.gt;
  relOpTest[36].left.highBits := 1;
  relOpTest[36].left.lowBits := 1;
  relOpTest[36].right.highBits := 0;
  relOpTest[36].right.lowBits := 1;
  relOpTest[36].expected := TRUE;
  
  relOpTest[37].label := "INT64.gt(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[37].proc := INT64.gt;
  relOpTest[37].left.highBits := 0;
  relOpTest[37].left.lowBits := 0FFFFFFFFH;
  relOpTest[37].right.highBits := 1;
  relOpTest[37].right.lowBits := 0;
  relOpTest[37].expected := FALSE;
  
  relOpTest[38].label := "INT64.gt(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[38].proc := INT64.gt;
  relOpTest[38].left.highBits := 1;
  relOpTest[38].left.lowBits := 0;
  relOpTest[38].right.highBits := 0;
  relOpTest[38].right.lowBits := 0FFFFFFFFH;
  relOpTest[38].expected := TRUE;
  
  relOpTest[39].label := "INT64.gt(MAX(INT64T)-1, MAX(INT64T))";
  relOpTest[39].proc := INT64.gt;
  relOpTest[39].left.highBits := 2147483647;
  relOpTest[39].left.lowBits := 0FFFFFFFEH;
  relOpTest[39].right.highBits := 2147483647;
  relOpTest[39].right.lowBits := 0FFFFFFFFH;
  relOpTest[39].expected := FALSE;

  relOpTest[40].label := "INT64.gt(MAX(INT64T), MAX(INT64T))";
  relOpTest[40].proc := INT64.gt;
  relOpTest[40].left.highBits := 2147483647;
  relOpTest[40].left.lowBits := 0FFFFFFFFH;
  relOpTest[40].right.highBits := 2147483647;
  relOpTest[40].right.lowBits := 0FFFFFFFFH;
  relOpTest[40].expected := FALSE;

  relOpTest[41].label := "INT64.gteq(0, 0)";
  relOpTest[41].proc := INT64.gteq;
  relOpTest[41].left.highBits := 0;
  relOpTest[41].left.lowBits := 0;
  relOpTest[41].right.highBits := 0;
  relOpTest[41].right.lowBits := 0;
  relOpTest[41].expected := TRUE;
  
  relOpTest[42].label := "INT64.gteq(0, 1)";
  relOpTest[42].proc := INT64.gteq;
  relOpTest[42].left.highBits := 0;
  relOpTest[42].left.lowBits := 0;
  relOpTest[42].right.highBits := 0;
  relOpTest[42].right.lowBits := 1;
  relOpTest[42].expected := FALSE;
  
  relOpTest[43].label := "INT64.gteq(1, 0)";
  relOpTest[43].proc := INT64.gteq;
  relOpTest[43].left.highBits := 0;
  relOpTest[43].left.lowBits := 1;
  relOpTest[43].right.highBits := 0;
  relOpTest[43].right.lowBits := 0;
  relOpTest[43].expected := TRUE;
  
  relOpTest[44].label := "INT64.gteq(1, MAX(LONGCARD)+2)";
  relOpTest[44].proc := INT64.gteq;
  relOpTest[44].left.highBits := 0;
  relOpTest[44].left.lowBits := 1;
  relOpTest[44].right.highBits := 1;
  relOpTest[44].right.lowBits := 1;
  relOpTest[44].expected := FALSE;
  
  relOpTest[45].label := "INT64.gteq(MAX(LONGCARD)+2, 1)";
  relOpTest[45].proc := INT64.gteq;
  relOpTest[45].left.highBits := 1;
  relOpTest[45].left.lowBits := 1;
  relOpTest[45].right.highBits := 0;
  relOpTest[45].right.lowBits := 1;
  relOpTest[45].expected := TRUE;
  
  relOpTest[46].label := "INT64.gteq(MAX(LONGCARD), MAX(LONGCARD)+1)";
  relOpTest[46].proc := INT64.gteq;
  relOpTest[46].left.highBits := 0;
  relOpTest[46].left.lowBits := 0FFFFFFFFH;
  relOpTest[46].right.highBits := 1;
  relOpTest[46].right.lowBits := 0;
  relOpTest[46].expected := FALSE;
  
  relOpTest[47].label := "INT64.gteq(MAX(LONGCARD)+1, MAX(LONGCARD))";
  relOpTest[47].proc := INT64.gteq;
  relOpTest[47].left.highBits := 1;
  relOpTest[47].left.lowBits := 0;
  relOpTest[47].right.highBits := 0;
  relOpTest[47].right.lowBits := 0FFFFFFFFH;
  relOpTest[47].expected := TRUE;
  
  relOpTest[48].label := "INT64.gteq(MAX(INT64T)-1, MAX(INT64T))";
  relOpTest[48].proc := INT64.gteq;
  relOpTest[48].left.highBits := 2147483647;
  relOpTest[48].left.lowBits := 0FFFFFFFEH;
  relOpTest[48].right.highBits := 2147483647;
  relOpTest[48].right.lowBits := 0FFFFFFFFH;
  relOpTest[48].expected := FALSE;
  
  relOpTest[49].label := "INT64.gteq(MAX(INT64T), MAX(INT64T))";
  relOpTest[49].proc := INT64.gteq;
  relOpTest[49].left.highBits := 2147483647;
  relOpTest[49].left.lowBits := 0FFFFFFFFH;
  relOpTest[49].right.highBits := 2147483647;
  relOpTest[49].right.lowBits := 0FFFFFFFFH;
  relOpTest[49].expected := TRUE
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
END TestInt64RelOps.
