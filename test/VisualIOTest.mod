(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

MODULE VisualIOTest;

(* --------------------------------------------------------------------------
 * Program Module: VisualIOTest
 * --------------------------------------------------------------------------
 * Visual tests for CARD64IO and INT64IO libraries.
 * Prints edge-case values as unformatted, formatted and radix-16 output.
 * ----------------------------------------------------------------------- *)

IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT INT64;

FROM INT64 IMPORT INT64T;

IMPORT InOut, CARD64IO, INT64IO;


(* --------------------------------------------------------------------------
 * Maximum test label length
 * ----------------------------------------------------------------------- *)

CONST MaxLabelLength = 40;


(* --------------------------------------------------------------------------
 * Maximum output string length
 * ----------------------------------------------------------------------- *)

CONST MaxOutputLength = 40;


(* --------------------------------------------------------------------------
 * Test label string type
 * ----------------------------------------------------------------------- *)

TYPE LabelString = ARRAY [0..MaxLabelLength] OF CHAR;


(* --------------------------------------------------------------------------
 * Output string type
 * ----------------------------------------------------------------------- *)

TYPE OutputString = ARRAY [0..MaxOutputLength] OF CHAR;


(* --------------------------------------------------------------------------
 * Expected output tuple type
 * ----------------------------------------------------------------------- *)

TYPE ExpectedOutput = RECORD
  unformatted,
  dotSeparated,
  commaSeparated,
  radix16 : OutputString
END; (* ExpectedOutput *)


(* --------------------------------------------------------------------------
 * Test parameter type for CARD64
 * ----------------------------------------------------------------------- *)

TYPE CardTest = RECORD
  value : Card64T;
  label : LabelString;
  expected : ExpectedOutput
END; (* CardTest *)


(* --------------------------------------------------------------------------
 * Test parameter type for INT64
 * ----------------------------------------------------------------------- *)

TYPE IntTest = RECORD
  value : INT64T;
  label : LabelString;
  expected : ExpectedOutput
END; (* IntTest *)


(* --------------------------------------------------------------------------
 * Procedure:  InitCardTests
 * --------------------------------------------------------------------------
 * Initialises test case parameters for CARD64T.
 * ----------------------------------------------------------------------- *)

CONST CardTestCount = 4;

VAR cardTest : ARRAY [0..CardTestCount-1] OF CardTest;

PROCEDURE InitCardTests;
BEGIN
  cardTest[0].label := "CARD64: zero";
  cardTest[0].value.highBits := 0;
  cardTest[0].value.lowBits := 0;
  cardTest[0].expected.unformatted := "0";
  cardTest[0].expected.dotSeparated := "0";
  cardTest[0].expected.commaSeparated := "0";
  cardTest[0].expected.radix16 := "0x00000000:00000000";

  cardTest[1].label := "CARD64: one";
  cardTest[1].value.highBits := 0;
  cardTest[1].value.lowBits := 1;
  cardTest[1].expected.unformatted := "1";
  cardTest[1].expected.dotSeparated := "1";
  cardTest[1].expected.commaSeparated := "1";
  cardTest[1].expected.radix16 := "0x00000000:00000001";

  cardTest[2].label := "CARD64: MAX(LONGCARD)";
  cardTest[2].value.highBits := 0;
  cardTest[2].value.lowBits := MAX(LONGCARD);
  cardTest[2].expected.unformatted := "4294967295";
  cardTest[2].expected.dotSeparated := "4.294.967.295";
  cardTest[2].expected.commaSeparated := "4,294,967,295";
  cardTest[2].expected.radix16 := "0x00000000:FFFFFFFF";

  cardTest[3].label := "CARD64: MAX(CARD64T)";
  cardTest[3].value.highBits := MAX(LONGCARD);
  cardTest[3].value.lowBits := MAX(LONGCARD);
  cardTest[3].expected.unformatted := "18446744073709551615";
  cardTest[3].expected.dotSeparated := "18.446.744.073.709.551.615";
  cardTest[3].expected.commaSeparated := "18,446,744,073,709,551,615";
  cardTest[3].expected.radix16 := "0xFFFFFFFF:FFFFFFFF"
 END InitCardTests;


(* --------------------------------------------------------------------------
 * Procedure:  InitIntTests
 * --------------------------------------------------------------------------
 * Initialises test case parameters for INT64T.
 * ----------------------------------------------------------------------- *)

CONST IntTestCount = 6;

VAR intTest : ARRAY [0..IntTestCount-1] OF IntTest;

PROCEDURE InitIntTests;
BEGIN
  intTest[0].label := "INT64: zero";
  intTest[0].value.highBits := 0;
  intTest[0].value.lowBits := 0;
  intTest[0].expected.unformatted := "0";
  intTest[0].expected.dotSeparated := "0";
  intTest[0].expected.commaSeparated := "0";
  intTest[0].expected.radix16 := "0x00000000:00000000";

  intTest[1].label := "INT64: one";
  intTest[1].value.highBits := 0;
  intTest[1].value.lowBits := 1;
  intTest[1].expected.unformatted := "1";
  intTest[1].expected.dotSeparated := "1";
  intTest[1].expected.commaSeparated := "1";
  intTest[1].expected.radix16 := "0x00000000:00000001";
  
  intTest[2].label := "INT64: minus one";
  intTest[2].value.highBits := -1;
  intTest[2].value.lowBits := 0FFFFFFFFH;
  intTest[2].expected.unformatted := "-1";
  intTest[2].expected.dotSeparated := "-1";
  intTest[2].expected.commaSeparated := "-1";
  intTest[2].expected.radix16 := "0xFFFFFFFF:FFFFFFFF";
  
  intTest[3].label := "INT64: MIN(LONGINT)";
  intTest[3].value.highBits := -1;
  intTest[3].value.lowBits := 80000000H;
  intTest[3].expected.unformatted := "-2147483648";
  intTest[3].expected.dotSeparated := "-2.147.483.648";
  intTest[3].expected.commaSeparated := "-2,147,483,648";
  intTest[3].expected.radix16 := "0xFFFFFFFF:80000000";

  intTest[4].label := "INT64: MIN(INT64T)";
  intTest[4].value.highBits := 80000000H;
  intTest[4].value.lowBits := 0;
  intTest[4].expected.unformatted := "-9223372036854775808";
  intTest[4].expected.dotSeparated := "-9.223.372.036.854.775.808";
  intTest[4].expected.commaSeparated := "-9,223,372,036,854,775,808";
  intTest[4].expected.radix16 := "0x80000000:00000000";

  intTest[5].label := "INT64: MAX(INT64T)";
  intTest[5].value.highBits := 7FFFFFFFH;
  intTest[5].value.lowBits := 0FFFFFFFFH;
  intTest[5].expected.unformatted := "9223372036854775807";
  intTest[5].expected.dotSeparated := "9.223.372.036.854.775.807";
  intTest[5].expected.commaSeparated := "9,223,372,036,854,775,807";
  intTest[5].expected.radix16 := "0x7FFFFFFF:FFFFFFFF"
 END InitIntTests;


(* --------------------------------------------------------------------------
 * Procedure:  PrintCardTest(test)
 * --------------------------------------------------------------------------
 * Print test outputs for CARD64 test case 'test'.
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintCardTest ( test : CardTest );
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  (* Print expected unformatted output *)
  InOut.WriteString("(1) Unformatted, expected  : ");
  InOut.WriteString(test.expected.unformatted);
  InOut.WriteLn;
  
  (* Print actual unformatted output *)
  InOut.WriteString("    Unformatted, actual    : ");
  CARD64IO.Write(test.value); InOut.WriteLn;
  InOut.WriteLn;
  
  (* Print expected formatted '.' separated output *)
  InOut.WriteString("(2) '.' separated, expected: ");
  InOut.WriteString(test.expected.dotSeparated);
  InOut.WriteLn;
  
  (* Print actual formatted '.' separated output *)
  InOut.WriteString("    '.' separated, actual  : ");
  CARD64IO.WriteFmt(".", test.value); InOut.WriteLn;
  InOut.WriteLn;
 
  (* Print expected formatted ',' separated output *)
  InOut.WriteString("(3) ',' separated, expected: ");
  InOut.WriteString(test.expected.commaSeparated);
  InOut.WriteLn;
  
  (* Print actual formatted ',' separated output *)
  InOut.WriteString("    ',' separated, actual  : ");
  CARD64IO.WriteFmt(",", test.value); InOut.WriteLn;
  InOut.WriteLn;
  
  (* Print expected radix-16 (hexadecimal) output *)
  InOut.WriteString("(4) radix-16, expected     : ");
  InOut.WriteString(test.expected.radix16);
  InOut.WriteLn;
  
  (* Print actual radix-16 output *)
  InOut.WriteString("    radix-16, actual       : ");
  CARD64IO.WriteFmt("x", test.value); InOut.WriteLn;
  InOut.WriteLn
END PrintCardTest;


(* --------------------------------------------------------------------------
 * Procedure:  PrintIntTest(test)
 * --------------------------------------------------------------------------
 * Print test outputs for INT64 test case 'test'.
 * ----------------------------------------------------------------------- *)

PROCEDURE PrintIntTest ( test : IntTest );
BEGIN
  (* Print label *)
  InOut.WriteString("*** ");
  InOut.WriteString(test.label);
  InOut.WriteString(" ***");
  InOut.WriteLn;
  
  (* Print expected unformatted output *)
  InOut.WriteString("(1) Unformatted, expected  : ");
  InOut.WriteString(test.expected.unformatted);
  InOut.WriteLn;
  
  (* Print actual unformatted output *)
  InOut.WriteString("    Unformatted, actual    : ");
  INT64IO.Write(test.value); InOut.WriteLn;
  InOut.WriteLn;
  
  (* Print expected formatted '.' separated output *)
  InOut.WriteString("(2) '.' separated, expected: ");
  InOut.WriteString(test.expected.dotSeparated);
  InOut.WriteLn;
  
  (* Print actual formatted '.' separated output *)
  InOut.WriteString("    '.' separated, actual  : ");
  INT64IO.WriteFmt(".", test.value); InOut.WriteLn;
  InOut.WriteLn;
 
  (* Print expected formatted ',' separated output *)
  InOut.WriteString("(3) ',' separated, expected: ");
  InOut.WriteString(test.expected.commaSeparated);
  InOut.WriteLn;
  
  (* Print actual formatted ',' separated output *)
  InOut.WriteString("    ',' separated, actual  : ");
  INT64IO.WriteFmt(",", test.value); InOut.WriteLn;
  InOut.WriteLn;
  
  (* Print expected radix-16 (hexadecimal) output *)
  InOut.WriteString("(4) radix-16, expected     : ");
  InOut.WriteString(test.expected.radix16);
  InOut.WriteLn;
  
  (* Print actual radix-16 output *)
  InOut.WriteString("    radix-16, actual       : ");
  INT64IO.WriteFmt("x", test.value); InOut.WriteLn;
  InOut.WriteLn
END PrintIntTest;


(* --------------------------------------------------------------------------
 * Main body
 * ----------------------------------------------------------------------- *)

VAR
  index : CARDINAL;

BEGIN (* VisualIOTest *)
  InitCardTests;
  InitIntTests;
  
  InOut.WriteString("Visual IO Tests for CARD64IO");
  InOut.WriteLn; InOut.WriteLn;
  
  FOR index := 0 TO CardTestCount-1 DO
    PrintCardTest(cardTest[index]);
  END; (* FOR *)

  InOut.WriteString("Visual IO Tests for INT64IO");
  InOut.WriteLn; InOut.WriteLn;
  
  FOR index := 0 TO IntTestCount-1 DO
    PrintIntTest(intTest[index]);
  END; (* FOR *)

  InOut.WriteString("done.");
  InOut.WriteLn
END VisualIOTest.
