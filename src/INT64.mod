(*!m2pim*) (* Copyright (c) 2026 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE INT64;

(* 64-bit Signed Integer Type for 32-bit Host Bootstrapping *)

FROM CARD64 IMPORT
  CARD64T, SetZero AS SetZeroC64, SetMax AS SetMaxC64, FromCard AS FromCardC64,
  FromLongCard AS FromLongCardC64, FromHighLow AS FromHighLowC64,
  ToCard AS ToCardC64, ToLongCard AS ToLongCardC64, odd AS oddC64,
  eq AS eqC64, neq AS neqC64, gt AS gtC64, gteq AS gteqC64, lt AS ltC64, lteq AS lteqC64,
  Add AS AddC64, Sub AS SubC64, Mul AS MulC64, DivMod AS DivModC64,
  Shl AS ShlC64, Shr AS ShrC64, Status AS StatusC64;

CONST
  Max32Card = 0FFFFFFFFH;
  Max32Int  = 07FFFFFFFH;  (* 2147483647 *)
  Min32Int  = 080000000H;  (* -2147483648 in 32-bit two's complement *)


PROCEDURE SetZero ( VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 0
END SetZero;


PROCEDURE SetMax ( VAR res : INT64T );
BEGIN
  res.highBits := Max32Int;
  res.lowBits := Max32Card
END SetMax;


PROCEDURE SetMin ( VAR res : INT64T );
BEGIN
  res.highBits := Min32Int;
  res.lowBits := 0
END SetMin;


PROCEDURE FromInt ( i : INTEGER; VAR res : INT64T );
BEGIN
  IF i < 0 THEN
    res.highBits := -1;
    res.lowBits := 0 - VAL(LONGCARD, ABS(i))
  ELSE
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromInt;


PROCEDURE FromLongInt ( i : LONGINT; VAR res : INT64T );
BEGIN
  IF i < 0 THEN
    res.highBits := -1;
    IF i = Min32Int THEN
      res.lowBits := 080000000H
    ELSE
      res.lowBits := 0 - VAL(LONGCARD, ABS(i))
    END (* IF *)
  ELSE
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromLongInt;


PROCEDURE FromCard ( n : CARDINAL; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := VAL(LONGCARD, n)
END FromCard;


PROCEDURE FromLongCard ( n : LONGCARD; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := n
END FromLongCard;


PROCEDURE FromCard64 ( c : CARD64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF c.highBits > VAL(LONGCARD, Max32Int) THEN
    stat := Overflow;
    RETURN
  ELSE
    res.highBits := VAL(LONGINT, c.highBits);
    res.lowBits := c.lowBits;
    stat := Success
  END (* IF *)
END FromCard64;


PROCEDURE FromHighLow ( high : LONGINT; low : LONGCARD; VAR res : INT64T );
BEGIN
  res.highBits := high;
  res.lowBits := low
END FromHighLow;


PROCEDURE ToCard64 ( i : INT64T; VAR res : CARD64T; VAR stat : Status );
BEGIN
  IF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  ELSE
    res.highBits := VAL(LONGCARD, i.highBits);
    res.lowBits := i.lowBits;
    stat := Success
  END (* IF *)
END ToCard64;


PROCEDURE ToInt ( i : INT64T; VAR res : INTEGER; VAR stat : Status );
VAR
  mag : LONGCARD;
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < -1 THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits = -1 THEN
    mag := (Max32Card - i.lowBits) + 1;
    IF mag > VAL(LONGCARD, ABS(MIN(INTEGER))) THEN
      stat := Underflow;
      RETURN
    ELSE
      res := -VAL(INTEGER, mag);
      stat := Success
    END (* IF *)
  ELSE (* i.highBits = 0 *)
    IF i.lowBits > VAL(LONGCARD, MAX(INTEGER)) THEN
      stat := Overflow;
      RETURN
    ELSE
      res := VAL(INTEGER, i.lowBits);
      stat := Success
    END (* IF *)
  END (* IF *)
END ToInt;


PROCEDURE ToLongInt ( i : INT64T; VAR res : LONGINT; VAR stat : Status );
VAR
  mag : LONGCARD;
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < -1 THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits = -1 THEN
    mag := (Max32Card - i.lowBits) + 1;
    IF mag > 080000000H THEN
      stat := Underflow;
      RETURN
    ELSIF mag = 080000000H THEN
      res := Min32Int;
      stat := Success
    ELSE
      res := -VAL(LONGINT, mag);
      stat := Success
    END (* IF *)
  ELSE (* i.highBits = 0 *)
    IF i.lowBits > VAL(LONGCARD, Max32Int) THEN
      stat := Overflow;
      RETURN
    ELSE
      res := VAL(LONGINT, i.lowBits);
      stat := Success
    END (* IF *)
  END (* IF *)
END ToLongInt;


PROCEDURE ToCard ( i : INT64T; VAR res : CARDINAL; VAR stat : Status );
BEGIN
  IF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.lowBits > VAL(LONGCARD, MAX(CARDINAL)) THEN
    stat := Overflow;
    RETURN
  ELSE
    res := VAL(CARDINAL, i.lowBits);
    stat := Success
  END (* IF *)
END ToCard;


PROCEDURE ToLongCard ( i : INT64T; VAR res : LONGCARD; VAR stat : Status );
BEGIN
  IF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSE
    res := i.lowBits;
    stat := Success
  END (* IF *)
END ToLongCard;


PROCEDURE ToHighLow ( i : INT64T; VAR high : LONGINT; VAR low : LONGCARD );
BEGIN
  high := i.highBits;
  low := i.lowBits
END ToHighLow;


PROCEDURE odd ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN ODD(i.lowBits)
END odd;


PROCEDURE eq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits = right.highBits) AND (left.lowBits = right.lowBits)
END eq;


PROCEDURE neq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits # right.highBits) OR (left.lowBits # right.lowBits)
END neq;


PROCEDURE gt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  IF left.highBits > right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits < right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits > right.lowBits
  END (* IF *)
END gt;


PROCEDURE gteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  IF left.highBits > right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits < right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits >= right.lowBits
  END (* IF *)
END gteq;


PROCEDURE lt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  IF left.highBits < right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits > right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits < right.lowBits
  END (* IF *)
END lt;


PROCEDURE lteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  IF left.highBits < right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits > right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits <= right.lowBits
  END (* IF *)
END lteq;


PROCEDURE Abs ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF i.highBits >= 0 THEN
    res := i;
    stat := Success
  ELSIF (i.highBits = Min32Int) AND (i.lowBits = 0) THEN
    stat := Overflow;
    res := i
  ELSE
    Neg(i, res, stat)
  END (* IF *)
END Abs;


PROCEDURE Neg ( i : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  invLow : LONGCARD;
  invHigh : LONGINT;
  carry : LONGCARD;
BEGIN
  IF (i.highBits = Min32Int) AND (i.lowBits = 0) THEN
    stat := Overflow;
    res := i;
    RETURN
  END; (* IF *)

  invLow := (Max32Card - i.lowBits) + 1;
  IF invLow = 0 THEN
    carry := 1
  ELSE
    carry := 0
  END; (* IF *)

  invHigh := -1 - i.highBits + VAL(LONGINT, carry);
  res.highBits := invHigh;
  res.lowBits := invLow;
  stat := Success
END Neg;


PROCEDURE Add ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  sumLow : LONGCARD;
  carry : LONGCARD;
  sumHigh : LONGINT;
BEGIN
  sumLow := left.lowBits + right.lowBits;
  IF sumLow < left.lowBits THEN
    carry := 1
  ELSE
    carry := 0
  END; (* IF *)

  (* Check signed overflow on high bits *)
  IF (left.highBits > 0) AND (right.highBits > 0) THEN
    IF left.highBits > (Max32Int - right.highBits - VAL(LONGINT, carry)) THEN
      stat := Overflow;
      res.highBits := 0;
      res.lowBits := 0;
      RETURN
    END (* IF *)
  ELSIF (left.highBits < 0) AND (right.highBits < 0) THEN
    IF left.highBits < (Min32Int - right.highBits - VAL(LONGINT, carry)) THEN
      stat := Underflow;
      res.highBits := 0;
      res.lowBits := 0;
      RETURN
    END (* IF *)
  END; (* IF *)

  sumHigh := left.highBits + right.highBits + VAL(LONGINT, carry);
  res.highBits := sumHigh;
  res.lowBits := sumLow;
  stat := Success
END Add;


PROCEDURE Sub ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  negRight : INT64T;
BEGIN
  IF (right.highBits = Min32Int) AND (right.lowBits = 0) THEN
    IF left.highBits < 0 THEN
      stat := Success;
      negRight.highBits := Max32Int;
      negRight.lowBits := 0;
      Add(left, negRight, res, stat);
      res.lowBits := res.lowBits + 0; (* Min32Int magnitude adjustment *)
      RETURN
    ELSE
      stat := Overflow;
      RETURN
    END (* IF *)
  END; (* IF *)

  Neg(right, negRight, stat);
  IF stat # Success THEN
    RETURN
  END; (* IF *)

  Add(left, negRight, res, stat)
END Sub;


PROCEDURE Mul ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resIsNeg : BOOLEAN;
  absLeft, absRight : INT64T;
  cLeft, cRight, cProd : CARD64T;
  cStat : StatusC64;
BEGIN
  IF (left.highBits = 0) AND (left.lowBits = 0) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)
  IF (right.highBits = 0) AND (right.lowBits = 0) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)

  resIsNeg := (left.highBits < 0) # (right.highBits < 0);

  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;

  cLeft.highBits := VAL(LONGCARD, absLeft.highBits);
  cLeft.lowBits := absLeft.lowBits;
  cRight.highBits := VAL(LONGCARD, absRight.highBits);
  cRight.lowBits := absRight.lowBits;

  MulC64(cLeft, cRight, cProd, cStat);
  IF cStat # Success THEN
    IF resIsNeg THEN stat := Underflow ELSE stat := Overflow END;
    RETURN
  END; (* IF *)

  IF resIsNeg THEN
    (* Max negative magnitude is 2^63 (Min32Int in high, 0 in low) *)
    IF (cProd.highBits > 080000000H) OR ((cProd.highBits = 080000000H) AND (cProd.lowBits # 0)) THEN
      stat := Underflow;
      RETURN
    ELSIF (cProd.highBits = 080000000H) AND (cProd.lowBits = 0) THEN
      res.highBits := Min32Int;
      res.lowBits := 0;
      stat := Success;
      RETURN
    END; (* IF *)
    res.highBits := VAL(LONGINT, cProd.highBits);
    res.lowBits := cProd.lowBits;
    Neg(res, res, stat)
  ELSE
    IF cProd.highBits > VAL(LONGCARD, Max32Int) THEN
      stat := Overflow;
      RETURN
    END; (* IF *)
    res.highBits := VAL(LONGINT, cProd.highBits);
    res.lowBits := cProd.lowBits;
    stat := Success
  END (* IF *)
END Mul;


PROCEDURE Div ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resIsNeg : BOOLEAN;
  absLeft, absRight : INT64T;
  cLeft, cRight, cQuot, cRem : CARD64T;
  cStat : StatusC64;
BEGIN
  IF (right.highBits = 0) AND (right.lowBits = 0) THEN
    stat := DivByZero;
    SetZero(res);
    RETURN
  END; (* IF *)

  (* Check MinInt / -1 *)
  IF (left.highBits = Min32Int) AND (left.lowBits = 0) AND
     (right.highBits = -1) AND (right.lowBits = Max32Card) THEN
    stat := Overflow;
    SetZero(res);
    RETURN
  END; (* IF *)

  resIsNeg := (left.highBits < 0) # (right.highBits < 0);

  Abs(left, absLeft, stat);
  IF stat # Success THEN
    (* left is MinInt *)
    cLeft.highBits := 080000000H;
    cLeft.lowBits := 0
  ELSE
    cLeft.highBits := VAL(LONGCARD, absLeft.highBits);
    cLeft.lowBits := absLeft.lowBits
  END; (* IF *)

  Abs(right, absRight, stat);
  IF stat # Success THEN
    (* right is MinInt *)
    cRight.highBits := 080000000H;
    cRight.lowBits := 0
  ELSE
    cRight.highBits := VAL(LONGCARD, absRight.highBits);
    cRight.lowBits := absRight.lowBits
  END; (* IF *)

  DivModC64(cLeft, cRight, cQuot, cRem, cStat);
  IF cStat # Success THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)

  res.highBits := VAL(LONGINT, cQuot.highBits);
  res.lowBits := cQuot.lowBits;

  IF resIsNeg THEN
    Neg(res, res, stat)
  ELSE
    stat := Success
  END (* IF *)
END Div;


PROCEDURE Mod ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  leftIsNeg : BOOLEAN;
  absLeft, absRight : INT64T;
  cLeft, cRight, cQuot, cRem : CARD64T;
  cStat : StatusC64;
BEGIN
  IF (right.highBits = 0) AND (right.lowBits = 0) THEN
    stat := DivByZero;
    SetZero(res);
    RETURN
  END; (* IF *)

  leftIsNeg := left.highBits < 0;

  Abs(left, absLeft, stat);
  IF stat # Success THEN
    cLeft.highBits := 080000000H;
    cLeft.lowBits := 0
  ELSE
    cLeft.highBits := VAL(LONGCARD, absLeft.highBits);
    cLeft.lowBits := absLeft.lowBits
  END; (* IF *)

  Abs(right, absRight, stat);
  IF stat # Success THEN
    cRight.highBits := 080000000H;
    cRight.lowBits := 0
  ELSE
    cRight.highBits := VAL(LONGCARD, absRight.highBits);
    cRight.lowBits := absRight.lowBits
  END; (* IF *)

  DivModC64(cLeft, cRight, cQuot, cRem, cStat);
  IF cStat # Success THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)

  res.highBits := VAL(LONGINT, cRem.highBits);
  res.lowBits := cRem.lowBits;

  IF leftIsNeg THEN
    Neg(res, res, stat)
  ELSE
    stat := Success
  END (* IF *)
END Mod;


PROCEDURE Shl ( i : INT64T; shift : CARDINAL; VAR res : INT64T; VAR stat : Status );
VAR
  cIn, cOut : CARD64T;
  cStat : StatusC64;
  origSign : BOOLEAN;
BEGIN
  origSign := i.highBits < 0;
  cIn.highBits := VAL(LONGCARD, i.highBits);
  cIn.lowBits := i.lowBits;
  ShlC64(cIn, shift, cOut, cStat);
  res.highBits := VAL(LONGINT, cOut.highBits);
  res.lowBits := cOut.lowBits;
  IF (res.highBits < 0) # origSign THEN
    stat := Overflow
  ELSE
    stat := Success
  END (* IF *)
END Shl;


PROCEDURE Shr ( i : INT64T; shift : CARDINAL; VAR res : INT64T );
VAR
  cIn, cOut : CARD64T;
  s : CARDINAL;
  powS : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  END; (* IF *)

  IF i.highBits >= 0 THEN
    cIn.highBits := VAL(LONGCARD, i.highBits);
    cIn.lowBits := i.lowBits;
    ShrC64(cIn, shift, cOut);
    res.highBits := VAL(LONGINT, cOut.highBits);
    res.lowBits := cOut.lowBits
  ELSE
    (* Arithmetic Shift Right: replicate sign bits (1s) *)
    IF shift >= 64 THEN
      res.highBits := -1;
      res.lowBits := Max32Card;
      RETURN
    ELSIF shift >= 32 THEN
      s := shift - 32;
      powS := Pow2(s);
      res.highBits := -1;
      res.lowBits := VAL(LONGCARD, i.highBits DIV VAL(LONGINT, powS))
    ELSE
      s := shift;
      powS := Pow2(s);
      cIn.highBits := VAL(LONGCARD, i.highBits);
      cIn.lowBits := i.lowBits;
      ShrC64(cIn, shift, cOut);
      (* Fill in upper s bits with 1s *)
      res.highBits := VAL(LONGINT, cOut.highBits + ((Max32Card - (Max32Card DIV powS)) * (Max32Card DIV (Max32Card DIV powS + 1) + 1)));
      res.lowBits := cOut.lowBits
    END (* IF *)
  END (* IF *)
END Shr;


PROCEDURE Pow2 ( p : CARDINAL ) : LONGCARD;
VAR
  res : LONGCARD;
  i : CARDINAL;
BEGIN
  IF p = 0 THEN
    RETURN 1
  END; (* IF *)
  res := 1;
  FOR i := 1 TO p DO
    res := res * 2
  END; (* FOR *)
  RETURN res
END Pow2;


END INT64.
