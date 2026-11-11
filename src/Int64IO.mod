(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE Int64IO;

(* Console IO library for Type INT64T *)


IMPORT INT64;

FROM INT64 IMPORT INT64T;

IMPORT CARD64;

FROM CARD64 IMPORT CARD64T;

IMPORT LongCardIO, InOut;


(* --------------------------------------------------------------------------
 * Procedure:  Int64IO.Read(i, stat)
 * --------------------------------------------------------------------------
 * Read unformatted decimal number from console and pass it in i.
 * ----------------------------------------------------------------------- *)

PROCEDURE Read ( VAR i : INT64T; VAR stat : INT64.Status );
VAR
  ch : CHAR;
  minusSign : BOOLEAN;
  ten, val, digitVal, minIntMagnitude, maxIntMagnitude : CARD64T;
BEGIN
  CARD64.SetZero(val);
  ten.highBits := 0;
  ten.lowBits := 10;
  
  InOut.Read(ch);
  IF NOT InOut.Done() THEN
    stat := INT64.NoInput;
    RETURN
  END (* IF *)
  
  IF (ch = "-") OR (ch = "+") THEN
    minusSign := (ch = "-");
    InOut.Read(ch)
  END; (* IF *)
  
  IF (ch < "0") OR (ch > "9") THEN
    stat := INT64.InvalidInput;
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
  
  minIntMagnitude.highBits := 80000000H;
  minIntMagnitude.lowBits := 0;

  maxIntMagnitude.highBits := 7FFFFFFFH;
  maxIntMagnitude.lowBits := 0FFFFFFFFH;
  
  IF minusSign THEN
    IF CARD64.gt(val, minIntMagnitude) THEN
      stat := INT64.Underflow;
      RETURN
    END; (* IF *)
    IF CARD64.eq(val, minIntMagnitude) THEN
      INT64.SetMin(i);
      stat := INT64.Success
    ELSE
      INT64.FromCard64(val, i, stat);
      INT64.Neg(i, i, stat)
    END (* IF *)
  ELSE (* no minus sign *)
    IF CARD64.gt(val, maxIntMagnitude) THEN
      stat := INT64.Overflow;
      RETURN
    END; (* IF *)
    INT64.FromCard64(val, i, stat)
  END (* IF *)
END Read;


(* --------------------------------------------------------------------------
 * Procedure:  Int64IO.Write(i)
 * --------------------------------------------------------------------------
 * Write i as a decimal number unformatted to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Write ( i : INT64T );
VAR
  index, count : CARDINAL;
  digits : ARRAY [0..CARD64.MaxDecimalDigits] OF CHAR;
BEGIN
  IF i.highBits < 0 THEN
    InOut.Write("-")
  END; (* IF *)
  
  index := 0;
  GetDigitSeq(i, digits, count);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    INC(index)
  END (* WHILE *)
END Write;


(* --------------------------------------------------------------------------
 * Procedure:  Int64IO.WriteF(fmt, i)
 * --------------------------------------------------------------------------
 * Write i formatted to console following format fmt.
 *
 * fmt | radix    | separation       | digit grouping
 * ----+----------+------------------+---------------
 * ',' | decimal  | comma separated  | 3 digits 
 * '.' | decimal  | period separated | 3 digits
 * 'x' | radix-16 | colon separated  | 8 digits
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteF ( fmt : CHAR; i : INT64T );
BEGIN
  IF (fmt = ".") OR (fmt = ",") THEN
    WriteFmtDec(fmt, i)
  ELSIF fmt = "x" THEN
    WriteFmtHex(i)
  ELSE
    IF i.highBits > 0 THEN
      InOut.Write(" ")
    END; (* IF *)
    Write(i)
  END (* IF *)
END WriteF;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure:  GetDigitSeq(n, digits)
 * --------------------------------------------------------------------------
 * Passes the decimal digit sequence for n in digits.
 * ----------------------------------------------------------------------- *)

CONST MinIntDigitSeq = "9223372036854775808";

PROCEDURE GetDigitSeq
  ( i : INT64T; VAR digits : ARRAY OF CHAR; VAR count : CARDINAL );
VAR
  index : CARDINAL;
  ignore : CARD64.Status;
  ten, rem, digitVal : CARD64T;
BEGIN
  IF INT64.isZero(i) THEN
    digits := "0";
    count := 1;
    RETURN
  ELSIF INT64.isOne(i) THEN
    digits := "1";
    count := 1;
    RETURN
  ELSIF INT64.isMin(i) THEN
    digits := MinIntDigitSeq;
    count := CARD64.MaxDecimalDigits;
    RETURN
  END; (* IF *)
  
  IF i.highBits < 0 THEN
    INT64.Abs(i, rem, ignore)
  ELSE
    rem.highBits := LONGCARD(i.highBits);
    rem.lowBits := i.lowBits
  END; (* IF *)
  
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
 * Procedure:  WriteFmtDec(fmt, i)
 * --------------------------------------------------------------------------
 * Write i as decimal number to console with digit group separator fmt.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtDec ( fmt : CHAR; i : INT64T );
VAR
  index, weight : CARDINAL;
  digits : ARRAY [0..CARD64.MaxDecimalDigits] OF CHAR;
BEGIN
  IF i.highBits < 0 THEN
    InOut.Write("-")
  ELSE
    InOut.Write(" ")
  END; (* IF *)
  
  index := 0;
  GetDigitSeq(i, digits, weight);
  DEC(weight);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    DEC(weight);
    IF (weight MOD 3 = 0) AND (weight > 0) THEN
      InOut.Write(fmt);
    END; (* IF *)
    INC(index)
  END (* WHILE *)
END WriteFmtDec;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtHex(i)
 * --------------------------------------------------------------------------
 * Write i as radix-16 number to console with digit group separator ":".
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtHex ( i : INT64T );
BEGIN
  InOut.Write("0");
  InOut.Write("x");
  LongCardIO.WriteHex(LONGCARD(i.highBits));
  InOut.Write(":");
  LongCardIO.WriteHex(i.lowBits)
END WriteFmtHex;


END Int64IO.
