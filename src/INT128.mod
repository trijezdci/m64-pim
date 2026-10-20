(*!m2pim*) (* Copyright (c) 2026 Modula-2 Software Foundation. *)

IMPLEMENTATION MODULE INT128;

(* 128-bit Integer Type *)


(*
TYPE INT128T = RECORD
  highBits : LONGINT;
  lowBits : LONGCARD
END; (* INT128T *)

TYPE Status = ( Success, Underflow, Overflow, DivByZero );
*)


(* --------------------------------------------------------------------------
 * Procedure:  INT128.SetZero(res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of zero in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetZero ( VAR res : INT128T );
BEGIN
  res.highBits := 0;
  res.lowBits := 0
END SetZero;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.SetMax(res)
 * --------------------------------------------------------------------------
 * Passes the largest value of type INT128T in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMax ( VAR res : INT128T );
BEGIN
  res.highBits := MAX(LONGINT); (* 0x7FFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFF *)
  res.lowBits := MAX(LONGCARD)  (* 0xFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFF *)
END SetMax;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.SetMin(res)
 * --------------------------------------------------------------------------
 * Passes the smallest value of type INT128T in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMin ( VAR res : INT128T );
BEGIN
  res.highBits := MIN(LONGINT); (* 0xFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFF *)
  res.lowBits := MAX(LONGCARD)  (* 0xFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFF *)
END SetMin;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.FromCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of CARDINAL n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromCard ( n : CARDINAL; VAR res : INT128T );
BEGIN
  res.highBits := 0;
  res.lowBits := VAL(LONGCARD, n)
END FromCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.FromLongCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of LONGCARD n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongCard ( n : LONGCARD; VAR res : INT128T );
BEGIN
  res.highBits := 0;
  res.lowBits := n
END FromLongCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.FromInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of INTEGER i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromInt ( i : INTEGER; VAR res : INT128T );
BEGIN
  IF i < 0 THEN
    res.highBits := (-1); (* sign extension *)
    res.lowBits := 0 - VAL(LONGCARD, ABS(i)) (* complement *)
  ELSE (* i >= 0 *)
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.FromLongInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of LONGINT i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongInt ( i : LONGINT;  VAR res : INT128T );
BEGIN
  IF i < 0 THEN
    res.highBits := (-1); (* sign extension *)
    IF i = MIN(LONGINT) THEN
      res.lowBits := 08000000000000000H (* 2^63 *)
    ELSE
      res.lowBits := 0 - VAL(LONGCARD, ABS(i)) (* complement *)
    END (* IF *)
  ELSE (* i >= 0 *)
    res.highBits := 0;
    res.lowBits := VAL(LONGCARD, i)
  END (* IF *)
END FromLongInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.ToCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the CARDINAL value of INT128T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToCard ( i : INT128T; VAR res : CARDINAL; VAR stat : Status );
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
 * Procedure:  INT128.ToLongCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGCARD value of INT128T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongCard ( i : INT128T; VAR res : LONGCARD; VAR stat : Status );
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
 * Procedure:  INT128.ToInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the INTEGER value of INT128T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToInt ( i : INT128T; VAR res : INTEGER; VAR stat : Status );
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
    If magnitude > VAL(LONGCARD, ABS(MIN(INTEGER))) THEN
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
 * Procedure:  INT128.ToLongInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGINT value of INT128T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongInt ( i : INT128T; VAR res : LONGINT; VAR stat : Status );
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits < (-1) THEN
    stat := Underflow;
    RETURN
  ELSIF i.highBits = (-1) THEN
    IF i.lowBits < (* MIN(LONGINT) *) 08000000000000000H THEN
      stat := Underflow;
      RETURN
    ELSIF i.lowBits = (* MIN(LONGINT) *) 08000000000000000H THEN
      res := MIN(LONGINT);
      stat := Success
    ELSE (* in range *)
      (* res := MIN(LONGINT) + i.lowBits - MIN(LONGINT) => res := i.lowBits *)
      res := MIN(LONGINT) + VAL(LONGINT, i.lowBits - 08000000000000000H);
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
 * Function:  INT128.odd(i)
 * --------------------------------------------------------------------------
 * Returns TRUE if i is odd, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE odd ( i : INT128T ) : BOOLEAN;
BEGIN
  RETURN ODD(i.lowBits)
END odd;


(* --------------------------------------------------------------------------
 * function:  INT128.eq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left = right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE eq ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits = right.highBits) AND (left.lowBits = right.lowBits)
END eq;


(* --------------------------------------------------------------------------
 * Function:  INT128.neq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left # right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE neq ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits # right.highBits) OR (left.lowBits # right.lowBits)
END neq;


(* --------------------------------------------------------------------------
 * Function:  INT128.gt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left > right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gt ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits > right.lowBits))
END gt;


(* --------------------------------------------------------------------------
 * Function:  INT128.gteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left >= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gteq ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits >= right.lowBits))
END gtEq;


(* --------------------------------------------------------------------------
 * Function:  INT128.lt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left < right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lt ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits < right.lowBits))
END lt;


(* --------------------------------------------------------------------------
 * Function:  INT128.lteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left <= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lteq ( left, right : INT128T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits <= right.lowBits))
END ltEq;


