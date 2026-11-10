(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE CARD64IO;

(* Console IO library for Type CARD64T *)


IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT InOut;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64IO.Read(n, stat)
 * --------------------------------------------------------------------------
 * Read unformatted decimal number from console and pass it in n.
 * ----------------------------------------------------------------------- *)

PROCEDURE Read ( VAR n : CARD64T; VAR stat : CARD64.Status );
VAR
  ch : CHAR;
  ten, val, digitVal : CARD64T;
BEGIN
  CARD64.SetZero(val);
  ten.highBits := 0;
  ten.lowBits := 10;
  
  InOut.Read(ch);
  IF NOT InOut.Done() THEN
    stat := CARD64.NoInput;
    RETURN
  END (* IF *)
  
  IF ch = "+" THEN
    InOut.Read(ch)
  END; (* IF *)
  
  IF (ch < "0") OR (ch > "9") THEN
    stat := CARD64.InvalidInput;
    RETURN
  END; (* IF *)
  
  WHILE InOut.Done() AND (ch >= "0") AND (ch <= "9") DO
    CARD64.Mul(val, ten, val, stat);
    IF stat # CARD64.Success THEN
      RETURN
    END; (* IF *)
    
    digitVal.highBits := 0;
    digitVal.lowBits := ORD(ch) - ORD("0");
    
    CARD64.Add(val, digitVal, val, stat);
    IF stat # CARD64.Success THEN
      RETURN
    END; (* IF *)
    
    InOut.Read(ch)
  END; (* WHILE *)
  
  n := val
END Read;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64IO.Write(n)
 * --------------------------------------------------------------------------
 * Write n as a decimal number unformatted to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Write ( n : CARD64T );
VAR
  index, count : CARDINAL;
  digits : ARRAY [0..CARD64.MaxDecimalDigits] OF CHAR;
BEGIN
  index := 0;
  GetDigitSeq(n, digits, count);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    INC(index)
  END (* WHILE *)
END Write;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64IO.WriteF(fmt, n)
 * --------------------------------------------------------------------------
 * Write i formatted to console following format fmt.
 *
 * fmt | radix    | separation       | digit grouping
 * ----+----------+------------------+---------------
 * ',' | decimal  | comma separated  | 3 digits 
 * '.' | decimal  | period separated | 3 digits
 * 'x' | radix-16 | colon separated  | 8 digits
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteF ( fmt : CHAR; n : CARD64T );
BEGIN
  IF (fmt = ".") OR (fmt = ",") THEN
    WriteFmtDec(fmt, n)
  ELSIF fmt = "x" THEN
    WriteFmtHex(n)
  ELSE
    Write(n)
  END (* IF *)
END WriteF;


(* --------------------------------------------------------------------------
 * Procedure:  WriteStatus(stat)
 * --------------------------------------------------------------------------
 * Write stat to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteStatus ( stat : Status );
BEGIN 
  CASE stat OF
    Success        : InOut.WriteString("Success")
  | Underflow      : InOut.WriteString("Underflow")
  | Overflow       : InOut.WriteString("Overflow")
  | DivByZero      : InOut.WriteString("DivByZero")
  | StrLenTooShort : InOut.WriteString("StrLenTooShort")
  | NoInput        : InOut.WriteString("NoInput")
  | InvalidInput   : InOut.WriteString("InvalidInput")
  END (* CASE *)
END WriteStatus;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure:  GetDigitSeq(n, digits)
 * --------------------------------------------------------------------------
 * Passes the decimal digit sequence for n in digits.
 * ----------------------------------------------------------------------- *)

PROCEDURE GetDigitSeq
  ( n : CARD64T; VAR digits : ARRAY OF CHAR; VAR count : CARDINAL );
VAR
  index : CARDINAL;
  ignore : CARD64.Status;
  ten, rem, digitVal : CARD64T;
BEGIN
  IF CARD64.isZero(n) THEN
    digits := "0";
    count := 1;
    RETURN
  ELSIF CARD64.isOne(n) THEN
    digits := "1";
    count := 1;
    RETURN
  END; (* IF *)
  
  rem := n;
    
  ten.highBits := 0;
  ten.lowBits := 10;
  
  index := CARD64.digitCount(rem);
  digits[index] := CHR(0);
  count := index;
  
  WHILE index > 0 DO
    DEC(index);
    CARD64.Mod(rem, ten, digitVal, ignore);
    CARD64.Div(rem, ten, rem, ignore);
    digits[index] := CHR(ORD("0") + CARDINAL(digitVal.lowBits))
  END (* WHILE *)
END GetDigitSeq;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtDec(fmt, n)
 * --------------------------------------------------------------------------
 * Write n as decimal number to console with digit group separator fmt.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtDec ( fmt : CHAR; n : CARD64T );
VAR
  index, weight : CARDINAL;
  digits : ARRAY [0..CARD64.MaxDecimalDigits] OF CHAR;
BEGIN
  index := 0;
  GetDigitSeq(n, digits, weight);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    IF (weight MOD 3 = 0) AND (weight > 0) THEN
      InOut.Write(fmt)
    END; (* IF *)
    INC(index);
    DEC(weight)
  END (* WHILE *)
END WriteFmtDec;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtHex(n)
 * --------------------------------------------------------------------------
 * Write n as radix-16 number to console with digit group separator ":".
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtHex ( n : CARD64T );
BEGIN
  InOut.Write("0");
  InOut.Write("x");
  WriteLCHex(n.highBits);
  InOut.Write(":");
  WriteLCHex(n.lowBits)
END WriteFmtHex;


(* --------------------------------------------------------------------------
 * Procedure:  WriteLCHex(n)
 * --------------------------------------------------------------------------
 * Write LONGCARD n as radix-16 number to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteLCHex ( n : LONGCARD );
CONST
  HexDigit = "0123456789ABCDEF";
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO 7 DO
    InOut.Write(HexDigit[(n DIV shiftFactor[index]) MOD 16])
  END (* FOR *)
END WriteLCHex;


(* --------------------------------------------------------------------------
 * Procedure:  InitShiftFactorTable
 * --------------------------------------------------------------------------
 * Initialise table with powers of 2 for n = {28, 24, 20, 16, 12, 8, 4, 0}
 * ----------------------------------------------------------------------- *)

VAR shiftFactor : ARRAY [0..7] OF LONGCARD;

PROCEDURE InitShiftFactorTable;
VAR
  index : CARDINAL;
BEGIN
  shiftFactor[0] := 10000000H;
  FOR index := 1 TO 7 DO
    shiftFactor[index] := shiftFactor[index-1] DIV 16
  END (* FOR *)
END InitShiftFactorTable;


(* Module initialisation *)

BEGIN
  InitShiftFactorTable
END CARD64IO.
