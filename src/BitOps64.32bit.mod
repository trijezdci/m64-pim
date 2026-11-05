(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE BitOps64;

(* 64-bit Bit Operations for 32-bit Compiler *)


FROM SYSTEM IMPORT
  BYTE, TSIZE;


(* ---------------------------------------------------------------------------
 * BitOps64 Operand Type
 * ------------------------------------------------------------------------ *)
(*
TYPE WORD64 = RECORD
  CASE : CARDINAL OF
    0 : card64 :
      RECORD
        highBits,
        lowBits : LONGCARD
      END
  | 1 : int64 :
      RECORD
        highBits : LONGINT;
        lowBits : LONGCARD
      END
  | 2 : longreal :
      LONGREAL
  | 3 : bitset64 :
      RECORD
        highBits,
        lowBits : BITSET
      END
  | 4 : arrOfByte :
      ARRAY [0..7] OF BYTE
  END (* CASE *)
END; (* WORD64 *)
*)


(* ---------------------------------------------------------------------------
 * Bit width
 * ------------------------------------------------------------------------ *)
(*
CONST Bitwidth = TSIZE(WORD64) * 8;
*)

(* ---------------------------------------------------------------------------
 * Bit Index Type
 * ------------------------------------------------------------------------ *)
(*
TYPE BitIndex = CARDINAL [0..Bitwidth-1];
*)

(* --------------------------------------------------------------------------
 * Function:  BitOps.BIT(value, index)
 * --------------------------------------------------------------------------
 * Returns TRUE if bit at index in value is set, otherwise FALSE.
 * ----------------------------------------------------------------------- *)

PROCEDURE BIT ( value : WORD64; index : BitIndex ) : BOOLEAN;
BEGIN

END BIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SETBIT(value, index, stat)
 * --------------------------------------------------------------------------
 * Sets bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE SETBIT ( VAR value : WORD64; index : BitIndex );
BEGIN

END SETBIT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.CLEARBIT(value, index)
 * --------------------------------------------------------------------------
 * Clears bit at index in value.  !!! Destructive Operation !!!
 * ----------------------------------------------------------------------- *)

PROCEDURE CLEARBIT ( VAR value : WORD64; index : BitIndex );
BEGIN

END CLEARBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.MSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the most significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE MSBIT ( VAR value : WORD64 ) : BitIndex;
BEGIN

END MSBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.LSBIT(value)
 * --------------------------------------------------------------------------
 * Returns the bit index of the least significant set bit in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE LSBIT ( VAR value : WORD64 ) : BitIndex;
BEGIN

END LSBIT;


(* --------------------------------------------------------------------------
 * Function:  BitOps.BITCOUNT(value)
 * --------------------------------------------------------------------------
 * Returns the number of set bits in value.
 * ----------------------------------------------------------------------- *)

PROCEDURE BITCOUNT ( VAR value : WORD64 ) : CARDINAL;
BEGIN

END BITCOUNT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWAND(value1, value2, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise AND of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWAND ( value1, value2 : WORD64; VAR res : WORD64 );
BEGIN

END BWAND;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise OR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWOR ( value1, value2 : WORD64; VAR res : WORD64 );
BEGIN

END BWOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWXOR(value1, value2, res, stat)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise XOR of value1 and value2 in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWXOR ( val1, val2 : WORD64; VAR res : WORD64 );
BEGIN

END BWXOR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.BWNOT(value, res)
 * --------------------------------------------------------------------------
 * Passes the result of bitwise inversion (NOT) of value in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE BWNOT ( value : WORD64; VAR res : WORD64 );
BEGIN

END BWNOT;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHL(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value left shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)

PROCEDURE SHL ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
BEGIN

END SHL;

  
(* --------------------------------------------------------------------------
 * Procedure:  BitOps.SHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value logically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE SHR ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
BEGIN

END SHR;


(* --------------------------------------------------------------------------
 * Procedure:  BitOps.ASHR(value, shiftFactor, res)
 * --------------------------------------------------------------------------
 * Passes value arithmetically right shifted by shiftFactor in res.
 * ----------------------------------------------------------------------- *)
 
PROCEDURE ASHR ( value : WORD64; shiftFactor : CARDINAL; VAR res : WORD64 );
BEGIN

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

END InitPow2Table;


(* ---------------------------------------------------------------------------
 * Module initialisation.
 * ------------------------------------------------------------------------ *)

BEGIN (* BitOps64 *)
  InitPow2Table
END BitOps64.
