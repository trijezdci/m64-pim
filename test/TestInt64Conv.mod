(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE TestInt64Conv;

(* Test Suite for INT64 Constant Assignments and Type Conversions *)


IMPORT INT64;

FROM INT64 IMPORT INT64T;

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
  
  InOut.WriteString("Constant Assignment Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all set value tests *)
  RunSetValTests(passed, failed);
  
  InOut.WriteString("Conversion Tests for INT64");
  InOut.WriteLn; InOut.WriteLn;
  
  (* run all conversion tests *)
  RunFromCardTests(passed, failed);
  RunFromLongCardTests(passed, failed);
  RunFromIntTests(passed, failed);
  RunFromLongIntTests(passed, failed);
  RunToCardTests(passed, failed);
  RunToLongCardTests(passed, failed);
  RunToIntTests(passed, failed);
  RunToLongIntTests(passed, failed);
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
    FromCardTestCount + FromLongCardTestCount + FromIntTestCount +
    FromLongIntTestCount + ToCardTestCount + ToLongCardTestCount +
    ToIntTestCount + ToLongIntTestCount + ToStringTestCount;
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
 * Test parameter type for INT64 SetZero, SetOne, SetMin and SetMax
 * ----------------------------------------------------------------------- *)

TYPE SetValProc = PROCEDURE ( VAR INT64T );

TYPE SetValTest = RECORD
  proc : SetValProc;
  expected : INT64T;
  label : LabelString
END; (* SetValTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitSetValTests
 * --------------------------------------------------------------------------
 * Initialises tests for SetZero, SetOne, SetMax.
 * ----------------------------------------------------------------------- *)

CONST SetValTestCount = 4;

VAR setValTest : ARRAY [0..SetValTestCount-1] OF SetValTest;

PROCEDURE InitSetValTests;
BEGIN
  setValTest[0].label := "INT64.SetZero";
  setValTest[0].proc := INT64.SetZero;
  setValTest[0].expected.highBits := 0;
  setValTest[0].expected.lowBits := 0;
  
  setValTest[1].label := "INT64.SetOne";
  setValTest[1].proc := INT64.SetOne;
  setValTest[1].expected.highBits := 0;
  setValTest[1].expected.lowBits := 1;
  
  setValTest[2].label := "INT64.SetMin";
  setValTest[2].proc := INT64.SetMin;
  setValTest[2].expected.highBits := MIN(LONGINT); (* 0x80000000 *)
  setValTest[2].expected.lowBits := 0;

  setValTest[3].label := "INT64.SetMax";
  setValTest[3].proc := INT64.SetMax;
  setValTest[3].expected.highBits := MAX(LONGINT); (* 0x7FFFFFFF *)
  setValTest[3].expected.lowBits := MAX(LONGCARD); (* 0xFFFFFFFF *)
END InitSetValTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunSetValTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunSetValTest ( test : SetValTest; VAR passed, failed : CARDINAL );
VAR
  i : INT64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  test.proc(i);
  PrintResult(i);
  IF (i.highBits = test.expected.highBits) AND
     (i.lowBits = test.expected.lowBits) THEN
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
 * Test parameter type for INT64.FromCard
 * ----------------------------------------------------------------------- *)

TYPE FromCardTest = RECORD
  operand : CARDINAL;
  expected : INT64T;
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
  fromCardTest[0].label := "INT64.FromCard(0, n)";
  fromCardTest[0].operand := 0;
  fromCardTest[0].expected.highBits := 0;
  fromCardTest[0].expected.lowBits := 0;
  
  fromCardTest[1].label := "INT64.FromCard(1, n)";
  fromCardTest[1].operand := 1;
  fromCardTest[1].expected.highBits := 0;
  fromCardTest[1].expected.lowBits := 1;
  
  fromCardTest[2].label := "INT64.FromCard(MAX(CARDINAL), n)";
  fromCardTest[2].operand := MAX(CARDINAL);
  fromCardTest[2].expected.highBits := 0;
  fromCardTest[2].expected.lowBits := MAX(CARDINAL)
END InitFromCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromCardTest
  ( test : FromCardTest; VAR passed, failed : CARDINAL );
VAR
  i : INT64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromCard(test.operand, i);
  PrintResult(i);
  IF (i.highBits = test.expected.highBits) AND
     (i.lowBits = test.expected.lowBits) THEN
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
 * Test parameter type for INT64.FromLongCard
 * ----------------------------------------------------------------------- *)

