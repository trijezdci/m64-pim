(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestCard64PowLog;

(* Test Suite for CARD64 Exponentiation and Logarithm Functions *)


IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

FROM NumStatus IMPORT Status;

IMPORT InOut, NumStatusIO, LongCardIO;


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
  
  InOut.WriteString("Pow2 Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run Pow2 tests *)
  RunPow2Tests(passed, failed);

  InOut.WriteString("Pow10 Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run Pow10 tests *)
  RunPow10Tests(passed, failed);
  
  InOut.WriteString("Log2 Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run Log2 tests *)
  RunLog2Tests(passed, failed);
  
  InOut.WriteString("Log10 Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run Log10 tests *)
  RunLog10Tests(passed, failed);
  
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
  RETURN Pow2TestCount + Pow10TestCount + Log2TestCount + Log10TestCount
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
 * Procedure:  InitPow2Tests
 * --------------------------------------------------------------------------
 * Initialises tests for Pow2
 * ----------------------------------------------------------------------- *)

CONST Pow2TestCount = MAX(BitIndex) + 1;

VAR powerOf2 : ARRAY BitIndex OF CARD64T;

PROCEDURE InitPow2Tests;
VAR
  n : BitIndex;
  two : CARD64T;
  ignore : Status;
BEGIN
  SetOne(powerOf2[0]);
  two.highBits := 0;
  two.lowBits := 2;
  
  FOR n := 1 TO MAX(BitIndex) DO
    CARD64.Mul(powerOf2[n-1], two, powerOf2[n], ignore)
  END (* FOR *)
END InitPow2Tests;


(* --------------------------------------------------------------------------
 * Procedure:  RunPow2Tests(passed, failed)
 * --------------------------------------------------------------------------
 * Run tests and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunPow2Tests ( VAR passed, failed : CARDINAL );
VAR
  n : BitIndex;
  res : CARD64T;
BEGIN
  FOR n := 0 TO MAX(BitIndex) DO
    PrintLabelForPow2(n);
    CARD64.Pow2(n, res);
    PrintResult(res);
    IF CARD64.eq(res, powerOf2[n]) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END; (* IF *)
    InOut.WriteLn;
    InOut.WriteLn
  END (* FOR *)
END RunPow2Tests;


(* --------------------------------------------------------------------------
 * Procedure:  InitPow10Tests
 * --------------------------------------------------------------------------
 * Initialises tests for Pow10
 * ----------------------------------------------------------------------- *)

CONST Pow10TestCount = MAX(DigitRange) + 1;

VAR powerOf10 : ARRAY DigitRange OF CARD64T;

PROCEDURE InitPow10Tests;
VAR
  n : DigitRange;
  ten : CARD64T;
  ignore : Status;
BEGIN
  SetOne(powerOf10[0]);
  ten.highBits := 0;
  ten.lowBits := 10;
  
  FOR n := 1 TO MAX(DigitRange) DO
    CARD64.Mul(powerOf10[n-1], ten, powerOf10[n], ignore)
  END (* FOR *)
END InitPow10Tests;


(* --------------------------------------------------------------------------
 * Procedure:  RunPow10Tests(passed, failed)
 * --------------------------------------------------------------------------
 * Run tests and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunPow10Tests ( VAR passed, failed : CARDINAL );
VAR
  n : DigitRange;
  res : CARD64T;
BEGIN
  FOR n := 0 TO MAX(DigitRange) DO
    PrintLabelForPow10(n);
    CARD64.Pow10(n, res);
    PrintResult(res);
    IF CARD64.eq(res, powerOf10[n]) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END; (* IF *)
    InOut.WriteLn;
    InOut.WriteLn
  END (* FOR *)
END RunPow10Tests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.Log2
 * ----------------------------------------------------------------------- *)

TYPE Log2Test = RECORD
  operand : CARD64T;
  expected : LONGCARD;
  expStatus : Status;
  label : LabelString
END; (* Log2Test *)


(* --------------------------------------------------------------------------
 * Procedure:  InitLog2Tests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure Log2.
 * ----------------------------------------------------------------------- *)

CONST Log2TestCount = 12;

VAR log2Test : ARRAY [0..Log2TestCount-1] OF Log2Test;

PROCEDURE InitLog2Tests;
BEGIN
  log2Test[0].label := "CARD64.Log2(0, n)";
  log2Test[0].operand.highBits := 0;
  log2Test[0].operand.lowBits := 0;
  log2Test[0].expStatus := DivByZero;
  
  log2Test[1].label := "CARD64.Log2(1, n)";
  log2Test[1].operand.highBits := 0;
  log2Test[1].operand.lowBits := 1;
  log2Test[1].expected := 0;
  log2Test[1].expStatus := Success;
  
  log2Test[2].label := "CARD64.Log2(2, n)";
  log2Test[2].operand.highBits := 0;
  log2Test[2].operand.lowBits := 2;
  log2Test[2].expected := 1;
  log2Test[2].expStatus := Success;
  
  log2Test[3].label := "CARD64.Log2(3, n)";
  log2Test[3].operand.highBits := 0;
  log2Test[3].operand.lowBits := 3;
  log2Test[3].expected := 1;
  log2Test[3].expStatus := Success;
  
  log2Test[4].label := "CARD64.Log2(MAX(LONGCARD), n)";
  log2Test[4].operand.highBits := 0;
  log2Test[4].operand.lowBits := MAX(LONGCARD);
  log2Test[4].expected := 31;
  log2Test[4].expStatus := Success;
  
  log2Test[5].label := "CARD64.Log2(MAX(LONGCARD)+1, n)";
  log2Test[5].operand.highBits := 1;
  log2Test[5].operand.lowBits := 0;
  log2Test[5].expected := 32;
  log2Test[5].expStatus := Success;
  
  log2Test[6].label := "CARD64.Log2(MAX(LONGCARD)+2, n)";
  log2Test[6].operand.highBits := 1;
  log2Test[6].operand.lowBits := 1;
  log2Test[6].expected := 32;
  log2Test[6].expStatus := Success;
  
  log2Test[7].label := "CARD64.Log2(40000000:00000000 - 1, n)";
  log2Test[7].operand.highBits := 03FFFFFFFH;
  log2Test[7].operand.lowBits := MAX(LONGCARD);
  log2Test[7].expected := 61;
  log2Test[7].expStatus := Success;
  
  log2Test[8].label := "CARD64.Log2(40000000:00000000, n)";
  log2Test[8].operand.highBits := 040000000H;
  log2Test[8].operand.lowBits := 0;
  log2Test[8].expected := 62;
  log2Test[8].expStatus := Success;
  
  log2Test[9].label := "CARD64.Log2(40000000:00000000 + 1, n)";
  log2Test[9].operand.highBits := 040000000H;
  log2Test[9].operand.lowBits := 1;
  log2Test[9].expected := 62;
  log2Test[9].expStatus := Success;
  
  log2Test[10].label := "CARD64.Log2(MAX(CARD64T) - 1, n)";
  log2Test[10].operand.highBits := MAX(LONGCARD);
  log2Test[10].operand.lowBits := MAX(LONGCARD) - 1;
  log2Test[10].expected := 63;
  log2Test[10].expStatus := Success;
  
  log2Test[11].label := "CARD64.Log2(MAX(CARD64T), n)";
  log2Test[11].operand.highBits := 0FFFFFFFFH;
  log2Test[11].operand.lowBits := 0FFFFFFFFH;
  log2Test[11].expected := 63;
  log2Test[11].expStatus := Success
END InitLog2Tests;


(* --------------------------------------------------------------------------
 * Procedure:  RunLog2Test(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunLog2Test
  ( test : Log2Test; VAR passed, failed : CARDINAL );
VAR
  res : LONGCARD;
  stat : Status;
BEGIN
  PrintLabel(test.label);
  
  CARD64.Log2(test.operand, res, stat);
  
  IF stat = Success THEN
    PrintLongCardResult(res); PrintStatus(stat);
    IF (test.expStatus = Success) AND (res = test.expected) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* stat # Success *)
    PrintStatus(stat);
    IF stat = test.expStatus THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunLog2Test;


(* --------------------------------------------------------------------------
 * Procedure:  RunLog2Tests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all Log2Test tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunLog2Tests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO Log2TestCount-1 DO
    RunLog2Test(log2Test[index], passed, failed)
  END (* FOR *)
END RunLog2Tests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.Log10
 * ----------------------------------------------------------------------- *)

TYPE Log10Test = RECORD
  operand : CARD64T;
  expected : LONGCARD;
  expStatus : Status;
  label : LabelString
END; (* Log10Test *)


(* --------------------------------------------------------------------------
 * Procedure:  InitLog10Tests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure Log10.
 * ----------------------------------------------------------------------- *)

CONST Log10TestCount = 18;

VAR log10Test : ARRAY [0..Log10TestCount-1] OF Log10Test;

PROCEDURE InitLog10Tests;
BEGIN
  log10Test[0].label := "CARD64.Log10(0, n)";
  log10Test[0].operand.highBits := 0;
  log10Test[0].operand.lowBits := 0;
  log10Test[0].expStatus := DivByZero;
  
  log10Test[1].label := "CARD64.Log10(1, n)";
  log10Test[1].operand.highBits := 0;
  log10Test[1].operand.lowBits := 1;
  log10Test[1].expected := 0;
  log10Test[1].expStatus := Success;
  
  log10Test[2].label := "CARD64.Log10(9, n)";
  log10Test[2].operand.highBits := 0;
  log10Test[2].operand.lowBits := 9;
  log10Test[2].expected := 0;
  log10Test[2].expStatus := Success;
  
  log10Test[3].label := "CARD64.Log10(10, n)";
  log10Test[3].operand.highBits := 0;
  log10Test[3].operand.lowBits := 10;
  log10Test[3].expected := 1;
  log10Test[3].expStatus := Success;
  
  log10Test[4].label := "CARD64.Log10(11, n)";
  log10Test[4].operand.highBits := 0;
  log10Test[4].operand.lowBits := 11;
  log10Test[4].expected := 1;
  log10Test[4].expStatus := Success;
  
  log10Test[5].label := "CARD64.Log10(10^9 - 1, n)";
  log10Test[5].operand.highBits := 0;
  log10Test[5].operand.lowBits := 999999999;
  log10Test[5].expected := 8;
  log10Test[5].expStatus := Success;
  
  log10Test[6].label := "CARD64.Log10(10^9, n)";
  log10Test[6].operand.highBits := 0;
  log10Test[6].operand.lowBits := 1000000000;
  log10Test[6].expected := 9;
  log10Test[6].expStatus := Success;
  
  log10Test[7].label := "CARD64.Log10(10^9 + 1, n)";
  log10Test[7].operand.highBits := 0;
  log10Test[7].operand.lowBits := 1000000001;
  log10Test[7].expected := 9;
  log10Test[7].expStatus := Success;
  
  log10Test[8].label := "CARD64.Log10(MAX(LONGCARD), n)";
  log10Test[8].operand.highBits := 0;
  log10Test[8].operand.lowBits := MAX(LONGCARD);
  log10Test[8].expected := 9;
  log10Test[8].expStatus := Success;
  
  log10Test[9].label := "CARD64.Log10(MAX(LONGCARD) + 1, n)";
  log10Test[9].operand.highBits := 1;
  log10Test[9].operand.lowBits := 0;
  log10Test[9].expected := 9;
  log10Test[9].expStatus := Success;
  
  log10Test[10].label := "CARD64.Log10(10^10 - 1, n)";
  log10Test[10].operand.highBits := 2;
  log10Test[10].operand.lowBits := 1410065407;
  log10Test[10].expected := 9;
  log10Test[10].expStatus := Success;
  
  log10Test[11].label := "CARD64.Log10(10^10, n)";
  log10Test[11].operand.highBits := 2;
  log10Test[11].operand.lowBits := 1410065408;
  log10Test[11].expected := 10;
  log10Test[11].expStatus := Success;
  
  log10Test[12].label := "CARD64.Log10(10^10 + 1, n)";
  log10Test[12].operand.highBits := 2;
  log10Test[12].operand.lowBits := 1410065409;
  log10Test[12].expected := 10;
  log10Test[12].expStatus := Success;
  
  log10Test[13].label := "CARD64.Log10(10^19 - 1, n)";
  log10Test[13].operand.highBits := 08AC72304H;
  log10Test[13].operand.lowBits := 089E7FFFFH;
  log10Test[13].expected := 18;
  log10Test[13].expStatus := Success;
  
  log10Test[14].label := "CARD64.Log10(10^19, n)";
  log10Test[14].operand.highBits := 08AC72304H;
  log10Test[14].operand.lowBits := 089E80000H;
  log10Test[14].expected := 19;
  log10Test[14].expStatus := Success;
  
  log10Test[15].label := "CARD64.Log10(10^19 + 1, n)";
  log10Test[15].operand.highBits := 08AC72304H;
  log10Test[15].operand.lowBits := 089E80001H;
  log10Test[15].expected := 19;
  log10Test[15].expStatus := Success;
  
  log10Test[16].label := "CARD64.Log10(MAX(CARD64T) - 1, n)";
  log10Test[16].operand.highBits := 0FFFFFFFFH;
  log10Test[16].operand.lowBits := 0FFFFFFFEH;
  log10Test[16].expected := 19;
  log10Test[16].expStatus := Success;
  
  log10Test[17].label := "CARD64.Log10(MAX(CARD64T), n)";
  log10Test[17].operand.highBits := 0FFFFFFFFH;
  log10Test[17].operand.lowBits := 0FFFFFFFFH;
  log10Test[17].expected := MaxDecimalDigits;
  log10Test[17].expStatus := Success
END InitLog10Tests;


(* --------------------------------------------------------------------------
 * Procedure:  RunLog10Test(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunLog10Test
  ( test : Log10Test; VAR passed, failed : CARDINAL );
VAR
  res : LONGCARD;
  stat : Status;
BEGIN
  PrintLabel(test.label);
  
  CARD64.Log10(test.operand, res, stat);
  
  IF stat = Success THEN
    PrintLongCardResult(res); PrintStatus(stat);
    IF (test.expStatus = Success) AND (res = test.expected) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* stat # Success *)
    PrintStatus(stat);
    IF stat = test.expStatus THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunLog10Test;


(* --------------------------------------------------------------------------
 * Procedure:  RunLog10Tests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all Log10Test tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunLog10Tests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO Log10TestCount-1 DO
    RunLog10Test(log10Test[index], passed, failed)
  END (* FOR *)
END RunLog10Tests;


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
 * Procedure:  PrintResult(n)
 * --------------------------------------------------------------------------
 * Prints result label followed by value n. 
 * ----------------------------------------------------------------------- *)

CONST ResultLabel = " result: ";

PROCEDURE PrintResult ( n : CARD64T );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(LONGCARD(n.highBits));
  InOut.Write(":");
  LongCardIO.WriteHex(n.lowBits);
  InOut.WriteLn
END PrintResult;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLongCardResult(n)
 * --------------------------------------------------------------------------
 * Prints result label followed by value n. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLongCardResult ( n : LONGCARD );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(n);
  InOut.WriteLn
END PrintLongCardResult;


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

BEGIN (* TestCard64PowLog *)
  InitPow2Tests;
  InitPow10Tests;
  InitLog2Tests;
  InitLog10Tests
END TestCard64PowLog.
