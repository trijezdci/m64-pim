(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestCard64Conv;

(* Test Suite for CARD64 Constant Assignments and Type Conversions *)


IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT InOut, LongCardIO, Card64IO;


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
  
  InOut.WriteString("Constant Assignment Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all set value tests *)
  RunSetValTests(passed, failed);
  
  InOut.WriteString("Conversion Tests for CARD64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all conversion tests *)
  RunFromCardTests(passed, failed);
  RunFromLongCardTests(passed, failed);
  RunFromStringTests(passed, failed);
  RunToCardTests(passed, failed);
  RunToLongCardTests(passed, failed);
  RunToStringTests(passed, failed);
  
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
  RETURN SetValTestCount +
    FromCardTestCount + FromLongCardTestCount + FromStringTestCount +
    ToCardTestCount + ToLongCardTestCount + ToStringTestCount;
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

CONST MaxLabelLength = 47;


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
 * Test parameter type for CARD64 SetZero, SetOne and SetMax
 * ----------------------------------------------------------------------- *)

TYPE SetValProc = PROCEDURE ( VAR CARD64T );

TYPE SetValTest = RECORD
  proc : SetValProc;
  expected : CARD64T;
  label : LabelString
END; (* SetValTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitSetValTests
 * --------------------------------------------------------------------------
 * Initialises tests for SetZero, SetOne, SetMax.
 * ----------------------------------------------------------------------- *)

CONST SetValTestCount = 3;

VAR setValTest : ARRAY [0..SetValTestCount-1] OF SetValTest;

PROCEDURE InitSetValTests;
BEGIN
  setValTest[0].label := "CARD64.SetZero";
  setValTest[0].proc := CARD64.SetZero;
  setValTest[0].expected.highBits := 0;
  setValTest[0].expected.lowBits := 0;
  
  setValTest[1].label := "CARD64.SetOne";
  setValTest[1].proc := CARD64.SetOne;
  setValTest[1].expected.highBits := 0;
  setValTest[1].expected.lowBits := 1;
  
  setValTest[2].label := "CARD64.SetMax";
  setValTest[2].proc := CARD64.SetMax;
  setValTest[2].expected.highBits := 0FFFFFFFFH;
  setValTest[2].expected.lowBits := 0FFFFFFFFH
END InitSetValTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunSetValTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunSetValTest ( test : SetValTest; VAR passed, failed : CARDINAL );
VAR
  n : CARD64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  test.proc(n);
  PrintResult(n);
  IF (n.highBits = test.expected.highBits) AND
     (n.lowBits = test.expected.lowBits) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunSetValTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunSetValTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all SetValTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunSetValTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO SetValTestCount-1 DO
    RunSetValTest(setValTest[index], passed, failed)
  END (* FOR *)
END RunSetValTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.FromCard
 * ----------------------------------------------------------------------- *)

TYPE FromCardTest = RECORD
  operand : CARDINAL;
  expected : CARD64T;
  label : LabelString
END; (* FromCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitFromCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure FromCard.
 * ----------------------------------------------------------------------- *)

CONST FromCardTestCount = 3;

VAR fromCardTest : ARRAY [0..FromCardTestCount-1] OF FromCardTest;

PROCEDURE InitFromCardTests;
BEGIN
  fromCardTest[0].label := "CARD64.FromCard(0, n)";
  fromCardTest[0].operand := 0;
  fromCardTest[0].expected.highBits := 0;
  fromCardTest[0].expected.lowBits := 0;
  
  fromCardTest[1].label := "CARD64.FromCard(1, n)";
  fromCardTest[1].operand := 1;
  fromCardTest[1].expected.highBits := 0;
  fromCardTest[1].expected.lowBits := 1;
  
  fromCardTest[2].label := "CARD64.FromCard(MAX(CARDINAL), n)";
  fromCardTest[2].operand := MAX(CARDINAL);
  fromCardTest[2].expected.highBits := 0;
  fromCardTest[2].expected.lowBits := 0FFFFFFFFH
END InitFromCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromCardTest
  ( test : FromCardTest; VAR passed, failed : CARDINAL );
VAR
  n : CARD64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromCard(test.operand, n);
  PrintResult(n);
  IF (n.highBits = test.expected.highBits) AND
     (n.lowBits = test.expected.lowBits) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunFromCardTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromCardTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all FromCardTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromCardTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO FromCardTestCount-1 DO
    RunFromCardTest(fromCardTest[index], passed, failed)
  END (* FOR *)
END RunFromCardTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.FromLongCard
 * ----------------------------------------------------------------------- *)

