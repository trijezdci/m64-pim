(*!m2pim+mocka*) (* File ZType.mod Copyright (C) 2026 by Benjamin Kowarsch *)

(* ------------------------------------------------------------------------ *
 * MOCKA Modula-2 Compiler System, Version 2610                             *
 *                                                                          *
 * Copyright (C) 1988-2000 by                                               *
 *  GMD Gesellschaft fuer Mathematik und Datenverarbeitung,                 *
 *  Ehemalige GMD Forschungsstelle an der Uni Karlsruhe;                    *
 *  [EN] German National Research Center for Computer Science,              *
 *  Former GMD Research Lab at the University of Karlsruhe.                 *
 *                                                                          *
 * Copyright (C) 2001-2018 by                                               *
 *  Fraunhofer-Gesellschaft zur Foerderung der angewandten Forschung;       *
 *  [EN] Fraunhofer Society for the Advancement of Applied Research.        *
 *                                                                          *
 * Copyright (C) 2026 by Fraunhofer & Benjamin Kowarsch                     *
 * ------------------------------------------------------------------------ *)

IMPLEMENTATION MODULE ZType; (* 128-bit Integer Type for ConstExpr Evaluation *)

(*
TYPE ZTypeT = RECORD
  hi : LONGINT;
  lo : LONGCARD
END; (* ZTypeT *)

TYPE Status = ( Success, Underflow, Overflow, DivByZero, IllegalFormat );

VAR
  Zero, MinusOne, PlusOne, MaxCard, MaxLongCard,
  MinInt, MaxInt, MinLongInt, MaxLongInt, MinZType, MaxZType : ZTypeT;
*)

(* -------------------------------------------------------------------------
   Procedure Assign
   -------------------------------------------------------------------------
   Convert whole number literal passed in lexeme to ZType binary and pass it
   back in val.  Pass the status of the conversion back in stat.
   ------------------------------------------------------------------------- *)
PROCREDURE Assign
  ( VAR val : ZTypeT; lexeme : ARRAY OF CHAR; VAR stat : Status );
BEGIN

END Assign;

  
(* -------------------------------------------------------------------------
   Procedure Add
   -------------------------------------------------------------------------
   Add left and right, pass the result in right and the status in stat.
   ------------------------------------------------------------------------- *)
PROCEDURE Add ( left : ZTypeT; VAR right : ZTypeT; VAR stat : Status );
BEGIN

END Add;

(* -------------------------------------------------------------------------
   Procedure Sub
   -------------------------------------------------------------------------
   Subtract right from left, pass the result in right and status in stat.
   ------------------------------------------------------------------------- *)
PROCEDURE Sub ( left : ZTypeT; VAR right : ZTypeT; VAR stat : Status );
BEGIN

END Sub;

(* -------------------------------------------------------------------------
   Procedure Mul
   -------------------------------------------------------------------------
   Multiply left and right, pass the result in right, and status in stat.
   ------------------------------------------------------------------------- *)
PROCEDURE Mul ( left : ZTypeT; VAR right : ZTypeT; VAR stat : Status );
BEGIN

END Mul;

(* -------------------------------------------------------------------------
   Procedure Div
   -------------------------------------------------------------------------
   Divide left by right using truncated integer division,  pass the quotient
   in right and the status in stat.
   ------------------------------------------------------------------------- *)
PROCEDURE Div ( left : ZTypeT; VAR right : ZTypeT; VAR stat : Status );
BEGIN

Div;

(* -------------------------------------------------------------------------
   Procedure Div
   -------------------------------------------------------------------------
   Divide left by right  using truncated integer division,  pass the modulus
   in right and the status in stat.
   ------------------------------------------------------------------------- *)
PROCEDURE Mod ( left : ZTypeT; VAR right : ZTypeT; VAR stat : Status );
BEGIN

END Mod;

(* -------------------------------------------------------------------------
   Function isEq
   -------------------------------------------------------------------------
   Returns TRUE if left and right are equal, otherwise FALSE.
   ------------------------------------------------------------------------- *)
PROCEDURE isEq ( left, right : ZTypeT ) : BOOLEAN;
BEGIN
  RETURN (left.hi = right.hi) AND (left.lo = right.lo)
END isEq;

(* -------------------------------------------------------------------------
   Function isLess
   -------------------------------------------------------------------------
   Returns TRUE if left is less than right, otherwise FALSE.
   ------------------------------------------------------------------------- *)
PROCEDURE isLess ( left, right : ZTypeT) : BOOLEAN;
BEGIN
  RETURN (left.hi < right.hi)
    OR ((left.hi = right.hi) AND (left.lo < right.lo))
END isLess;

(* -------------------------------------------------------------------------
   Function isLessEq
   -------------------------------------------------------------------------
   Returns TRUE if left is equal to or less than right, otherwise FALSE.
   ------------------------------------------------------------------------- *)
PROCEDURE isLessEq ( left : ZTypeT; VAR right : ZTypeT ) : BOOLEAN;
BEGIN
  RETURN NOT (* left is greater than right *)
    ((left.hi > right.hi) OR ((left.hi = right.hi) AND (left.lo > right.lo)))
END isLessEq;

(* -------------------------------------------------------------------------
   Function toCard
   -------------------------------------------------------------------------
   Converts val to type CARDINAL and returns it.
   ------------------------------------------------------------------------- *)
PROCEDURE toCard ( val : ZTypeT ) : CARDINAL;
BEGIN

END toCard;

(* -------------------------------------------------------------------------
   Function toInt
   -------------------------------------------------------------------------
   Converts val to type INTEGER and returns it.
   ------------------------------------------------------------------------- *)
PROCEDURE toInt ( val : ZTypeT ) : INTEGER;
BEGIN

END toInt;

(* -------------------------------------------------------------------------
   Function toCard
   -------------------------------------------------------------------------
   Converts val to type CARDINAL and returns it.
   ------------------------------------------------------------------------- *)
PROCEDURE toLongCard ( val : ZTypeT ) : LONGCARD;
BEGIN

END toLongCard;

(* -------------------------------------------------------------------------
   Function toLongInt
   -------------------------------------------------------------------------
   Converts val to type LONGINT and returns it.
   ------------------------------------------------------------------------- *)
PROCEDURE toLongInt ( val : ZTypeT ) : LONGINT;
BEGIN

END toLongInt;

END ZType.