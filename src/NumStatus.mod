(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE NumStatus;

(* Status Type for Numeric Libraries *)

FROM SYSTEM IMPORT ADR;


(* ---------------------------------------------------------------------------
 * Status Identifier String Table
 * ------------------------------------------------------------------------ *)

TYPE IdentStr = ARRAY [0..MaxIdentLen] OF CHAR;

TYPE IdentStrTable = ARRAY [MIN(Status)..MAX(Status)] OF IdentStr;

VAR identStr = IdentStrTable;


(* --------------------------------------------------------------------------
 * Procedure:  NumStatus.identString(stat)
 * --------------------------------------------------------------------------
 * Returns a pointer to the identifier string for status stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE identString ( stat : Status ) : IdentString;
BEGIN
  RETURN IdentString(ADR(identStr[stat]))
END identString;


(* Module initialisation *)

BEGIN (* NumStatus *)
  identStr[Success]        := "Success";
  identStr[Underflow]      := "Underflow";
  identStr[Overflow]       := "Overflow";
  identStr[DivByZero]      := "DivByZero";
  identStr[StrLenTooShort] := "StrLenTooShort";
  identStr[NoInput]        := "NoInput";
  identStr[InvalidInput]   := "InvalidInput"
END NumStatus.

