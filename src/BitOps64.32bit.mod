(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE BitOps64;

(* 64-bit Bit Operations for 32-bit Compiler *)


FROM SYSTEM IMPORT
  BYTE, TSIZE;


(* ---------------------------------------------------------------------------
 * Register bit width
 * ------------------------------------------------------------------------ *)

CONST RegBitwidth = Bitwidth DIV 2;


(* ---------------------------------------------------------------------------
 * Highest bit index in register
 * ------------------------------------------------------------------------ *)

CONST Highbit = RegBitwidth - 1;


(* --------------------------------------------------------------------------
 * Function:  BitOps.BIT(value, index)
 * --------------------------------------------------------------------------
 * Returns TRUE if bit at index in value is set, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE BIT ( value : WORD64; index : BitIndex ) : BOOLEAN;
BEGIN
  IF index < RegBitwidth THEN
    RETURN index IN value.bitset64.lowBits;
  ELSE (* index >= 32 *)
    RETURN (index - RegBitwidth) IN value.bitset64.highBits;
  END (* IF *)
END BIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SETBIT(value, index, stat)
 * --------------------------------------------------------------------------
 * Sets bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE SETBIT ( VAR value : WORD64; index : BitIndex );
BEGIN
  IF index < RegBitwidth THEN
    INCL(value.bitset64.lowBits, index);
  ELSE (* index >= 32 *)
    INCL(value.bitset64.highBits, index - RegBitwidth);
  END (* IF *)
END SETBIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.CLEARBIT(value, index)
 * --------------------------------------------------------------------------
 * Clears bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE CLEARBIT ( VAR value : WORD64; index : BitIndex );
BEGIN
BEGIN
  IF index < RegBitwidth THEN
    EXCL(value.bitset64.lowBits, index);
  ELSE (* index >= 32 *)
    EXCL(value.bitset64.highBits, index - RegBitwidth);
  END (* IF *)
END CLEARBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.MSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the most significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE MSBIT ( VAR value : WORD64 ) : BitIndex;
VAR
  val  : LONGCARD;
  shiftFactor : BitIndex;
BEGIN
  IF value.card64.highBits > 0 THEN
    val := value.card64.highBits;
    shiftFactor := RegBitwidth
  ELSE
    val := value.card64.lowBits;
    shiftFactor := 0
  END; (* IF *)

  IF val = 0 THEN
    RETURN 0
  END; (* IF *)

  IF val >= 65536 THEN
    val := val DIV 65536;
    shiftFactor := shiftFactor + 16;
  END; (* IF *)

  IF val >= 256 THEN
    val := val DIV 256;
    shiftFactor := shiftFactor + 8;
  END; (* IF *)

  IF val >= 16 THEN
    val := val DIV 16;
    shiftFactor := shiftFactor + 4;
  END; (* IF *)

  IF val >= 4 THEN
    val := val DIV 4;
    shiftFactor := shiftFactor + 2;
  END; (* IF *)

  IF val >= 2 THEN
    shiftFactor := shiftFactor + 1;
  END; (* IF *)

  RETURN shiftFactor
END MSBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.LSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the least significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE LSBIT ( VAR value : WORD64 ) : BitIndex;
VAR
  val : LONGCARD;
  shiftFactor : BitIndex;
BEGIN
  IF value.card64.lowBits > 0 THEN
    val := value.card64.lowBits;
    shiftFactor := 0
  ELSE
    val := value.card64.highBits;
    shiftFactor := RegBitwidth
  END; (* IF *)

  IF val = 0 THEN
    RETURN 0
  END; (* IF *)

  IF (val MOD 65536) = 0 THEN
    val := val DIV 65536;
    shiftFactor := shiftFactor + 16
  END; (* IF *)

  IF (val MOD 256) = 0 THEN
    val := val DIV 256;
    shiftFactor := shiftFactor + 8
  END; (* IF *)

  IF (val MOD 16) = 0 THEN
    val := val DIV 16;
    shiftFactor := shiftFactor + 4
  END; (* IF *)

  IF (val MOD 4) = 0 THEN
    val := val DIV 4;
    shiftFactor := shiftFactor + 2
  END; (* IF *)

  IF (val MOD 2) = 0 THEN
    shiftFactor := shiftFactor + 1
  END; (* IF *)

  RETURN shiftFactor
END LSBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.BITCOUNT(value)
 * --------------------------------------------------------------------------
 * Returns the number of set bits in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE BITCOUNT ( VAR value : WORD64 ) : CARDINAL;
VAR
  val, mask1, mask2, mask3, mask4 : LONGCARD;
  valDiv2, valDiv4, valDiv16 : LONGCARD;
  lowCount, highCount : CARDINAL;
BEGIN
  (* initialise masks *)
  mask1 := 055555555H;
  mask2 := 033333333H;
  mask3 := 00F0F0F0FH;
  mask4 := 00000003FH;

  (* count bits in the lower 32-bit word *)
  val := value.card64.lowBits;
  
  valDiv2 := val DIV 2;
  val := (val AND mask1) + (valDiv2 AND mask1);
  
  valDiv4 := val DIV 4;
  val := (val AND mask2) + (valDiv4 AND mask2);
  
  valDiv16 := val DIV 16;
  val := (val AND mask3) + (valDiv16 AND mask3);
  
  val := val + (val DIV 0100H);
  val := val + (val DIV 010000H);
  lowCount := val AND mask4;

  (* count bits in the upper 32-bit word *)
  val := value.card64.highBits;
  
  valDiv2 := val DIV 2;
  val := (val AND mask1) + (vDiv2 AND mask1);
  
  valDiv4 := val DIV 4;
  val := (val AND mask2) + (vDiv4 AND mask2);
  
  valDiv16 := val DIV 16;
  val := (val AND mask3) + (vDiv16 AND mask3);
  
  val := val + (val DIV 0100H);
  val := val + (val DIV 010000H);
  highCount := val AND mask4;

  RETURN lowCount + highCount
END BITCOUNT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWAND(value1, value2, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise AND of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWAND ( value1, value2 : WORD64; VAR res : WORD64 );
BEGIN
  res.bitset64.lowBits := value1.bitset64.lowBits * value2.bitset64.lowBits;
  res.bitset64.highBits := value1.bitset64.highBits * value2.bitset64.highBits;
END BWAND;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise OR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWOR ( value1, value2 : WORD64; VAR res : WORD64 );
BEGIN
  res.bitset64.lowBits := value1.bitset64.lowBits + value2.bitset64.lowBits;
  res.bitset64.highBits := value1.bitset64.highBits + value2.bitset64.highBits;
END BWOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWXOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise XOR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWXOR ( val1, val2 : WORD64; VAR res : WORD64 );
BEGIN
  res.bitset64.lowBits := val1.bitset64.lowBits / val2.bitset64.lowBits;
  res.bitset64.highBits := val1.bitset64.highBits / val2.bitset64.highBits;
END BWXOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWNOT(value, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise inversion (NOT) of value in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWNOT ( value : WORD64; VAR res : WORD64 );
VAR
  mask : WORD32;
BEGIN
  mask.cardinal := 0FFFFFFFFH;
  res.bitset64.lowBits := mask.bitset / value.bitset64.lowBits;
  res.bitset64.highBits := mask.bitset / value.bitset64.highBits;
END BWNOT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHL(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value left shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SHL ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
VAR
  overflowMask,
  overflowBits : WORD32;
BEGIN
  IF shiftFactor = 0 THEN
    res := value
  ELSIF shiftFactor >= Bitwidth THEN
    res.card64.lowBits := 0;
    res.card64.highBits := 0
  ELSIF shiftFactor >= RegBitwidth THEN
    res.card64.highBits :=
      value.card64.lowBits * powerOf2[shiftFactor - RegBitwidth];
    res.card64.lowBits := 0
  ELSE
    (* shift left *)
    res.card64.lowBits := value.card64.lowBits * powerOf2[shiftFactor];
    res.card64.highBits := value.card64.highBits * powerOf2[shiftFactor];
    
    (* mask overflow bits *)
    overflowMask.cardinal := 0FFFFFFFFH DIV powerOf2[RegBitwidth - shiftFactor];
    overflowMask.cardinal :=
      overflowMask.cardinal * powerOf2[RegBitwidth - shiftFactor];
    
    overflowBits.cardinal := value.card64.lowBits;
    overflowBits.bitset := overflowBits.bitset * overflowMask.bitset;
    
    (* shift the overflow bits down *)
    overflowBits.cardinal :=
      overflowBits.cardinal / powerOf2[RegBitwidth - shiftFactor];
    
    (* merge overflow bits into the high register *)
    res.card64.highBits := res.card64.highBits + overflowBits.cardinal
  END (* IF *)
END SHL;

  
(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value logically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE SHR ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
VAR
  underflowMask,
  underflowBits : WORD32;
BEGIN
  IF shiftFactor = 0 THEN
    res := value;
  ELSIF shiftFactor >= Bitwidth THEN
    res.card64.lowBits := 0;
    res.card64.highBits := 0;
  ELSIF shiftFactor >= RegBitwidth THEN
    res.card64.lowBits :=
      value.card64.highBits DIV powerOf2[shiftFactor - RegBitwidth];
    res.card64.highBits := 0;
  ELSE
    (* shift right *)
    res.card64.lowBits := value.card64.lowBits DIV powerOf2[shiftFactor];
    res.card64.highBits := value.card64.highBits DIV powerOf2[shiftFactor];
    
    (* mask underflow bits *)
    underflowMask.cardinal := 0FFFFFFFFH DIV powerOf2[RegBitwidth - shiftFactor];
    
    underflowBits.cardinal := value.card64.highBits;
    underflowBits.bitset := unerflowBits.bitset * unerflowMask.bitset;
    
    (* shift the overflow bits up *)
    underflowBits.cardinal :=
      underflowBits.cardinal * powerOf2[RegBitwidth - shiftFactor];
    
    (* merge underflow bits into the low register *)
    res.card64.lowBits := res.card64.lowBits + underflowBits.cardinal
  END (* IF *)
END SHR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.ASHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value arithmetically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE ASHR ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
VAR
  allBitsSet,
  shiftedMask,
  signExtendMask : WORD32;
BEGIN
  IF shiftFactor = 0 THEN
    res := value
    RETURN
  END; (* IF *)
  
  IF shiftFactor >= Bitwidth THEN
    IF Highbit IN value.bitset64.highBits THEN
      res.card64.lowBits := 0FFFFFFFFH;
      res.card64.highBits := 0FFFFFFFFH
    ELSE (* high bit not set *)
      res.card64.lowBits := 0;
      res.card64.highBits := 0
    END; (* IF *)
    RETURN
  END; (* IF *)
  
  (* logical shift right *)
  SHR(value, shiftFactor, res);
    
  (* if sign bit is set *)
  IF Highbit IN value.bitset64.highBits THEN
    (* compute mask for sign extension *)
    allBitsSet.cardinal := 0FFFFFFFFH;
      
    IF shiftFactor >= RegBitwidth THEN
      (* sign extension high register *)
      res.card64.highBits := 0FFFFFFFFH;
        
      (* sign extension lower register *)
      shiftedMask.cardinal :=
        allBitsSet.cardinal DIV powerOf2[shiftFactor - RegBitwidth];
      signExtendMask.bitset := allBitsSet.bitset / shiftedMask.bitset;
      res.bitset64.lowBits := res.bitset64.lowBits + signExtendMask.bitset
    ELSE (* shiftFactor < 32 *)
      (* sign extension upper bits of high register *)
      shiftedMask.cardinal := allBitsSet.cardinal DIV powerOf2[shiftFactor];
      signExtendMask.bitset := allBitsSet.bitset / shiftedMask.bitset;
      res.bitset64.highBits := res.bitset64.highBits + signExtendMask.bitset
    END (* IF *)
  END (* IF *)
END ASHR;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * Powers of 2 table
 * ------------------------------------------------------------------------ *)

VAR
  powerOf2 : ARRAY [0..HighBit] OF LONGCARD;


(* ---------------------------------------------------------------------------
 * private procedure InitPow2Table
 * ---------------------------------------------------------------------------
 * Initialises the powers of 2 table
 * ------------------------------------------------------------------------ *)

PROCEDURE InitPow2Table;

VAR
  index : BitIndex;
  
BEGIN
  powerOf2[0] := 1;
  FOR index := 1 TO Highbit DO
    powerOf2[index] := powerOf2[index-1] * 2
  END (* FOR *)
END InitPow2Table;


(* ---------------------------------------------------------------------------
 * Module initialisation.
 * ------------------------------------------------------------------------ *)

BEGIN (* BitOps64 *)
  InitPow2Table
END BitOps64.
