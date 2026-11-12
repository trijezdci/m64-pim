(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestInt64RelOps;

(* Test Suite for INT64 Relational Operations *)


IMPORT INT64, InOut;

FROM INT64 IMPORT INT64T;


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
  
  (* run all relational operation tests *)
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

TYPE RelOpId = ( Eq, Neq, Lt, Lteq, Gt, Gteq );

TYPE RelOp = RECORD
  proc : RelOpProc;
  expected : BOOLEAN
END; (* RelOp *)

TYPE RelOpTest = RECORD
  operation : ARRAY [Eq..Gteq] OF RelOp;
  left, right : INT64T;
  args : LabelString
END; (* RelOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitRelOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for  eq, neq, gt, gteq, lt and lteq
 * ----------------------------------------------------------------------- *)

CONST RelOpTestGroupCount = 20;

CONST RelOpTestCount = RelOpTestGroupCount * ORD(MAX(RelOpId))+1;

VAR relOpTest : ARRAY [0..RelOpTestGroupCount-1] OF RelOpTest;

PROCEDURE InitRelOpTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO RelOpTestGroupCount-1 DO
    relopTest[index].operation[Eq].proc := INT64.eq;
    relopTest[index].operation[Neq].proc := INT64.neq;
    relopTest[index].operation[Lt].proc := INT64.lt;
    relopTest[index].operation[Lteq].proc := INT64.lteq;
    relopTest[index].operation[Gt].proc := INT64.gt;
    relopTest[index].operation[Gteq].proc := INT64.gteq
  END; (* FOR *)
  
  (* operands *)
  relOpTest[0].args := "(0, 0)";
  relOpTest[0].left.highBits := 0;
  relOpTest[0].left.lowBits := 0;
  relOpTest[0].right.highBits := 0;
  relOpTest[0].right.lowBits := 0;

  (* expected results *)
  relopTest[0].operation[Eq].expected := TRUE;
  relopTest[0].operation[Neq].expected := FALSE;
  relopTest[0].operation[Lt].expected := FALSE;
  relopTest[0].operation[Lteq].expected := TRUE;
  relopTest[0].operation[Gt].expected := FALSE;
  relopTest[0].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[1].args := "(0, 1)";
  relOpTest[1].left.highBits := 0;
  relOpTest[1].left.lowBits := 0;
  relOpTest[1].right.highBits := 0;
  relOpTest[1].right.lowBits := 1;

  (* expected results *)
  relopTest[1].operation[Eq].expected := FALSE;
  relopTest[1].operation[Neq].expected := TRUE;
  relopTest[1].operation[Lt].expected := TRUE;
  relopTest[1].operation[Lteq].expected := TRUE;
  relopTest[1].operation[Gt].expected := FALSE;
  relopTest[1].operation[Gteq].expected := FALSE;
   
  (* operands *)
  relOpTest[2].args := "(1, 0)";
  relOpTest[2].left.highBits := 0;
  relOpTest[2].left.lowBits := 1;
  relOpTest[2].right.highBits := 0;
  relOpTest[2].right.lowBits := 0;

  (* expected results *)
  relopTest[2].operation[Eq].expected := FALSE;
  relopTest[2].operation[Neq].expected := TRUE;
  relopTest[2].operation[Lt].expected := FALSE;
  relopTest[2].operation[Lteq].expected := FALSE;
  relopTest[2].operation[Gt].expected := TRUE;
  relopTest[2].operation[Gteq].expected := TRUE;
   
  (* operands *)
  relOpTest[3].args := "(MAX(LONGCARD)+1, 0)";
  relOpTest[3].left.highBits := 1;
  relOpTest[3].left.lowBits := 0;
  relOpTest[3].right.highBits := 0;
  relOpTest[3].right.lowBits := 0;

  (* expected results *)
  relopTest[3].operation[Eq].expected := FALSE;
  relopTest[3].operation[Neq].expected := TRUE;
  relopTest[3].operation[Lt].expected := FALSE;
  relopTest[3].operation[Lteq].expected := FALSE;
  relopTest[3].operation[Gt].expected := TRUE;
  relopTest[3].operation[Gteq].expected := TRUE;
   
  (* operands *)
  relOpTest[4].args := "(MAX(LONGCARD)+2, 1)";
  relOpTest[4].left.highBits := 1;
  relOpTest[4].left.lowBits := 1;
  relOpTest[4].right.highBits := 0;
  relOpTest[4].right.lowBits := 1;

  (* expected results *)
  relopTest[4].operation[Eq].expected := FALSE;
  relopTest[4].operation[Neq].expected := TRUE;
  relopTest[4].operation[Lt].expected := FALSE;
  relopTest[4].operation[Lteq].expected := FALSE;
  relopTest[4].operation[Gt].expected := TRUE;
  relopTest[4].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[5].args := "(MAX(INT64T)-1, MAX(INT64T))";
  relOpTest[5].left.highBits := 2147483647;
  relOpTest[5].left.lowBits := 0FFFFFFFEH;
  relOpTest[5].right.highBits := 2147483647;
  relOpTest[5].right.lowBits := 0FFFFFFFFH;
  
  (* expected results *)
  relopTest[5].operation[Eq].expected := FALSE;
  relopTest[5].operation[Neq].expected := TRUE;
  relopTest[5].operation[Lt].expected := TRUE;
  relopTest[5].operation[Lteq].expected := TRUE;
  relopTest[5].operation[Gt].expected := FALSE;
  relopTest[5].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[6].args := "(MAX(INT64T), MAX(INT64T))";
  relOpTest[6].left.highBits := 2147483647;
  relOpTest[6].left.lowBits := 0FFFFFFFFH;
  relOpTest[6].right.highBits := 2147483647;
  relOpTest[6].right.lowBits := 0FFFFFFFFH;

  (* expected results *)
  relopTest[6].operation[Eq].expected := TRUE;
  relopTest[6].operation[Neq].expected := FALSE;
  relopTest[6].operation[Lt].expected := FALSE;
  relopTest[6].operation[Lteq].expected := TRUE;
  relopTest[6].operation[Gt].expected := FALSE;
  relopTest[6].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[7].args := "(-1, 0)";
  relOpTest[7].left.highBits := -1;
  relOpTest[7].left.lowBits := 0FFFFFFFFH;
  relOpTest[7].right.highBits := 0;
  relOpTest[7].right.lowBits := 0;

  (* expected results *)
  relopTest[7].operation[Eq].expected := FALSE;
  relopTest[7].operation[Neq].expected := TRUE;
  relopTest[7].operation[Lt].expected := TRUE;
  relopTest[7].operation[Lteq].expected := TRUE;
  relopTest[7].operation[Gt].expected := FALSE;
  relopTest[7].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[8].args := "(0, -1)";
  relOpTest[8].left.highBits := 0;
  relOpTest[8].left.lowBits := 0;
  relOpTest[8].right.highBits := -1;
  relOpTest[8].right.lowBits := 0FFFFFFFFH;
  
  (* expected results *)
  relopTest[8].operation[Eq].expected := FALSE;
  relopTest[8].operation[Neq].expected := TRUE;
  relopTest[8].operation[Lt].expected := FALSE;
  relopTest[8].operation[Lteq].expected := FALSE;
  relopTest[8].operation[Gt].expected := TRUE;
  relopTest[8].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[9].args := "(-1, 1)";
  relOpTest[9].left.highBits := -1;
  relOpTest[9].left.lowBits := 0FFFFFFFFH;
  relOpTest[9].right.highBits := 0;
  relOpTest[9].right.lowBits := 1;

  (* expected results *)
  relopTest[9].operation[Eq].expected := FALSE;
  relopTest[9].operation[Neq].expected := TRUE;
  relopTest[9].operation[Lt].expected := TRUE;
  relopTest[9].operation[Lteq].expected := TRUE;
  relopTest[9].operation[Gt].expected := FALSE;
  relopTest[9].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[10].args := "(1, -1)";
  relOpTest[10].left.highBits := 0;
  relOpTest[10].left.lowBits := 1;
  relOpTest[10].right.highBits := -1;
  relOpTest[10].right.lowBits := 0FFFFFFFFH;

  (* expected results *)
  relopTest[10].operation[Eq].expected := FALSE;
  relopTest[10].operation[Neq].expected := TRUE;
  relopTest[10].operation[Lt].expected := FALSE;
  relopTest[10].operation[Lteq].expected := FALSE;
  relopTest[10].operation[Gt].expected := TRUE;
  relopTest[10].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[11].args := "(-1, -1)";
  relOpTest[11].left.highBits := -1;
  relOpTest[11].left.lowBits := 0FFFFFFFFH;
  relOpTest[11].right.highBits := -1;
  relOpTest[11].right.lowBits := 0FFFFFFFFH;

  (* expected results *)
  relopTest[11].operation[Eq].expected := TRUE;
  relopTest[11].operation[Neq].expected := FALSE;
  relopTest[11].operation[Lt].expected := FALSE;
  relopTest[11].operation[Lteq].expected := TRUE;
  relopTest[11].operation[Gt].expected := FALSE;
  relopTest[11].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[12].args := "(-1, -2)";
  relOpTest[12].left.highBits := -1;
  relOpTest[12].left.lowBits := 0FFFFFFFFH;
  relOpTest[12].right.highBits := -1;
  relOpTest[12].right.lowBits := 0FFFFFFFEH;

  (* expected results *)
  relopTest[12].operation[Eq].expected := FALSE;
  relopTest[12].operation[Neq].expected := TRUE;
  relopTest[12].operation[Lt].expected := FALSE;
  relopTest[12].operation[Lteq].expected := FALSE;
  relopTest[12].operation[Gt].expected := TRUE;
  relopTest[12].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[13].args := "(-2, -1)";
  relOpTest[13].left.highBits := -1;
  relOpTest[13].left.lowBits := 0FFFFFFFEH;
  relOpTest[13].right.highBits := -1;
  relOpTest[13].right.lowBits := 0FFFFFFFFH;

  (* expected results *)
  relopTest[13].operation[Eq].expected := FALSE;
  relopTest[13].operation[Neq].expected := TRUE;
  relopTest[13].operation[Lt].expected := TRUE;
  relopTest[13].operation[Lteq].expected := TRUE;
  relopTest[13].operation[Gt].expected := FALSE;
  relopTest[13].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[14].args := "(-MAX(LONGCARD)-1, 0)";
  relOpTest[14].left.highBits := -1;
  relOpTest[14].left.lowBits := 0;
  relOpTest[14].right.highBits := 0;
  relOpTest[14].right.lowBits := 0;

  (* expected results *)
  relopTest[14].operation[Eq].expected := FALSE;
  relopTest[14].operation[Neq].expected := TRUE;
  relopTest[14].operation[Lt].expected := TRUE;
  relopTest[14].operation[Lteq].expected := TRUE;
  relopTest[14].operation[Gt].expected := FALSE;
  relopTest[14].operation[Gteq].expected := FALSE;
    
  (* operands *)
  relOpTest[15].args := "(-MAX(LONGCARD), 1)";
  relOpTest[15].left.highBits := -1;
  relOpTest[15].left.lowBits := 1;
  relOpTest[15].right.highBits := 0;
  relOpTest[15].right.lowBits := 1;
  
  (* expected results *)
  relopTest[15].operation[Eq].expected := FALSE;
  relopTest[15].operation[Neq].expected := TRUE;
  relopTest[15].operation[Lt].expected := TRUE;
  relopTest[15].operation[Lteq].expected := TRUE;
  relopTest[15].operation[Gt].expected := FALSE;
  relopTest[15].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[16].args := "(-MAX(LONGCARD)-1, -MAX(LONGCARD)-1)";
  relOpTest[16].left.highBits := -1;
  relOpTest[16].left.lowBits := 0;
  relOpTest[16].right.highBits := -1;
  relOpTest[16].right.lowBits := 0;
  
  (* expected results *)
  relopTest[16].operation[Eq].expected := TRUE;
  relopTest[16].operation[Neq].expected := FALSE;
  relopTest[16].operation[Lt].expected := FALSE;
  relopTest[16].operation[Lteq].expected := TRUE;
  relopTest[16].operation[Gt].expected := FALSE;
  relopTest[16].operation[Gteq].expected := TRUE;
  
  (* operands *)
  relOpTest[17].args := "(MIN(INT64T), 0)";
  relOpTest[17].left.highBits := -2147483648;
  relOpTest[17].left.lowBits := 0;
  relOpTest[17].right.highBits := 0;
  relOpTest[17].right.lowBits := 0;
  
  (* expected results *)
  relopTest[17].operation[Eq].expected := FALSE;
  relopTest[17].operation[Neq].expected := TRUE;
  relopTest[17].operation[Lt].expected := TRUE;
  relopTest[17].operation[Lteq].expected := TRUE;
  relopTest[17].operation[Gt].expected := FALSE;
  relopTest[17].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[18].args := "(MIN(INT64T), MIN(INT64T)+1)";
  relOpTest[18].left.highBits := -2147483648;
  relOpTest[18].left.lowBits := 0;
  relOpTest[18].right.highBits := -2147483648;
  relOpTest[18].right.lowBits := 1;
  
  (* expected results *)
  relopTest[18].operation[Eq].expected := FALSE;
  relopTest[18].operation[Neq].expected := TRUE;
  relopTest[18].operation[Lt].expected := TRUE;
  relopTest[18].operation[Lteq].expected := TRUE;
  relopTest[18].operation[Gt].expected := FALSE;
  relopTest[18].operation[Gteq].expected := FALSE;
  
  (* operands *)
  relOpTest[19].args := "(MIN(INT64T), MIN(INT64T))";
  relOpTest[19].left.highBits := -2147483648;
  relOpTest[19].left.lowBits := 0;
  relOpTest[19].right.highBits := -2147483648;
  relOpTest[19].right.lowBits := 0;
  
  (* expected results *)
  relopTest[19].operation[Eq].expected := TRUE;
  relopTest[19].operation[Neq].expected := FALSE;
  relopTest[19].operation[Lt].expected := FALSE;
  relopTest[19].operation[Lteq].expected := TRUE;
  relopTest[19].operation[Gt].expected := FALSE;
  relopTest[19].operation[Gteq].expected := TRUE
END InitRelOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunRelOpTest(relOp, test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunRelOpTest
  ( relOp : RelOpId; test : RelOpTest; VAR passed, failed : CARDINAL );
VAR
  res : BOOLEAN;
BEGIN
  PrintLabelForRelOp(relOp, test.args);
  
  res := test.operation[relOp].proc(test.left, test.right);
  PrintBoolResult(res);
  IF (res = test.operation[relOp].expected) THEN
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
  relOp : RelOpId;
  index : CARDINAL;
BEGIN
  FOR relOp := MIN(RelOpId) TO MAX(RelOpId) DO
    FOR index := 0 TO RelOpTestGroupCount-1 DO
      RunRelOpTest(relOp, relOpTest[index], passed, failed)
    END (* FOR *)
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
 * Procedure:  PrintLabelForRelOp(label)
 * --------------------------------------------------------------------------
 * Prints test label string for relOp with args. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabelForRelOp ( relOp : RelOpId; args : LabelString );
BEGIN
  InOut.WriteString("*** ");
  CASE relOp OF
    Eq   : InOut.WriteString("INT64.eq")
  | Neq  : InOut.WriteString("INT64.neq")
  | Lt   : InOut.WriteString("INT64.lt")
  | Lteq : InOut.WriteString("INT64.lteq")
  | Gt   : InOut.WriteString("INT64.gt")
  | Gteq : InOut.WriteString("INT64.gteq")
  END; (* CASE *)
  InOut.WriteString(args);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabelForRelOp;


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

BEGIN (* TestInt64RelOps *)
  InitConstCompTests;
  InitOddEvenTests;
  InitRelOpTests
END TestInt64RelOps.
