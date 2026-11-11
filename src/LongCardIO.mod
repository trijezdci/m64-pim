(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE LongCardIO;

(* Console IO library for Type LONGCARD *)


IMPORT InOut, LongCardMath;


(* --------------------------------------------------------------------------
 * Procedure:  LongCardIO.Read(n, stat)
 * --------------------------------------------------------------------------
 * Read unformatted decimal number from console and pass it in n.
 * ----------------------------------------------------------------------- *)

PROCEDURE Read ( VAR n : LONGCARD; VAR stat : Status );
CONST
  MaxDiv10 = MAX(LONGCARD) DIV 10;
  MaxMod10 = MAX(LONGCARD) MOD 10;
VAR
  ch : CHAR;
  val, digitVal : LONGCARD;
BEGIN
  val := 0;
  
  InOut.Read(ch);
  IF NOT InOut.Done() THEN
    stat := NoInput;
    RETURN
  END; (* IF *)
  
  IF ch = "+" THEN
    InOut.Read(ch)
  END; (* IF *)
  
  IF (ch < "0") OR (ch > "9") THEN
    stat := InvalidInput;
    RETURN
  END; (* IF *)
  
  WHILE InOut.Done() AND (ch >= "0") AND (ch <= "9") DO
    digitVal := VAL(LONGCARD, ORD(ch) - ORD("0"));
    
    IF (val > MaxDiv10) OR ((val = MaxDiv10) AND (digitVal > MaxMod10)) THEN
      stat := Overflow;
      RETURN
    END; (* IF *)
    
    val := val * 10 + digitVal;
    InOut.Read(ch)
  END; (* WHILE *)
  
  n := val;
  stat := Success
END Read;


(* --------------------------------------------------------------------------
 * Procedure:  LongCardIO.Write(n)
 * --------------------------------------------------------------------------
 * Write n as a decimal number unformatted to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Write ( n : LONGCARD );
VAR
  index, count : CARDINAL;
  digits : ARRAY [0..LongCardMath.MaxDecimalDigits] OF CHAR;
BEGIN
  index := 0;
  GetDigitSeq(n, digits, count);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    INC(index)
  END (* WHILE *)
END Write;


(* --------------------------------------------------------------------------
 * Procedure:  LongCardIO.WriteHex(n)
 * --------------------------------------------------------------------------
 * Write LONGCARD n as radix-16 number to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteHex ( n : LONGCARD );
CONST
  HexDigit = "0123456789ABCDEF";
VAR
  index : CARDINAL;
BEGIN
  FOR index := 0 TO 7 DO
    InOut.Write(HexDigit[(n DIV shiftFactor[index]) MOD 16])
  END (* FOR *)
END WriteHex;


(* --------------------------------------------------------------------------
 * Procedure:  LongCardIO.WriteF(fmt, n)
 * --------------------------------------------------------------------------
 * Write n formatted to console following format fmt.
 *
 * fmt | radix    | formatting       | digit grouping
 * ----+----------+------------------+---------------
 * ',' | decimal  | comma separated  | 3 digits 
 * '.' | decimal  | period separated | 3 digits
 * 'x' | radix-16 | '0x' prefixed    | 8 digits
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteF ( fmt : CHAR; n : LONGCARD );
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
 * Procedure:  LongCardIO.WriteStatus(stat)
 * --------------------------------------------------------------------------
 * Write stat to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteStatus ( stat : Status );
BEGIN 
  CASE stat OF
    Success        : InOut.WriteString("Success")
  | Overflow       : InOut.WriteString("Overflow")
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
  ( n : LONGCARD; VAR digits : ARRAY OF CHAR; VAR count : CARDINAL );
VAR
  index : CARDINAL;
  rem, digitVal : LONGCARD;
BEGIN
  IF n = 0 THEN
    digits := "0";
    count := 1;
    RETURN
  ELSIF n = 1 THEN
    digits] := "1";
    count := 1;
    RETURN
  END;
  
  rem := n;
  (* calculate digit count *)
  index := VAL(CARDINAL, LongCardMath.log10(rem)) + 1;
  digits[index] := CHR(0);
  count := index;
  
  WHILE index > 0 DO
    DEC(index);
    digitVal := rem MOD 10;
    rem := rem DIV 10;
    digits[index] := CHR(ORD("0") + VAL(CARDINAL, digitVal))
  END
END GetDigitSeq;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtDec(fmt, n)
 * --------------------------------------------------------------------------
 * Write n as decimal number to console with digit group separator fmt.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtDec ( fmt : CHAR; n : LONGCARD );
VAR
  index, weight : CARDINAL;
  digits : ARRAY [0..MaxDecimalDigits] OF CHAR;
BEGIN
  index := 0;
  GetDigitSeq(n, digits, weight);
  WHILE digits[index] # CHR(0) DO
    InOut.Write(digits[index]);
    DEC(weight);
    IF (weight MOD 3 = 0) AND (weight > 0) THEN
      InOut.Write(fmt)
    END; (* IF *)
    INC(index)
  END (* WHILE *)
END WriteFmtDec;


(* --------------------------------------------------------------------------
 * Procedure:  WriteFmtHex(n)
 * --------------------------------------------------------------------------
 * Write n as radix-16 numberw ith 0x prefix to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE WriteFmtHex ( n : LONGCARD );
BEGIN
  InOut.Write("0");
  InOut.Write("x");
  WriteHex(n)
END WriteFmtHex;


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
END LongCardIO.
