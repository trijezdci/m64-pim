(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

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
 * bit width
 * ----------------------------------------------------------------------- *)

CONST
  Bitwidth = TSIZE(INT128T);


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
 * Procedure: INT128.FromInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of INTEGER i in res.
 * ----------------------------------------------------------------------- *)
PROCEDURE FromInt ( i : INTEGER; VAR res : INT128T );
VAR
  ignore : Status;
BEGIN
  IF i = MIN(INTEGER) THEN
    res.highBits := -1;
    (* 64-bit sign extension *)
    res.lowBits := VAL(LONGCARD, VAL(LONGINT, i));
    RETURN
  END; (* IF *)
  
  res.highBits := 0;
  IF i >= 0 THEN
    res.lowBits := VAL(LONGCARD, i)
  ELSE
    res.lowBits := VAL(LONGCARD, ABS(i));
    TwosComplement(res, res, ignore)
  END (* IF *)
END FromInt;


(* --------------------------------------------------------------------------
 * Procedure: INT128.FromLongInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT128T value of LONGINT i in res.
 * ----------------------------------------------------------------------- *)
PROCEDURE FromLongInt ( i : LONGINT; VAR res : INT128T );
VAR
  ignore : Status;
BEGIN
  IF i = MIN(LONGINT) THEN
    res.highBits := -1;
    res.lowBits := 08000000000000000H; (* MIN(LONGINT) = -2^63 *)
    RETURN
  END; (* IF *)
  
  res.highBits := 0;
  IF i >= 0 THEN
    res.lowBits := VAL(LONGCARD, i)
  ELSE
    res.lowBits := VAL(LONGCARD, ABS(i));
    TwosComplement(res, res, ignore)
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
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > 0FFFFFFFFH THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(CARDINAL, i.lowBits);
      stat := Success
    END
  ELSE (* i.highBits < 0 *)
    stat := Underflow;
    RETURN
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
  ELSIF i.highBits = 0 THEN
    res := i.lowBits;
    stat := Success
  ELSE (* i.highBits < 0 *)
    stat := Underflow;
    RETURN
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
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > 07FFFFFFFH THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(INTEGER, i.lowBits);
      stat := Success
    END
  ELSIF i.highBits = (-1) THEN
    IF i.lowBits = 0 THEN
      stat := Underflow;
      RETURN
    ELSE
      magnitude := (MAX(LONGCARD) - i.lowBits) + 1;
      IF magnitude > 080000000H THEN
        stat := Underflow;
        RETURN
      ELSE (* in range *)
        res := - VAL(INTEGER, magnitude);
        stat := Success
      END (* IF *)
    END (* IF *)
  ELSE (* i.highBits < (-1) *)
    stat := Underflow;
    RETURN
  END (* IF *)   
END ToInt;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.ToLongInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGINT value of INT128T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongInt ( i : INT128T; VAR res : LONGINT; VAR stat : Status );
VAR
  magnitude : LONGCARD;
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > 07FFFFFFFFFFFFFFFH THEN
      stat := Overflow;
      RETURN
    ELSE (* in range *)
      res := VAL(LONGINT, i.lowBits);
      stat := Success
    END (* IF *)
  ELSIF i.highBits = (-1) THEN
    IF i.lowBits = 0 THEN
      stat := Underflow;
      RETURN
    ELSE
      magnitude := (MAX(LONGCARD) - i.lowBits) + 1;
      IF magnitude > 08000000000000000H THEN
        stat := Underflow;
        RETURN
      ELSE (* in range *)
        res := - VAL(LONGINT, magnitude);
        stat := Success
      END (* IF *)
    END (* IF *)
  ELSE (* i.highBits < (-1) *)
    stat := Underflow;
    RETURN
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
    stat := Success
  ELSE (* i is negative *)
    TwosComplement( i, res, stat )
  END
END Abs;