(* --------------------------------------------------------------------------
 * Function:  INT128.Abs(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the absolute value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Abs ( i : INT128T; VAR res : INT128T; VAR stat : Status );
BEGIN
  IF i.highBits >= 0 THEN
    res := i;
    stat := Success;
    RETURN
  ELSIF (i.highBits = MIN(LONGINT)) AND (i.lowBits = MAX(LONGCARD)) THEN
    stat := Overflow;
    RETURN
  ELSE (* MIN(INT128T) < i < 0 *)
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
 * Function:  INT128.Neg(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sign inversed value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Neg ( i : INT128T; VAR res : INT128T; VAR stat : Status );
BEGIN
  IF (i.highBits = MIN(LONGINT)) AND (i.lowBits = MAX(LONGCARD)) THEN
    stat := Overflow; (* MIN(INT128T) has no positive counterpart *)
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
 * Procedure:  INT128.Add(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sum left + right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Add ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );
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
 * Procedure:  INT128.Sub(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the difference left - right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Sub ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );
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
    (* Subtracting like signs is mathematically guaranteed to fit within 128 bits *)
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
 * Procedure:  INT128.Mul(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the product left * right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mul ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );

PROCEDURE Mul ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );
VAR
  resLow      : LONGCARD;
  resHigh     : LONGINT;
  nativeLeft  : LONGINT;
  nativeRight : LONGINT;
  native64    : LONGINT;
  tempLeft    : INT128T;
  tempRight   : INT128T;
  prod        : INT128T;
  isNeg       : BOOLEAN;
BEGIN
  
  IF (left.highBits = 0) AND (right.highBits = 0) THEN
    (* both operands are non-negative and fit in 64-bit *)
    IF NOT prodOverflowsLC(left.lowBits, right.lowBits) THEN
      (* product fits in 64-bit *)
      res.lowBits := left.lowBits * right.lowBits;
      res.highBits := 0;
      stat := Success;
      RETURN
    ELSE (* product overflows 64-bit *)
      LongMul(left, right, res, stat);
      RETURN
    END (* IF *)
  END; (* IF *)
  
  IF ((left.highBits = -1) AND (right.highBits = 0)) THEN
  
    (* sign reduce left operator to 64-bit *)
    left64 := MIN(LONGINT) + VAL(LONGINT, left.lowBits - 08000000000000000H)
    
  ELSEIF ((right.highBits = -1) AND (left.highBits = 0)) THEN
  
    (* sign reduce right operator to 64-bit *)
    right64 := MIN(LONGINT) + VAL(LONGINT, right.lowBits - 08000000000000000H)
  ELSE
  
  END;
    
  
  (* operands have different signs and fit in signed 64-bit *)
  IF ((left.highBits = 0)  OR (left.highBits = -1)) AND
     ((right.highBits = 0) OR (right.highBits = -1)) THEN
     
    (* Sign reduce left operator into 64-bit signed staging variable *)
    IF left.highBits = -1 THEN
      nativeLeft := MIN(LONGINT) + VAL(LONGINT, left.lowBits - 08000000000000000H)
    ELSE
      nativeLeft := VAL(LONGINT, left.lowBits)
    END;

    (* Sign reduce right operator into 64-bit signed staging variable *)
    IF right.highBits = -1 THEN
      nativeRight := MIN(LONGINT) + VAL(LONGINT, right.lowBits - 08000000000000000H)
    ELSE
      nativeRight := VAL(LONGINT, right.lowBits)
    END;

    (* Verify no 64-bit signed overflow or underflow occurs *)
    IF prodOverflowsLI(nativeLeft, nativeRight) THEN
      (* If it overflows 64-bit but could fit in 128-bit, skip to long multiplication *)
    ELSIF prodUnderflowsLI(nativeLeft, nativeRight) THEN
      (* If it underflows 64-bit but could fit in 128-bit, skip to long multiplication *)
    ELSE
      (* Safe native 64-bit multiplication *)
      native64 := nativeLeft * nativeRight;
      
      (* Sign extend the 64-bit result into the 128-bit destination *)
      IF native64 < 0 THEN
        resLow := 0 - VAL(LONGCARD, ABS(native64));
        resHigh := -1
      ELSE
        resLow := VAL(LONGCARD, native64);
        resHigh := 0
      END;
      
      res.lowBits := resLow;
      res.highBits := resHigh;
      stat := Success;
      RETURN
    END (* IF *)
  END; (* IF *)
  
  LongMul(left, right, res, stat);
  
END Mul;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );


(* --------------------------------------------------------------------------
 * Procedure:  INT128.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division modulus left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );


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
    RETURN (i + c) > (MIN(LONGINT) - j))
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

PROCEDURE LongMul ( i, j : INT128T; VAR res : INT128T; VAR stat : Status );
VAR
  resIsNegative : BOOLEAN;
  absI, absJ, prod : INT128T;
  
BEGIN
  resIsNegative := ORD((i.highBits < 0) # (j.highBits < 0));
  
  Abs(i, absLeft, stat);
  IF stat # Success THEN RETURN END; (* ABS(i) > MAX(INT128T) *)
  
  Abs(j, absRight, stat);
  IF stat # Success THEN RETURN END; (* ABS(j) > MAX(INT128T) *)

  prod.highBits := 0;
  prod.lowBits := 0;

  WHILE (absRight.lowBits # 0) OR (absRight.highBits # 0) DO
    IF ODD(absI.lowBits) THEN
      Add(prod, absI, prod, stat);
      IF stat # Success THEN 
        IF isNeg THEN
          stat := Underflow
        ELSE
          stat := Overflow
        END;
        RETURN
      END
    END;
    Shl128(absI, 1);
    Shr128(absJ, 1)
  END; (* WHILE *)

  IF resIsNegative THEN
    Neg(prod, res, stat)
  ELSE
    res := prod;
    stat := Success
  END
END LongMul;

END INT128.