TYPE FromLongCardTest = RECORD
  operand : LONGCARD;
  expected : INT64T;
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
  fromLongCardTest[0].label := "INT64.FromLongCard(0, n)";
  fromLongCardTest[0].operand := 0;
  fromLongCardTest[0].expected.highBits := 0;
  fromLongCardTest[0].expected.lowBits := 0;
  
  fromLongCardTest[1].label := "INT64.FromLongCard(1, n)";
  fromLongCardTest[1].operand := 1;
  fromLongCardTest[1].expected.highBits := 0;
  fromLongCardTest[1].expected.lowBits := 1;
  
  fromLongCardTest[2].label := "INT64.FromLongCard(MAX(LONGCARD), n)";
  fromLongCardTest[2].operand := MAX(LONGCARD);
  fromLongCardTest[2].expected.highBits := 0;
  fromLongCardTest[2].expected.lowBits := MAX(LONGCARD)
END InitFromLongCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromLongCardTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromLongCardTest
  ( test : FromLongCardTest; VAR passed, failed : CARDINAL );
VAR
  i : INT64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromLongCard(test.operand, i);
  PrintResult(i);
  IF (i.highBits = test.expected.highBits) AND
     (i.lowBits = test.expected.lowBits) THEN
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
 * Test parameter type for INT64.FromInt
 * ----------------------------------------------------------------------- *)

TYPE FromIntTest = RECORD
  operand : INTEGER;
  expected : INT64T;
  label : LabelString
END; (* FromIntTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitFromIntTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure FromInt.
 * ----------------------------------------------------------------------- *)

CONST FromIntTestCount = 5;

VAR fromIntTest : ARRAY [0..FromIntTestCount-1] OF FromIntTest;

PROCEDURE InitFromIntTests;
BEGIN
  fromIntTest[0].label := "INT64.FromInt(0, i)";
  fromIntTest[0].operand := 0;
  fromIntTest[0].expected.highBits := 0;
  fromIntTest[0].expected.lowBits := 0;
  
  fromIntTest[1].label := "INT64.FromInt(1, i)";
  fromIntTest[1].operand := 1;
  fromIntTest[1].expected.highBits := 0;
  fromIntTest[1].expected.lowBits := 1;
  
  fromIntTest[2].label := "INT64.FromInt(-1, i)";
  fromIntTest[2].operand := -1;
  fromIntTest[2].expected.highBits := -1;
  fromIntTest[2].expected.lowBits := 0FFFFFFFFH;
  
  fromIntTest[3].label := "INT64.FromInt(MIN(INTEGER), i)";
  fromIntTest[3].operand := MIN(INTEGER);
  fromIntTest[3].expected.highBits := -1;
  fromIntTest[3].expected.lowBits := 080000000H;

  fromIntTest[4].label := "INT64.FromInt(MAX(INTEGER), i)";
  fromIntTest[4].operand := MAX(INTEGER);
  fromIntTest[4].expected.highBits := 0;
  fromIntTest[4].expected.lowBits := 07FFFFFFFH
END InitFromIntTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromIntTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromIntTest
  ( test : FromIntTest; VAR passed, failed : CARDINAL );
VAR
  i : INT64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromInt(test.operand, i);
  PrintResult(i);
  IF (i.highBits = test.expected.highBits) AND
     (i.lowBits = test.expected.lowBits) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunFromIntTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromIntTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all FromIntTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromIntTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO FromIntTestCount-1 DO
    RunFromIntTest(fromIntTest[index], passed, failed)
  END (* FOR *)
END RunFromIntTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64.FromLongInt
 * ----------------------------------------------------------------------- *)

TYPE FromLongIntTest = RECORD
  operand : LONGINT;
  expected : INT64T;
  label : LabelString
END; (* FromLongIntTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitFromLongIntTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure FromLongInt.
 * ----------------------------------------------------------------------- *)

CONST FromLongIntTestCount = 5;

VAR fromLongIntTest : ARRAY [0..FromLongIntTestCount-1] OF FromLongIntTest;

