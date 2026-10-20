(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE INT64;

FROM CARD64 IMPORT CARD64T;

(* 64-bit Integer Type *)


(*
TYPE INT64T = RECORD
  highBits : LONGINT;
  lowBits : LONGCARD
END; (* INT64T *)

TYPE Status = ( Success, Underflow, Overflow, DivByZero );
*)


(* --------------------------------------------------------------------------
 * Procedure:  INT64.SetZero(res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of zero in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetZero ( VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 0
END SetZero;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.SetMax(res)
 * --------------------------------------------------------------------------
 * Passes the largest value of type INT64T in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMax ( VAR res : INT64T );
BEGIN
  res.highBits := MAX(LONGINT); (* 0x7FFFFFFF:FFFFFFFF *)
  res.lowBits := MAX(LONGCARD)  (* 0xFFFFFFFFFFFFFFFF *)
END SetMax;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.SetMin(res)
 * --------------------------------------------------------------------------
 * Passes the smallest value of type INT64T in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMin ( VAR res : INT64T );
BEGIN
  res.highBits := MIN(LONGINT); (* 0x80000000:00000000 *)
  res.lowBits := 0
END SetMin;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.FromCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of CARDINAL n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromCard ( n : CARDINAL; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := VAL(LONGCARD, n)
END FromCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.FromLongCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of LONGCARD n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongCard ( n : LONGCARD; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := n
END FromLongCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.FromCard64(n, res, stat)
 * --------------------------------------------------------------------------
 * Converts unsigned CARD64T n to signed INT64T res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromCard64 ( n : CARD64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF n.highBits > VAL(LONGCARD, MAX(LONGINT)) THEN
    stat := Overflow;
    RETURN
  END;
  res.highBits := VAL(LONGINT, n.highBits);
  res.lowBits := n.lowBits;
  stat := Success
END FromCard64;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.FromInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of INTEGER i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromInt ( i : INTEGER; VAR res : INT64T );
BEGIN
  IF i < 0 THEN
    res.highBits := (-1); (* sign extension *)
    res.lowBits := MAX(LONGCARD) - VAL(LONGCARD, -(i + 1))
  ELSE (* i >= 0 *)
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.FromLongInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of LONGINT i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongInt ( i : LONGINT;  VAR res : INT64T );
BEGIN
  IF i < 0 THEN
    res.highBits := (-1); (* sign extension *)
    res.lowBits := MAX(LONGCARD) - VAL(LONGCARD, -(i + 1))
  ELSE (* i >= 0 *)
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromLongInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.ToCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the CARDINAL value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToCard ( i : INT64T; VAR res : CARDINAL; VAR stat : Status );
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  ELSE (* i.highBits = 0 *)
    IF i.lowBits > VAL(LONGCARD, MAX(CARDINAL)) THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(CARDINAL, i.lowBits);
      stat := Success
    END (* IF *)
  END (* IF *)
END ToCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.ToLongCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGCARD value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongCard ( i : INT64T; VAR res : LONGCARD; VAR stat : Status );
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  ELSE (* in range *)
    res := i.lowBits;
    stat := Success
  END (* IF *)
END ToLongCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.ToCard64(i, res, stat)
 * --------------------------------------------------------------------------
 * Converts signed INT64T i to unsigned CARD64T res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToCard64 ( i : INT64T; VAR res : CARD64T; VAR stat : Status );
BEGIN
  IF i.highBits < 0 THEN
    stat := Underflow;
    RETURN
  END;
  res.highBits := VAL(LONGCARD, i.highBits);
  res.lowBits := i.lowBits;
  stat := Success
END ToCard64;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.ToInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the INTEGER value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToInt ( i : INT64T; VAR res : INTEGER; VAR stat : Status );
VAR
  magnitude : LONGCARD;
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < (-1) THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits = (-1) THEN
    magnitude := (MAX(LONGCARD) - i.lowBits) + 1;
    IF i.lowBits = 080000000H THEN
      res := MIN(INTEGER);
      stat := Success;
      RETURN
    ELSIF magnitude > VAL(LONGCARD, MAX(INTEGER)) THEN
      stat := Underflow;
      RETURN
    ELSE (* in range *)
      res := -VAL(INTEGER, magnitude);
      stat := Success
    END (* IF *)
  ELSE (* i.highBits = 0 *)
    IF i.lowBits > VAL(LONGCARD, MAX(INTEGER)) THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(INTEGER, i.lowBits);
      stat := Success
    END (* IF *)
  END (* IF *)
END ToInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.ToLongInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGINT value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongInt ( i : INT64T; VAR res : LONGINT; VAR stat : Status );
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < (-1) THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits = (-1) THEN
    IF i.lowBits < (* MIN(LONGINT) *) 080000000H THEN
      stat := Underflow;
      RETURN
    ELSIF i.lowBits = (* MIN(LONGINT) *) 080000000H THEN
      res := MIN(LONGINT);
      stat := Success
    ELSE (* in range *)
      (* res := MIN(LONGINT) + i.lowBits - MIN(LONGINT) => res := i.lowBits *)
      res := MIN(LONGINT) + VAL(LONGINT, i.lowBits - 080000000H);
      stat := Success
    END (* IF *)
  ELSE (* i.highBits = 0 *)
    IF i.lowBits > VAL(LONGCARD, MAX(LONGINT)) THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(LONGINT, i.lowBits);
      stat := Success
    END (* IF *)
  END (* IF *)
END ToLongInt;

(* --------------------------------------------------------------------------
 * Function:  INT64.odd(i)
 * --------------------------------------------------------------------------
 * Returns TRUE if i is odd, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE odd ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN ODD(i.lowBits)
END odd;


(* --------------------------------------------------------------------------
 * function:  INT64.eq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left = right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE eq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits = right.highBits) AND (left.lowBits = right.lowBits)
END eq;


(* --------------------------------------------------------------------------
 * Function:  INT64.neq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left # right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE neq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits # right.highBits) OR (left.lowBits # right.lowBits)
END neq;


(* --------------------------------------------------------------------------
 * Function:  INT64.gt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left > right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits > right.lowBits))
END gt;


(* --------------------------------------------------------------------------
 * Function:  INT64.gteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left >= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits >= right.lowBits))
END gteq;


(* --------------------------------------------------------------------------
 * Function:  INT64.lt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left < right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits < right.lowBits))
END lt;


(* --------------------------------------------------------------------------
 * Function:  INT64.lteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left <= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits <= right.lowBits))
END lteq;


(* --------------------------------------------------------------------------
 * Function:  INT64.Abs(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the absolute value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Abs ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF i.highBits >= 0 THEN
    res := i;
    stat := Success;
    RETURN
  ELSIF (i.highBits = MIN(LONGINT)) AND (i.lowBits = 0) THEN
    stat := Overflow;
    RETURN
  ELSE (* MIN(INT64T) < i < 0 *)
    res.lowBits := 0 - i.lowBits; (* complement *)
    IF i.lowBits = 0 THEN
      res.highBits := -i.highBits
    ELSE
      res.highBits := -i.highBits - 1
    END (* IF *)
  END; (* IF *)
  stat := Success
END Abs;


(* --------------------------------------------------------------------------
 * Function:  INT64.Neg(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sign inversed value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Neg ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF (i.highBits = MIN(LONGINT)) AND (i.lowBits = 0) THEN
    stat := Overflow; (* MIN(INT64T) has no positive counterpart *)
    RETURN
  ELSE
    res.lowBits := 0 - i.lowBits; (* complement *)
    IF i.lowBits = 0 THEN
      res.highBits := -i.highBits
    ELSE
      res.highBits := -i.highBits - 1
    END (* IF *)
  END; (* IF *)
  stat := Success
END Neg;

(* --------------------------------------------------------------------------
 * Procedure:  INT64.Add(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sum left + right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Add ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resLow  : LONGCARD;
  resHigh : LONGINT;
  lowCarry : LONGCARD;
BEGIN
  (* compute sum of lower bits and carry *)
  IF sumOverflowsLC(left.lowBits, right.lowBits) THEN
    lowCarry := 1;
    resLow := left.lowBits - (MAX(LONGCARD) - right.lowBits) - 1
  ELSE
    lowCarry := 0;
    resLow := left.lowBits + right.lowBits
  END;
  
  (* both operands non-negative *)
  IF (left.highBits >= 0) AND (right.highBits >= 0) THEN
    IF sumOverflowsLI(left.highBits, right.highBits, lowCarry) THEN
      stat := Overflow;
      RETURN
    END (* IF *);
    resHigh := left.highBits + right.highBits + VAL(LONGINT, lowCarry);

  (* mixed non-negative and negative operands *)
  ELSIF ((left.highBits >= 0) AND (right.highBits < 0))
    OR ((left.highBits < 0) AND (right.highBits >= 0)) THEN
    resHigh := left.highBits + right.highBits + VAL(LONGINT, lowCarry);

  (* both operands negative *)
  ELSE (* (left.highBits < 0) AND (right.highBits < 0) *)
    IF sumUnderflowsLI(left.highBits, right.highBits, lowCarry) THEN
      stat := Underflow;
      RETURN
    END (* IF *);
    resHigh := left.highBits + right.highBits + VAL(LONGINT, lowCarry);
  END; (* IF *)

  (* pass result *)
  res.lowBits := resLow;
  res.highBits := resHigh;
  stat := Success
END Add;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Sub(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the difference left - right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Sub ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resLow  : LONGCARD;
  resHigh : LONGINT;
  lowBorrow : LONGCARD;
BEGIN
  (* compute difference of lower bits and borrow *)
  IF diffBorrowsLC(left.lowBits, right.lowBits) THEN
    lowBorrow := 1;
    resLow := MAX(LONGCARD) - (right.lowBits - left.lowBits) + 1
  ELSE
    lowBorrow := 0;
    resLow := left.lowBits - right.lowBits
  END;

  (* both operands non-negative *)
  IF (left.highBits >= 0) AND (right.highBits >= 0) THEN
    (* Subtracting like signs is mathematically guaranteed to fit within 64 bits *)
    resHigh := left.highBits - right.highBits - VAL(LONGINT, lowBorrow);

  (* left operand non-negative, right operand negative *)
  ELSIF (left.highBits >= 0) AND (right.highBits < 0) THEN
    IF diffOverflowsLI(left.highBits, right.highBits, lowBorrow) THEN
      stat := Overflow;
      RETURN
    END;
    resHigh := left.highBits - right.highBits - VAL(LONGINT, lowBorrow);

  (* left operand negative, right operand non-negative *)
  ELSIF (left.highBits < 0) AND (right.highBits >= 0) THEN
    IF diffUnderflowsLI(left.highBits, right.highBits, lowBorrow) THEN
      stat := Underflow;
      RETURN
    END;
    resHigh := left.highBits - right.highBits - VAL(LONGINT, lowBorrow);

  (* both operands negative *)
  ELSE (* (left.highBits < 0) AND (right.highBits < 0) *)
    resHigh := left.highBits - right.highBits - VAL(LONGINT, lowBorrow);
  END; (* IF *)

  (* pass result *)
  res.lowBits := resLow;
  res.highBits := resHigh;
  stat := Success
END Sub;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Mul(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the product left * right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mul ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
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
  LongMul(left, right, res, stat)
END Mul;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resIsNeg : BOOLEAN;
  absLeft, absRight, quot, rem : INT64T;
BEGIN
  IF (right.highBits = 0) AND (right.lowBits = 0) THEN
    stat := DivByZero;
    SetZero(res);
    RETURN
  END; (* IF *)

  resIsNeg := (left.highBits < 0) # (right.highBits < 0);
  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;

  DivMod64(absLeft, absRight, quot, rem, stat);
  IF stat # Success THEN RETURN END;

  IF resIsNeg THEN
    Neg(quot, res, stat)
  ELSE
    res := quot;
    stat := Success
  END (* IF *)
END Div;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division modulus left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  leftIsNeg : BOOLEAN;
  absLeft, absRight, quot, rem : INT64T;
BEGIN
  IF (right.highBits = 0) AND (right.lowBits = 0) THEN
    stat := DivByZero;
    SetZero(res);
    RETURN
  END; (* IF *)

  leftIsNeg := left.highBits < 0;
  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;

  DivMod64(absLeft, absRight, quot, rem, stat);
  IF stat # Success THEN RETURN END;

  IF leftIsNeg THEN
    Neg(rem, res, stat)
  ELSE
    res := rem;
    stat := Success
  END (* IF *)
END Mod;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Shl(i, shift, res, stat)
 * --------------------------------------------------------------------------
 * Shifts i left by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shl ( i : INT64T; shift : CARDINAL; VAR res : INT64T; VAR stat : Status );
VAR
  s : CARDINAL;
  carryBits : LONGCARD;
  powS, powInv : LONGCARD;
  highBits : LONGCARD;
  isNegative : BOOLEAN;
BEGIN
  isNegative := i.highBits < 0;
  IF shift = 0 THEN
    res := i;
    stat := Success;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    res.lowBits := 0;
    IF (i.highBits # 0) OR (i.lowBits # 0) THEN
      stat := Overflow
    ELSE
      stat := Success
    END; (* IF *)
    RETURN
  ELSIF shift >= 32 THEN
    s := shift - 32;
    IF i.highBits # 0 THEN
      stat := Overflow
    ELSE
      stat := Success
    END; (* IF *)
    powS := Pow2(s);
    res.highBits := VAL(LONGINT, i.lowBits * powS);
    res.lowBits := 0
  ELSE (* 1 <= shift < 32 *)
    s := shift;
    powS := Pow2(s);
    powInv := Pow2(32 - s);
    carryBits := i.lowBits DIV powInv;
    highBits := VAL(LONGCARD, i.highBits) * powS + carryBits;
    res.highBits := VAL(LONGINT, highBits);
    res.lowBits := i.lowBits * powS
  END; (* IF *)
  IF (res.highBits < 0) # isNegative THEN
    stat := Overflow
  ELSE
    stat := Success
  END (* IF *)
END Shl;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Shr(i, shift, res)
 * --------------------------------------------------------------------------
 * Arithmetic shift right of i by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE AShr ( i : INT64T; shift : CARDINAL; VAR res : INT64T );
VAR
  s : CARDINAL;
  carryBits : LONGCARD;
  powS, powInv : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 64 THEN
    IF i.highBits < 0 THEN
      res.highBits := -1;
      res.lowBits := MAX(LONGCARD)
    ELSE
      res.highBits := 0;
      res.lowBits := 0
    END; (* IF *)
    RETURN
  ELSIF shift >= 32 THEN
    s := shift - 32;
    powS := Pow2(s);
    IF i.highBits < 0 THEN
      res.highBits := -1;
      IF s = 31 THEN
        res.lowBits := MAX(LONGCARD)
      ELSE
        res.lowBits := VAL(LONGCARD, i.highBits DIV VAL(LONGINT, powS))
      END
    ELSE
      res.highBits := 0;
      res.lowBits := VAL(LONGCARD, i.highBits) DIV powS
    END (* IF *)
  ELSE (* 1 <= shift < 32 *)
    s := shift;
    powS := Pow2(s);
    powInv := Pow2(32 - s);
    carryBits := (VAL(LONGCARD, i.highBits) MOD powS) * powInv;
    IF s = 31 THEN
      IF i.highBits < 0 THEN
        res.highBits := -1
      ELSE
        res.highBits := 0
      END
    ELSE
      res.highBits := i.highBits DIV VAL(LONGINT, powS)
    END;
    res.lowBits := (i.lowBits DIV powS) + carryBits
  END (* IF *)
END AShr;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Function:  sumOverflowsLC(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if the sum of n and m would overflow LONGCARD, else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE sumOverflowsLC ( n, m : LONGCARD ) : BOOLEAN;
BEGIN
  RETURN n > (MAX(LONGCARD) - m)
END sumOverflowsLC;


(* --------------------------------------------------------------------------
 * Function:  sumOverflowsLI(i, j, carry)
 * --------------------------------------------------------------------------
 * Returns TRUE if i+j+carry would overflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE sumOverflowsLI ( i, j : LONGINT; carry : LONGCARD ) : BOOLEAN;
VAR
  c : LONGINT;
BEGIN
  IF (i > 0) AND (j > 0) THEN
    c := VAL(LONGINT, carry);
    (* test i+c > MAX(LONGINT) *)
    IF (i > (MAX(LONGINT) - c)) THEN
      RETURN TRUE
    ELSE (* test i+j+c > MAX(LONGINT) *)
      RETURN (i + c > (MAX(LONGINT) - j))
    END (* IF *)
  ELSE (* (i <= 0) OR (j <= 0) *)
    RETURN FALSE
  END (* IF *)
END sumOverflowsLI;


(* --------------------------------------------------------------------------
 * Function:  sumUnderflowsLI(i, j, carry)
 * --------------------------------------------------------------------------
 * Returns TRUE if i+j+carry would underflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE sumUnderflowsLI ( i, j : LONGINT; carry : LONGCARD ) : BOOLEAN;
VAR
  c : LONGINT;
BEGIN
  IF (i < 0) AND (j < 0) THEN
    c := VAL(LONGINT, carry);
    (* test i+j+c < MIN(LONGINT) *)
    RETURN (i + c) < (MIN(LONGINT) - j)
  ELSE (* (i >= 0) OR (j >= 0) *)
    RETURN FALSE
  END (* IF *)
END sumUnderflowsLI;


(* --------------------------------------------------------------------------
 * Function:  diffBorrowsLC(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if n-m would underflow LONGCARD, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE diffBorrowsLC ( n, m : LONGCARD ) : BOOLEAN;
BEGIN
  RETURN n < m
END diffBorrowsLC;


(* --------------------------------------------------------------------------
 * Function:  diffOverflowsLI(i, j, borrow)
 * --------------------------------------------------------------------------
 * Returns TRUE if i-j-borrow would overflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE diffOverflowsLI ( i, j : LONGINT; borrow : LONGCARD ) : BOOLEAN;
VAR
  b : LONGINT;
BEGIN
  IF (i >= 0) AND (j < 0) THEN
    b := VAL(LONGINT, borrow);
    IF j = MIN(LONGINT) THEN
      IF (i = 0) AND (b = 1) THEN
        RETURN FALSE (* 0 - MIN(LONGINT) - 1 = MAX(LONGINT) *)
      ELSE
        RETURN TRUE
      END (* IF *)
    END; (* IF *)
    (* test i-j- b > MAX(LONGINT) *)
    RETURN i > (MAX(LONGINT) + j + b)
  ELSE (* (i < 0) AND (j > 0) *)
    RETURN FALSE
  END (* IF *)
END diffOverflowsLI;


(* --------------------------------------------------------------------------
 * Function:  diffUnderflowsLI(i, j, borrow)
 * --------------------------------------------------------------------------
 * Returns TRUE if i-j-borrow would underflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE diffUnderflowsLI ( i, j : LONGINT; borrow : LONGCARD ) : BOOLEAN;
VAR
  b : LONGINT;
BEGIN
  IF (i < 0) AND (j >= 0) THEN
    b := VAL(LONGINT, borrow);
    (* test i-j-b < MIN(LONGINT) *)
    RETURN i < (MIN(LONGINT) + j + b)
  ELSE (* (i >= 0) OR (j < 0) *)
    RETURN FALSE
  END (* IF *)
END diffUnderflowsLI;


(* --------------------------------------------------------------------------
 * Function:  prodOverflowsLC(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if n * m would overflow LONGCARD, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE prodOverflowsLC ( n, m : LONGCARD ) : BOOLEAN;
BEGIN
  IF (n = 0) OR (m = 0) THEN
    RETURN FALSE
  END;
  (* test n * m > MAX(LONGCARD) *)
  RETURN n > (MAX(LONGCARD) DIV m)
END prodOverflowsLC;


(* --------------------------------------------------------------------------
 * Function:  prodOverflowsLI(i, j)
 * --------------------------------------------------------------------------
 * Returns TRUE if i * j would overflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE prodOverflowsLI ( i, j : LONGINT ) : BOOLEAN;
VAR
  absI, absJ : LONGINT;
BEGIN
  (* both operands have the same sign *)
  IF ((i > 0) AND (j > 0)) OR ((i < 0) AND (j < 0)) THEN
    IF (i = MIN(LONGINT)) OR (j = MIN(LONGINT)) THEN
      RETURN TRUE
    ELSE (* i # MIN(LONGINT) AND (j # MIN(LONGINE)) *)
      IF i < 0 THEN absI := -i ELSE absI := i END;
      IF j < 0 THEN absJ := -j ELSE absJ := j END;
      RETURN absI > (MAX(LONGINT) DIV absJ)
    END (* IF *)
  ELSE (* operands have different signs *)
    RETURN FALSE
  END (* IF *)
END prodOverflowsLI;


(* --------------------------------------------------------------------------
 * Function:  prodUnderflowsLI(i, j)
 * --------------------------------------------------------------------------
 * Returns TRUE if i * j would underflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE prodUnderflowsLI ( i, j : LONGINT ) : BOOLEAN;
VAR
  absI, absJ : LONGINT;
BEGIN
  (* both operands have the same sign *)
  IF ((i > 0) AND (j < 0)) OR ((i < 0) AND (j > 0)) THEN
    IF i = MIN(LONGINT) THEN
      RETURN j # 1
    ELSIF j = MIN(LONGINT) THEN
      RETURN i # 1
    END; (* IF *)
    IF i < 0 THEN absI := -i ELSE absI := i END;
    IF j < 0 THEN absJ := -j ELSE absJ := j END;
    (* test absI * absJ > MAX(LONGINT) + 1 *)
    IF absI > (MAX(LONGINT) DIV absJ) THEN
      IF (absI = (MAX(LONGINT) DIV absJ) + 1)
        AND (MAX(LONGINT) MOD absJ = absJ - 1) THEN
        RETURN FALSE (* 2^63 *)
      ELSE
        RETURN TRUE
      END
    ELSE
      RETURN FALSE
    END (* IF *)
  ELSE
    RETURN FALSE
  END (* IF *)
END prodUnderflowsLI;


(* --------------------------------------------------------------------------
 * Procedure:  LongMul(i, j, res, stat)
 * --------------------------------------------------------------------------
 * Returns the long multiplication product i * j in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE LongMul ( i, j : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  resIsNegative : BOOLEAN;
  absI, absJ, prod : INT64T;
  tempStat : Status;
BEGIN
  resIsNegative := (i.highBits < 0) # (j.highBits < 0);

  Abs(i, absI, stat);
  IF stat # Success THEN RETURN END;

  Abs(j, absJ, stat);
  IF stat # Success THEN RETURN END;

  SetZero(prod);

  WHILE (absJ.lowBits # 0) OR (absJ.highBits # 0) DO
    IF ODD(absJ.lowBits) THEN
      Add(prod, absI, prod, stat);
      IF stat # Success THEN
        IF resIsNegative THEN
          stat := Underflow
        ELSE
          stat := Overflow
        END; (* IF *)
        RETURN
      END (* IF *)
    END; (* IF *)
    Shl(absI, 1, absI, tempStat);
    Shr(absJ, 1, absJ)
  END; (* WHILE *)

  IF resIsNegative THEN
    Neg(prod, res, stat)
  ELSE
    res := prod;
    stat := Success
  END (* IF *)
END LongMul;


(* --------------------------------------------------------------------------
 * Procedure:  Shr(i, shift, res)
 * --------------------------------------------------------------------------
 * Logical shift right of i by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shr ( i : INT64T; shift : CARDINAL; VAR res : INT64T );
VAR
  s : CARDINAL;
  carryBits : LONGCARD;
  powS, powInv : LONGCARD;
  uHigh : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift >= 32 THEN
    s := shift - 32;
    powS := Pow2(s);
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i.highBits) DIV powS
  ELSE (* 1 <= shift < 32 *)
    s := shift;
    powS := Pow2(s);
    powInv := Pow2(32 - s);
    uHigh := VAL(LONGCARD, i.highBits);
    carryBits := (uHigh MOD powS) * powInv;
    res.highBits := VAL(LONGINT, uHigh DIV powS);
    res.lowBits := (i.lowBits DIV powS) + carryBits
  END (* IF *)
END Shr;


(* --------------------------------------------------------------------------
 * Procedure:  DivMod(left, right, quot, rem, stat)
 * --------------------------------------------------------------------------
 * Passes quotient and remainder in quot and rem respectively.
 * ----------------------------------------------------------------------- *)

PROCEDURE DivMod64 ( left, right : INT64T; VAR quot, rem : INT64T; VAR stat : Status );
VAR
  bit : CARDINAL;
  zero64 : INT64T;
  tempStat : Status;
BEGIN
  SetZero(zero64);
  IF eq(right, zero64) THEN
    stat := DivByZero;
    SetZero(quot);
    SetZero(rem);
    RETURN
  END; (* IF *)

  IF lt(left, right) THEN
    SetZero(quot);
    rem := left;
    stat := Success;
    RETURN
  END; (* IF *)

  IF eq(left, right) THEN
    FromCard(1, quot);
    SetZero(rem);
    stat := Success;
    RETURN
  END; (* IF *)

  SetZero(quot);
  SetZero(rem);

  bit := 64;
  REPEAT
    DEC(bit);
    Shl(rem, 1, rem, tempStat);
    IF bit >= 32 THEN
      IF (VAL(LONGCARD, left.highBits) DIV Pow2(bit - 32)) MOD 2 = 1 THEN
        rem.lowBits := rem.lowBits + 1
      END; (* IF *)
    ELSE
      IF (left.lowBits DIV Pow2(bit)) MOD 2 = 1 THEN
        rem.lowBits := rem.lowBits + 1
      END; (* IF *)
    END; (* IF *)

    IF gteq(rem, right) THEN
      Sub(rem, right, rem, tempStat);
      IF bit >= 32 THEN
        quot.highBits := quot.highBits + VAL(LONGINT, Pow2(bit - 32))
      ELSE
        quot.lowBits := quot.lowBits + Pow2(bit)
      END (* IF *)
    END (* IF *)
  UNTIL bit = 0;

  stat := Success
END DivMod64;


(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

CONST
  Bitwidth = 32;

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF LONGCARD;


(* --------------------------------------------------------------------------
 * Procedure:  Pow2(n, res, stat)
 * --------------------------------------------------------------------------
 * Passes the n-th power of 2 in res, and status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE Pow2 ( n : CARDINAL ) : LONGCARD;
BEGIN
  RETURN powerOf2[n]
END Pow2;


(* --------------------------------------------------------------------------
 * procedure InitPow2Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 2.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow2Table;

VAR
  index : CARDINAL;

BEGIN
  powerOf2[0] := 1;
  FOR index := 1 TO Bitwidth-1 DO
    powerOf2[index] := powerOf2[index-1] * 2
  END (* FOR *)
END InitPow2Table;


(* Initialise data table *)

BEGIN
  InitPow2Table
END INT64.