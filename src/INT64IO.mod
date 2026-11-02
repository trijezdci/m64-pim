(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE Int64IO;

(* Console IO library for Type INT64T *)


FROM INT64 IMPORT INT64T;


(* --------------------------------------------------------------------------
 * Procedure:  Int64IO.Read(i)
 * --------------------------------------------------------------------------
 * Read unformatted decimal number from console and pass it in i.
 * ----------------------------------------------------------------------- *)

PROCEDURE Read ( VAR i : INT64T );
BEGIN

END Read;


(* --------------------------------------------------------------------------
 * Procedure:  Int64IO.Write(i)
 * --------------------------------------------------------------------------
 * Write i as a decimal number unformatted to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Write ( i : INT64T );
BEGIN
  IF INT64.isZero(i) THEN
    WriteChar("0");
    RETURN
  ELSIF INT64.isOne(i) THEN
    WriteChar("1");
    RETURN
  END; (* IF *)
  
  rem := i;
  index := 0;
  WHILE NOT INT64.isZero(rem) DO
    INT64.Mod(rem, ten, digitVal, stat);
    INT64.Div(rem, ten, rem, stat);
    digit[index] := CHR(ORD("0") + digitVal;
    INC(index)
  END; (* WHILE *)
  
  REPEAT
    WriteChar(digit[index]);
    DEC(index)
  UNTIL index = 0
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
  IF fmt = "." THEN
    WriteFmtDec(".", i)
  ELSE fmt = "," THEN
    WriteFmtDec(",", i)
  ELSE fmt = "x" THEN
    WriteFmtHex(i)
  ELSE
    Write(i)
  END (* IF *)
END WriteF;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtDec(fmt, i)
 * --------------------------------------------------------------------------
 * Write i as decimal number to console with digit group separator fmt.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtDec ( fmt : CHAR; i : INT64T );
BEGIN
  If (fmt = ".") OR (fmt = ",") THEN
    
  ELSE
    Write(i)
  END (* IF *)
END WriteFmtDec;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtHex(i)
 * --------------------------------------------------------------------------
 * Write i as radix-16 number to console with digit group separator ":".
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtHex ( i : INT64T );
BEGIN
  WriteChar("0");
  WriteChar("x");
  WriteLCHex(LONGCARD(i.highBits));
  WriteChar(":");
  WriteLCHex(i.lowBits)
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
    WriteChar(HexDigit[(n DIV shiftFactor[index]) MOD 16]
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





(* --------------------------------------------------------------------------
 * function pow10(n)
 * --------------------------------------------------------------------------
 * Returns the power of 10 for argument n
 * ----------------------------------------------------------------------- *)

PROCEDURE pow10 ( n : CARDINAL ) : CARDINAL;

BEGIN
  RETURN powerOf10[n]
END pow10;


(* --------------------------------------------------------------------------
 * function log10(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the logarithm of 10 for argument n
 * ----------------------------------------------------------------------- *)

PROCEDURE log10 ( n : CARDINAL ) : CARDINAL;

VAR
  index, approximation : CARDINAL;
  
BEGIN
  index := shr((log2(n) + 1) * 1233, 12);
  approximation := powerOf10[index];
  IF n < approximation THEN
    RETURN index - 1
  ELSE
    RETURN approximation
  END (* IF *)
END log10;


(* --------------------------------------------------------------------------
 * function maxDecimalDigits(n)
 * --------------------------------------------------------------------------
 * Returns the number of decimal digits of the largest unsigned integer that
 * can be encoded in base-2 using n number of 8-bit octets for 1 <= n <= 16.
 * ----------------------------------------------------------------------- *)

PROCEDURE maxDecimalDigits ( octets : Card1To16 ) : CARDINAL;

BEGIN
  RETURN maxDecDigits[octets]
END maxDecimalDigits;


BEGIN
  InitShiftFactorTable
END Int64IO.