PROCEDURE InitFromLongIntTests;
BEGIN
  fromLongIntTest[0].label := "INT64.FromLongInt(0, i)";
  fromLongIntTest[0].operand := 0;
  fromLongIntTest[0].expected.highBits := 0;
  fromLongIntTest[0].expected.lowBits := 0;
  
  fromLongIntTest[1].label := "INT64.FromLongInt(1, i)";
  fromLongIntTest[1].operand := 1;
  fromLongIntTest[1].expected.highBits := 0;
  fromLongIntTest[1].expected.lowBits := 1;
  
  fromLongIntTest[2].label := "INT64.FromLongInt(-1, i)";
  fromLongIntTest[2].operand := -1;
  fromLongIntTest[2].expected.highBits := -1;
  fromLongIntTest[2].expected.lowBits := 0FFFFFFFFH;
  
  fromLongIntTest[3].label := "INT64.FromLongInt(MIN(LONGINT), i)";
  fromLongIntTest[3].operand := MIN(LONGINT);
  fromLongIntTest[3].expected.highBits := -1;
  fromLongIntTest[3].expected.lowBits := 080000000H;

  fromLongIntTest[4].label := "INT64.FromLongInt(MAX(LONGINT), i)";
  fromLongIntTest[4].operand := MAX(LONGINT);
  fromLongIntTest[4].expected.highBits := 0;
  fromLongIntTest[4].expected.lowBits := 07FFFFFFFH
END InitFromLongIntTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromLongIntTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromLongIntTest
  ( test : FromLongIntTest; VAR passed, failed : CARDINAL );
VAR
  i : INT64T;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  FromLongInt(test.operand, i);
  PrintResult(i);
  IF (i.highBits = test.expected.highBits) AND
     (i.lowBits = test.expected.lowBits) THEN
    InOut.WriteString(PassNotice);
    INC(passed)
  ELSE
    InOut.WriteString(FailNotice);
    INC(failed)
  END; (* IF *)
  
  InOut.WriteLn;
  InOut.WriteLn
END RunFromLongIntTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunFromLongIntTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all FromLongIntTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunFromLongIntTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO FromLongIntTestCount-1 DO
    RunFromLongIntTest(fromLongIntTest[index], passed, failed)
  END (* FOR *)
END RunFromLongIntTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64.ToCard
 * ----------------------------------------------------------------------- *)

TYPE ToCardTest = RECORD
  operand : INT64T;
  expected : CARDINAL;
  expStatus : Status;
  label : LabelString
END; (* ToCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToCard.
 * ----------------------------------------------------------------------- *)

CONST ToCardTestCount = 5;

VAR toCardTest : ARRAY [0..ToCardTestCount-1] OF ToCardTest;

PROCEDURE InitToCardTests;
BEGIN
  toCardTest[0].label := "INT64.ToCard() for 0";
  toCardTest[0].operand.highBits := 0;
  toCardTest[0].operand.lowBits := 0;
  toCardTest[0].expected := 0;
  toCardTest[0].expStatus := Success;
  
  toCardTest[1].label := "INT64.ToCard() for 1";
  toCardTest[1].operand.highBits := 0;
  toCardTest[1].operand.lowBits := 1;
  toCardTest[1].expected := 1;
  toCardTest[1].expStatus := Success;
  
  toCardTest[2].label := "INT64.ToCard() for -1";
  toCardTest[2].operand.highBits := -1;
  toCardTest[2].operand.lowBits := 0FFFFFFFFH;
  toCardTest[2].expected := 0; (* ignored *)
  toCardTest[2].expStatus := Underflow;
  
  toCardTest[3].label := "INT64.ToCard() for MAX(CARDINAL)";
  toCardTest[3].operand.highBits := 0;
  toCardTest[3].operand.lowBits := 0FFFFFFFFH;
  toCardTest[3].expected := 0FFFFFFFFH;
  toCardTest[3].expStatus := Success;
  
  toCardTest[4].label := "INT64.ToCard() for MAX(CARDINAL)+1";
  toCardTest[4].operand.highBits := 1;
  toCardTest[4].operand.lowBits := 0;
  toCardTest[4].expected := 0; (* ignored *)
  toCardTest[4].expStatus := Overflow
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
 * Test parameter type for INT64.ToLongCard
 * ----------------------------------------------------------------------- *)

TYPE ToLongCardTest = RECORD
  operand : INT64T;
  expected : LONGCARD;
  expStatus : Status;
  label : LabelString
