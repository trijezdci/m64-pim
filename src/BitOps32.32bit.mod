(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE BitOps32;

(* 32-bit Bit Operations for 32-bit Compiler *)


FROM SYSTEM IMPORT
  BYTE, ADDRESS, TSIZE;


(* --------------------------------------------------------------------------
 * Function:  BitOps.BIT(value, index)
 * --------------------------------------------------------------------------
 * Returns TRUE if bit at index in value is set, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE BIT ( value : WORD32; index : BitIndex ) : BOOLEAN;
BEGIN
  RETURN index IN value.bitset
END BIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SETBIT(value, index, stat)
 * --------------------------------------------------------------------------
 * Sets bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE SETBIT ( VAR value : WORD32; index : BitIndex );
BEGIN
  INCL(value.bitset, index)
END SETBIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.CLEARBIT(value, index)
 * --------------------------------------------------------------------------
 * Clears bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE CLEARBIT ( VAR value : WORD32; index : BitIndex );
BEGIN
  EXCL(value.bitset, index)
END CLEARBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.MSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the most significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE MSBIT ( VAR value : WORD32 ) : BitIndex;
VAR
  val : CARDINAL;
  shiftFactor : BitIndex;
BEGIN
  val := value.cardinal;
  
  IF val = 0 THEN
    RETURN 0
  END; (* IF *)
    
  shiftFactor := 0;
  
  IF val >= 65536 THEN
    val := val DIV 65536;
    shiftFactor := shiftFactor + 16
  END; (* IF *)
  
  IF val >= 256 THEN
    val := val DIV 256;
    shiftFactor := shiftFactor + 8
  END; (* IF *)
  
  IF val >= 16 THEN
    val := val DIV 16;
    shiftFactor := shiftFactor + 4
  END; (* IF *)
  
  IF val >= 4 THEN
    val := val DIV 4;
    shiftFactor := shiftFactor + 2
  END; (* IF *)
  
  IF val >= 2 THEN
    shiftFactor := shiftFactor + 1
  END; (* IF *)
  
    RETURN shiftFactor
END MSBIT;
 

(* --------------------------------------------------------------------------
 * Function:  BitOps.LSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the least significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE LSBIT ( VAR value : WORD32 ) : BitIndex;
VAR
  val : CARDINAL;
  shiftFactor : BitIndex;
BEGIN
  val := value.cardinal;

  IF val = 0 THEN
    RETURN 0
  END; (* IF *)

  shiftFactor := 0;

  (* Check lower 16 bits *)
  IF (val MOD 65536) = 0 THEN
    val := val DIV 65536;
    shiftFactor := shiftFactor + 16
  END; (* IF *)

  (* Check lower 8 bits *)
  IF (val MOD 256) = 0 THEN
    val := val DIV 256;
    shiftFactor := shiftFactor + 8
  END; (* IF *)

  (* Check lower 4 bits *)
  IF (val MOD 16) = 0 THEN
    val := val DIV 16;
    shiftFactor := shiftFactor + 4
  END; (* IF *)

  (* Check lower 2 bits *)
  IF (val MOD 4) = 0 THEN
    val := val DIV 4;
    shiftFactor := shiftFactor + 2
  END; (* IF *)

  (* Check the last bit *)
  IF (val MOD 2) = 0 THEN
    shiftFactor := shiftFactor + 1
  END; (* IF *)

  RETURN shift
END LSBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.BITCOUNT(value)
 * --------------------------------------------------------------------------
 * Returns the number of set bits in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE BITCOUNT ( VAR value : WORD32 ) : CARDINAL;
VAR
  val, mask1, mask2, mask3, mask4,
  valDiv2, valDiv4, valDiv16 : WORD32;
BEGIN
  val := value;

  (* initialise masks *)
  mask1.cardinal := 055555555H;
  mask2.cardinal := 033333333H;
  mask3.cardinal := 00F0F0F0FH;
  mask4.cardinal := 00000003FH;
  
  (* Count pairs: val = (val & mask1) + ((val >> 1) & mask1) *)
  valDiv2.cardinal := val.cardinal DIV 2;
  val.bitset := (val.bitset * mask1.bitset) + (valDiv2.bitset * mask1.bitset);

  (* Count nibbles: val = (val & mask2) + ((val >> 2) & mask2) *)
  valDiv4.cardinal := val.cardinal DIV 4;
  val.bitset := (val.bitset * mask2.bitset) + (vDiv4.bitset * mask2.bitset);

  (* Count bytes: val = (val & mask3) + ((val >> 4) & mask3) *)
  valDiv16.cardinal := val.cardinal DIV 16;
  val.bitset := (val.bitset * mask3.bitset) + (vDiv16.bitset * mask3.bitset);

  (* Sum adjacent bytes and 16-bit halves *)
  val.cardinal := val.cardinal + (val.cardinal DIV 0100H);
  val.cardinal := val.cardinal + (val.cardinal DIV 010000H);

  (* Final mask out to clean up the total (max 32) *)
  val.bitset := val.bitset * mask4.bitset;

  RETURN val.cardinal
END BITCOUNT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWAND(value1, value2, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise AND of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWAND ( value1, value2 : WORD32; VAR res : WORD32 );
BEGIN
  res.bitset := value1.bitset * value2.bitset
END BWAND;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise OR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWOR ( value1, value2 : WORD32; VAR res : WORD32 );
BEGIN
  res.bitset := value1.bitset + value2.bitset
END BWOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWXOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise XOR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWXOR ( val1, val2 : WORD32; VAR res : WORD32 );
BEGIN
  res.bitset := val1.bitset / val2.bitset
END BWXOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWNOT(value, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise inversion (NOT) of value in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWNOT ( value : WORD32; VAR res : WORD32 );
VAR
  mask : WORD32;
BEGIN
  mask.cardinal := 0FFFFFFFFH;
  res.bitset := mask.bitset / value.bitset
END BWNOT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHL(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value left shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SHL ( value : WORD32; shiftFactor : CARDINAL; VAR res : WORD32 );
BEGIN
  IF shiftFactor = 0 THEN
    res := value
  ELSIF shiftFactor >= 32 THEN
    res.cardinal := 0
  ELSE
    res.cardinal := value.cardinal * powerOf2[shiftFactor]
  END (* IF *)
END SHL;
  
  
(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value logically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE SHR ( value : WORD32; shiftFactor : CARDINAL; VAR res : WORD32 );
BEGIN
  IF shiftFactor = 0 THEN
    res := value
  ELSIF shiftFactor >= 32 THEN
    res.cardinal := 0
  ELSE
    res.cardinal := value.cardinal DIV powerOf2[shiftFactor]
  END (* IF *)
END SHR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.ASHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value arithmetically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE ASHR ( value : WORD32; shiftFactor : CARDINAL; VAR res : WORD32 );
VAR
  allBitsSet     : WORD32;
  shiftedMask    : WORD32;
  signExtendMask : WORD32;
BEGIN
  IF shiftFactor = 0 THEN
    res := value;
    RETURN
  END; (* IF *)
  
  IF shiftFactor >= 32 THEN
    IF 31 IN value.bitset THEN
      res.cardinal := 0FFFFFFFFH;
    ELSE
      res.cardinal := 0;
    END; (* IF *)
    RETURN
  END; (* IF *)
  
  (* logical shift right *)
  res.cardinal := value.cardinal DIV powerOf2[shiftFactor];
    
  (* if sign bit is set *)
  IF 31 IN value.bitset THEN
    (* compute mask for sign extension *)
    allBitsSet.cardinal := 0FFFFFFFFH;
    shiftedMask.cardinal := allBitsSet.cardinal DIV powerOf2[shiftFactor];
  
    (* invert mask *)
    signExtendMask.bitset := allBitsSet.bitset / shiftedMask.bitset;
      
    (* apply mask to shifted result *)
    res.bitset := res.bitset + signExtendMask.bitset;
    END
  END
END ASHR;


(* ************************************************************************ *
 * Private Operations                                                       *
 * ************************************************************************ *)

(* ---------------------------------------------------------------------------
 * Powers of 2 table
 * ------------------------------------------------------------------------ *)

VAR
  powerOf2 : ARRAY [0..MAX(BitIndex)] OF CARDINAL;
  

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
  FOR index := 1 TO Bitwidth-2 DO
    powerOf2[index] := powerOf2[index-1] * 2
  END; (* FOR *)
  powerOf2[Bitwidth-1] := MAX(CARDINAL)
END InitPow2Table;


(* ---------------------------------------------------------------------------
 * Module initialisation.
 * ------------------------------------------------------------------------ *)

BEGIN (* BitOps32 *)
  InitPow2Table
END BitOps32.

