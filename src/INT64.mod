(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE INT64;

(* 64-bit Integer Type *)


FROM SYSTEM IMPORT TSIZE;

IMPORT CARD64;
FROM CARD64 IMPORT
  CARD64T, Status;

(*
TYPE CARD64T = RECORD (* Requires 32-bit LONGCARD type *)
  highBits,
  lowBits : LONGCARD
END; (* RECORD *)

TYPE INT64T = RECORD
  highBits : LONGINT;
  lowBits : LONGCARD
END; (* INT64T *)

TYPE Status = ( Success, Underflow, Overflow, DivByZero );
*)


(* --------------------------------------------------------------------------
 * bit width
 * ----------------------------------------------------------------------- *)

CONST
  Bitwidth = TSIZE(INT64T) * 8;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.SetZero(res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of zero in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetZero ( VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 0
END SetZero;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.SetOne(res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of 1 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetOne ( VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 1
END SetOne;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.SetMin(res)
 * --------------------------------------------------------------------------
 * Passes the smallest value of type INT64T (0x80000000:0x00000000) in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMin ( VAR res : INT64T );
BEGIN
  res.highBits := MIN(LONGINT); (* 0x80000000 *)
  res.lowBits := 0              (* 0x00000000 *)
END SetMin;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.SetMax(res)
 * --------------------------------------------------------------------------
 * Passes the largest value of type INT64T (0x7FFFFFFF:0xFFFFFFFF) in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMax ( VAR res : INT64T );
BEGIN
  res.highBits := MAX(LONGINT); (* 0x7FFFFFFF *)
  res.lowBits := MAX(LONGCARD)  (* 0xFFFFFFFF *)
END SetMax;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.FromCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of CARDINAL n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromCard ( n : CARDINAL; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := VAL(LONGCARD, n)
END FromCard;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.FromLongCard(n, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of LONGCARD n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE FromLongCard ( n : LONGCARD; VAR res : INT64T );
BEGIN
  res.highBits := 0;
  res.lowBits := n
END FromLongCard;


(* --------------------------------------------------------------------------
* Procedure: INT64.FromCard64(n, res, stat)
* --------------------------------------------------------------------------
* Converts unsigned 64-bit CARD64T n to signed INT64T res.
* ----------------------------------------------------------------------- *)
PROCEDURE FromCard64 ( n : CARD64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  (* any CARD64T value with the high bit set overflows INT64T *)
  IF n.highBits > MAX(LONGCARD) DIV 2 THEN
    stat := Overflow;
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSE
    res.highBits := VAL(LONGINT, n.highBits);
    res.lowBits := n.lowBits;
    stat := Success
  END
END FromCard64;


(* --------------------------------------------------------------------------
 * Procedure: INT64T.FromInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of INTEGER i in res.
 * ----------------------------------------------------------------------- *)
PROCEDURE FromInt ( i : INTEGER; VAR res : INT64T );
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
 * Procedure: INT64T.FromLongInt(i, res)
 * --------------------------------------------------------------------------
 * Passes the INT64T value of LONGINT i in res.
 * ----------------------------------------------------------------------- *)
PROCEDURE FromLongInt ( i : LONGINT; VAR res : INT64T );
VAR
  ignore : Status;
BEGIN
  IF i = MIN(LONGINT) THEN
    res.highBits := -1;
    res.lowBits := MAX(LONGCARD) DIV 2 + 1; (* => MIN(LONGINT) = -2^31 *)
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
 * Procedure:  INT64T.ToCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the CARDINAL value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToCard ( i : INT64T; VAR res : CARDINAL; VAR stat : Status );
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > MAX(CARDINAL) THEN
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
 * Procedure:  INT64T.ToLongCard(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGCARD value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongCard ( i : INT64T; VAR res : LONGCARD; VAR stat : Status );
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
* Procedure: INT64.ToCard64(i, res, stat)
* --------------------------------------------------------------------------
* Converts signed INT64T i to unsigned CARD64T res.
* ----------------------------------------------------------------------- *)

PROCEDURE ToCard64 ( i : INT64T; VAR res : CARD64T; VAR stat : Status );
BEGIN
  (* any negative INT64T value underflows CARD64T *)
  IF i.highBits < 0 THEN
    stat := Underflow;
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSE
    res.highBits := VAL(LONGCARD, i.highBits);
    res.lowBits := i.lowBits;
    stat := Success
  END
END ToCard64;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.ToInt(i, res, stat)
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
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > (MAX(CARDINAL) DIV 2) THEN
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
      IF magnitude > MAX(LONGCARD) DIV 2 + 1 THEN
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
 * Procedure:  INT64T.ToLongInt(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the LONGINT value of INT64T i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE ToLongInt ( i : INT64T; VAR res : LONGINT; VAR stat : Status );
VAR
  magnitude : LONGCARD;
BEGIN
  IF i.highBits > 0 THEN
    stat := Overflow;
    RETURN
  ELSIF i.highBits = 0 THEN
    IF i.lowBits > MAX(LONGCARD) DIV 2 THEN
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
      magnitude := MAX(LONGCARD) - i.lowBits + 1;
      IF magnitude > MAX(LONGCARD) DIV 2 + 1 THEN
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
 * Function:  INT64.isZero(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is 0, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isZero ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN (i.highBits = 0) AND (i.lowBits = 0)
END isZero;


(* --------------------------------------------------------------------------
 * Function:  INT64.isOne(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is 1, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isOne ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN (i.highBits = 0) AND (i.lowBits = 1)
END isOne;


(* --------------------------------------------------------------------------
 * Function:  INT64.isMin(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is MIN(INT64), otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isMin ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN (i.highBits = MIN(LONGINT)) AND (i.lowBits = MAX(LONGCARD))
END isMin;


(* --------------------------------------------------------------------------
 * Function:  INT64.isMax(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is MAX(INT64), otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isMax ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN (i.highBits = MAX(LONGINT)) AND (i.lowBits = MAX(LONGCARD))
END isMax;


(* --------------------------------------------------------------------------
 * Function:  INT64T.odd(i)
 * --------------------------------------------------------------------------
 * Returns TRUE if i is odd, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE odd ( i : INT64T ) : BOOLEAN;
BEGIN
  RETURN ODD(i.lowBits)
END odd;


(* --------------------------------------------------------------------------
 * function:  INT64T.eq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left = right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE eq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits = right.highBits) AND (left.lowBits = right.lowBits)
END eq;


(* --------------------------------------------------------------------------
 * Function:  INT64T.neq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left # right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE neq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits # right.highBits) OR (left.lowBits # right.lowBits)
END neq;


(* --------------------------------------------------------------------------
 * Function:  INT64T.gt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left > right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits > right.lowBits))
END gt;


(* --------------------------------------------------------------------------
 * Function:  INT64T.gteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left >= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE gteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits > right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits >= right.lowBits))
END gteq;


(* --------------------------------------------------------------------------
 * Function:  INT64T.lt(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left < right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lt ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits < right.lowBits))
END lt;


(* --------------------------------------------------------------------------
 * Function:  INT64T.lteq(left, right)
 * --------------------------------------------------------------------------
 * Returns TRUE if left <= right, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE lteq ( left, right : INT64T ) : BOOLEAN;
BEGIN
  RETURN (left.highBits < right.highBits)
    OR ((left.highBits = right.highBits) AND (left.lowBits <= right.lowBits))
END lteq;


(* --------------------------------------------------------------------------
 * Function:  INT64T.Abs(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the absolute value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Abs ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  IF i.highBits >= 0 THEN
    res := i;
    stat := Success
  ELSE (* i is negative *)
    TwosComplement( i, res, stat )
  END
END Abs;


(* --------------------------------------------------------------------------
 * Function:  INT64T.Neg(i, res, stat)
 * --------------------------------------------------------------------------
 * Passes the sign inversed value of i in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Neg ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  TwosComplement( i, res, stat )
END Neg;


(* --------------------------------------------------------------------------
 * Procedure:  INT64.Inc(i, stat)
 * --------------------------------------------------------------------------
 * Destructively increments i by 1.  Leaves i unchanged on Overflow.
 * Faster than using procedure INT64.Add().
 * ----------------------------------------------------------------------- *)

PROCEDURE Inc ( VAR i : INT64T; VAR stat : Status );
BEGIN
  IF (i.highBits = MAX(LONGINT)) AND (i.lowBits = MAX(LONGCARD)) THEN
    stat := Overflow;
    RETURN
  END; (* IF *)
  
  IF i.lowBits = MAX(LONGCARD) THEN
    i.lowBits := 0;
    INC(i.highBits)
  ELSE (* no carry *)
    INC(i.lowBits)
  END; (* IF *)
  stat := Success
END Inc;


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
 * Procedure:  INT64.Dec(i, stat)
 * --------------------------------------------------------------------------
 * Destructively decrements i by 1.  Leaves i unchanged on Underflow.
 * Faster than using procedure INT64.Sub().
 * ----------------------------------------------------------------------- *)

PROCEDURE Dec ( VAR i : INT64T; VAR stat : Status );
BEGIN
  IF (i.highBits = MIN(LONGINT)) AND (i.lowBits = MAX(LONGCARD)) THEN
    stat := Underflow;
    RETURN
  END; (* IF *)
  
  IF i.lowBits = 0 THEN
    i.lowBits := MAX(LONGCARD);
    DEC(i.highBits)
  ELSE (* no borrow *)
    DEC(i.lowBits)
  END; (* IF *)
  stat := Success
END Dec;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.Sub(left, right, res, stat)
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
 * Passes the product left * right in res, status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mul ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  absLeft, absRight : INT64T;
  cardLeft, cardRight, cardProd : CARD64T;
BEGIN
  (* left = 0 OR right = 0 *)
  IF isZero(left) OR isZero(right) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)

  (* left # 0 AND right = 1 *)
  IF isOne(right) THEN
    res := left;
    stat := Success;
    RETURN
  END; (* IF *)
  
  (* right # 0 AND left = 1 *)
  IF isOne(left) THEN
    res := right;
    stat := Success;
    RETURN
  END; (* IF *)
  
  (* both operands fit into 32 bits each *)
  IF (left.highBits = 0) AND (right.highBits = 0) AND
     (* and their product will not overflow LONGCARD *)
     (left.lowBits <= MAX(LONGCARD) DIV right.lowBits) THEN
    res.highBits := 0;
    res.lowBits := left.lowBits * right.lowBits;
    stat := Success;
    RETURN
  END; (* IF *)
  
  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;

  ToCard64(absLeft, cardLeft, stat);
  ToCard64(absRight, cardRight, stat);

  CARD64.Mul(cardLeft, cardRight, cardProd, stat);
  IF stat # Success THEN RETURN END;
  
  (* operands with different signs determine negative result *)
  IF (left.highBits < 0) # (right.highBits < 0) THEN
    IF (cardProd.highBits > MAX(LONGCARD) DIV 2 + 1) OR 
       ((cardProd.highBits = MAX(LONGCARD) DIV 2 + 1) AND (cardProd.lowBits # 0)) THEN
      stat := Underflow;
      RETURN
    ELSE
      FromCard64(cardProd, res, stat);
      Neg(res, res, stat)
    END (* IF *)
  ELSE (* not negative *)
    IF cardProd.highBits > MAX(LONGCARD) DIV 2 THEN
      stat := Overflow;
      RETURN
    ELSE
      FromCard64(cardProd, res, stat);
      stat := Success
    END (* IF *)
  END (* IF *)
END Mul;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  absLeft, absRight : INT64T;
  cardLeft, cardRight, cardQuot : CARD64T;
BEGIN
  IF isZero(right) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)

  IF isZero(left) THEN
    res := left;
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF isOne(right) THEN
    res := left;
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF isOne(left) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF eq(left, right) THEN
    SetOne(res);
    stat := Success;
    RETURN
  END; (* IF *)
    
  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;

  ToCard64(absLeft, cardLeft, stat);
  ToCard64(absRight, cardRight, stat);

  CARD64.Div(cardLeft, cardRight, cardQuot, stat);
  IF stat # Success THEN RETURN END;

  FromCard64(cardQuot, res, stat);
  
  (* operands with different signs determine negative result *)
  IF (left.highBits < 0) # (right.highBits < 0) THEN
    Neg(res, res, stat)
  END (* IF *)
END Div;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the truncated integer division modulus left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : INT64T; VAR res : INT64T; VAR stat : Status );
VAR
  absLeft, absRight : INT64T;
  cardLeft, cardRight, cardRem : CARD64T;
BEGIN
  IF isZero(right) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)
  
  IF isZero(left) THEN
    res := left;
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF isOne(right) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF isOne(left) THEN
    res := left;
    stat := Success;
    RETURN
  END; (* IF *)
  
  IF eq(left, right) THEN
    SetZero(res);
    stat := Success;
    RETURN
  END; (* IF *)

  Abs(left, absLeft, stat);
  IF stat # Success THEN RETURN END;
  Abs(right, absRight, stat);
  IF stat # Success THEN RETURN END;
  
  ToCard64(absLeft, cardLeft, stat);
  ToCard64(absRight, cardRight, stat);

  CARD64.Mod(cardLeft, cardRight, cardRem, stat);
  IF stat # Success THEN RETURN END;

  FromCard64(cardRem, res, stat);
  
  (* left always determines sign of result *)
  IF left.highBits < 0 THEN
    Neg(res, res, stat)
  END (* IF *)
END Mod;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.Shl(i, shift, res)
 * --------------------------------------------------------------------------
 * Shifts i left by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shl ( i : INT64T; shift : CARDINAL; VAR res : INT64T );
VAR
  powS, powInv, carryBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift = 32 THEN
    res.highBits := VAL(LONGINT, i.lowBits);
    res.lowBits := 0;
    RETURN
  ELSIF shift > 32 THEN
    res.lowBits := 0;
    powS := powerOf2[shift - 32].lowBits;
    powInv := powerOf2[64 - shift].lowBits;
    res.highBits := VAL(LONGINT, (i.lowBits MOD powInv) * powS);
    RETURN
  ELSE (* 1 <= shift < 32 *)
    powS := powerOf2[shift].lowBits;
    powInv := powerOf2[32 - shift].lowBits;
    carryBits := i.lowBits DIV powInv;
    res.lowBits := (i.lowBits MOD powInv) * powS;
    res.highBits := VAL(LONGINT,
      (VAL(LONGCARD, i.highBits) MOD powInv) * powS + carryBits);
    RETURN
  END (* IF *)
END Shl;


(* --------------------------------------------------------------------------
 * Procedure:  INT64T.AShr(i, shift, res)
 * --------------------------------------------------------------------------
 * Arithmetic shift right of i by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE AShr ( i : INT64T; shift : CARDINAL; VAR res : INT64T );
VAR
  ignore : Status;
  magnitude : CARD64T;
  powS, powInv, mask, carryBits, remainingBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := i;
    RETURN
  END; (* IF *)
  
  (* i is positive *)
  IF i.highBits >= 0 THEN
    ToCard64(i, magnitude, ignore);
    CARD64.Shr(magnitude, shift, res);
    RETURN
  END; (* IF *)
  
  (* i is negative *)
  IF shift >= 64 THEN
    res.highBits := MAX(LONGINT);
    res.lowBits := MAX(LONGCARD)
  ELSIF shift = 32 THEN
    res.highBits := MAX(LONGINT);
    res.lowBits := LONGCARD(i.highBits)
  ELSIF shift > 32 THEN
    (* compute mask to set high bits *)
    res.highBits := MAX(LONGINT);
    powS := powerOf2[shift - 32].lowBits;
    mask := (MAX(LONGCARD) DIV powS) * powS;
    res.lowBits := i.lowBits + (MAX(LONGCARD) - mask)
  ELSE (* shift > 0 AND shift < 32 *)
    powS := powerOf2[shift].lowBits;
    powInv := powerOf2[32 - shift].lowBits;
    carryBits := LONGCARD(i.highBits) MOD powS;
    remainingBits := LONGCARD(i.highBits) DIV powS;
    mask := (MAX(LONGCARD) DIV powS) * powS;
    res.lowBits := (i.lowBits DIV powS) + (carryBits * powInv);
    res.highBits := LONGINT(remainingBits + (MAX(LONGCARD) - mask))
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

PROCEDURE TwosComplement ( i : INT64T; VAR res : INT64T; VAR stat : Status );
BEGIN
  (* i = MIN(INT64T) *)
  IF (i.highBits = MIN(LONGINT)) AND (i.lowBits = 0) THEN
    stat := Overflow;
    RETURN
  END; (* IF *)
    
  IF res.lowBits = 0 THEN
    res.highBits := 0 - i.highBits
  ELSE (* borrow occurred *)
    res.lowBits := MAX(LONGCARD) - i.lowBits + 1;
    res.highBits := 0 - i.highBits - 1
  END; (* IF *)  
  stat := Success
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
  RETURN n > MAX(LONGCARD) DIV m
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
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF INT64T;


(* --------------------------------------------------------------------------
 * procedure InitPow2Table
 * --------------------------------------------------------------------------
 * Initialises data table with powers of 2.
 * ----------------------------------------------------------------------- *)

PROCEDURE InitPow2Table;
VAR
  index : CARDINAL;
BEGIN
  powerOf2[0].highBits := 0;
  powerOf2[0].lowBits := 1;

  FOR index := 1 TO 31 DO
    powerOf2[index].highBits := 0;
    powerOf2[index].lowBits := powerOf2[index-1].lowBits * 2
  END; (* FOR *)

  powerOf2[32].highBits := 1;
  powerOf2[32].lowBits := 0;

  FOR index := 33 TO 63 DO
    powerOf2[index].highBits := powerOf2[index-1].highBits * 2;
    powerOf2[index].lowBits := 0
  END (* FOR *)
END InitPow2Table;


(* Initialise data table *)

BEGIN
  InitPow2Table
END INT64.