(* --------------------------------------------------------------------------
 * Function:  INT128.Neg(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sign inversed value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Neg ( i : INT128T; VAR res : INT128T; VAR stat : Status );
BEGIN
  TwosComplement( i, res, stat )
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
 * Procedure:  INT128.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );
VAR
  resIsNeg : BOOLEAN;
  absLeft, absRight, quot, rem : INT128T;
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

  DivMod128(absLeft, absRight, quot, rem, stat);
  IF stat # Success THEN RETURN END;

  IF resIsNeg THEN
    Neg(quot, res, stat)
  ELSE
    res := quot;
    stat := Success
  END (* IF *)
END Div;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division modulus left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : INT128T; VAR res : INT128T; VAR stat : Status );
VAR
  leftIsNeg : BOOLEAN;
  absLeft, absRight, quot, rem : INT128T;
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

  DivMod128(absLeft, absRight, quot, rem, stat);
  IF stat # Success THEN RETURN END;

  IF leftIsNeg THEN
    Neg(rem, res, stat)
  ELSE
    res := rem;
    stat := Success
  END (* IF *)
END Mod;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.Shl(i, shift, res)
 * --------------------------------------------------------------------------
 * Shifts i left by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shl ( i : INT128T; shift : CARDINAL; VAR res : INT128T );
VAR
  s : CARDINAL;
  powS, powInv, carryBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 128 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift >= 64 THEN
    res.lowBits := 0;
    s := shift - 64;
    IF s >= 64 THEN
      res.highBits := 0
    ELSE
      powS := PowerOfTwo(s);
      res.highBits := LONGINT(i.lowBits * powS)
    END;
    RETURN
  ELSE (* 1 <= shift < 64 *)
    powS := PowerOfTwo(shift);
    powInv := PowerOfTwo(64 - shift);
    carryBits := i.lowBits DIV powInv;
    res.highBits := LONGINT((LONGCARD(i.highBits) * powS) + carryBits);
    res.lowBits := i.lowBits * powS;
    RETURN
  END (* IF *)
END Shl;