END; (* ToLongCardTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToLongCardTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToLongCard.
 * ----------------------------------------------------------------------- *)

CONST ToLongCardTestCount = 5;

VAR toLongCardTest : ARRAY [0..ToLongCardTestCount-1] OF ToLongCardTest;

PROCEDURE InitToLongCardTests;
BEGIN
  toLongCardTest[0].label := "INT64.ToLongCard() for 0";
  toLongCardTest[0].operand.highBits := 0;
  toLongCardTest[0].operand.lowBits := 0;
  toLongCardTest[0].expected := 0;
  toLongCardTest[0].expStatus := Success;
  
  toLongCardTest[1].label := "INT64.ToLongCard() for 1";
  toLongCardTest[1].operand.highBits := 0;
  toLongCardTest[1].operand.lowBits := 1;
  toLongCardTest[1].expected := 1;
  toLongCardTest[1].expStatus := Success;
  
  toLongCardTest[2].label := "INT64.ToLongCard() for -1";
  toLongCardTest[2].operand.highBits := -1;
  toLongCardTest[2].operand.lowBits := 0FFFFFFFFH;
  toLongCardTest[2].expected := 0; (* ignored *)
  toLongCardTest[2].expStatus := Underflow;
  
  toLongCardTest[3].label := "INT64.ToLongCard() for MAX(LONGCARD)";
  toLongCardTest[3].operand.highBits := 0;
  toLongCardTest[3].operand.lowBits := 0FFFFFFFFH;
  toLongCardTest[3].expected := 0FFFFFFFFH;
  toLongCardTest[3].expStatus := Success;
  
  toLongCardTest[4].label := "INT64.ToLongCard() for MAX(LONGCARD)+1";
  toLongCardTest[4].operand.highBits := 1;
  toLongCardTest[4].operand.lowBits := 0;
  toLongCardTest[4].expected := 0; (* ignored *)
  toLongCardTest[4].expStatus := Overflow
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
 * Test parameter type for INT64.ToInt
 * ----------------------------------------------------------------------- *)

TYPE ToIntTest = RECORD
  operand : INT64T;
  expected : INTEGER;
  expStatus : Status;
  label : LabelString
END; (* ToIntTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToIntTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToInt.
 * ----------------------------------------------------------------------- *)

CONST ToIntTestCount = 7;

VAR toIntTest : ARRAY [0..ToIntTestCount-1] OF ToIntTest;

PROCEDURE InitToIntTests;
BEGIN
  toIntTest[0].label := "INT64.ToInt() for 0";
  toIntTest[0].operand.highBits := 0;
  toIntTest[0].operand.lowBits := 0;
  toIntTest[0].expected := 0;
  toIntTest[0].expStatus := Success;
  
  toIntTest[1].label := "INT64.ToInt() for 1";
  toIntTest[1].operand.highBits := 0;
  toIntTest[1].operand.lowBits := 1;
  toIntTest[1].expected := 1;
  toIntTest[1].expStatus := Success;
  
  toIntTest[2].label := "INT64.ToInt() for -1";
  toIntTest[2].operand.highBits := -1;
  toIntTest[2].operand.lowBits := 0FFFFFFFFH;
  toIntTest[2].expected := -1;
  toIntTest[2].expStatus := Success;
  
  toIntTest[3].label := "INT64.ToInt() for MIN(INTEGER)";
  toIntTest[3].operand.highBits := -1;
  toIntTest[3].operand.lowBits := 080000000H;
  toIntTest[3].expected := -2147483648;
  toIntTest[3].expStatus := Success;
  
  toIntTest[4].label := "INT64.ToInt() for MIN(INTEGER)-1";
  toIntTest[4].operand.highBits := -1;
  toIntTest[4].operand.lowBits := 07FFFFFFFH;
  toIntTest[4].expected := 0; (* ignored *)
  toIntTest[4].expStatus := Underflow;
  
  toIntTest[5].label := "INT64.ToInt() for MAX(INTEGER)";
  toIntTest[5].operand.highBits := 0;
  toIntTest[5].operand.lowBits := 07FFFFFFFH;
  toIntTest[5].expected := 2147483647;
  toIntTest[5].expStatus := Success;
  
  toIntTest[6].label := "INT64.ToInt() for MAX(INTEGER)+1";
  toIntTest[6].operand.highBits := 0;
  toIntTest[6].operand.lowBits := 080000000H;
  toIntTest[6].expected := 0; (* ignored *)
  toIntTest[6].expStatus := Overflow
END InitToIntTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunToIntTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToIntTest ( test : ToIntTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  i : INTEGER;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  ToInt(test.operand, i, stat);
  PrintIntResult(i); PrintStatus(stat);
  IF test.expStatus = Success THEN
    IF (i = test.expected) THEN
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
END RunToIntTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunToIntTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ToIntTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToIntTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ToIntTestCount-1 DO
    RunToIntTest(toIntTest[index], passed, failed)
  END (* FOR *)
END RunToIntTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64.ToLongInt
 * ----------------------------------------------------------------------- *)

TYPE ToLongIntTest = RECORD
  operand : INT64T;
  expected : LONGINT;
  expStatus : Status;
  label : LabelString
END; (* ToLongIntTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToLongIntTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToLongInt.
 * ----------------------------------------------------------------------- *)

CONST ToLongIntTestCount = 7;

VAR toLongIntTest : ARRAY [0..ToLongIntTestCount-1] OF ToLongIntTest;

PROCEDURE InitToLongIntTests;
BEGIN
  toLongIntTest[0].label := "INT64.ToLongInt() for 0";
  toLongIntTest[0].operand.highBits := 0;
  toLongIntTest[0].operand.lowBits := 0;
  toLongIntTest[0].expected := 0;
  toLongIntTest[0].expStatus := Success;
  
  toLongIntTest[1].label := "INT64.ToLongInt() for 1";
  toLongIntTest[1].operand.highBits := 0;
  toLongIntTest[1].operand.lowBits := 1;
  toLongIntTest[1].expected := 1;
  toLongIntTest[1].expStatus := Success;
  
  toLongIntTest[2].label := "INT64.ToLongInt() for -1";
  toLongIntTest[2].operand.highBits := -1;
  toLongIntTest[2].operand.lowBits := 0FFFFFFFFH;
  toLongIntTest[2].expected := -1;
  toLongIntTest[2].expStatus := Success;
  
  toLongIntTest[3].label := "INT64.ToLongInt() for MIN(LONGINT)";
  toLongIntTest[3].operand.highBits := -1;
  toLongIntTest[3].operand.lowBits := 080000000H;
  toLongIntTest[3].expected := -2147483648;
  toLongIntTest[3].expStatus := Success;
  
  toLongIntTest[4].label := "INT64.ToLongInt() for MIN(LONGINT)-1";
  toLongIntTest[4].operand.highBits := -1;
  toLongIntTest[4].operand.lowBits := 07FFFFFFFH;
  toLongIntTest[4].expected := 0; (* ignored *)
  toLongIntTest[4].expStatus := Underflow;
  
  toLongIntTest[5].label := "INT64.ToLongInt() for MAX(LONGINT)";
  toLongIntTest[5].operand.highBits := 0;
  toLongIntTest[5].operand.lowBits := 07FFFFFFFH;
  toLongIntTest[5].expected := 2147483647;
  toLongIntTest[5].expStatus := Success;
  
  toLongIntTest[6].label := "INT64.ToLongInt() for MAX(LONGINT)+1";
  toLongIntTest[6].operand.highBits := 0;
  toLongIntTest[6].operand.lowBits := 080000000H;
  toLongIntTest[6].expected := 0; (* ignored *)
  toLongIntTest[6].expStatus := Overflow
END InitToLongIntTests;


