(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE LongCardMath;


(* --------------------------------------------------------------------------
 * Function:  LongCardMath.log2(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the binary logarithm of n.
 * ----------------------------------------------------------------------- *)

PROCEDURE log2 ( n : LONGCARD ) : LONGCARD;
VAR
  res : LONGCARD;
BEGIN
  res := 0;

  IF n >= 010000H THEN
    n := n DIV 010000H;
    res := res + 16
  END; (* IF *)

  IF n >= 0100H THEN
    n := n DIV 0100H;
    res := res + 8
  END; (* IF *)

  IF n >= 010H THEN
    n := n DIV 010H;
    res := res + 4
  END; (* IF *)

  IF n >= 04H THEN
    n := n DIV 04H;
    res := res + 2
  END; (* IF *)

  IF n >= 02H THEN
    res := res + 1
  END; (* IF *)

  RETURN res
END log2;


(* --------------------------------------------------------------------------
 * Function:  LongCardMath.pow2(n)
 * --------------------------------------------------------------------------
 * Returns the n-th power of 2.
 * ----------------------------------------------------------------------- *)

PROCEDURE pow2 ( n : BitIndex ) : LONGCARD;
  RETURN powerOf2[n]
END pow2;


(* --------------------------------------------------------------------------
 * Function:  LongCardMath.log10(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the decimal logarithm of n.
 * ----------------------------------------------------------------------- *)

PROCEDURE log10 ( n : LONGCARD ) : LONGCARD;
VAR
  approx : LONGCARD;
BEGIN
  (* approximation = (log2(n) * 77) / 256 *)
  approx := (log2(n) * 77) DIV 256;
  IF n >= powerOf10[approx+1] THEN
    RETURN approx + 1
  ELSE
    RETURN approx
  END (* IF *)
END log10;


(* --------------------------------------------------------------------------
 * Function:  LongCardMath.pow10(n)
 * --------------------------------------------------------------------------
 * Returns the n-th power of 10.
 * ----------------------------------------------------------------------- *)

PROCEDURE pow10 ( n : DigitRange ) : LONGCARD;
BEGIN
  RETURN powerOf10[n]
END pow10;


(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF LONGCARD;


(* --------------------------------------------------------------------------
 * procedure InitPow2Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 2.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow2Table;
VAR
  index : BitIndex;
BEGIN
  powerOf2[0] := 1;
  FOR index := 1 TO BitIndex DO
    powerOf2[index] := powerOf2[index-1] * 2
  END (* FOR *)
END InitPow2Table;


(* --------------------------------------------------------------------------
 * Data table for powers of 10
 * ----------------------------------------------------------------------- *)

VAR
  powerOf10 : ARRAY [0..MaxDecimalDigits] OF LONGCARD;


(* --------------------------------------------------------------------------
 * procedure InitPow10Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 10.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow10Table;
VAR
  index : DigitRange;
BEGIN
  powerOf10[0] := 1;
  FOR index := 1 TO MaxDecimalDigits DO
    powerOf10[index] := powerOf10[index-1] * 10
  END (* FOR *)
END InitPow10Table;


(* Module initialisation *)

BEGIN
  (* ASSERT MaxDecimalDigits matches Bitwidth *)
  IF (((Bitwidth-1) * 77) DIV 256) >= MaxDecimalDigits THEN
    HALT
  END;
  
  (* initialise tables *)
  InitPow2Table;
  InitPow10Table
END LongCardMath.