(* --------------------------------------------------------------------------
 * Procedure:  INT128.Shr(i, shift, res)
 * --------------------------------------------------------------------------
 * Arithmetic shift right of i by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE AShr ( i : INT128T; shift : CARDINAL; VAR res : INT128T );
VAR
  s : CARDINAL;
  powS, powInv, carryBits, mask : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 128 THEN
    IF i.highBits < 0 THEN
      res.highBits := -1;
      res.lowBits := 0FFFFFFFFFFFFFFFFH
    ELSE
      res.highBits := 0;
      res.lowBits := 0
    END;
    RETURN
  ELSIF shift >= 64 THEN
    s := shift - 64;
    IF s >= 64 THEN
      res.lowBits := 0
    ELSE
      powS := PowerOfTwo(s);
      IF i.highBits < 0 THEN
        res.highBits := -1;
        
        (* compute mask to set high bits *)
        res.lowBits := LONGCARD(i.highBits) DIV powS;
        mask := 0FFFFFFFFFFFFFFFFH DIV powS;
        mask := mask * powS;
        res.lowBits := res.lowBits + (0FFFFFFFFFFFFFFFFH - mask)
      ELSE
        res.highBits := 0;
        res.lowBits := LONGCARD(i.highBits) DIV powS
      END
    END;
    RETURN
  ELSE (* 1 <= shift < 64 *)
    powS := PowerOfTwo(shift);
    powInv := PowerOfTwo(64 - shift);
    
    carryBits := LONGCARD(i.highBits) MOD powS;
    res.lowBits := (i.lowBits DIV powS) + (carryBits * powInv);
    
    IF i.highBits < 0 THEN
      res.highBits := LONGINT(LONGCARD(i.highBits) DIV powS);
      
      (* compute mask to set high bits *)
      mask := 0FFFFFFFFFFFFFFFFH DIV powS;
      mask := mask * powS;
      res.highBits := LONGINT(LONGCARD(res.highBits) + (0FFFFFFFFFFFFFFFFH - mask))
    ELSE
      res.highBits := LONGINT(LONGCARD(i.highBits) DIV powS)
    END;
    RETURN
  END (* IF *)
END AShr;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure: TwosComplement(i, res)
 * --------------------------------------------------------------------------
 * Computes the two's complement of i, passes result in res, status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE TwosComplement ( i : INT128T; VAR res : INT128T; VAR stat : Status );
BEGIN
  IF (i.highBits = MIN(LONGINT)) AND (i.lowBits = 0) THEN
    stat := Overflow;
    RETURN
  END; (* IF *)
  
  stat := Success;
  res.lowBits := MAX(LONGCARD) - i.lowBits + 1;
  
  IF res.lowBits = 0 THEN
    res.highBits := 0 - i.highBits
  ELSE (* borrow occurred *)
    res.highBits := 0 - i.highBits - 1
  END (* IF *)  
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
 * Function:  sumOverflowsLI(i, j, carry)
 * --------------------------------------------------------------------------
 * Returns TRUE if i+j+carry would overflow LONGINT, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE sumOverflowsLI ( i, j : LONGINT; carry : LONGCARD ) : BOOLEAN;
VAR
  c : LONGINT;
BEGIN
  IF (i > 0) AND (j >= 0) THEN
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
    ELSE (* i # MIN(LONGINT) AND (j # MIN(LONGINT)) *)
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


PROCEDURE Shr ( i : INT128T; shift : CARDINAL; VAR res : INT128T );
VAR
  s : CARDINAL;
  powS, powInv, carryBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 128 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    s := shift - 64;
    IF s >= 64 THEN
      res.lowBits := 0
    ELSE
      powS := PowerOfTwo(s);
      res.lowBits := LONGCARD(i.highBits) DIV powS
    END;
    RETURN
  ELSE (* 1 <= shift < 64 *)
    powS := PowerOfTwo(shift);
    powInv := PowerOfTwo(64 - shift);
    carryBits := LONGCARD(i.highBits) MOD powS;
    res.highBits := LONGINT(LONGCARD(i.highBits) DIV powS);
    res.lowBits := (i.lowBits DIV powS) + (carryBits * powInv);
    RETURN
  END (* IF *)
END Shr;


(* --------------------------------------------------------------------------
 * Procedure:  DivMod(i, j, quot, rem, stat)
 * --------------------------------------------------------------------------
 * Passes quotient and remainder in quot and rem respectively.
 * ----------------------------------------------------------------------- *)

PROCEDURE DivMod ( i, j : INT128T; VAR quot, rem : INT128T; VAR stat : Status );
VAR
  bitIndex : CARDINAL;
  zero : INT128T;
  ignore : Status;
BEGIN
  SetZero(zero);
  IF eq(j, zero) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)

  IF lt(i, j) THEN
    SetZero(quot);
    rem := i;
    stat := Success;
    RETURN
  END; (* IF *)

  IF eq(i, j) THEN
    FromCard(1, quot);
    SetZero(rem);
    stat := Success;
    RETURN
  END; (* IF *)

  SetZero(quot);
  SetZero(rem);

  bitIndex := Bitwidth;
  REPEAT
    DEC(bitIndex);
    Shl(rem, 1, rem, ignore);
    IF bitIndex >= 64 THEN
      IF (VAL(LONGCARD, i.highBits) DIV Pow2(bitIndex - 64)) MOD 2 = 1 THEN
        rem.lowBits := rem.lowBits + 1
      END (* IF *)
    ELSE
      IF (i.lowBits DIV Pow2(bitIndex)) MOD 2 = 1 THEN
        rem.lowBits := rem.lowBits + 1
      END (* IF *)
    END; (* IF *)

    IF gteq(rem, j) THEN
      Sub(rem, j, rem, ignore);
      IF bitIndex >= 64 THEN
        quot.highBits := quot.highBits + VAL(LONGINT, Pow2(bitIndex - 64))
      ELSE
        quot.lowBits := quot.lowBits + Pow2(bitIndex)
      END (* IF *)
    END (* IF *)
  UNTIL bitIndex = 0;

  stat := Success
END DivMod;


(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF INT128T;


(* --------------------------------------------------------------------------
 * Procedure:  Pow2(n, res)
 * --------------------------------------------------------------------------
 * Passes the n-th power of 2 in res.  No result if n >= Bitwidth.
 * ----------------------------------------------------------------------- *)

PROCEDURE Pow2 ( n : CARDINAL; VAR res : INT128; );
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
END INT128.