(* --------------------------------------------------------------------------
 * Procedure:  RunToLongIntTest(test, passed, failed)
 * --------------------------------------------------------------------------
 * Run test and update the appropriate counter. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToLongIntTest
  ( test : ToLongIntTest; VAR passed, failed : CARDINAL );
VAR
  stat : Status;
  i : LONGINT;
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  ToLongInt(test.operand, i, stat);
  PrintLongIntResult(i); PrintStatus(stat);
  IF test.expStatus = Success THEN
    IF (i = test.expected) THEN
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
END RunToLongIntTest;


(* --------------------------------------------------------------------------
 * Procedure:  RunToLongIntTests(passed, failed)
 * --------------------------------------------------------------------------
 * Run all ToLongIntTest tests and update counters. 
 * ----------------------------------------------------------------------- *)

PROCEDURE RunToLongIntTests ( VAR passed, failed : CARDINAL );
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO ToLongIntTestCount-1 DO
    RunToLongIntTest(toLongIntTest[index], passed, failed)
  END (* FOR *)
END RunToLongIntTests;


(* --------------------------------------------------------------------------
 * Test parameter type for INT64.ToString
 * ----------------------------------------------------------------------- *)

TYPE ToStringTest = RECORD
  operand : INT64T;
  expected : NumberString;
  label : LabelString
END; (* ToStringTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitToStringTests
 * --------------------------------------------------------------------------
 * Initialises tests for procedure ToString.
 * ----------------------------------------------------------------------- *)

CONST ToStringTestCount = 25;

VAR toStringTest : ARRAY [0..ToStringTestCount-1] OF ToStringTest;

PROCEDURE InitToStringTests;
BEGIN
  toStringTest[0].label := "INT64.ToString() for 0";
  toStringTest[0].operand.highBits := 0;
  toStringTest[0].operand.lowBits := 0;
  toStringTest[0].expected := "0";
  
  toStringTest[1].label := "INT64.ToString() for 1";
  toStringTest[1].operand.highBits := 0;
  toStringTest[1].operand.lowBits := 1;
  toStringTest[1].expected := "1";
  
  toStringTest[2].label := "INT64.ToString() for 2";
  toStringTest[2].operand.highBits := 0;
  toStringTest[2].operand.lowBits := 2;
  toStringTest[2].expected := "2";
  
  toStringTest[3].label := "INT64.ToString() for 3";
  toStringTest[3].operand.highBits := 0;
  toStringTest[3].operand.lowBits := 3;
  toStringTest[3].expected := "3";
  
  toStringTest[4].label := "INT64.ToString() for 4";
  toStringTest[4].operand.highBits := 0;
  toStringTest[4].operand.lowBits := 4;
  toStringTest[4].expected := "4";
  
  toStringTest[5].label := "INT64.ToString() for 5";
  toStringTest[5].operand.highBits := 0;
  toStringTest[5].operand.lowBits := 5;
  toStringTest[5].expected := "5";
  
  toStringTest[6].label := "INT64.ToString() for 6";
  toStringTest[6].operand.highBits := 0;
  toStringTest[6].operand.lowBits := 6;
  toStringTest[6].expected := "6";
  
  toStringTest[7].label := "INT64.ToString() for 7";
  toStringTest[7].operand.highBits := 0;
  toStringTest[7].operand.lowBits := 7;
  toStringTest[7].expected := "7";
  
  toStringTest[8].label := "INT64.ToString() for 8";
  toStringTest[8].operand.highBits := 0;
  toStringTest[8].operand.lowBits := 8;
  toStringTest[8].expected := "8";
  
  toStringTest[9].label := "INT64.ToString() for 9";
  toStringTest[9].operand.highBits := 0;
  toStringTest[9].operand.lowBits := 9;
  toStringTest[9].expected := "9";
  
  toStringTest[10].label := "INT64.ToString() for 10";
  toStringTest[10].operand.highBits := 0;
  toStringTest[10].operand.lowBits := 10;
  toStringTest[10].expected := "10";
  
  toStringTest[11].label := "INT64.ToString() for 99";
  toStringTest[11].operand.highBits := 0;
  toStringTest[11].operand.lowBits := 99;
  toStringTest[11].expected := "99";
  
  toStringTest[12].label := "INT64.ToString() for 100";
  toStringTest[12].operand.highBits := 0;
  toStringTest[12].operand.lowBits := 100;
  toStringTest[12].expected := "100";
  
  toStringTest[13].label := "INT64.ToString() for 999";
  toStringTest[13].operand.highBits := 0;
  toStringTest[13].operand.lowBits := 999;
  toStringTest[13].expected := "999";
  
  toStringTest[14].label := "INT64.ToString() for 1000";
  toStringTest[14].operand.highBits := 0;
  toStringTest[14].operand.lowBits := 1000;
  toStringTest[14].expected := "1000";
  
  toStringTest[15].label := "INT64.ToString() for 4294967294";
  toStringTest[15].operand.highBits := 0;
  toStringTest[15].operand.lowBits := 0FFFFFFFEH;
  toStringTest[15].expected := "4294967294";
  
  toStringTest[16].label := "INT64.ToString() for 4294967295";
  toStringTest[16].operand.highBits := 0;
  toStringTest[16].operand.lowBits := 0FFFFFFFFH;
  toStringTest[16].expected := "4294967295";
  
  toStringTest[17].label := "INT64.ToString() for 4294967296";
  toStringTest[17].operand.highBits := 1;
  toStringTest[17].operand.lowBits := 0;
  toStringTest[17].expected := "4294967296";
  
  toStringTest[18].label := "INT64.ToString() for 9223372036854775807";
  toStringTest[18].operand.highBits := 0FFFFFFFFH;
  toStringTest[18].operand.lowBits := 0FFFFFFFFH;
  toStringTest[18].expected := "9223372036854775807";

  toStringTest[19].label := "INT64.ToString() for -1";
  toStringTest[19].operand.highBits := -1;
  toStringTest[19].operand.lowBits := 0FFFFFFFFH;
  toStringTest[19].expected := "-1";
  
  toStringTest[20].label := "INT64.ToString() for -10";
  toStringTest[20].operand.highBits := -1;
  toStringTest[20].operand.lowBits := 0FFFFFFF6H;
  toStringTest[20].expected := "-10";
  
  toStringTest[21].label := "INT64.ToString() for -100";
  toStringTest[21].operand.highBits := -1;
  toStringTest[21].operand.lowBits := 0FFFFFF9CH;
  toStringTest[21].expected := "-100";
  
  toStringTest[22].label := "INT64.ToString() for -1000";
  toStringTest[22].operand.highBits := -1;
  toStringTest[22].operand.lowBits := 0FFFFFC18H;
  toStringTest[22].expected := "-1000";
  
  (* MIN(LONGINT)+1 *)
  toStringTest[23].label := "INT64.ToString() for -4294967295";
  toStringTest[23].operand.highBits := -1;
  toStringTest[23].operand.lowBits := 1;
  toStringTest[23].expected := "-4294967295";
  
  (* MIN(LONGINT) *)
  toStringTest[23].label := "INT64.ToString() for -4294967296";
  toStringTest[23].operand.highBits := -1;
  toStringTest[23].operand.lowBits := 0;
  toStringTest[23].expected := "-42949672956";
  
  (* MIN(LONGINT)-1 *)
  toStringTest[23].label := "INT64.ToString() for -4294967297";
  toStringTest[23].operand.highBits := -2;
  toStringTest[23].operand.lowBits := 0FFFFFFFFH;
  toStringTest[23].expected := "-42949672956";
  
  (* MIN(INT64T) *)
  toStringTest[24].label := "INT64.ToString() for -9223372036854775808";
  toStringTest[24].operand.highBits := -2147483648;
  toStringTest[24].operand.lowBits := 0;
  toStringTest[24].expected := "-9223372036854775808"
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
 * Procedure:  PrintResult(i)
 * --------------------------------------------------------------------------
 * Prints result label followed by value i. 
 * ----------------------------------------------------------------------- *)

CONST ResultLabel = " result: ";

PROCEDURE PrintResult ( i : INT64T );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(LONGCARD(i.highBits));
  InOut.Write(":");
  LongCardIO.WriteHex(i.lowBits);
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
 * Procedure:  PrintIntResult(i)
 * --------------------------------------------------------------------------
 * Prints result label followed by value i. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintIntResult ( i : INTEGER );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(LONGCARD(i));
  InOut.WriteLn
END PrintIntResult;


(* --------------------------------------------------------------------------
 * Procedure:  PrintLongIntResult(i)
 * --------------------------------------------------------------------------
 * Prints result label followed by value i. 
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintLongIntResult ( i : LONGINT );
BEGIN
  InOut.WriteString(ResultLabel);
  LongCardIO.WriteHex(LONGCARD(i));
  InOut.WriteLn
END PrintLongIntResult;


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

BEGIN (* TestInt64Conv *)
  InitSetValTests;
  InitFromCardTests;
  InitFromLongCardTests;
  InitFromIntTests;
  InitFromLongIntTests;
  InitToCardTests;
  InitToLongCardTests;
  InitToIntTests;
  InitToLongIntTests;
  InitToStringTests
END TestInt64Conv.
