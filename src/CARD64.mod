(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE CARD64;

(* 64-bit Cardinal Type for 32-bit Compiler *)


(*
TYPE CARD64T = RECORD
  highBits,
  lowBits : LONGCARD
END; (* RECORD *)

TYPE Status = ( Success, Overflow, DivByZero );
*)


(* --------------------------------------------------------------------------
 * bit width
 * ----------------------------------------------------------------------- *)

CONST
  Bitwidth = TSIZE(CARD64T);


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.SetZero(res)
 * --------------------------------------------------------------------------
 * Passes the CARD64T value of zero in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetZero ( VAR res : CARD64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 0
END SetZero;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.SetMax(res)
 * --------------------------------------------------------------------------
 * Passes the largest value of type CARD64T (0xFFFFFFFFFFFFFFFF) in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMax ( VAR res : CARD64T );
BEGIN
  res.highBits := Max32Card;
  res.lowBits := Max32Card
END SetMax;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.FromCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the CARD64T value of CARDINAL n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromCard ( n : CARDINAL; VAR res : CARD64T );
BEGIN
  res.highBits := 0;
  res.lowBits := VAL(LONGCARD, n)
END FromCard;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.FromLongCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the CARD64T value of LONGCARD n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongCard ( n : LONGCARD; VAR res : CARD64T );
BEGIN
  res.highBits := 0;
  res.lowBits := n
END FromLongCard;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.ToCard(c, res, stat)
 * --------------------------------------------------------------------------
 * Passes the CARDINAL value of CARD64T c in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToCard ( c : CARD64T; VAR res : CARDINAL; VAR stat : Status );
BEGIN
  IF c.highBits # 0 THEN
    stat := Overflow;
    RETURN
  ELSIF c.lowBits > VAL(LONGCARD, MAX(CARDINAL)) THEN
    stat := Overflow;
    RETURN
  ELSE
    res := VAL(CARDINAL, c.lowBits);
    stat := Success
  END (* IF *)
END ToCard;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.ToLongCard(n, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGCARD value of CARD64T n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongCard ( n : CARD64T; VAR res : LONGCARD; VAR stat : Status );
BEGIN
  IF c.highBits # 0 THEN
    stat := Overflow;
    RETURN
  ELSE
    res := c.lowBits;
    stat := Success
  END (* IF *)
END ToLongCard;


(* --------------------------------------------------------------------------
 * Function:  CARD64.odd(n)
 * --------------------------------------------------------------------------
 * Returns TRUE if n is odd, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE odd ( n : CARD64T ) : BOOLEAN;
BEGIN
  RETURN ODD(c.lowBits)
END odd;


(* --------------------------------------------------------------------------
 * Function:  CARD64.eq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left = right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE eq ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits = right.highBits) AND (left.lowBits = right.lowBits)
END eq;


(* --------------------------------------------------------------------------
 * Function:  CARD64.neq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left # right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE neq ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits # right.highBits) OR (left.lowBits # right.lowBits)
END neq;


(* --------------------------------------------------------------------------
 * Function:  CARD64.gt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left > right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gt ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  IF left.highBits > right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits < right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits > right.lowBits
  END (* IF *)
END gt;


(* --------------------------------------------------------------------------
 * Function:  CARD64.gteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left >= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gteq ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  IF left.highBits > right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits < right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits >= right.lowBits
  END (* IF *)
END gteq;


(* --------------------------------------------------------------------------
 * Function:  CARD64.lt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left < right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lt ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  IF left.highBits < right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits > right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits < right.lowBits
  END (* IF *)
END lt;


(* --------------------------------------------------------------------------
 * Function:  CARD64.lteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left <= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lteq ( left, right : CARD64T ) : BOOLEAN;
BEGIN
  IF left.highBits < right.highBits THEN
    RETURN TRUE
  ELSIF left.highBits > right.highBits THEN
    RETURN FALSE
  ELSE
    RETURN left.lowBits <= right.lowBits
  END (* IF *)
END lteq;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Add(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sum left + right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Add ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  sumLow : LONGCARD;
  carry : LONGCARD;
BEGIN
  sumLow := left.lowBits + right.lowBits;
  IF sumLow < left.lowBits THEN
    carry := 1
  ELSE
    carry := 0
  END; (* IF *)

  IF left.highBits > (MAX(LONGCARD) - right.highBits) THEN
    stat := Overflow
  ELSIF (carry = 1) AND (left.highBits + right.highBits = MAX(LONGCARD)) THEN
    stat := Overflow
  ELSE
    stat := Success
  END; (* IF *)

  res.lowBits := sumLow;
  res.highBits := left.highBits + right.highBits + carry
END Add;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Sub(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the difference left - right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Sub ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  diffLow : LONGCARD;
  borrow : LONGCARD;
BEGIN
  IF lt(left, right) THEN
    stat := Overflow;
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  END; (* IF *)

  IF left.lowBits < right.lowBits THEN
    diffLow := (MAX(LONGCARD) - right.lowBits) + left.lowBits + 1;
    borrow := 1
  ELSE
    diffLow := left.lowBits - right.lowBits;
    borrow := 0
  END; (* IF *)

  res.lowBits := diffLow;
  res.highBits := left.highBits - right.highBits - borrow;
  stat := Success
END Sub;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Mul(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the product left * right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mul ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN

END Mul;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN

END Div;

(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the remainder left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN

END Mod;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Shl(n, shift, res)
 * --------------------------------------------------------------------------
 * Shifts n left by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shl ( n : CARD64T; shift : CARDINAL; VAR res : CARD64T );
BEGIN

END Shl;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Shr(n, shift, res)
 * --------------------------------------------------------------------------
 * Logical shift right of n by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shr ( n : CARD64T; shift : CARDINAL; VAR res : CARD64T );
BEGIN

END Shr;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure: TwosComplement(n, res)
 * --------------------------------------------------------------------------
 * Computes the two's complement of n, passes result in res, status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE TwosComplement ( n : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN

END TwosComplement;


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
 * Function:  diffUnderflowsLC(n, m, borrow)
 * --------------------------------------------------------------------------
 * Returns TRUE if i-j-borrow would underflow LONGRACE, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE diffUnderflowsLC ( n, m : LONGINT; borrow : LONGCARD ) : BOOLEAN;
BEGIN

END diffUnderflowsLC;


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
 * Procedure:  LongMul(n, m, res, stat)
 * --------------------------------------------------------------------------
 * Returns the long multiplication product n * m in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE LongMul ( n, m : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN

END LongMul;


(* --------------------------------------------------------------------------
 * Procedure:  DivMod(n, m, quot, rem, stat)
 * --------------------------------------------------------------------------
 * Passes quotient and remainder in quot and rem respectively.
 * ----------------------------------------------------------------------- *)

PROCEDURE DivMod ( n, m : CARD64T; VAR quot, rem : CARD64T; VAR stat : Status );
BEGIN

END DivMod;


(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF CARD64T;


(* --------------------------------------------------------------------------
 * Procedure:  Pow2(n, res)
 * --------------------------------------------------------------------------
 * Passes the n-th power of 2 in res.  No result if n >= Bitwidth.
 * ----------------------------------------------------------------------- *)

PROCEDURE Pow2 ( n : CARDINAL; VAR res : CARD64T; );
BEGIN
  IF n < Bitwidth THEN
    stat := Success;
    res := powerOf2[n]
  END (* IF *)
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
  factor.lowBits := 2;
  
  (* powerOf2[0] := 1; *)
  powerOf2[0].highBits := 0;
  powerOf2[0].lowBits := 1;
  
  (* powerOf2[index] := factor * powerOf2[index-1]; *)
  FOR index := 1 TO Bitwidth-1 DO
    Shl(powerOf2[index-1], 1, powerOf2[index]);
  END (* FOR *)
END InitPow2Table;


(* Initialise data table *)

BEGIN
  InitPow2Table
END CARD64.
