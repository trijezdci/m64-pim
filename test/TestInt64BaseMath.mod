(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestInt64BaseMath;

(* Test Suite for INT64 Basic Arithmetic Operations *)


IMPORT CARD64, Int64IO, LongCardIO, NumStatusIO, InOut;

FROM CARD64 IMPORT CARD64T;

FROM NumStatus IMPORT Status;


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
  
  InOut.WriteString("Abs/Neg Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run non-destructive unary operation tests *)
  RunAbsNegTests(passed, failed);
  
  InOut.WriteString("Unary Arithmentic Operation Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run destructive unary operation tests *)
  RunUnaryOpTests(passed, failed);
  
  InOut.WriteString("Binary Arithmentic Operation Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all binary arithmetic operation tests *)
  RunBinOpTests(passed, failed);
  
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
  RETURN AbsNegTestCount + UnaryOpTestCount + BinOpTestCount;
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
 * Test parameter type for INT64 Abs and Neg
 * ----------------------------------------------------------------------- *)

TYPE AbsNegOpProc = PROCEDURE ( INT64T, VAR INT64T, VAR Status );

TYPE AbsNegOpId = ( Abs, Neg );

TYPE AbsNegOp = RECORD
  proc : AbsNegOpProc;
  expected : INT64T;
  expStatus : Status
END; (* AbsNegOp *)

TYPE AbsNegTest = RECORD
  operation : ARRAY [Abs..Neg] OF AbsNegOp;
  operand : INT64T;
  args : LabelString
END; (* AbsNegTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitAbsNegTests
 * --------------------------------------------------------------------------
 * Initialises tests for non-destructive unary arithmetic operations.
 * ----------------------------------------------------------------------- *)

CONST AbsNegTestGroupCount = 10;

CONST AbsNegTestCount = AbsNegTestGroupCount * (ORD(MAX(AbsNegOpId)) + 1);

VAR absNegTest : ARRAY [0..AbsNegTestGroupCount-1] OF AbsNegTest;

PROCEDURE InitAbsNegTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO AbsNegTestGroupCount-1 DO
    absNegTest[index].operation[Abs].proc := INT64.Abs;
    absNegTest[index].operation[Neg].proc := INT64.Neg
  END; (* FOR *)
  
  (* operand *)
  absNegTest[0].args := "(0)";
  absNegTest[0].operand.highBits := 0;
  absNegTest[0].operand.lowBits := 0;
  
  (* expected results *)
  absNegTest[0].operation[Abs].expected.highBits := 0;
  absNegTest[0].operation[Abs].expected.lowBits := 0;
  absNegTest[0].operation[Abs].expStatus := Success;
  
  absNegTest[0].operation[Neg].expected.highBits := 0;
  absNegTest[0].operation[Neg].expected.lowBits := 0;
  absNegTest[0].operation[Neg].expStatus := Success;
  
  (* operand *)
  absNegTest[1].args := "(1)";
  absNegTest[1].operand.highBits := 0;
  absNegTest[1].operand.lowBits := 1;
  
  (* expected results *)
  absNegTest[1].operation[Abs].expected.highBits := 0;
  absNegTest[1].operation[Abs].expected.lowBits := 1;
  absNegTest[1].operation[Abs].expStatus := Success;
  
  absNegTest[0].operation[Neg].expected.highBits := -1;
  absNegTest[0].operation[Neg].expected.lowBits := MAX(LONGCARD);
  absNegTest[0].operation[Neg].expStatus := Success;
  
  (* operand *)
  absNegTest[2].args := "(-1)";
  absNegTest[2].operand.highBits := -1;
  absNegTest[2].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  absNegTest[2].operation[Abs].expected.highBits := 0;
  absNegTest[2].operation[Abs].expected.lowBits := 1;
  absNegTest[2].operation[Abs].expStatus := Success;

  absNegTest[2].operation[Neg].expected.highBits := 0;
  absNegTest[2].operation[Neg].expected.lowBits := 1;
  absNegTest[2].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[3].args := "(MAX(LONGCARD))";
  absNegTest[3].operand.highBits := 0;
  absNegTest[3].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  absNegTest[3].operation[Abs].expected.highBits := 0;
  absNegTest[3].operation[Abs].expected.lowBits := MAX(LONGCARD);
  absNegTest[3].operation[Abs].expStatus := Success;

  absNegTest[3].operation[Neg].expected.highBits := -1;
  absNegTest[3].operation[Neg].expected.lowBits := 1;
  absNegTest[3].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[4].args := "(-4294967296)";
  absNegTest[4].operand.highBits := -1;
  absNegTest[4].operand.lowBits := 0;

  (* expected results *)
  absNegTest[4].operation[Abs].expected.highBits := 1;
  absNegTest[4].operation[Abs].expected.lowBits := 0;
  absNegTest[4].operation[Abs].expStatus := Success;

  absNegTest[4].operation[Neg].expected.highBits := 1;
  absNegTest[4].operation[Neg].expected.lowBits := 0;
  absNegTest[4].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[5].args := "(4294967296)";
  absNegTest[5].operand.highBits := 1;
  absNegTest[5].operand.lowBits := 0;

  (* expected results *)
  absNegTest[5].operation[Abs].expected.highBits := 1;
  absNegTest[5].operation[Abs].expected.lowBits := 0;
  absNegTest[5].operation[Abs].expStatus := Success;

  absNegTest[5].operation[Neg].expected.highBits := -1;
  absNegTest[5].operation[Neg].expected.lowBits := 0;
  absNegTest[5].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[6].args := "(4294967297)";
  absNegTest[6].operand.highBits := 1;
  absNegTest[6].operand.lowBits := 1;

  (* expected results *)
  absNegTest[6].operation[Abs].expected.highBits := 1;
  absNegTest[6].operation[Abs].expected.lowBits := 1;
  absNegTest[6].operation[Abs].expStatus := Success;

  absNegTest[6].operation[Neg].expected.highBits := -2;
  absNegTest[6].operation[Neg].expected.lowBits := MAX(LONGCARD);
  absNegTest[6].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[7].args := "(-4294967297)";
  absNegTest[7].operand.highBits := -2;
  absNegTest[7].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  absNegTest[7].operation[Abs].expected.highBits := 1;
  absNegTest[7].operation[Abs].expected.lowBits := 1;
  absNegTest[7].operation[Abs].expStatus := Success;

  absNegTest[7].operation[Neg].expected.highBits := 1;
  absNegTest[7].operation[Neg].expected.lowBits := 1;
  absNegTest[7].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[8].args := "(MAX(INT64T))";
  absNegTest[8].operand.highBits := MAX(LONGINT);
  absNegTest[8].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  absNegTest[8].operation[Abs].expected.highBits := MAX(LONGINT);
  absNegTest[8].operation[Abs].expected.lowBits := MAX(LONGCARD);
  absNegTest[8].operation[Abs].expStatus := Success;

  absNegTest[8].operation[Neg].expected.highBits := MIN(LONGINT);
  absNegTest[8].operation[Neg].expected.lowBits := 1;
  absNegTest[8].operation[Neg].expStatus := Success;

  (* operand *)
  absNegTest[9].args := "(MIN(INT64T))";
  absNegTest[9].operand.highBits := MIN(LONGINT);
  absNegTest[9].operand.lowBits := 0;

  (* expected results *)
  absNegTest[9].operation[Abs].expStatus := Overflow;

  absNegTest[9].operation[Neg].expStatus := Overflow
END InitAbsNegTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunAbsNegTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunAbsNegTest
  ( absNegOp : AbsNegOpId; test : AbsNegTest; VAR passed, failed : CARDINAL );
VAR
  operand, res : INT64T;
  operation : AbsNegOp;
  stat : Status;
BEGIN
  PrintLabelForAbsNegOp(absNegOp, test.args);
  
  operand := test.operand;
  operation := test.operation[absNegOp];
  
  operation.proc(operand, res, stat);
  PrintResult(res); PrintStatus(stat);
  
  IF stat = Success THEN
    IF (operation.expStatus = Success) AND
      (res.highBits = operation.expected.highBits) AND
      (res.lowBits = operation.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* stat # Success *)
    IF stat = operation.expStatus THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunAbsNegTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunAbsNegTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all AbsNegTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunAbsNegTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
  absNegOp : AbsNegOpId;
BEGIN
  FOR absNegOp := MIN(AbsNegOpId) TO MAX(AbsNegOpId) DO
    FOR index := 0 TO AbsNegOpTestGroupCount-1 DO
      RunAbsNegTest(absNegOp, absNegTest[index], passed, failed)
    END (* FOR *)
  END (* FOR *)
END RunAbsNegTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64 Inc and Dec
 * ----------------------------------------------------------------------- *)

TYPE UnaryOpProc = PROCEDURE ( VAR INT64T, VAR Status );

TYPE UnaryOpId = ( Inc, Dec );

TYPE UnaryOp = RECORD
  proc : UnaryOpProc;
  expected : INT64T;
  expStatus : Status
END; (* UnaryOp *)

TYPE UnaryOpTest = RECORD
  operation : ARRAY [Inc..Dec] OF UnaryOp;
  operand : INT64T;
  args : LabelString
END; (* UnaryOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitUnaryOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for unary arithmetic operations.
 * ----------------------------------------------------------------------- *)

CONST UnaryOpTestGroupCount = 16;

CONST UnaryOpTestCount = UnaryOpTestGroupCount * (ORD(MAX(UnaryOpId)) + 1);

VAR unaryOpTest : ARRAY [0..UnaryOpTestCount-1] OF UnaryOpTest;

PROCEDURE InitUnaryOpTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO UnaryOpTestGroupCount-1 DO
    unaryOpTest[index].operation[Inc].proc := INT64.Inc;
    unaryOpTest[index].operation[Dec].proc := INT64.Dec
  END; (* FOR *)
  
  (* operand *)
  unaryOpTest[0].args := "(0)";
  unaryOpTest[0].operand.highBits := 0;
  unaryOpTest[0].operand.lowBits := 0;
  
  (* expected results *)
  unaryOpTest[0].operation[Inc].expected.highBits := 0;
  unaryOpTest[0].operation[Inc].expected.lowBits := 1;
  unaryOpTest[0].operation[Inc].expStatus := Success;
  
  unaryOpTest[0].operation[Dec].expected.highBits := -1;
  unaryOpTest[0].operation[Dec].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[0].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[1].args := "(1)";
  unaryOpTest[1].operand.highBits := 0;
  unaryOpTest[1].operand.lowBits := 1;
  
  (* expected results *)
  unaryOpTest[1].operation[Inc].expected.highBits := 0;
  unaryOpTest[1].operation[Inc].expected.lowBits := 2;
  unaryOpTest[1].operation[Inc].expStatus := Success;
  
  unaryOpTest[1].operation[Dec].expected.highBits := 0;
  unaryOpTest[1].operation[Dec].expected.lowBits := 0;
  unaryOpTest[1].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[2].args := "(2)";
  unaryOpTest[2].operand.highBits := 0;
  unaryOpTest[2].operand.lowBits := 2;
  
  (* expected results *)
  unaryOpTest[2].operation[Inc].expected.highBits := 0;
  unaryOpTest[2].operation[Inc].expected.lowBits := 3;
  unaryOpTest[2].operation[Inc].expStatus := Success;
  
  unaryOpTest[2].operation[Dec].expected.highBits := 0;
  unaryOpTest[2].operation[Dec].expected.lowBits := 1;
  unaryOpTest[2].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[3].args := "(3)";
  unaryOpTest[3].operand.highBits := 0;
  unaryOpTest[3].operand.lowBits := 3;
  
  (* expected results *)
  unaryOpTest[3].operation[Inc].expected.highBits := 0;
  unaryOpTest[3].operation[Inc].expected.lowBits := 4;
  unaryOpTest[3].operation[Inc].expStatus := Success;
  
  unaryOpTest[3].operation[Dec].expected.highBits := 0;
  unaryOpTest[3].operation[Dec].expected.lowBits := 2;
  unaryOpTest[3].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[4].args := "(4)";
  unaryOpTest[4].operand.highBits := 0;
  unaryOpTest[4].operand.lowBits := 4;
  
  (* expected results *)
  unaryOpTest[4].operation[Inc].expected.highBits := 0;
  unaryOpTest[4].operation[Inc].expected.lowBits := 5;
  unaryOpTest[4].operation[Inc].expStatus := Success;

  unaryOpTest[4].operation[Dec].expected.highBits := 0;
  unaryOpTest[4].operation[Dec].expected.lowBits := 3;
  unaryOpTest[4].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[5].args := "(-1)";
  unaryOpTest[5].operand.highBits := -1;
  unaryOpTest[5].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  unaryOpTest[5].operation[Inc].expected.highBits := 0;
  unaryOpTest[5].operation[Inc].expected.lowBits := 0;
  unaryOpTest[5].operation[Inc].expStatus := Success;

  unaryOpTest[5].operation[Dec].expected.highBits := -1;
  unaryOpTest[5].operation[Dec].expected.lowBits := MAX(LONGCARD) - 1;
  unaryOpTest[5].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[6].args := "(MAX(LONGCARD))";
  unaryOpTest[6].operand.highBits := 0;
  unaryOpTest[6].operand.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  unaryOpTest[6].operation[Inc].expected.highBits := 1;
  unaryOpTest[6].operation[Inc].expected.lowBits := 0;
  unaryOpTest[6].operation[Inc].expStatus := Success;

  unaryOpTest[6].operation[Dec].expected.highBits := 0;
  unaryOpTest[6].operation[Dec].expected.lowBits := MAX(LONGCARD)-1;
  unaryOpTest[6].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[7].args := "(-MAX(LONGCARD))";
  unaryOpTest[7].operand.highBits := -1;
  unaryOpTest[7].operand.lowBits := 1;
  
  (* expected results *)
  unaryOpTest[7].operation[Inc].expected.highBits := -1;
  unaryOpTest[7].operation[Inc].expected.lowBits := 2;
  unaryOpTest[7].operation[Inc].expStatus := Success;
  
  unaryOpTest[7].operation[Dec].expected.highBits := -1;
  unaryOpTest[7].operation[Dec].expected.lowBits := 0;
  unaryOpTest[7].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[8].args := "(MAX(LONGCARD)+1)";
  unaryOpTest[8].operand.highBits := 1;
  unaryOpTest[8].operand.lowBits := 0;
  
  (* expected results *)
  unaryOpTest[8].operation[Inc].expected.highBits := 1;
  unaryOpTest[8].operation[Inc].expected.lowBits := 1;
  unaryOpTest[8].operation[Inc].expStatus := Success;

  unaryOpTest[8].operation[Dec].expected.highBits := 0;
  unaryOpTest[8].operation[Dec].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[8].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[9].args := "(-MAX(LONGCARD)-1)";
  unaryOpTest[9].operand.highBits := -1;
  unaryOpTest[9].operand.lowBits := 0;
  
  (* expected results *)
  unaryOpTest[9].operation[Inc].expected.highBits := -1;
  unaryOpTest[9].operation[Inc].expected.lowBits := 1;
  unaryOpTest[9].operation[Inc].expStatus := Success;
  
  unaryOpTest[9].operation[Dec].expected.highBits := -2;
  unaryOpTest[9].operation[Dec].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[9].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[10].args := "(MAX(LONGCARD)+2)";
  unaryOpTest[10].operand.highBits := 1;
  unaryOpTest[10].operand.lowBits := 2;
  
  (* expected results *)
  unaryOpTest[10].operation[Inc].expected.highBits := 1;
  unaryOpTest[10].operation[Inc].expected.lowBits := 3;
  unaryOpTest[10].operation[Inc].expStatus := Success;

  unaryOpTest[10].operation[Dec].expected.highBits := 1;
  unaryOpTest[10].operation[Dec].expected.lowBits := 1;
  unaryOpTest[10].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[11].args := "(-MAX(LONGCARD)-2)";
  unaryOpTest[11].operand.highBits := -2;
  unaryOpTest[11].operand.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  unaryOpTest[11].operation[Inc].expected.highBits := -1;
  unaryOpTest[11].operation[Inc].expected.lowBits := 0;
  unaryOpTest[11].operation[Inc].expStatus := Success;
  
  unaryOpTest[11].operation[Dec].expected.highBits := -2;
  unaryOpTest[11].operation[Dec].expected.lowBits := MAX(LONGCARD) - 1;
  unaryOpTest[11].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[12].args := "(MAX(INT64T)-1)";
  unaryOpTest[12].operand.highBits := MAX(LONGINT);
  unaryOpTest[12].operand.lowBits := MAX(LONGCARD) - 1;

  (* expected results *)
  unaryOpTest[12].operation[Inc].expected.highBits := MAX(LONGINT);
  unaryOpTest[12].operation[Inc].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[12].operation[Inc].expStatus := Success;

  unaryOpTest[12].operation[Dec].expected.highBits := MAX(LONGINT);
  unaryOpTest[12].operation[Dec].expected.lowBits := MAX(LONGCARD) - 2;
  unaryOpTest[12].operation[Dec].expStatus := Success;

  (* operand *)
  unaryOpTest[13].args := "(MIN(INT64T)+1)";
  unaryOpTest[13].operand.highBits := MIN(LONGINT);
  unaryOpTest[13].operand.lowBits := 1;

  (* expected results *)
  unaryOpTest[13].operation[Inc].expected.highBits := MIN(LONGINT);
  unaryOpTest[13].operation[Inc].expected.lowBits := 2;
  unaryOpTest[13].operation[Inc].expStatus := Success;

  unaryOpTest[13].operation[Dec].expected.highBits := MIN(LONGINT);
  unaryOpTest[13].operation[Dec].expected.lowBits := 0;
  unaryOpTest[13].operation[Dec].expStatus := Success;

  (* operand *)
  unaryOpTest[14].args := "(MAX(INT64T))";
  unaryOpTest[14].operand.highBits := MAX(LONGINT);
  unaryOpTest[14].operand.lowBits := MAX(LONGCARD);

  (* expected results *)
  unaryOpTest[14].operation[Inc].expStatus := Overflow;

  unaryOpTest[14].operation[Dec].expected.highBits := MAX(LONGINT);
  unaryOpTest[14].operation[Dec].expected.lowBits := MAX(LONGCARD) - 1;
  unaryOpTest[14].operation[Dec].expStatus := Success;

  (* operand *)
  unaryOpTest[15].args := "(MIN(INT64T))";
  unaryOpTest[15].operand.highBits := MIN(LONGINT);
  unaryOpTest[15].operand.lowBits := 0;

  (* expected results *)
  unaryOpTest[15].operation[Inc].expected.highBits := MIN(LONGINT);
  unaryOpTest[15].operation[Inc].expected.lowBits := 1;
  unaryOpTest[15].operation[Inc].expStatus := Success;

  unaryOpTest[15].operation[Dec].expStatus := Underflow
END InitUnaryOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunUnaryOpTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunUnaryOpTest
  ( unaryOp : UnaryOpId; test : UnaryOpTest; VAR passed, failed : CARDINAL );
VAR
  operand : INT64T;
  operation : UnaryOp;
  stat : Status;
BEGIN
  PrintLabelForUnaryOp(unaryOp, test.args);
  
  operand := test.operand;
  operation := test.operation[unaryOp];
  
  operation.proc(operand, stat);
  PrintResult(operand); PrintStatus(stat);

  IF stat = Success THEN
    IF (operation.expStatus = Success) AND
      (operand.highBits = operation.expected.highBits) AND
      (operand.lowBits = operation.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* stat # Success *)
    IF stat = operation.expStatus THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunUnaryOpTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunUnaryOpTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all UnaryTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunUnaryOpTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
  unaryOp : UnaryOpId;
BEGIN
  FOR unaryOp := MIN(UnaryOpId) TO MAX(UnaryOpId) DO
    FOR index := 0 TO UnaryOpTestGroupCount-1 DO
      RunUnaryOpTest(unaryOp, unaryOpTest[index], passed, failed)
    END (* FOR *)
  END (* FOR *)
END RunUnaryOpTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64 Add, Sub, Mul, Div and Mod
 * ----------------------------------------------------------------------- *)

TYPE BinOpProc = PROCEDURE ( INT64T, INT64T, VAR INT64T, VAR Status );

TYPE BinOpId = ( Add, Sub, Mul, Div, Mod );

TYPE BinOp = RECORD
  proc : BinOpProc;
  expected : INT64T;
  expStatus : Status
END; (* BinOp *)

TYPE BinOpTest = RECORD
  operation : ARRAY [Add..Mod] OF BinOp;
  left, right : INT64T;
  args : LabelString
END; (* BinOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitBinOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for INT64 Add, Sub, Mul, Div and Mod
 * ----------------------------------------------------------------------- *)

CONST BinOpTestGroupCount = 30;

CONST BinOpTestCount = BinOpTestGroupCount * (ORD(MAX(BinOpId)) + 1);

VAR binOpTest : ARRAY [0..BinOpTestGroupCount-1] OF BinOpTest;

PROCEDURE InitBinOpTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO BinOpTestGroupCount-1 DO
    binOpTest[index].operation[Add].proc := INT64.Add;
    binOpTest[index].operation[Sub].proc := INT64.Sub;
    binOpTest[index].operation[Mul].proc := INT64.Mul;
    binOpTest[index].operation[Div].proc := INT64.Div;
    binOpTest[index].operation[Mod].proc := INT64.Mod
  END; (* FOR *)
  
  (* operands *)
  binOpTest[0].args := "(0, 0)";
  binOpTest[0].left.highBits := 0;
  binOpTest[0].left.lowBits := 0;
  binOpTest[0].right.highBits := 0;
  binOpTest[0].right.lowBits := 0;

  (* expected results *)
  binOpTest[0].operation[Add].expected.highBits := 0;
  binOpTest[0].operation[Add].expected.lowBits := 0;
  binOpTest[0].operation[Add].expStatus := Success;

  binOpTest[0].operation[Sub].expected.highBits := 0;
  binOpTest[0].operation[Sub].expected.lowBits := 0;
  binOpTest[0].operation[Sub].expStatus := Success;

  binOpTest[0].operation[Mul].expected.highBits := 0;
  binOpTest[0].operation[Mul].expected.lowBits := 0;
  binOpTest[0].operation[Mul].expStatus := Success;

  binOpTest[0].operation[Div].expStatus := DivByZero;
  binOpTest[0].operation[Mod].expStatus := DivByZero;
  
  (* operands *)
  binOpTest[1].args := "(0, 1)";
  binOpTest[1].left.highBits := 0;
  binOpTest[1].left.lowBits := 0;
  binOpTest[1].right.highBits := 0;
  binOpTest[1].right.lowBits := 1;

  (* expected results *)
  binOpTest[1].operation[Add].expected.highBits := 0;
  binOpTest[1].operation[Add].expected.lowBits := 1;
  binOpTest[1].operation[Add].expStatus := Success;

  binOpTest[1].operation[Sub].expected.highBits := -1;
  binOpTest[1].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[1].operation[Sub].expStatus := Success;

  binOpTest[1].operation[Mul].expected.highBits := 0;
  binOpTest[1].operation[Mul].expected.lowBits := 0;
  binOpTest[1].operation[Mul].expStatus := Success;

  binOpTest[1].operation[Div].expected.highBits := 0;
  binOpTest[1].operation[Div].expected.lowBits := 0;
  binOpTest[1].operation[Div].expStatus := Success;

  binOpTest[1].operation[Mod].expected.highBits := 0;
  binOpTest[1].operation[Mod].expected.lowBits := 0;
  binOpTest[1].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[2].args := "(0, -1)";
  binOpTest[2].left.highBits := 0;
  binOpTest[2].left.lowBits := 0;
  binOpTest[2].right.highBits := -1;
  binOpTest[2].right.lowBits := MAX(LONGCARD);

  (* expected results *)
  binOpTest[2].operation[Add].expected.highBits := -1;
  binOpTest[2].operation[Add].expected.lowBits := MAX(LONGCARD);
  binOpTest[2].operation[Add].expStatus := Success;
  
  binOpTest[2].operation[Sub].expected.highBits := 0;
  binOpTest[2].operation[Sub].expected.lowBits := 1;
  binOpTest[2].operation[Sub].expStatus := Success;
  
  binOpTest[2].operation[Mul].expected.highBits := 0;
  binOpTest[2].operation[Mul].expected.lowBits := 0;
  binOpTest[2].operation[Mul].expStatus := Success;
  
  binOpTest[2].operation[Div].expected.highBits := 0;
  binOpTest[2].operation[Div].expected.lowBits := 0;
  binOpTest[2].operation[Div].expStatus := Success;
  
  binOpTest[2].operation[Mod].expected.highBits := 0;
  binOpTest[2].operation[Mod].expected.lowBits := 0;
  binOpTest[2].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[3].args := "(1, 0)";
  binOpTest[3].left.highBits := 0;
  binOpTest[3].left.lowBits := 1;
  binOpTest[3].right.highBits := 0;
  binOpTest[3].right.lowBits := 0;

  (* expected results *)
  binOpTest[3].operation[Add].expected.highBits := 0;
  binOpTest[3].operation[Add].expected.lowBits := 1;
  binOpTest[3].operation[Add].expStatus := Success;

  binOpTest[3].operation[Sub].expected.highBits := 0;
  binOpTest[3].operation[Sub].expected.lowBits := 1;
  binOpTest[3].operation[Sub].expStatus := Success;

  binOpTest[3].operation[Mul].expected.highBits := 0;
  binOpTest[3].operation[Mul].expected.lowBits := 0;
  binOpTest[3].operation[Mul].expStatus := Success;

  binOpTest[3].operation[Div].expStatus := DivByZero;
  binOpTest[3].operation[Mod].expStatus := DivByZero;
  
  (* operands *)
  binOpTest[4].args := "(-1, 0)";
  binOpTest[4].left.highBits := -1;
  binOpTest[4].left.lowBits := MAX(LONGCARD);
  binOpTest[4].right.highBits := 0;
  binOpTest[4].right.lowBits := 0;

  (* expected results *)
  binOpTest[4].operation[Add].expected.highBits := -1;
  binOpTest[4].operation[Add].expected.lowBits := MAX(LONGCARD);
  binOpTest[4].operation[Add].expStatus := Success;

  binOpTest[4].operation[Sub].expected.highBits := -1;
  binOpTest[4].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[4].operation[Sub].expStatus := Success;

  binOpTest[4].operation[Mul].expected.highBits := 0;
  binOpTest[4].operation[Mul].expected.lowBits := 0;
  binOpTest[4].operation[Mul].expStatus := Success;

  binOpTest[4].operation[Div].expStatus := DivByZero;
  binOpTest[4].operation[Mod].expStatus := DivByZero;
  
  (* operands *)
  binOpTest[5].args := "(1, 1)";
  binOpTest[5].left.highBits := 0;
  binOpTest[5].left.lowBits := 1;
  binOpTest[5].right.highBits := 0;
  binOpTest[5].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[5].operation[Add].expected.highBits := 0;
  binOpTest[5].operation[Add].expected.lowBits := 2;
  binOpTest[5].operation[Add].expStatus := Success;
  
  binOpTest[5].operation[Sub].expected.highBits := 0;
  binOpTest[5].operation[Sub].expected.lowBits := 0;
  binOpTest[5].operation[Sub].expStatus := Success;
  
  binOpTest[5].operation[Mul].expected.highBits := 0;
  binOpTest[5].operation[Mul].expected.lowBits := 1;
  binOpTest[5].operation[Mul].expStatus := Success;
  
  binOpTest[5].operation[Div].expected.highBits := 0;
  binOpTest[5].operation[Div].expected.lowBits := 1;
  binOpTest[5].operation[Div].expStatus := Success;
  
  binOpTest[5].operation[Mod].expected.highBits := 0;
  binOpTest[5].operation[Mod].expected.lowBits := 0;
  binOpTest[5].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[6].args := "(1, -1)";
  binOpTest[6].left.highBits := 0;
  binOpTest[6].left.lowBits := 1;
  binOpTest[6].right.highBits := -1;
  binOpTest[6].right.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  binOpTest[6].operation[Add].expected.highBits := 0;
  binOpTest[6].operation[Add].expected.lowBits := 0;
  binOpTest[6].operation[Add].expStatus := Success;
  
  binOpTest[6].operation[Sub].expected.highBits := 0;
  binOpTest[6].operation[Sub].expected.lowBits := 2;
  binOpTest[6].operation[Sub].expStatus := Success;
  
  binOpTest[6].operation[Mul].expected.highBits := -1;
  binOpTest[6].operation[Mul].expected.lowBits := MAX(LONGCARD);
  binOpTest[6].operation[Mul].expStatus := Success;
  
  binOpTest[6].operation[Div].expected.highBits := -1;
  binOpTest[6].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[6].operation[Div].expStatus := Success;
  
  binOpTest[6].operation[Mod].expected.highBits := 0;
  binOpTest[6].operation[Mod].expected.lowBits := 0;
  binOpTest[6].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[7].args := "(-1, 1)";
  binOpTest[7].left.highBits := -1;
  binOpTest[7].left.lowBits := MAX(LONGCARD);
  binOpTest[7].right.highBits := 0;
  binOpTest[7].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[7].operation[Add].expected.highBits := 0;
  binOpTest[7].operation[Add].expected.lowBits := 0;
  binOpTest[7].operation[Add].expStatus := Success;
  
  binOpTest[7].operation[Sub].expected.highBits := -1;
  binOpTest[7].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[7].operation[Sub].expStatus := Success;
  
  binOpTest[7].operation[Mul].expected.highBits := -1;
  binOpTest[7].operation[Mul].expected.lowBits := MAX(LONGCARD);
  binOpTest[7].operation[Mul].expStatus := Success;
  
  binOpTest[7].operation[Div].expected.highBits := -1;
  binOpTest[7].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[7].operation[Div].expStatus := Success;
  
  binOpTest[7].operation[Mod].expected.highBits := 0;
  binOpTest[7].operation[Mod].expected.lowBits := 0;
  binOpTest[7].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[8].args := "(-1, -1)";
  binOpTest[8].left.highBits := -1;
  binOpTest[8].left.lowBits := MAX(LONGCARD);
  binOpTest[8].right.highBits := -1;
  binOpTest[8].right.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  binOpTest[8].operation[Add].expected.highBits := -1;
  binOpTest[8].operation[Add].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[8].operation[Add].expStatus := Success;
  
  binOpTest[8].operation[Sub].expected.highBits := 0;
  binOpTest[8].operation[Sub].expected.lowBits := 0;
  binOpTest[8].operation[Sub].expStatus := Success;
  
  binOpTest[8].operation[Mul].expected.highBits := 0;
  binOpTest[8].operation[Mul].expected.lowBits := 1;
  binOpTest[8].operation[Mul].expStatus := Success;
  
  binOpTest[8].operation[Div].expected.highBits := 0;
  binOpTest[8].operation[Div].expected.lowBits := 1;
  binOpTest[8].operation[Div].expStatus := Success;
  
  binOpTest[8].operation[Mod].expected.highBits := 0;
  binOpTest[8].operation[Mod].expected.lowBits := 0;
  binOpTest[8].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[9].args := "(7, 3)";
  binOpTest[9].left.highBits := 0;
  binOpTest[9].left.lowBits := 7;
  binOpTest[9].right.highBits := 0;
  binOpTest[9].right.lowBits := 3;
  
  (* expected results *)
  binOpTest[9].operation[Add].expected.highBits := 0;
  binOpTest[9].operation[Add].expected.lowBits := 10;
  binOpTest[9].operation[Add].expStatus := Success;
  
  binOpTest[9].operation[Sub].expected.highBits := 0;
  binOpTest[9].operation[Sub].expected.lowBits := 4;
  binOpTest[9].operation[Sub].expStatus := Success;
  
  binOpTest[9].operation[Mul].expected.highBits := 0;
  binOpTest[9].operation[Mul].expected.lowBits := 21;
  binOpTest[9].operation[Mul].expStatus := Success;
  
  binOpTest[9].operation[Div].expected.highBits := 0;
  binOpTest[9].operation[Div].expected.lowBits := 2;
  binOpTest[9].operation[Div].expStatus := Success;
  
  binOpTest[9].operation[Mod].expected.highBits := 0;
  binOpTest[9].operation[Mod].expected.lowBits := 1;
  binOpTest[9].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[10].args := "(7, -3)";
  binOpTest[10].left.highBits := 0;
  binOpTest[10].left.lowBits := 7;
  binOpTest[10].right.highBits := -1;
  binOpTest[10].right.lowBits := MAX(LONGCARD) - 2;
  
  (* expected results *)
  binOpTest[10].operation[Add].expected.highBits := 0;
  binOpTest[10].operation[Add].expected.lowBits := 4;
  binOpTest[10].operation[Add].expStatus := Success;
  
  binOpTest[10].operation[Sub].expected.highBits := 0;
  binOpTest[10].operation[Sub].expected.lowBits := 10;
  binOpTest[10].operation[Sub].expStatus := Success;
  
  binOpTest[10].operation[Mul].expected.highBits := -1;
  binOpTest[10].operation[Mul].expected.lowBits := MAX(LONGCARD) - 20;
  binOpTest[10].operation[Mul].expStatus := Success;
  
  binOpTest[10].operation[Div].expected.highBits := -1;
  binOpTest[10].operation[Div].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[10].operation[Div].expStatus := Success;
  
  binOpTest[10].operation[Mod].expected.highBits := 0;
  binOpTest[10].operation[Mod].expected.lowBits := 1;
  binOpTest[10].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[11].args := "(-7, 3)";
  binOpTest[11].left.highBits := -1;
  binOpTest[11].left.lowBits := MAX(LONGCARD) - 6;
  binOpTest[11].right.highBits := 0;
  binOpTest[11].right.lowBits := 3;
  
  (* expected results *)
  binOpTest[11].operation[Add].expected.highBits := -1;
  binOpTest[11].operation[Add].expected.lowBits := MAX(LONGCARD) - 3;
  binOpTest[11].operation[Add].expStatus := Success;
  
  binOpTest[11].operation[Sub].expected.highBits := -1;
  binOpTest[11].operation[Sub].expected.lowBits := MAX(LONGCARD) - 9;
  binOpTest[11].operation[Sub].expStatus := Success;
  
  binOpTest[11].operation[Mul].expected.highBits := -1;
  binOpTest[11].operation[Mul].expected.lowBits := MAX(LONGCARD) - 20;
  binOpTest[11].operation[Mul].expStatus := Success;
  
  binOpTest[11].operation[Div].expected.highBits := -1;
  binOpTest[11].operation[Div].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[11].operation[Div].expStatus := Success;
  
  binOpTest[11].operation[Mod].expected.highBits := -1;
  binOpTest[11].operation[Mod].expected.lowBits := MAX(LONGCARD);
  binOpTest[11].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[12].args := "(-7, -3)";
  binOpTest[12].left.highBits := -1;
  binOpTest[12].left.lowBits := MAX(LONGCARD) - 6;
  binOpTest[12].right.highBits := -1;
  binOpTest[12].right.lowBits := MAX(LONGCARD) - 2;

  (* expected results *)
  binOpTest[12].operation[Add].expected.highBits := -1;
  binOpTest[12].operation[Add].expected.lowBits := MAX(LONGCARD) - 9;
  binOpTest[12].operation[Add].expStatus := Success;

  binOpTest[12].operation[Sub].expected.highBits := -1;
  binOpTest[12].operation[Sub].expected.lowBits := MAX(LONGCARD) - 3;
  binOpTest[12].operation[Sub].expStatus := Success;

  binOpTest[12].operation[Mul].expected.highBits := 0;
  binOpTest[12].operation[Mul].expected.lowBits := 21;
  binOpTest[12].operation[Mul].expStatus := Success;

  binOpTest[12].operation[Div].expected.highBits := 0;
  binOpTest[12].operation[Div].expected.lowBits := 2;
  binOpTest[12].operation[Div].expStatus := Success;

  binOpTest[12].operation[Mod].expected.highBits := -1;
  binOpTest[12].operation[Mod].expected.lowBits := MAX(LONGCARD);
  binOpTest[12].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[13].args := "(65535, 1)";
  binOpTest[13].left.highBits := 0;
  binOpTest[13].left.lowBits := 0FFFFH;
  binOpTest[13].right.highBits := 0;
  binOpTest[13].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[13].operation[Add].expected.highBits := 0;
  binOpTest[13].operation[Add].expected.lowBits := 010000H;
  binOpTest[13].operation[Add].expStatus := Success;
  
  binOpTest[13].operation[Sub].expected.highBits := 0;
  binOpTest[13].operation[Sub].expected.lowBits := 0FFFEH;
  binOpTest[13].operation[Sub].expStatus := Success;
  
  binOpTest[13].operation[Mul].expected.highBits := 0;
  binOpTest[13].operation[Mul].expected.lowBits := 0FFFFH;
  binOpTest[13].operation[Mul].expStatus := Success;
  
  binOpTest[13].operation[Div].expected.highBits := 0;
  binOpTest[13].operation[Div].expected.lowBits := 0FFFFH;
  binOpTest[13].operation[Div].expStatus := Success;
  
  binOpTest[13].operation[Mod].expected.highBits := 0;
  binOpTest[13].operation[Mod].expected.lowBits := 0;
  binOpTest[13].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[14].args := "(MAX(LONGCARD), 1)";
  binOpTest[14].left.highBits := 0;
  binOpTest[14].left.lowBits := MAX(LONGCARD);
  binOpTest[14].right.highBits := 0;
  binOpTest[14].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[14].operation[Add].expected.highBits := 1;
  binOpTest[14].operation[Add].expected.lowBits := 0;
  binOpTest[14].operation[Add].expStatus := Success;
  
  binOpTest[14].operation[Sub].expected.highBits := 0;
  binOpTest[14].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[14].operation[Sub].expStatus := Success;
  
  binOpTest[14].operation[Mul].expected.highBits := 0;
  binOpTest[14].operation[Mul].expected.lowBits := MAX(LONGCARD);
  binOpTest[14].operation[Mul].expStatus := Success;
  
  binOpTest[14].operation[Div].expected.highBits := 0;
  binOpTest[14].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[14].operation[Div].expStatus := Success;
  
  binOpTest[14].operation[Mod].expected.highBits := 0;
  binOpTest[14].operation[Mod].expected.lowBits := 0;
  binOpTest[14].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[15].args := "(-MAX(LONGCARD), -1)";
  binOpTest[15].left.highBits := -1;
  binOpTest[15].left.lowBits := 1;
  binOpTest[15].right.highBits := -1;
  binOpTest[15].right.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  binOpTest[15].operation[Add].expected.highBits := -1;
  binOpTest[15].operation[Add].expected.lowBits := 0;
  binOpTest[15].operation[Add].expStatus := Success;
  
  binOpTest[15].operation[Sub].expected.highBits := -1;
  binOpTest[15].operation[Sub].expected.lowBits := 2;
  binOpTest[15].operation[Sub].expStatus := Success;
  
  binOpTest[15].operation[Mul].expected.highBits := 0;
  binOpTest[15].operation[Mul].expected.lowBits := MAX(LONGCARD);
  binOpTest[15].operation[Mul].expStatus := Success;
  
  binOpTest[15].operation[Div].expected.highBits := 0;
  binOpTest[15].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[15].operation[Div].expStatus := Success;
  
  binOpTest[15].operation[Mod].expected.highBits := 0;
  binOpTest[15].operation[Mod].expected.lowBits := 0;
  binOpTest[15].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[16].args := "(MAX(LONGCARD)+1, 1)";
  binOpTest[16].left.highBits := 1;
  binOpTest[16].left.lowBits := 0;
  binOpTest[16].right.highBits := 0;
  binOpTest[16].right.lowBits := 1;

  (* expected results *)
  binOpTest[16].operation[Add].expected.highBits := 1;
  binOpTest[16].operation[Add].expected.lowBits := 1;
  binOpTest[16].operation[Add].expStatus := Success;
  
  binOpTest[16].operation[Sub].expected.highBits := 0;
  binOpTest[16].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[16].operation[Sub].expStatus := Success;
  
  binOpTest[16].operation[Mul].expected.highBits := 1;
  binOpTest[16].operation[Mul].expected.lowBits := 0;
  binOpTest[16].operation[Mul].expStatus := Success;
  
  binOpTest[16].operation[Div].expected.highBits := 1;
  binOpTest[16].operation[Div].expected.lowBits := 0;
  binOpTest[16].operation[Div].expStatus := Success;
  
  binOpTest[16].operation[Mod].expected.highBits := 0;
  binOpTest[16].operation[Mod].expected.lowBits := 0;
  binOpTest[16].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[17].args := "(-MAX(LONGCARD)-1, 1)";
  binOpTest[17].left.highBits := -1;
  binOpTest[17].left.lowBits := 0;
  binOpTest[17].right.highBits := 0;
  binOpTest[17].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[17].operation[Add].expected.highBits := -1;
  binOpTest[17].operation[Add].expected.lowBits := 1;
  binOpTest[17].operation[Add].expStatus := Success;
  
  binOpTest[17].operation[Sub].expected.highBits := -2;
  binOpTest[17].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[17].operation[Sub].expStatus := Success;
  
  binOpTest[17].operation[Mul].expected.highBits := -1;
  binOpTest[17].operation[Mul].expected.lowBits := 0;
  binOpTest[17].operation[Mul].expStatus := Success;
  
  binOpTest[17].operation[Div].expected.highBits := -1;
  binOpTest[17].operation[Div].expected.lowBits := 0;
  binOpTest[17].operation[Div].expStatus := Success;
  
  binOpTest[17].operation[Mod].expected.highBits := 0;
  binOpTest[17].operation[Mod].expected.lowBits := 0;
  binOpTest[17].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[18].args := "(MAX(LONGCARD), MAX(LONGCARD))";
  binOpTest[18].left.highBits := 0;
  binOpTest[18].left.lowBits := MAX(LONGCARD);
  binOpTest[18].right.highBits := 0;
  binOpTest[18].right.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  binOpTest[18].operation[Add].expected.highBits := 1;
  binOpTest[18].operation[Add].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[18].operation[Add].expStatus := Success;
  
  binOpTest[18].operation[Sub].expected.highBits := 0;
  binOpTest[18].operation[Sub].expected.lowBits := 0;
  binOpTest[18].operation[Sub].expStatus := Success;
  
  binOpTest[18].operation[Mul].expStatus := Overflow;
  
  binOpTest[18].operation[Div].expected.highBits := 0;
  binOpTest[18].operation[Div].expected.lowBits := 1;
  binOpTest[18].operation[Div].expStatus := Success;
  
  binOpTest[18].operation[Mod].expected.highBits := 0;
  binOpTest[18].operation[Mod].expected.lowBits := 0;
  binOpTest[18].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[19].args := "(MAX(LONGCARD), -MAX(LONGCARD))";
  binOpTest[19].left.highBits := 0;
  binOpTest[19].left.lowBits := MAX(LONGCARD);
  binOpTest[19].right.highBits := -1;
  binOpTest[19].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[19].operation[Add].expected.highBits := 0;
  binOpTest[19].operation[Add].expected.lowBits := 0;
  binOpTest[19].operation[Add].expStatus := Success;
  
  binOpTest[19].operation[Sub].expected.highBits := 1;
  binOpTest[19].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[19].operation[Sub].expStatus := Success;
  
  binOpTest[19].operation[Mul].expStatus := Underflow;
  
  binOpTest[19].operation[Div].expected.highBits := -1;
  binOpTest[19].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[19].operation[Div].expStatus := Success;
  
  binOpTest[19].operation[Mod].expected.highBits := 0;
  binOpTest[19].operation[Mod].expected.lowBits := 0;
  binOpTest[19].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[20].args := "(-MAX(LONGCARD), -MAX(LONGCARD))";
  binOpTest[20].left.highBits := -1;
  binOpTest[20].left.lowBits := 1;
  binOpTest[20].right.highBits := -1;
  binOpTest[20].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[20].operation[Add].expected.highBits := -2;
  binOpTest[20].operation[Add].expected.lowBits := 2;
  binOpTest[20].operation[Add].expStatus := Success;
  
  binOpTest[20].operation[Sub].expected.highBits := 0;
  binOpTest[20].operation[Sub].expected.lowBits := 0;
  binOpTest[20].operation[Sub].expStatus := Success;
  
  binOpTest[20].operation[Mul].expStatus := Overflow;
  
  binOpTest[20].operation[Div].expected.highBits := 0;
  binOpTest[20].operation[Div].expected.lowBits := 1;
  binOpTest[20].operation[Div].expStatus := Success;
  
  binOpTest[20].operation[Mod].expected.highBits := 0;
  binOpTest[20].operation[Mod].expected.lowBits := 0;
  binOpTest[20].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[21].args := "(00000001:0000FFFF, 00000000:FFFF0001)";
  binOpTest[21].left.highBits := 1;
  binOpTest[21].left.lowBits := 0FFFFH;
  binOpTest[21].right.highBits := 0;
  binOpTest[21].right.lowBits := 0FFFF0001H;
  
  (* expected results *)
  binOpTest[21].operation[Add].expected.highBits := 2;
  binOpTest[21].operation[Add].expected.lowBits := 0;
  binOpTest[21].operation[Add].expStatus := Success;
  
  binOpTest[21].operation[Sub].expected.highBits := 0;
  binOpTest[21].operation[Sub].expected.lowBits := 01FFFEH;
  binOpTest[21].operation[Sub].expStatus := Success;
  
  binOpTest[21].operation[Mul].expStatus := Overflow;
  
  binOpTest[21].operation[Div].expected.highBits := 0;
  binOpTest[21].operation[Div].expected.lowBits := 1;
  binOpTest[21].operation[Div].expStatus := Success;
  
  binOpTest[21].operation[Mod].expected.highBits := 0;
  binOpTest[21].operation[Mod].expected.lowBits := 01FFFEH;
  binOpTest[21].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[22].args := "(MAX(INT64T), 1000000000)";
  binOpTest[22].left.highBits := MAX(LONGINT);
  binOpTest[22].left.lowBits := MAX(LONGCARD);
  binOpTest[22].right.highBits := 0;
  binOpTest[22].right.lowBits := 1000000000;
  
  (* expected results *)
  binOpTest[22].operation[Add].expStatus := Overflow;
  
  binOpTest[22].operation[Sub].expected.highBits := MAX(LONGINT);
  binOpTest[22].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1000000000;
  binOpTest[22].operation[Sub].expStatus := Success;
  
  binOpTest[22].operation[Mul].expStatus := Overflow;
  
  binOpTest[22].operation[Div].expected.highBits := 2;
  binOpTest[22].operation[Div].expected.lowBits := 633825300; (* 025C71E14H *)
  binOpTest[22].operation[Div].expStatus := Success;
  
  binOpTest[22].operation[Mod].expected.highBits := 0;
  binOpTest[22].operation[Mod].expected.lowBits := 854775807; (* 032F2B7FFH *)
  binOpTest[22].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[23].args := "(MIN(INT64T), -1000000000)";
  binOpTest[23].left.highBits := MIN(LONGINT);
  binOpTest[23].left.lowBits := 0;
  binOpTest[23].right.highBits := -1;
  binOpTest[23].right.lowBits := MAX(LONGCARD) - 999999999;
  
  (* expected results *)
  binOpTest[23].operation[Add].expStatus := Underflow;
  
  binOpTest[23].operation[Sub].expected.highBits := MIN(LONGINT);
  binOpTest[23].operation[Sub].expected.lowBits := 1000000000;
  binOpTest[23].operation[Sub].expStatus := Success;
  
  binOpTest[23].operation[Mul].expStatus := Overflow;
  
  binOpTest[23].operation[Div].expected.highBits := 2;
  binOpTest[23].operation[Div].expected.lowBits := 633825300; (* 025C71E14H *)
  binOpTest[23].operation[Div].expStatus := Success;
  
  binOpTest[23].operation[Mod].expected.highBits := -1;
  binOpTest[23].operation[Mod].expected.lowBits := MAX(LONGCARD) - 854775807;
  binOpTest[23].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[24].args := "(MAX(INT64T), MAX(LONGCARD)+1)";
  binOpTest[24].left.highBits := MAX(LONGINT);
  binOpTest[24].left.lowBits := MAX(LONGCARD);
  binOpTest[24].right.highBits := 1;
  binOpTest[24].right.lowBits := 0;
  
  (* expected results *)
  binOpTest[24].operation[Add].expStatus := Overflow;
  
  binOpTest[24].operation[Sub].expected.highBits := MAX(LONGINT) - 1;
  binOpTest[24].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[24].operation[Sub].expStatus := Success;
  
  binOpTest[24].operation[Mul].expStatus := Overflow;
  
  binOpTest[24].operation[Div].expected.highBits := 0;
  binOpTest[24].operation[Div].expected.lowBits := MAX(LONGINT);
  binOpTest[24].operation[Div].expStatus := Success;
  
  binOpTest[24].operation[Mod].expected.highBits := 0;
  binOpTest[24].operation[Mod].expected.lowBits := MAX(LONGCARD);
  binOpTest[24].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[25].args := "(MIN(INT64T), -MAX(LONGCARD)-1)";
  binOpTest[25].left.highBits := MIN(LONGINT);
  binOpTest[25].left.lowBits := 0;
  binOpTest[25].right.highBits := -1;
  binOpTest[25].right.lowBits := 0;
  
  (* expected results *)
  binOpTest[25].operation[Add].expStatus := Underflow;
  
  binOpTest[25].operation[Sub].expected.highBits := MIN(LONGINT) + 1;
  binOpTest[25].operation[Sub].expected.lowBits := 0;
  binOpTest[25].operation[Sub].expStatus := Success;
  
  binOpTest[25].operation[Mul].expStatus := Overflow;
  
  binOpTest[25].operation[Div].expected.highBits := 0;
  binOpTest[25].operation[Div].expected.lowBits := 080000000H;
  binOpTest[25].operation[Div].expStatus := Success;
  
  binOpTest[25].operation[Mod].expected.highBits := 0;
  binOpTest[25].operation[Mod].expected.lowBits := 0;
  binOpTest[25].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[26].args := "(MAX(INT64T), 40000000:00000001)";
  binOpTest[26].left.highBits := MAX(LONGINT);
  binOpTest[26].left.lowBits := MAX(LONGCARD);
  binOpTest[26].right.highBits := 040000000H;
  binOpTest[26].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[26].operation[Add].expStatus := Overflow;
  
  binOpTest[26].operation[Sub].expected.highBits := 03FFFFFFFH;
  binOpTest[26].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[26].operation[Sub].expStatus := Success;
  
  binOpTest[26].operation[Mul].expStatus := Overflow;
  
  binOpTest[26].operation[Div].expected.highBits := 0;
  binOpTest[26].operation[Div].expected.lowBits := 1;
  binOpTest[26].operation[Div].expStatus := Success;
  
  binOpTest[26].operation[Mod].expected.highBits := 03FFFFFFFH;
  binOpTest[26].operation[Mod].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[26].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[27].args := "(40000000:00000000, 2)";
  binOpTest[27].left.highBits := 040000000H;
  binOpTest[27].left.lowBits := 0;
  binOpTest[27].right.highBits := 0;
  binOpTest[27].right.lowBits := 2;
  
  (* expected results *)
  binOpTest[27].operation[Add].expected.highBits := 040000000H;
  binOpTest[27].operation[Add].expected.lowBits := 2;
  binOpTest[27].operation[Add].expStatus := Success;
  
  binOpTest[27].operation[Sub].expected.highBits := 03FFFFFFFH;
  binOpTest[27].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[27].operation[Sub].expStatus := Success;
  
  binOpTest[27].operation[Mul].expStatus := Overflow;
  
  binOpTest[27].operation[Div].expected.highBits := 020000000H;
  binOpTest[27].operation[Div].expected.lowBits := 0;
  binOpTest[27].operation[Div].expStatus := Success;
  
  binOpTest[27].operation[Mod].expected.highBits := 0;
  binOpTest[27].operation[Mod].expected.lowBits := 0;
  binOpTest[27].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[28].args := "(MIN(INT64T), 1)";
  binOpTest[28].left.highBits := MIN(LONGINT);
  binOpTest[28].left.lowBits := 0;
  binOpTest[28].right.highBits := 0;
  binOpTest[28].right.lowBits := 1;

  (* expected results *)
  binOpTest[28].operation[Add].expected.highBits := MIN(LONGINT);
  binOpTest[28].operation[Add].expected.lowBits := 1;
  binOpTest[28].operation[Add].expStatus := Success;

  binOpTest[28].operation[Sub].expStatus := Underflow;

  binOpTest[28].operation[Mul].expected.highBits := MIN(LONGINT);
  binOpTest[28].operation[Mul].expected.lowBits := 0;
  binOpTest[28].operation[Mul].expStatus := Success;

  binOpTest[28].operation[Div].expected.highBits := MIN(LONGINT);
  binOpTest[28].operation[Div].expected.lowBits := 0;
  binOpTest[28].operation[Div].expStatus := Success;

  binOpTest[28].operation[Mod].expected.highBits := 0;
  binOpTest[28].operation[Mod].expected.lowBits := 0;
  binOpTest[28].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[29].args := "(MIN(INT64T), -1)";
  binOpTest[29].left.highBits := MIN(LONGINT);
  binOpTest[29].left.lowBits := 0;
  binOpTest[29].right.highBits := -1;
  binOpTest[29].right.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  binOpTest[29].operation[Add].expStatus := Underflow;
  
  binOpTest[29].operation[Sub].expected.highBits := MIN(LONGINT);
  binOpTest[29].operation[Sub].expected.lowBits := 1;
  binOpTest[29].operation[Sub].expStatus := Success;
  
  binOpTest[29].operation[Mul].expStatus := Overflow;
  
  binOpTest[29].operation[Div].expStatus := Overflow;
  
  binOpTest[29].operation[Mod].expected.highBits := 0;
  binOpTest[29].operation[Mod].expected.lowBits := 0;
  binOpTest[29].operation[Mod].expStatus := Success
END InitBinOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunBinOpTest(binOp, test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunBinOpTest
  ( binOp : BinOpId; test : BinOpTest; VAR passed, failed : CARDINAL );
VAR
  res : INT64T;
  operation : BinOp;
  stat : Status;
BEGIN
  PrintLabelForBinOp(binOp, test.args);
  
  operation := test.operation[binOp];
  
  operation.proc(test.left, test.right, res, stat);
  PrintResult(res); PrintStatus(stat);

  IF stat = Success THEN
    IF (operation.expStatus = Success) AND
      (res.highBits = operation.expected.highBits) AND
      (res.lowBits = operation.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* stat # Success *)
    IF stat = operation.expStatus THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunBinOpTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunBinOpTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all BinOpTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunBinOpTests ( VAR passed, failed : CARDINAL );
VAR
  binOp : BinOpId;
  index : CARDINAL;
BEGIN
  FOR binOp := MIN(BinOpId) TO MAX(BinOpId) DO
    FOR index := 0 TO BinOpTestGroupCount-1 DO
      RunBinOpTest(binOp, binOpTest[index], passed, failed)
    END (* FOR *)
  END (* FOR *)
END RunBinOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLabelForAbsNegOp(absNegOp, label)
 * --------------------------------------------------------------------------
 * Prints test label string for absNegOp with args. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabelForAbsNegOp ( absNegOp : AbsNegOpId; args : LabelString );
BEGIN
  InOut.WriteString("*** ");
  CASE absNegOp OF
    Abs : InOut.WriteString("INT64.Abs")
  | Neg : InOut.WriteString("INT64.Neg")
  END; (* CASE *)
  InOut.WriteString(args);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabelForAbsNegOp;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLabelForUnaryOp(unaryOp, label)
 * --------------------------------------------------------------------------
 * Prints test label string for unaryOp with args. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabelForUnaryOp ( unaryOp : UnaryOpId; args : LabelString );
BEGIN
  InOut.WriteString("*** ");
  CASE unaryOp OF
    Inc : InOut.WriteString("INT64.Inc")
  | Dec : InOut.WriteString("INT64.Dec")
  END; (* CASE *)
  InOut.WriteString(args);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabelForUnaryOp;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLabelForBinOp(label)
 * --------------------------------------------------------------------------
 * Prints test label string for binOp with args. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabelForBinOp ( binOp : BinOpId; args : LabelString );
BEGIN
  InOut.WriteString("*** ");
  CASE binOp OF
    Add : InOut.WriteString("INT64.Add")
  | Sub : InOut.WriteString("INT64.Sub")
  | Mul : InOut.WriteString("INT64.Mul")
  | Div : InOut.WriteString("INT64.Div")
  | Mod : InOut.WriteString("INT64.Mod")
  END; (* CASE *)
  InOut.WriteString(args);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabelForBinOp;


(* --------------------------------------------------------------------------
 * Procedure:  PrintResult(i)
 * --------------------------------------------------------------------------
 * Prints result label followed by value i. 
 * ----------------------------------------------------------------------- *)

CONST ResultLabel = " result: ";

PROCEDURE PrintResult ( i : INT64T );
BEGIN
  InOut.WriteString(ResultLabel);
  Int64IO.Write(i);
  InOut.WriteLn
END PrintResult;


(* --------------------------------------------------------------------------
 * Procedure:  PrintCardResult(n)
 * --------------------------------------------------------------------------
 * Prints result label followed by value n. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintCardResult ( n : CARDINAL );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.Write(VAL(LONGCARD, n));
  InOut.WriteLn
END PrintCardResult;


(* --------------------------------------------------------------------------
 * Procedure:  PrintStatus(stat)
 * --------------------------------------------------------------------------
 * Prints status label followed by status stat. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintStatus ( stat : Status );
BEGIN
  InOut.WriteString(" status: ");
  NumStatusIO.Write(stat);
  InOut.WriteLn
END PrintStatus;


(* --------------------------------------------------------------------------
 * Module initialisation
 * ----------------------------------------------------------------------- *)

BEGIN (* TestInt64BaseMath *)
  InitAbsNegTests;
  InitUnaryOpTests;
  InitBinOpTests
END TestInt64BaseMath.