TYPE FromLongCardTest = RECORD
  operand : LONGCARD;
  expected : CARD64T;
  label : LabelString
END; (* FromLongCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitFromLongCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure FromLongCard.
 * ----------------------------------------------------------------------- *)

CONST FromLongCardTestCount = 3;

VAR fromLongCardTest : ARRAY [0..FromLongCardTestCount-1] OF FromLongCardTest;

PROCEDURE InitFromLongCardTests;
BEGIN
  fromLongCardTest[0].label := "CARD64.FromLongCard(0, n)";
  fromLongCardTest[0].operand := 0;
  fromLongCardTest[0].expected.highBits := 0;
  fromLongCardTest[0].expected.lowBits := 0;
  
  fromLongCardTest[1].label := "CARD64.FromLongCard(1, n)";
  fromLongCardTest[1].operand := 1;
  fromLongCardTest[1].expected.highBits := 0;
  fromLongCardTest[1].expected.lowBits := 1;
  
  fromLongCardTest[2].label := "CARD64.FromLongCard(MAX(LONGCARD), n)";
  fromLongCardTest[2].operand := MAX(LONGCARD);
  fromLongCardTest[2].expected.highBits := 0;
  fromLongCardTest[2].expected.lowBits := 0FFFFFFFFH
END InitFromLongCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromLongCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromLongCardTest
  ( test : FromLongCardTest; VAR passed, failed : CARDINAL );
VAR
  n : CARD64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromLongCard(test.operand, n);
  PrintResult(n);
  IF (n.highBits = test.expected.highBits) AND
     (n.lowBits = test.expected.lowBits) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunFromLongCardTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromLongCardTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all FromLongCardTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromLongCardTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO FromLongCardTestCount-1 DO
    RunFromLongCardTest(fromLongCardTest[index], passed, failed)
  END (* FOR *)
END RunFromLongCardTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.FromString
 * ----------------------------------------------------------------------- *)

TYPE FromStringTest = RECORD
  operand : NumberString;
  expected : CARD64T;
  expStatus : Status;
  label : LabelString
END; (* FromStringTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitFromStringTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure FromString.
 * ----------------------------------------------------------------------- *)

CONST FromStringTestCount = 22;

VAR fromStringTest : ARRAY [0..FromStringTestCount-1] OF FromStringTest;

