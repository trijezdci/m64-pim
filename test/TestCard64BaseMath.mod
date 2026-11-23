(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestCard64BaseMath;

(* Test Suite for CARD64 Basic Arithmetic Operations *)


IMPORT CARD64, Card64IO, LongCardIO, NumStatusIO, InOut;

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
  
  InOut.WriteString("Digit Count Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run digit count tests *)
  RunDigitCountTests(passed, failed);
  
  InOut.WriteString("Unary Arithmentic Operation Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all unary arithmetic operation tests *)
  RunUnaryOpTests(passed, failed);
  
  InOut.WriteString("Binary Arithmentic Operation Tests for CARD64");
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
  RETURN DigitCountTestCount + UnaryOpTestCount + BinOpTestCount;
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
 * Test parameter type for CARD64.digitCount
 * ----------------------------------------------------------------------- *)

TYPE DigitCountTest = RECORD
  operand : CARD64T;
  expected : CARDINAL;
  label : LabelString
END; (* DigitCountTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitDigitCountTests
 * --------------------------------------------------------------------------
 * Initialises tests for digitCount.
 * ----------------------------------------------------------------------- *)

CONST DigitCountTestCount = 40;

VAR digitCountTest : ARRAY [0..DigitCountTestCount-1] OF DigitCountTest;

PROCEDURE InitDigitCountTests;
BEGIN
  digitCountTest[0].label := "CARD64.digitCount(0)";
  digitCountTest[0].operand.highBits := 0;
  digitCountTest[0].operand.lowBits := 0;
  digitCountTest[0].expected := 1;
  
  digitCountTest[1].label := "CARD64.digitCount(9)";
  digitCountTest[1].operand.highBits := 0;
  digitCountTest[1].operand.lowBits := 9;
  digitCountTest[1].expected := 1;
  
  digitCountTest[2].label := "CARD64.digitCount(10)";
  digitCountTest[2].operand.highBits := 0;
  digitCountTest[2].operand.lowBits := 10;
  digitCountTest[2].expected := 2;
  
  digitCountTest[3].label := "CARD64.digitCount(99)";
  digitCountTest[3].operand.highBits := 0;
  digitCountTest[3].operand.lowBits := 99;
  digitCountTest[3].expected := 2;
  
  digitCountTest[4].label := "CARD64.digitCount(100)";
  digitCountTest[4].operand.highBits := 0;
  digitCountTest[4].operand.lowBits := 100;
  digitCountTest[4].expected := 3;
  
  digitCountTest[5].label := "CARD64.digitCount(999)";
  digitCountTest[5].operand.highBits := 0;
  digitCountTest[5].operand.lowBits := 999;
  digitCountTest[5].expected := 3;
  
  digitCountTest[6].label := "CARD64.digitCount(1,000)";
  digitCountTest[6].operand.highBits := 0;
  digitCountTest[6].operand.lowBits := 1000;
  digitCountTest[6].expected := 4;
  
  digitCountTest[7].label := "CARD64.digitCount(9,999)";
  digitCountTest[7].operand.highBits := 0;
  digitCountTest[7].operand.lowBits := 9999;
  digitCountTest[7].expected := 4;
  
  digitCountTest[8].label := "CARD64.digitCount(10,000)";
  digitCountTest[8].operand.highBits := 0;
  digitCountTest[8].operand.lowBits := 10000;
  digitCountTest[8].expected := 5;
  
  digitCountTest[9].label := "CARD64.digitCount(99,999)";
  digitCountTest[9].operand.highBits := 0;
  digitCountTest[9].operand.lowBits := 99999;
  digitCountTest[9].expected := 5;
  
  digitCountTest[10].label := "CARD64.digitCount(100,000)";
  digitCountTest[10].operand.highBits := 0;
  digitCountTest[10].operand.lowBits := 100000;
  digitCountTest[10].expected := 6;
  
  digitCountTest[11].label := "CARD64.digitCount(999,999)";
  digitCountTest[11].operand.highBits := 0;
  digitCountTest[11].operand.lowBits := 999999;
  digitCountTest[11].expected := 6;
  
  digitCountTest[12].label := "CARD64.digitCount(1,000,000)";
  digitCountTest[12].operand.highBits := 0;
  digitCountTest[12].operand.lowBits := 1000000;
  digitCountTest[12].expected := 7;
  
  digitCountTest[13].label := "CARD64.digitCount(9,999,999)";
  digitCountTest[13].operand.highBits := 0;
  digitCountTest[13].operand.lowBits := 9999999;
  digitCountTest[13].expected := 7;
  
  digitCountTest[14].label := "CARD64.digitCount(10,000,000)";
  digitCountTest[14].operand.highBits := 0;
  digitCountTest[14].operand.lowBits := 10000000;
  digitCountTest[14].expected := 8;
  
  digitCountTest[15].label := "CARD64.digitCount(99,999,999)";
  digitCountTest[15].operand.highBits := 0;
  digitCountTest[15].operand.lowBits := 99999999;
  digitCountTest[15].expected := 8;
  
  digitCountTest[16].label := "CARD64.digitCount(100,000,000)";
  digitCountTest[16].operand.highBits := 0;
  digitCountTest[16].operand.lowBits := 100000000;
  digitCountTest[16].expected := 9;
  
  digitCountTest[17].label := "CARD64.digitCount(999,999,999)";
  digitCountTest[17].operand.highBits := 0;
  digitCountTest[17].operand.lowBits := 999999999;
  digitCountTest[17].expected := 9;
  
  digitCountTest[18].label := "CARD64.digitCount(1,000,000,000)";
  digitCountTest[18].operand.highBits := 0;
  digitCountTest[18].operand.lowBits := 1000000000;
  digitCountTest[18].expected := 10;
  
  digitCountTest[19].label := "CARD64.digitCount(9,999,999,999)";
  digitCountTest[19].operand.highBits := 2;
  digitCountTest[19].operand.lowBits := 1410065407;
  digitCountTest[19].expected := 10;
  
  digitCountTest[20].label := "CARD64.digitCount(10,000,000,000)";
  digitCountTest[20].operand.highBits := 2;
  digitCountTest[20].operand.lowBits := 1410065408;
  digitCountTest[20].expected := 11;
  
  digitCountTest[21].label := "CARD64.digitCount(99,999,999,999)";
  digitCountTest[21].operand.highBits := 23;
  digitCountTest[21].operand.lowBits := 1215752191;
  digitCountTest[21].expected := 11;
  
  digitCountTest[22].label := "CARD64.digitCount(100,000,000,000)";
  digitCountTest[22].operand.highBits := 23;
  digitCountTest[22].operand.lowBits := 1215752192;
  digitCountTest[22].expected := 12;
  
  digitCountTest[23].label := "CARD64.digitCount(999,999,999,999)";
  digitCountTest[23].operand.highBits := 232;
  digitCountTest[23].operand.lowBits := 3567587327;
  digitCountTest[23].expected := 12;
  
  digitCountTest[24].label := "CARD64.digitCount(1,000,000,000,000)";
  digitCountTest[24].operand.highBits := 232;
  digitCountTest[24].operand.lowBits := 3567587328;
  digitCountTest[24].expected := 13;
  
  digitCountTest[25].label := "CARD64.digitCount(9,999,999,999,999)";
  digitCountTest[25].operand.highBits := 2328;
  digitCountTest[25].operand.lowBits := 1316134911;
  digitCountTest[25].expected := 13;
  
  digitCountTest[26].label := "CARD64.digitCount(10,000,000,000,000)";
  digitCountTest[26].operand.highBits := 2328;
  digitCountTest[26].operand.lowBits := 1316134912;
  digitCountTest[26].expected := 14;
  
  digitCountTest[27].label := "CARD64.digitCount(99,999,999,999,999)";
  digitCountTest[27].operand.highBits := 23283;
  digitCountTest[27].operand.lowBits := 276447231;
  digitCountTest[27].expected := 14;
  
  digitCountTest[28].label := "CARD64.digitCount(100,000,000,000,000)";
  digitCountTest[28].operand.highBits := 23283;
  digitCountTest[28].operand.lowBits := 276447232;
  digitCountTest[28].expected := 15;
  
  digitCountTest[29].label := "CARD64.digitCount(999,999,999,999,999)";
  digitCountTest[29].operand.highBits := 232830;
  digitCountTest[29].operand.lowBits := 2764472319;
  digitCountTest[29].expected := 15;
  
  digitCountTest[30].label := "CARD64.digitCount(1,000,000,000,000,000)";
  digitCountTest[30].operand.highBits := 232830;
  digitCountTest[30].operand.lowBits := 2764472320;
  digitCountTest[30].expected := 16;
  
  digitCountTest[31].label := "CARD64.digitCount(9,999,999,999,999,999)";
  digitCountTest[31].operand.highBits := 2328306;
  digitCountTest[31].operand.lowBits := 1874919423;
  digitCountTest[31].expected := 16;
  
  digitCountTest[32].label := "CARD64.digitCount(10,000,000,000,000,000)";
  digitCountTest[32].operand.highBits := 2328306;
  digitCountTest[32].operand.lowBits := 1874919424;
  digitCountTest[32].expected := 17;
  
  digitCountTest[33].label := "CARD64.digitCount(99,999,999,999,999,999)";
  digitCountTest[33].operand.highBits := 23283064;
  digitCountTest[33].operand.lowBits := 1569325055;
  digitCountTest[33].expected := 17;
  
  digitCountTest[34].label := "CARD64.digitCount(100,000,000,000,000,000)";
  digitCountTest[34].operand.highBits := 23283064;
  digitCountTest[34].operand.lowBits := 1569325056;
  digitCountTest[34].expected := 18;
  
  digitCountTest[35].label := "CARD64.digitCount(999,999,999,999,999,999)";
  digitCountTest[35].operand.highBits := 232830643;
  digitCountTest[35].operand.lowBits := 2808348671;
  digitCountTest[35].expected := 18;
  
  digitCountTest[36].label := "CARD64.digitCount(1,000,000,000,000,000,000)";
  digitCountTest[36].operand.highBits := 232830643;
  digitCountTest[36].operand.lowBits := 2808348672;
  digitCountTest[36].expected := 19;
  
  digitCountTest[37].label := "CARD64.digitCount(9,999,999,999,999,999,999)";
  digitCountTest[37].operand.highBits := 2328306436;
  digitCountTest[37].operand.lowBits := 2313682943;
  digitCountTest[37].expected := 19;
  
  digitCountTest[38].label := "CARD64.digitCount(10,000,000,000,000,000,000)";
  digitCountTest[38].operand.highBits := 2328306436;
  digitCountTest[38].operand.lowBits := 2313682944;
  digitCountTest[38].expected := 20;
  
  digitCountTest[39].label := "CARD64.digitCount(MAX(CARD64T))";
  digitCountTest[39].operand.highBits := 0FFFFFFFFH;
  digitCountTest[39].operand.lowBits := 0FFFFFFFFH;
  digitCountTest[39].expected := 20
END InitDigitCountTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunDigitCountTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunDigitCountTest
  ( test : DigitCountTest; VAR passed, failed : CARDINAL );
VAR
  res : CARDINAL;
BEGIN
  PrintLabel(test.label);
  
  res := CARD64.digitCount(test.operand);
  PrintCardResult(res);
  IF (res = test.expected) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunDigitCountTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunDigitCountTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all DigitCountTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunDigitCountTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO DigitCountTestCount-1 DO
    RunDigitCountTest(digitCountTest[index], passed, failed)
  END (* FOR *)
END RunDigitCountTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64 Inc and Dec
 * ----------------------------------------------------------------------- *)

TYPE UnaryOpProc = PROCEDURE ( VAR CARD64T, VAR Status );

TYPE UnaryOpId = ( Inc, Dec );

TYPE UnaryOp = RECORD
  proc : UnaryOpProc;
  expected : CARD64T;
  expStatus : Status
END; (* UnaryOp *)

TYPE UnaryOpTest = RECORD
  operation : ARRAY [Inc..Dec] OF UnaryOp;
  operand : CARD64T;
  args : LabelString
END; (* UnaryOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitUnaryOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for unary arithmetic operations.
 * ----------------------------------------------------------------------- *)

CONST UnaryOpTestGroupCount = 10;

CONST UnaryOpTestCount = UnaryOpTestGroupCount * (ORD(MAX(UnaryOpId)) + 1);

VAR unaryOpTest : ARRAY [0..UnaryOpTestCount-1] OF UnaryOpTest;

PROCEDURE InitUnaryOpTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO BinOpTestGroupCount-1 DO
    unaryOpTest[index].operation[Inc].proc := CARD64.Inc;
    unaryOpTest[index].operation[Dec].proc := CARD64.Dec
  END; (* FOR *)
  
  (* operand *)
  unaryOpTest[0].args := "(0:0)";
  unaryOpTest[0].operand.highBits := 0;
  unaryOpTest[0].operand.lowBits := 0;
  
  (* expected results *)
  unaryOpTest[0].operation[Inc].expected.highBits := 0;
  unaryOpTest[0].operation[Inc].expected.lowBits := 1;
  unaryOpTest[0].operation[Inc].expStatus := Success;
  
  unaryOpTest[0].operation[Dec].expStatus := Underflow;
  
  (* operand *)
  unaryOpTest[1].args := "(0:1)";
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
  unaryOpTest[2].args := "(0:2)";
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
  unaryOpTest[3].args := "(0:3)";
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
  unaryOpTest[4].args := "(0:4)";
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
  unaryOpTest[5].args := "(MAX(LONGCARD))";
  unaryOpTest[5].operand.highBits := 0;
  unaryOpTest[5].operand.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  unaryOpTest[5].operation[Inc].expected.highBits := 1;
  unaryOpTest[5].operation[Inc].expected.lowBits := 0;
  unaryOpTest[5].operation[Inc].expStatus := Success;

  unaryOpTest[5].operation[Dec].expected.highBits := 0;
  unaryOpTest[5].operation[Dec].expected.lowBits := MAX(LONGCARD)-1;
  unaryOpTest[5].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[6].args := "(MAX(LONGCARD)+1)";
  unaryOpTest[6].operand.highBits := 1;
  unaryOpTest[6].operand.lowBits := 1;
  
  (* expected results *)
  unaryOpTest[6].operation[Inc].expected.highBits := 1;
  unaryOpTest[6].operation[Inc].expected.lowBits := 2;
  unaryOpTest[6].operation[Inc].expStatus := Success;

  unaryOpTest[6].operation[Dec].expected.highBits := 0;
  unaryOpTest[6].operation[Dec].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[6].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[7].args := "(MAX(LONGCARD)+2)";
  unaryOpTest[7].operand.highBits := 1;
  unaryOpTest[7].operand.lowBits := 2;
  
  (* expected results *)
  unaryOpTest[7].operation[Inc].expected.highBits := 1;
  unaryOpTest[7].operation[Inc].expected.lowBits := 3;
  unaryOpTest[7].operation[Inc].expStatus := Success;

  unaryOpTest[7].operation[Dec].expected.highBits := 1;
  unaryOpTest[7].operation[Dec].expected.lowBits := 1;
  unaryOpTest[7].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[8].args := "(MAX(CARD64T)-1)";
  unaryOpTest[8].operand.highBits := MAX(LONGCARD);
  unaryOpTest[8].operand.lowBits := MAX(LONGCARD)-1;
  
  (* expected results *)
  unaryOpTest[8].operation[Inc].expected.highBits := MAX(LONGCARD);
  unaryOpTest[8].operation[Inc].expected.lowBits := MAX(LONGCARD);
  unaryOpTest[8].operation[Inc].expStatus := Success;

  unaryOpTest[8].operation[Dec].expected.highBits := MAX(LONGCARD);
  unaryOpTest[8].operation[Dec].expected.lowBits := MAX(LONGCARD)-2;
  unaryOpTest[8].operation[Dec].expStatus := Success;
  
  (* operand *)
  unaryOpTest[9].args := "(MAX(CARD64T))";
  unaryOpTest[9].operand.highBits := MAX(LONGCARD);
  unaryOpTest[9].operand.lowBits := MAX(LONGCARD);
  
  (* expected results *)
  unaryOpTest[9].operation[Inc].expStatus := Overflow;

  unaryOpTest[9].operation[Dec].expected.highBits := MAX(LONGCARD);
  unaryOpTest[9].operation[Dec].expected.lowBits := MAX(LONGCARD)-1;
  unaryOpTest[9].operation[Dec].expStatus := Success
END InitUnaryOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunUnaryOpTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunUnaryOpTest
  ( unaryOp : UnaryOpId; test : UnaryOpTest; VAR passed, failed : CARDINAL );
VAR
  operand : CARD64T;
  operation : UnaryOp;
  stat : Status;
BEGIN
  PrintLabelForUnaryOp(unaryOp, test.args);
  
  operand := test.operand;
  operation := test.operation[unaryOp];
  
  operation.proc(operand, stat);
  PrintResult(operand); PrintStatus(stat);
  
  IF operation.expStatus = Success THEN
    IF (operand.highBits = operation.expected.highBits) AND
      (operand.lowBits = operation.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* operation.expStatus # Success *)
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
 * Test parameter type for CARD64 Add, Sub, Mul, Div and Mod
 * ----------------------------------------------------------------------- *)

TYPE BinOpProc = PROCEDURE ( CARD64T, CARD64T, VAR CARD64T, VAR Status );

TYPE BinOpId = ( Add, Sub, Mul, Div, Mod );

TYPE BinOp = RECORD
  proc : BinOpProc;
  expected : CARD64T;
  expStatus : Status
END; (* BinOp *)

TYPE BinOpTest = RECORD
  operation : ARRAY [Add..Mod] OF BinOp;
  left, right : CARD64T;
  args : LabelString
END; (* BinOpTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitBinOpTests
 * --------------------------------------------------------------------------
 * Initialises tests for CARD64 Add, Sub, Mul, Div and Mod
 * ----------------------------------------------------------------------- *)

CONST BinOpTestGroupCount = 12;

CONST BinOpTestCount = BinOpTestGroupCount * (ORD(MAX(BinOpId)) + 1);

VAR binOpTest : ARRAY [0..BinOpTestGroupCount-1] OF BinOpTest;

PROCEDURE InitBinOpTests;
VAR
  index : CARDINAL;
BEGIN
  (* operations *)
  FOR index := 0 TO BinOpTestGroupCount-1 DO
    binOpTest[index].operation[Add].proc := CARD64.Add;
    binOpTest[index].operation[Sub].proc := CARD64.Sub;
    binOpTest[index].operation[Mul].proc := CARD64.Mul;
    binOpTest[index].operation[Div].proc := CARD64.Div;
    binOpTest[index].operation[Mod].proc := CARD64.Mod
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

  binOpTest[1].operation[Sub].expStatus := Underflow;

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
  binOpTest[2].args := "(1, 0)";
  binOpTest[2].left.highBits := 0;
  binOpTest[2].left.lowBits := 1;
  binOpTest[2].right.highBits := 0;
  binOpTest[2].right.lowBits := 0;

  (* expected results *)
  binOpTest[2].operation[Add].expected.highBits := 0;
  binOpTest[2].operation[Add].expected.lowBits := 1;
  binOpTest[2].operation[Add].expStatus := Success;

  binOpTest[2].operation[Sub].expected.highBits := 0;
  binOpTest[2].operation[Sub].expected.lowBits := 1;
  binOpTest[2].operation[Sub].expStatus := Success;

  binOpTest[2].operation[Mul].expected.highBits := 0;
  binOpTest[2].operation[Mul].expected.lowBits := 0;
  binOpTest[2].operation[Mul].expStatus := Success;

  binOpTest[2].operation[Div].expStatus := DivByZero;
  binOpTest[2].operation[Mod].expStatus := DivByZero;
  
  (* operands *)
  binOpTest[3].args := "(65535, 1)";
  binOpTest[3].left.highBits := 0;
  binOpTest[3].left.lowBits := 0FFFFH;
  binOpTest[3].right.highBits := 0;
  binOpTest[3].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[3].operation[Add].expected.highBits := 0;
  binOpTest[3].operation[Add].expected.lowBits := 010000H;
  binOpTest[3].operation[Add].expStatus := Success;

  binOpTest[3].operation[Sub].expected.highBits := 0;
  binOpTest[3].operation[Sub].expected.lowBits := 0FFFEH;
  binOpTest[3].operation[Sub].expStatus := Success;

  binOpTest[3].operation[Mul].expected.highBits := 0;
  binOpTest[3].operation[Mul].expected.lowBits := 0FFFFH;
  binOpTest[3].operation[Mul].expStatus := Success;

  binOpTest[3].operation[Div].expected.highBits := 0;
  binOpTest[3].operation[Div].expected.lowBits := 0FFFFH;
  binOpTest[3].operation[Div].expStatus := Success;

  binOpTest[3].operation[Mod].expected.highBits := 0;
  binOpTest[3].operation[Mod].expected.lowBits := 0;
  binOpTest[3].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[4].args := "(MAX(LONGCARD), 1)";
  binOpTest[4].left.highBits := 0;
  binOpTest[4].left.lowBits := MAX(LONGCARD);
  binOpTest[4].right.highBits := 0;
  binOpTest[4].right.lowBits := 1;
  
  (* expected results *)
  binOpTest[4].operation[Add].expected.highBits := 1;
  binOpTest[4].operation[Add].expected.lowBits := 0;
  binOpTest[4].operation[Add].expStatus := Success;

  binOpTest[4].operation[Sub].expected.highBits := 0;
  binOpTest[4].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[4].operation[Sub].expStatus := Success;

  binOpTest[4].operation[Mul].expected.highBits := 0;
  binOpTest[4].operation[Mul].expected.lowBits := MAX(LONGCARD);
  binOpTest[4].operation[Mul].expStatus := Success;

  binOpTest[4].operation[Div].expected.highBits := 0;
  binOpTest[4].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[4].operation[Div].expStatus := Success;

  binOpTest[4].operation[Mod].expected.highBits := 0;
  binOpTest[4].operation[Mod].expected.lowBits := 0;
  binOpTest[4].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[5].args := "(MAX(LONGCARD)+1, 1)";
  binOpTest[5].left.highBits := 1;
  binOpTest[5].left.lowBits := 0;
  binOpTest[5].right.highBits := 0;
  binOpTest[5].right.lowBits := 1;

  (* expected results *)
  binOpTest[5].operation[Add].expected.highBits := 1;
  binOpTest[5].operation[Add].expected.lowBits := 1;
  binOpTest[5].operation[Add].expStatus := Success;

  binOpTest[5].operation[Sub].expected.highBits := 0;
  binOpTest[5].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[5].operation[Sub].expStatus := Success;

  binOpTest[5].operation[Mul].expected.highBits := 1;
  binOpTest[5].operation[Mul].expected.lowBits := 0;
  binOpTest[5].operation[Mul].expStatus := Success;

  binOpTest[5].operation[Div].expected.highBits := 1;
  binOpTest[5].operation[Div].expected.lowBits := 0;
  binOpTest[5].operation[Div].expStatus := Success;

  binOpTest[5].operation[Mod].expected.highBits := 0;
  binOpTest[5].operation[Mod].expected.lowBits := 0;
  binOpTest[5].operation[Mod].expStatus := Success;

  (* operands *)
  binOpTest[6].args := "(MAX(LONGCARD), MAX(LONGCARD))";
  binOpTest[6].left.highBits := 0;
  binOpTest[6].left.lowBits := MAX(LONGCARD);
  binOpTest[6].right.highBits := 0;
  binOpTest[6].right.lowBits := MAX(LONGCARD);

  (* expected results *)
  binOpTest[6].operation[Add].expected.highBits := 1;
  binOpTest[6].operation[Add].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[6].operation[Add].expStatus := Success;

  binOpTest[6].operation[Sub].expected.highBits := 0;
  binOpTest[6].operation[Sub].expected.lowBits := 0;
  binOpTest[6].operation[Sub].expStatus := Success;

  binOpTest[6].operation[Mul].expected.highBits := MAX(LONGCARD) - 1;
  binOpTest[6].operation[Mul].expected.lowBits := 1;
  binOpTest[6].operation[Mul].expStatus := Success;

  binOpTest[6].operation[Div].expected.highBits := 0;
  binOpTest[6].operation[Div].expected.lowBits := 1;
  binOpTest[6].operation[Div].expStatus := Success;

  binOpTest[6].operation[Mod].expected.highBits := 0;
  binOpTest[6].operation[Mod].expected.lowBits := 0;
  binOpTest[6].operation[Mod].expStatus := Success;

  (* operands *)
  binOpTest[7].args := "(00000001:0000FFFF, 00000000:FFFF0001)";
  binOpTest[7].left.highBits := 1;
  binOpTest[7].left.lowBits := 0FFFFH;
  binOpTest[7].right.highBits := 0;
  binOpTest[7].right.lowBits := 0FFFF0001H;

  (* expected results *)
  binOpTest[7].operation[Add].expected.highBits := 2;
  binOpTest[7].operation[Add].expected.lowBits := 0;
  binOpTest[7].operation[Add].expStatus := Success;

  binOpTest[7].operation[Sub].expected.highBits := 0;
  binOpTest[7].operation[Sub].expected.lowBits := 01FFFEH;
  binOpTest[7].operation[Sub].expStatus := Success;

  binOpTest[7].operation[Mul].expected.highBits := MAX(LONGCARD);
  binOpTest[7].operation[Mul].expected.lowBits := 01FFFEH;
  binOpTest[7].operation[Mul].expStatus := Success;

  binOpTest[7].operation[Div].expected.highBits := 0;
  binOpTest[7].operation[Div].expected.lowBits := 1;
  binOpTest[7].operation[Div].expStatus := Success;

  binOpTest[7].operation[Mod].expected.highBits := 0;
  binOpTest[7].operation[Mod].expected.lowBits := 01FFFEH;
  binOpTest[7].operation[Mod].expStatus := Success;

  (* operands *)
  binOpTest[8].args := "(MAX(CARD64T), 1000000000)";
  binOpTest[8].left.highBits := MAX(LONGCARD);
  binOpTest[8].left.lowBits := MAX(LONGCARD);
  binOpTest[8].right.highBits := 0;
  binOpTest[8].right.lowBits := 1000000000;

  (* expected results *)
  binOpTest[8].operation[Add].expStatus := Overflow;

  binOpTest[8].operation[Sub].expected.highBits := MAX(LONGCARD);
  binOpTest[8].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1000000000;
  binOpTest[8].operation[Sub].expStatus := Success;

  binOpTest[8].operation[Mul].expStatus := Overflow;

  binOpTest[8].operation[Div].expected.highBits := 4;
  binOpTest[8].operation[Div].expected.lowBits := 1266874889; (* 04B82FA09H *)
  binOpTest[8].operation[Div].expStatus := Success;

  binOpTest[8].operation[Mod].expected.highBits := 0;
  binOpTest[8].operation[Mod].expected.lowBits := 709551615; (* 02A4A15FFH *)
  binOpTest[8].operation[Mod].expStatus := Success;
  
  (* operands *)
  binOpTest[9].args := "(MAX(CARD64T), MAX(LONGCARD)+1)";
  binOpTest[9].left.highBits := MAX(LONGCARD);
  binOpTest[9].left.lowBits := MAX(LONGCARD);
  binOpTest[9].right.highBits := 1;
  binOpTest[9].right.lowBits := 0;

  (* expected results *)
  binOpTest[9].operation[Add].expStatus := Overflow;

  binOpTest[9].operation[Sub].expected.highBits := MAX(LONGCARD) - 1;
  binOpTest[9].operation[Sub].expected.lowBits := MAX(LONGCARD);
  binOpTest[9].operation[Sub].expStatus := Success;

  binOpTest[9].operation[Mul].expStatus := Overflow;

  binOpTest[9].operation[Div].expected.highBits := 0;
  binOpTest[9].operation[Div].expected.lowBits := MAX(LONGCARD);
  binOpTest[9].operation[Div].expStatus := Success;

  binOpTest[9].operation[Mod].expected.highBits := 0;
  binOpTest[9].operation[Mod].expected.lowBits := MAX(LONGCARD);
  binOpTest[9].operation[Mod].expStatus := Success;

  (* operands *)
  binOpTest[10].args := "(MAX(CARD64T), 80000000:00000001)";
  binOpTest[10].left.highBits := MAX(LONGCARD);
  binOpTest[10].left.lowBits := MAX(LONGCARD);
  binOpTest[10].right.highBits := 080000000H;
  binOpTest[10].right.lowBits := 1;

  (* expected results *)
  binOpTest[10].operation[Add].expStatus := Overflow;

  binOpTest[10].operation[Sub].expected.highBits := 07FFFFFFFH;
  binOpTest[10].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[10].operation[Sub].expStatus := Success;

  binOpTest[10].operation[Mul].expStatus := Overflow;

  binOpTest[10].operation[Div].expected.highBits := 0;
  binOpTest[10].operation[Div].expected.lowBits := 1;
  binOpTest[10].operation[Div].expStatus := Success;

  binOpTest[10].operation[Mod].expected.highBits := 07FFFFFFFH;
  binOpTest[10].operation[Mod].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[10].operation[Mod].expStatus := Success;

  (* operands *)
  binOpTest[11].args := "(80000000:00000000, 2)";
  binOpTest[11].left.highBits := 080000000H;
  binOpTest[11].left.lowBits := 0;
  binOpTest[11].right.highBits := 0;
  binOpTest[11].right.lowBits := 2;

  (* expected results *)
  binOpTest[11].operation[Add].expected.highBits := 080000000H;
  binOpTest[11].operation[Add].expected.lowBits := 2;
  binOpTest[11].operation[Add].expStatus := Success;

  binOpTest[11].operation[Sub].expected.highBits := 07FFFFFFFH;
  binOpTest[11].operation[Sub].expected.lowBits := MAX(LONGCARD) - 1;
  binOpTest[11].operation[Sub].expStatus := Success;

  binOpTest[11].operation[Mul].expStatus := Overflow;

  binOpTest[11].operation[Div].expected.highBits := 040000000H;
  binOpTest[11].operation[Div].expected.lowBits := 0;
  binOpTest[11].operation[Div].expStatus := Success;

  binOpTest[11].operation[Mod].expected.highBits := 0;
  binOpTest[11].operation[Mod].expected.lowBits := 0;
  binOpTest[11].operation[Mod].expStatus := Success
END InitBinOpTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunBinOpTest(binOp, test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunBinOpTest
  ( binOp : BinOpId; test : BinOpTest; VAR passed, failed : CARDINAL );
VAR
  res : CARD64T;
  operation : BinOp;
  stat : Status;
BEGIN
  PrintLabelForBinOp(binOp, test.args);
  
  operation := test.operation[binOp];
  
  operation.proc(test.left, test.right, res, stat);
  PrintResult(res); PrintStatus(stat);

  IF operation.expStatus = Success THEN
    IF (res.highBits = operation.expected.highBits) AND
      (res.lowBits = operation.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* operation.expStatus # Success *)
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
 * Procedure:  PrintLabelForUnaryOp(unaryOp, label)
 * --------------------------------------------------------------------------
 * Prints test label string for binOp with args. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLabelForUnaryOp ( unaryOp : UnaryOpId; args : LabelString );
BEGIN
  InOut.WriteString("*** ");
  CASE unaryOp OF
    Inc : InOut.WriteString("CARD64.Inc")
  | Dec : InOut.WriteString("CARD64.Dec")
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
    Add : InOut.WriteString("CARD64.Add")
  | Sub : InOut.WriteString("CARD64.Sub")
  | Mul : InOut.WriteString("CARD64.Mul")
  | Div : InOut.WriteString("CARD64.Div")
  | Mod : InOut.WriteString("CARD64.Mod")
  END; (* CASE *)
  InOut.WriteString(args);
  InOut.WriteString(" ***");
  InOut.WriteLn;
END PrintLabelForBinOp;


(* --------------------------------------------------------------------------
 * Procedure:  PrintResult(n)
 * --------------------------------------------------------------------------
 * Prints result label followed by value n. 
 * ----------------------------------------------------------------------- *)

CONST ResultLabel = " result: ";

PROCEDURE PrintResult ( n : CARD64T );
BEGIN
  InOut.WriteString(ResultLabel);
  Card64IO.Write(n);
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

BEGIN (* TestCard64BaseMath *)
  InitDigitCountTests;
  InitUnaryOpTests;
  InitBinOpTests
END TestCard64BaseMath.
