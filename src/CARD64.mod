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
 * Procedure:  CARD64.SetOne(res)
 * --------------------------------------------------------------------------
 * Passes the CARD64T value of 1 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetOne ( VAR res : CARD64T );
BEGIN
  res.highBits := 0;
  res.lowBits := 1
END SetOne;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.SetMax(res)
 * --------------------------------------------------------------------------
 * Passes the largest value of type CARD64T (0xFFFFFFFF:0xFFFFFFFF) in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SetMax ( VAR res : CARD64T );
BEGIN
  res.highBits := MAX(LONGCARD); (* 0xFFFFFFFF *)
  res.lowBits := MAX(LONGCARD)   (* 0xFFFFFFFF *)
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
  IF n.highBits # 0 THEN
    stat := Overflow;
    RETURN
  ELSE
    res := n.lowBits;
    stat := Success
  END (* IF *)
END ToLongCard;


(* --------------------------------------------------------------------------
 * Function:  CARD64.isZero(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is 0, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isZero ( n : CARD64T ) : BOOLEAN;
BEGIN
  RETURN (n.highBits = 0) AND (n.lowBits = 0)
END isZero;


(* --------------------------------------------------------------------------
 * Function:  CARD64.isOne(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is 1, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isOne ( n : CARD64T ) : BOOLEAN;
BEGIN
  RETURN (n.highBits = 0) AND (n.lowBits = 1)
END isOne;


(* --------------------------------------------------------------------------
 * Function:  CARD64.isMax(value)
 * --------------------------------------------------------------------------
 * Returns TRUE if value is MAX(CARD64T), otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE isMax ( n : CARD64T ) : BOOLEAN;
BEGIN
  RETURN (n.highBits = MAX(LONGCARD)) AND (n.lowBits = MAX(LONGCARD))
END isMax;


(* --------------------------------------------------------------------------
 * Function:  CARD64.odd(n)
 * --------------------------------------------------------------------------
 * Returns TRUE if n is odd, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE odd ( n : CARD64T ) : BOOLEAN;
BEGIN
  RETURN ODD(n.lowBits)
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
    stat := Overflow;
    RETURN
  ELSIF (carry = 1) AND (left.highBits + right.highBits = MAX(LONGCARD)) THEN
    stat := Overflow;
    RETURN
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
VAR
  prod : CARD64T;
BEGIN
  IF ((left.highBits = 0) AND (left.lowBits = 0)) OR 
     ((right.highBits = 0) AND (right.lowBits = 0)) THEN
    SetZero(res);
    stat := Success;
    RETURN;
  END; (* IF *)
  
  CrossProdMul(left, right, prod, stat);
  IF stat = Success THEN
    res := prod
  END (* IF *)
END Mul;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Div(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the quotient left DIV right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Div ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  ignore : CARD64T;
BEGIN
  IF isZero(right) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)
    
  IF isZero(left) THEN
    res := left
  ELSIF isOne(right) THEN
    res := left
  ELSIF isOne(left) THEN
    SetZero(res)
  ELSIF eq(left, right) THEN
    SetOne(res)
  ELSE
    DivMod(left, right, res, ignore)
  END; (* IF *)
  
  stat := Success
END Div;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Mod(left, right, res, stat)
 * --------------------------------------------------------------------------
 * Passes the remainder left MOD right in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Mod ( left, right : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  ignore : CARD64T;
BEGIN
  IF isZero(right) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)
    
  IF isZero(left) THEN
    res := left
  ELSIF isOne(right) THEN
    SetZero(res)
  ELSIF isOne(left) THEN
    res := left
  ELSIF eq(left, right) THEN
    SetZero(res)
  ELSE
    DivMod(left, right, ignore, res)
  END; (* IF *)
  
  stat := Success
END Mod;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Pow2(n, res, stat)
 * --------------------------------------------------------------------------
 * Passes the n-th power of 2 in res, status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE Pow2 ( n : CARDINAL; VAR res : CARD64T; VAR stat : Status );
BEGIN
  IF n >= Bitwidth THEN
    stat := Overflow;
    RETURN
  END; (* IF *)
  
  res := powerOf2[n];
  stat := Success
END Pow2;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Log2(n, res, stat)
 * --------------------------------------------------------------------------
 * the integral part of the binary logarithm of n in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Log2 ( n : CARD64T; VAR res : CARD64T; VAR stat : Status );
BEGIN
  IF isZero(n) THEN
    stat := DivByZero;
    RETURN
  END; (* IF *)

  IF n.highBits # 0 THEN
    res := 32 + log2LC(n.highBits)
  ELSE
    res := log2LC(n.lowBits)
  END; (* IF *)

  stat := Success
END Log2;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Shl(n, shift, res)
 * --------------------------------------------------------------------------
 * Shifts n left by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shl ( n : CARD64T; shift : CARDINAL; VAR res : CARD64T );
VAR
  s : CARDINAL;
  p, powS, powInv, carryBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := n;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift >= 32 THEN
    res.lowBits := 0;
    s := shift - 32;
    powS := powerOf2[s].lowBits;
    IF prodOverflowsLC(n.lowBits, powS) THEN
      stat := Overflow;
      RETURN
    END; (* IF *)
    res.highBits := n.lowBits * powS;
    RETURN
  ELSE (* 1 <= shift < 32 *)
    powS := powerOf2[shift].lowBits;
    powInv := powerOf2[32 - shift].lowBits;
    carryBits := n.lowBits DIV powInv;
    IF prodOverflowsLC(n.highBits, powS) THEN
      stat := Overflow;
      RETURN
    END; (* IF *)
    p := n.highBits * powS;
    IF sumOverflowsLC(p, carryBits) THEN
      stat := Overflow;
      RETURN
    END; (* IF *)
    res.highBits := p + carryBits;
    res.lowBits := n.lowBits * powS;
    RETURN
  END (* IF *)
END Shl;


(* --------------------------------------------------------------------------
 * Procedure:  CARD64.Shr(n, shift, res)
 * --------------------------------------------------------------------------
 * Logical shift right of n by shift bits. Passes result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE Shr ( n : CARD64T; shift : CARDINAL; VAR res : CARD64T );
VAR
  s : CARDINAL;
  powS, powInv, carryBits : LONGCARD;
BEGIN
  IF shift = 0 THEN
    res := n;
    RETURN
  ELSIF shift >= 64 THEN
    res.highBits := 0;
    res.lowBits := 0;
    RETURN
  ELSIF shift >= 32 THEN
    res.highBits := 0;
    s := shift - 32;
    powS := powerOf2(s);
    res.lowBits := n.highBits DIV powS;
    RETURN
  ELSE (* 1 <= shift < 32 *)
    powS := powerOf2(shift);
    powInv := powerOf2(32 - shift);
    carryBits := n.highBits MOD powS;
    res.highBits := n.highBits DIV powS;
    res.lowBits := (n.lowBits DIV powS) + (carryBits * powInv);
    RETURN
  END (* IF *)
END Shr;


(* **************************************************************************
 * P R I V A T E   P R O C E D U R E S
 * *********************************************************************** *)

(* --------------------------------------------------------------------------
 * Procedure: TwosComplement(n, res, stat)
 * --------------------------------------------------------------------------
 * Computes the two's complement of n, passes result in res, status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE TwosComplement ( n : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  one, maxCard64 : CARD64T;
BEGIN
  SetOne(one);
  SetMax(maxCard64);
  Sub(maxCard64, n, res, stat);
  Add(res, one, res, stat);
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
 * Function:  sumOverflows(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if the sum of n and m would overflow CARD64T, else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE sumOverflows ( n, m : CARD64T ) : BOOLEAN;
VAR
  ignore : Status;
  diff, maxCard64 : CARD64T;
BEGIN
  SetMax(maxCard64);
  Sub(maxCard64, m, diff, ignore);
  RETURN gt(n, diff)
END sumOverflows;


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
 * Function:  prodOverflows(n, m)
 * --------------------------------------------------------------------------
 * Returns TRUE if the product n * m would overflow CARD64T, else FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE prodOverflows ( n, m : CARD64T ) : BOOLEAN;
BEGIN
  (* If both upper 32-bit cardinal words are populated, the product overflows *)
  IF (n.highBits # 0) AND (m.highBits # 0) THEN
    RETURN TRUE
  END;

  IF (m.highBits # 0) AND (n.lowBits > (MAX(LONGCARD) DIV m.highBits)) THEN
    RETURN TRUE
  END;
  
  IF (n.highBits # 0) AND (m.lowBits > (MAX(LONGCARD) DIV n.highBits)) THEN
    RETURN TRUE
  END; (*IF *)
  
  RETURN FALSE
END prodOverflows;


(* --------------------------------------------------------------------------
 * Procedure: CrossProdMulLC(n, m, res)
 * --------------------------------------------------------------------------
 * Calculates the LONGCARD product n * m, using cross product multiplication,
 * passes the result in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE CrossProdMulLC ( n, m : LONGCARD; VAR res : CARD64T );
VAR
  sumOfLHandHL, carry,
  nLow, nHigh, mLow, mHigh,
  prodLL, prodLH, prodHL, prodHH : LONGCARD;
BEGIN
  (* Split 32-bit factors into 16-bit halves *)
  nLow  := n MOD 010000H;
  nHigh := n DIV 010000H;
  mLow  := m MOD 010000H;
  mHigh := m DIV 010000H;

  (* Calculate 16-bit cross products *)
  prodLL := nLow * mLow;
  prodLH := nLow * mHigh;
  prodHL := nHigh * mLow;
  prodHH := nHigh * mHigh;

  (* LH + HL *)
  sumOfLHandHL := prodLH + prodHL;
  IF sumOfLHandHL < prodLH THEN
    carry := 010000H;
  ELSE
    carry := 0;
  END;

  (* nLow * mLow + nLow * mHigh + nHigh * mLow *)
  res.lowBits := prodLL + ((sumOfLHandHL MOD 010000H) * 010000H);
  IF res.lowBits < prodLL THEN
    carry := carry + 1
  END; (* IF *)
  
  res.highBits := prodHH + (sumOfLHandHL DIV 010000H) + carry;
END CrossProdMulLC;


(* --------------------------------------------------------------------------
 * Procedure: CrossProdMul ( n, m, res, stat )
 * --------------------------------------------------------------------------
 * Calculates the LONGCARD product n * m, using cross product multiplication,
 * passes the result in res, and the status in stat.
 * ----------------------------------------------------------------------- *)

PROCEDURE CrossProdMul ( n, m : CARD64T; VAR res : CARD64T; VAR stat : Status );
VAR
  prodLH, prodHL, resHigh : LONGCARD;
  prodLL : CARD64T;
BEGIN
  IF prodOverflows(n, m) THEN
    stat := Overflow;
    RETURN
  END; (* IF *)
  
  prodLH := n.lowBits * m.highBits;
  prodHL := n.highBits * m.lowBits;
  CrossProdMulLC(n.lowBits, m.lowBits, prodLL);

  IF (MAX(LONGCARD) - prodLL.highBits) < prodLH THEN
    stat := Overflow;
    RETURN;
  END; (* IF *)
  resHigh := prodLL.highBits + prodLH;

  IF (MAX(LONGCARD) - resHigh) < prodHL THEN
    stat := Overflow;
    RETURN;
  END;
  resHigh := resHigh + prodHL;

  res.lowBits  := prodLL.lowBits;
  res.highBits := resHigh;
  stat         := Success;
END CrossProdMul;


(* --------------------------------------------------------------------------
 * Procedure:  DivMod(n, m, quot, rem)
 * --------------------------------------------------------------------------
 * Passes quotient and remainder in quot and rem.  Divisor must not be zero.
 * ----------------------------------------------------------------------- *)

PROCEDURE DivMod ( n, m : CARD64T; VAR quot, rem : CARD64T );

(* Implements Knuth's Algorithm D (TAoCP Vol 2, 4.3.1) with digit base 2^16,
 * so that every intermediate product and sum fits into a 32-bit LONGCARD.
 * Digit arrays are little endian: index 0 is the least significant digit. *)

CONST
  Base = 010000H; (* 2^16 *)

VAR
  u, v, q, r : ARRAY [0..3] OF LONGCARD; (* dividend, divisor, quot, rem *)
  un : ARRAY [0..4] OF LONGCARD;         (* normalised dividend, 1 extra *)
  vn : ARRAY [0..3] OF LONGCARD;         (* normalised divisor *)
  numLen, denLen, i, j, k : CARDINAL;
  qhat, rhat, cur, prod, carry, borrow, mulS, divS, vTop : LONGCARD;
  done : BOOLEAN;

BEGIN
  (* dividend < divisor *)
  IF lt(n, m) THEN
    rem := n;
    SetZero(quot);
    RETURN
  END; (* IF *)

  (* both operands fit into 32 bits *)
  IF (n.highBits = 0) AND (m.highBits = 0) THEN
    quot.highBits := 0;
    quot.lowBits := n.lowBits DIV m.lowBits;
    rem.highBits := 0;
    rem.lowBits := n.lowBits MOD m.lowBits;
    RETURN
  END; (* IF *)

  (* split into 16-bit digits *)
  u[0] := n.lowBits MOD Base;
  u[1] := n.lowBits DIV Base;
  u[2] := n.highBits MOD Base;
  u[3] := n.highBits DIV Base;

  v[0] := m.lowBits MOD Base;
  v[1] := m.lowBits DIV Base;
  v[2] := m.highBits MOD Base;
  v[3] := m.highBits DIV Base;

  (* count significant digits; n >= m > 0 here so both loops terminate *)
  numLen := 4;
  WHILE u[numLen-1] = 0 DO
    DEC(numLen)
  END; (* WHILE *)

  denLen := 4;
  WHILE v[denLen-1] = 0 DO
    DEC(denLen)
  END; (* WHILE *)

  FOR i := 0 TO 3 DO
    q[i] := 0;
    r[i] := 0
  END; (* FOR *)

  IF denLen = 1 THEN
    (* single-digit divisor: short division *)
    rhat := 0;
    FOR i := 0 TO numLen-1 DO
      j := numLen - 1 - i;
      cur := rhat * Base + u[j];
      q[j] := cur DIV v[0];
      rhat := cur MOD v[0]
    END; (* FOR *)
    r[0] := rhat

  ELSE
    (* D1: normalise so that the top divisor digit is >= Base/2 *)
    mulS := 1;
    vTop := v[denLen-1];
    WHILE vTop < 08000H DO
      vTop := vTop * 2;
      mulS := mulS * 2
    END; (* WHILE *)
    divS := Base DIV mulS;

    vn[0] := (v[0] * mulS) MOD Base;
    FOR i := 1 TO denLen-1 DO
      vn[i] := (v[i] * mulS) MOD Base + v[i-1] DIV divS
    END; (* FOR *)

    un[0] := (u[0] * mulS) MOD Base;
    FOR i := 1 TO numLen-1 DO
      un[i] := (u[i] * mulS) MOD Base + u[i-1] DIV divS
    END; (* FOR *)
    un[numLen] := u[numLen-1] DIV divS;

    (* D2: loop over quotient digits, most significant first *)
    FOR k := 0 TO numLen-denLen DO
      j := numLen - denLen - k;

      (* D3: estimate quotient digit *)
      cur := un[j+denLen] * Base + un[j+denLen-1];
      qhat := cur DIV vn[denLen-1];
      rhat := cur MOD vn[denLen-1];
      done := FALSE;
      WHILE NOT done DO
        (* short-circuit evaluation guarantees no 32-bit overflow *)
        IF (qhat >= Base) OR
           (qhat * vn[denLen-2] > Base * rhat + un[j+denLen-2]) THEN
          qhat := qhat - 1;
          rhat := rhat + vn[denLen-1];
          done := rhat >= Base
        ELSE
          done := TRUE
        END (* IF *)
      END; (* WHILE *)

      (* D4: multiply and subtract: un[j..j+denLen] -= qhat * vn *)
      carry := 0;
      borrow := 0;
      FOR i := 0 TO denLen-1 DO
        prod := qhat * vn[i] + carry;
        carry := prod DIV Base;
        prod := prod MOD Base + borrow;
        IF un[i+j] >= prod THEN
          un[i+j] := un[i+j] - prod;
          borrow := 0
        ELSE
          un[i+j] := un[i+j] + Base - prod;
          borrow := 1
        END (* IF *)
      END; (* FOR *)

      prod := carry + borrow;
      IF un[j+denLen] >= prod THEN
        un[j+denLen] := un[j+denLen] - prod;
        borrow := 0
      ELSE
        un[j+denLen] := un[j+denLen] + Base - prod;
        borrow := 1
      END; (* IF *)

(* D5/D6: borrow out of the top digit means the subtraction underflowed,
   ie. qhat was one too large. Decrement qhat and add divisor back,
   which wraps the window around to the correct remainder. *)
      IF borrow = 1 THEN
        qhat := qhat - 1;
        carry := 0;
        FOR i := 0 TO denLen-1 DO
          cur := un[i+j] + vn[i] + carry;
          un[i+j] := cur MOD Base;
          carry := cur DIV Base
        END; (* FOR *)
        un[j+denLen] := (un[j+denLen] + carry) MOD Base
      END; (* IF *)

      q[j] := qhat
    END; (* FOR *)

    (* D8: denormalise remainder *)
    FOR i := 0 TO denLen-1 DO
      r[i] := un[i] DIV mulS + (un[i+1] MOD mulS) * divS
    END (* FOR *)
  END; (* IF *)

  (* pass result *)
  quot.lowBits := q[0] + q[1] * Base;
  quot.highBits := q[2] + q[3] * Base;
  rem.lowBits := r[0] + r[1] * Base;
  rem.highBits := r[2] + r[3] * Base
END DivMod;


(* --------------------------------------------------------------------------
 * Function: log2LC(n)
 * --------------------------------------------------------------------------
 * Returns the integral part of the base-2 logarithm of non-zero n.
 * ----------------------------------------------------------------------- *)

PROCEDURE log2LC ( n : LONGCARD ) : CARDINAL;
VAR
  res : CARDINAL;
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
END log2LC;


(* --------------------------------------------------------------------------
 * Data table for powers of 2
 * ----------------------------------------------------------------------- *)

VAR
  powerOf2 : ARRAY [0..Bitwidth-1] OF CARD64T;


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
END CARD64.