PROCEDURE InitFromStringTests;
BEGIN
  fromStringTest[0].label := "CARD64.FromString('0', n, stat)";
  fromStringTest[0].operand := "0";
  fromStringTest[0].expected.highBits := 0;
  fromStringTest[0].expected.lowBits := 0;
  fromStringTest[0].expStatus := Success;
  
  fromStringTest[1].label := "CARD64.FromString('1', n, stat)";
  fromStringTest[1].operand := "1";
  fromStringTest[1].expected.highBits := 0;
  fromStringTest[1].expected.lowBits := 1;
  fromStringTest[1].expStatus := Success;
  
  fromStringTest[2].label := "CARD64.FromString('2', n, stat)";
  fromStringTest[2].operand := "2";
  fromStringTest[2].expected.highBits := 0;
  fromStringTest[2].expected.lowBits := 2;
  fromStringTest[2].expStatus := Success;
  
  fromStringTest[3].label := "CARD64.FromString('3', n, stat)";
  fromStringTest[3].operand := "3";
  fromStringTest[3].expected.highBits := 0;
  fromStringTest[3].expected.lowBits := 3;
  fromStringTest[3].expStatus := Success;
  
  fromStringTest[4].label := "CARD64.FromString('4', n, stat)";
  fromStringTest[4].operand := "4";
  fromStringTest[4].expected.highBits := 0;
  fromStringTest[4].expected.lowBits := 4;
  fromStringTest[4].expStatus := Success;
  
  fromStringTest[5].label := "CARD64.FromString('5', n, stat)";
  fromStringTest[5].operand := "5";
  fromStringTest[5].expected.highBits := 0;
  fromStringTest[5].expected.lowBits := 5;
  fromStringTest[5].expStatus := Success;
  
  fromStringTest[6].label := "CARD64.FromString('6', n, stat)";
  fromStringTest[6].operand := "6";
  fromStringTest[6].expected.highBits := 0;
  fromStringTest[6].expected.lowBits := 6;
  fromStringTest[6].expStatus := Success;
  
  fromStringTest[7].label := "CARD64.FromString('7', n, stat)";
  fromStringTest[7].operand := "7";
  fromStringTest[7].expected.highBits := 0;
  fromStringTest[7].expected.lowBits := 7;
  fromStringTest[7].expStatus := Success;
  
  fromStringTest[8].label := "CARD64.FromString('8', n, stat)";
  fromStringTest[8].operand := "8";
  fromStringTest[8].expected.highBits := 0;
  fromStringTest[8].expected.lowBits := 8;
  fromStringTest[8].expStatus := Success;
  
  fromStringTest[9].label := "CARD64.FromString('9', n, stat)";
  fromStringTest[9].operand := "9";
  fromStringTest[9].expected.highBits := 0;
  fromStringTest[9].expected.lowBits := 9;
  fromStringTest[9].expStatus := Success;
  
  fromStringTest[10].label := "CARD64.FromString('10', n, stat)";
  fromStringTest[10].operand := "10";
  fromStringTest[10].expected.highBits := 0;
  fromStringTest[10].expected.lowBits := 10;
  fromStringTest[10].expStatus := Success;
  
  fromStringTest[11].label := "CARD64.FromString('99', n, stat)";
  fromStringTest[11].operand := "99";
  fromStringTest[11].expected.highBits := 0;
  fromStringTest[11].expected.lowBits := 99;
  fromStringTest[11].expStatus := Success;
  
  fromStringTest[12].label := "CARD64.FromString('100', n, stat)";
  fromStringTest[12].operand := "100";
  fromStringTest[12].expected.highBits := 0;
  fromStringTest[12].expected.lowBits := 100;
  fromStringTest[12].expStatus := Success;
  
  fromStringTest[13].label := "CARD64.FromString('999', n, stat)";
  fromStringTest[13].operand := "999";
  fromStringTest[13].expected.highBits := 0;
  fromStringTest[13].expected.lowBits := 999;
  fromStringTest[13].expStatus := Success;
  
  fromStringTest[14].label := "CARD64.FromString('1000', n, stat)";
  fromStringTest[14].operand := "1000";
  fromStringTest[14].expected.highBits := 0;
  fromStringTest[14].expected.lowBits := 1000;
  fromStringTest[14].expStatus := Success;
  
  fromStringTest[15].label := "CARD64.FromString('4294967294', n, stat)";
  fromStringTest[15].operand := "4294967294";
  fromStringTest[15].expected.highBits := 0;
  fromStringTest[15].expected.lowBits := 0FFFFFFFEH;
  fromStringTest[15].expStatus := Success;
  
  fromStringTest[16].label := "CARD64.FromString('4294967295', n, stat)";
  fromStringTest[16].operand := "4294967295";
  fromStringTest[16].expected.highBits := 0;
  fromStringTest[16].expected.lowBits := 0FFFFFFFFH;
  fromStringTest[16].expStatus := Success;
  
  fromStringTest[17].label := "CARD64.FromString('4294967296', n, stat)";
  fromStringTest[17].operand := "4294967296";
  fromStringTest[17].expected.highBits := 1;
  fromStringTest[17].expected.lowBits := 0FFFFFFFFH;
  fromStringTest[17].expStatus := Success;
  
  fromStringTest[18].label := "CARD64.FromString('18446744073709551615', n, stat)";
  fromStringTest[18].operand := "18446744073709551615";
  fromStringTest[18].expected.highBits := 0FFFFFFFFH;
  fromStringTest[18].expected.lowBits := 0FFFFFFFFH;
  fromStringTest[18].expStatus := Success;
  
  fromStringTest[19].label := "CARD64.FromString('18446744073709551616', n, stat)";
  fromStringTest[19].operand := "18446744073709551616";
  fromStringTest[19].expected.highBits := 0; (* ignored *)
  fromStringTest[19].expected.lowBits := 0; (* ignored *)
  fromStringTest[19].expStatus := Overflow;
  
  fromStringTest[20].label := "CARD64.FromString('', n, stat)";
  fromStringTest[20].operand := "";
  fromStringTest[20].expected.highBits := 0; (* ignored *)
  fromStringTest[20].expected.lowBits := 0; (* ignored *)
  fromStringTest[20].expStatus := NoInput;
  
  fromStringTest[21].label := "CARD64.FromString('123$', n, stat)";
  fromStringTest[21].operand := "123$";
  fromStringTest[21].expected.highBits := 0; (* ignored *)
  fromStringTest[21].expected.lowBits := 0; (* ignored *)
  fromStringTest[21].expStatus := InvalidInput
END InitFromStringTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromStringTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromStringTest
  ( test : FromStringTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  n : CARD64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromString(test.operand, n, stat);
  PrintResult(n); PrintStatus(stat);
  IF test.expStatus = Success THEN
    IF (n.highBits = test.expected.highBits) AND
       (n.lowBits = test.expected.lowBits) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* test.expStatus # Success *)
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
END RunFromStringTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromStringTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all FromStringTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromStringTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO FromStringTestCount-1 DO
    RunFromStringTest(fromStringTest[index], passed, failed)
  END (* FOR *)
END RunFromStringTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.ToCard
 * ----------------------------------------------------------------------- *)

TYPE ToCardTest = RECORD
  operand : CARD64T;
  expected : CARDINAL;
  expStatus : Status;
  label : LabelString
END; (* ToCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToCard.
 * ----------------------------------------------------------------------- *)

CONST ToCardTestCount = 4;

VAR toCardTest : ARRAY [0..ToCardTestCount-1] OF ToCardTest;

PROCEDURE InitToCardTests;
BEGIN
  toCardTest[0].label := "CARD64.ToCard() for 0";
  toCardTest[0].operand.highBits := 0;
  toCardTest[0].operand.lowBits := 0;
  toCardTest[0].expected := 0;
  toCardTest[0].expStatus := Success;
  
  toCardTest[1].label := "CARD64.ToCard() for 1";
  toCardTest[1].operand.highBits := 0;
  toCardTest[1].operand.lowBits := 1;
  toCardTest[1].expected := 1;
  toCardTest[1].expStatus := Success;
  
  toCardTest[2].label := "CARD64.ToCard() for MAX(CARDINAL)";
  toCardTest[2].operand.highBits := 0;
  toCardTest[2].operand.lowBits := MAX(CARDINAL);
  toCardTest[2].expected := 0FFFFFFFFH;
  toCardTest[2].expStatus := Success;
  
  toCardTest[3].label := "CARD64.ToCard() for MAX(CARDINAL)+1";
  toCardTest[3].operand.highBits := 1;
  toCardTest[3].operand.lowBits := 0;
  toCardTest[3].expected := 0; (* ignored *)
  toCardTest[3].expStatus := Overflow
END InitToCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunToCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToCardTest ( test : ToCardTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  n : CARDINAL;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  ToCard(test.operand, n, stat);
  PrintCardResult(n); PrintStatus(stat);
  IF test.expStatus = Success THEN
    IF (n = test.expected) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* test.expStatus # Success *)
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
END RunToCardTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunToCardTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ToCardTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToCardTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ToCardTestCount-1 DO
    RunToCardTest(toCardTest[index], passed, failed)
  END (* FOR *)
END RunToCardTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.ToLongCard
 * ----------------------------------------------------------------------- *)

TYPE ToLongCardTest = RECORD
  operand : CARD64T;
  expected : LONGCARD;
  expStatus : Status;
  label : LabelString
END; (* ToLongCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToLongCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToLongCard.
 * ----------------------------------------------------------------------- *)

CONST ToLongCardTestCount = 4;

VAR toLongCardTest : ARRAY [0..ToLongCardTestCount-1] OF ToLongCardTest;

PROCEDURE InitToLongCardTests;
BEGIN
  toLongCardTest[0].label := "CARD64.ToLongCard() for 0";
  toLongCardTest[0].operand.highBits := 0;
  toLongCardTest[0].operand.lowBits := 0;
  toLongCardTest[0].expected := 0;
  toLongCardTest[0].expStatus := Success;
  
  toLongCardTest[1].label := "CARD64.ToLongCard() for 1";
  toLongCardTest[1].operand.highBits := 0;
  toLongCardTest[1].operand.lowBits := 1;
  toLongCardTest[1].expected := 1;
  toLongCardTest[1].expStatus := Success;
  
  toLongCardTest[2].label := "CARD64.ToLongCard() for MAX(LONGCARD)";
  toLongCardTest[2].operand.highBits := 0;
  toLongCardTest[2].operand.lowBits := MAX(LONGCARD);
  toLongCardTest[2].expected := 0FFFFFFFFH;
  toLongCardTest[2].expStatus := Success;
  
  toLongCardTest[3].label := "CARD64.ToLongCard() for MAX(LONGCARD)+1";
  toLongCardTest[3].operand.highBits := 1;
  toLongCardTest[3].operand.lowBits := 0;
  toLongCardTest[3].expected := 0; (* ignored *)
  toLongCardTest[3].expStatus := Overflow
END InitToLongCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunToLongCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToLongCardTest
  ( test : ToLongCardTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  n : LONGCARD;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  ToLongCard(test.operand, n, stat);
  PrintLongCardResult(n); PrintStatus(stat);
  IF test.expStatus = Success THEN
    IF (n = test.expected) THEN
      InOut.WriteString(PassNotice);
      INC(passed)
    ELSE
      InOut.WriteString(FailNotice);
      INC(failed)
    END (* IF *)
  ELSE (* test.expStatus # Success *)
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
END RunToLongCardTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunToLongCardTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ToLongCardTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToLongCardTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ToLongCardTestCount-1 DO
    RunToLongCardTest(toLongCardTest[index], passed, failed)
  END (* FOR *)
END RunToLongCardTests;


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64.ToString
 * ----------------------------------------------------------------------- *)

TYPE ToStringTest = RECORD
  operand : CARD64T;
  expected : NumberString;
  label : LabelString
END; (* ToStringTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToStringTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToString.
 * ----------------------------------------------------------------------- *)

CONST ToStringTestCount = 19;

VAR toStringTest : ARRAY [0..ToStringTestCount-1] OF ToStringTest;

PROCEDURE InitToStringTests;
BEGIN
  toStringTest[0].label := "CARD64.ToString() for 0";
  toStringTest[0].operand.highBits := 0;
  toStringTest[0].operand.lowBits := 0;
  toStringTest[0].expected := "0";
  
  toStringTest[1].label := "CARD64.ToString() for 1";
  toStringTest[1].operand.highBits := 0;
  toStringTest[1].operand.lowBits := 1;
  toStringTest[1].expected := "1";
  
  toStringTest[2].label := "CARD64.ToString() for 2";
  toStringTest[2].operand.highBits := 0;
  toStringTest[2].operand.lowBits := 2;
  toStringTest[2].expected := "2";
  
  toStringTest[3].label := "CARD64.ToString() for 3";
  toStringTest[3].operand.highBits := 0;
  toStringTest[3].operand.lowBits := 3;
  toStringTest[3].expected := "3";
  
  toStringTest[4].label := "CARD64.ToString() for 4";
  toStringTest[4].operand.highBits := 0;
  toStringTest[4].operand.lowBits := 4;
  toStringTest[4].expected := "4";
  
  toStringTest[5].label := "CARD64.ToString() for 5";
  toStringTest[5].operand.highBits := 0;
  toStringTest[5].operand.lowBits := 5;
  toStringTest[5].expected := "5";
  
  toStringTest[6].label := "CARD64.ToString() for 6";
  toStringTest[6].operand.highBits := 0;
  toStringTest[6].operand.lowBits := 6;
  toStringTest[6].expected := "6";
  
  toStringTest[7].label := "CARD64.ToString() for 7";
  toStringTest[7].operand.highBits := 0;
  toStringTest[7].operand.lowBits := 7;
  toStringTest[7].expected := "7";
  
  toStringTest[8].label := "CARD64.ToString() for 8";
  toStringTest[8].operand.highBits := 0;
  toStringTest[8].operand.lowBits := 8;
  toStringTest[8].expected := "8";
  
  toStringTest[9].label := "CARD64.ToString() for 9";
  toStringTest[9].operand.highBits := 0;
  toStringTest[9].operand.lowBits := 9;
  toStringTest[9].expected := "9";
  
  toStringTest[10].label := "CARD64.ToString() for 10";
  toStringTest[10].operand.highBits := 0;
  toStringTest[10].operand.lowBits := 10;
  toStringTest[10].expected := "10";
  
  toStringTest[11].label := "CARD64.ToString() for 99";
  toStringTest[11].operand.highBits := 0;
  toStringTest[11].operand.lowBits := 99;
  toStringTest[11].expected := "99";
  
  toStringTest[12].label := "CARD64.ToString() for 100";
  toStringTest[12].operand.highBits := 0;
  toStringTest[12].operand.lowBits := 100;
  toStringTest[12].expected := "100";
  
  toStringTest[13].label := "CARD64.ToString() for 999";
  toStringTest[13].operand.highBits := 0;
  toStringTest[13].operand.lowBits := 999;
  toStringTest[13].expected := "999";
  
  toStringTest[14].label := "CARD64.ToString() for 1000";
  toStringTest[14].operand.highBits := 0;
  toStringTest[14].operand.lowBits := 1000;
  toStringTest[14].expected := "1000";
  
  toStringTest[15].label := "CARD64.ToString() for 4294967294";
  toStringTest[15].operand.highBits := 0;
  toStringTest[15].operand.lowBits := 0FFFFFFFEH;
  toStringTest[15].expected := "4294967294";
  
  toStringTest[16].label := "CARD64.ToString() for 4294967295";
  toStringTest[16].operand.highBits := 0;
  toStringTest[16].operand.lowBits := 0FFFFFFFFH;
  toStringTest[16].expected := "4294967295";
  
  toStringTest[17].label := "CARD64.ToString() for 4294967296";
  toStringTest[17].operand.highBits := 1;
  toStringTest[17].operand.lowBits := 0;
  toStringTest[17].expected := "4294967296";
  
  toStringTest[18].label := "CARD64.ToString() for 18446744073709551615";
  toStringTest[18].operand.highBits := 0FFFFFFFFH;
  toStringTest[18].operand.lowBits := 0FFFFFFFFH;
  toStringTest[18].expected := "18446744073709551615"
END InitToStringTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunToStringTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToStringTest
  ( test : ToStringTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  str : NumberString;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  ToString(test.operand, str, stat);
  PrintStringResult(str); PrintStatus(stat);
  IF eqStr(str, test.expected) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunToStringTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunToStringTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ToStringTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToStringTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ToStringTestCount-1 DO
    RunToStringTest(toStringTest[index], passed, failed)
  END (* FOR *)
END RunToStringTests;


(* --------------------------------------------------------------------------
 * Function:  eqStr(s1, s2)
 * --------------------------------------------------------------------------
 * Returns TRUE if strings s1 and s2 are equal, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE eqStr ( VAR s1, s2 : ARRAY OF CHAR ) : BOOLEAN;
VAR
  index : CARDINAL;
BEGIN
  index := 0;
  WHILE (index <= HIGH(s1)) AND (index <= HIGH(s2)) AND 
        (s1[index] # CHR(0)) AND (s2[index] # CHR(0)) DO
    IF s1[index] # s2[index] THEN
      RETURN FALSE
    END; (* IF *)
    INC(index)
  END; (* WHILE *)
  
  IF (index <= HIGH(s1)) AND (s1[index] # CHR(0)) THEN
    RETURN FALSE
  ELSIF (index <= HIGH(s2)) AND (s2[index] # CHR(0)) THEN
    RETURN FALSE
  ELSE
    RETURN TRUE
  END (* IF *)
END eqStr;


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
 * Procedure:  PrintCardResult(n)
 * --------------------------------------------------------------------------
 * Prints result label followed by value n. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintCardResult ( n : CARDINAL );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(LONGCARD(n));
  InOut.WriteLn
END PrintCardResult;


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
 * Procedure:  PrintStringResults(str)
 * --------------------------------------------------------------------------
 * Prints result label followed by value str. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintStringResult ( VAR str : ARRAY OF CHAR );
BEGIN
  InOut.WriteString(ResultLabel);
  InOut.WriteString(str);
  InOut.WriteLn
END PrintStringResult;


(* --------------------------------------------------------------------------
 * Procedure:  PrintStatus(stat)
 * --------------------------------------------------------------------------
 * Prints status label followed by status stat. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintStatus ( stat : Status );
BEGIN
  InOut.WriteString(" status: ");
  Card64IO.WriteStatus(stat);
  InOut.WriteLn
END PrintStatus;


(* --------------------------------------------------------------------------
 * Module initialisation
 * ----------------------------------------------------------------------- *)

BEGIN (* TestCard64Conv *)
  InitSetValTests;
  InitFromCardTests;
  InitFromLongCardTests;
  InitFromStringTests;
  InitToCardTests;
  InitToLongCardTests;
  InitToStringTests
END TestCard64Conv.
