(*!m2pim+mocka*)

(* ------------------------------------------------------------------------ *
 * MOCKA Modula-2 Compiler System, Version 2610                             *
 *                                                                          *
 * Copyright (C) 1988-2000 by                                               *
 *  GMD Gesellschaft fuer Mathematik und Datenverarbeitung,                 *
 *  Ehemalige GMD Forschungsstelle an der Uni Karlsruhe;                    *
 *  [EN] German National Research Center for Computer Science,              *
 *  Former GMD Research Lab at the University of Karlsruhe.                 *
 *                                                                          *
 * Copyright (C) 2001-2018 by                                               *
 *  Fraunhofer-Gesellschaft zur Foerderung der angewandten Forschung;       *
 *  [EN] Fraunhofer Society for the Advancement of Applied Research.        *
 *                                                                          *
 * Copyright (C) 2026 by Fraunhofer & Benjamin Kowarsch                     *
 * ------------------------------------------------------------------------ *)

(* BK 2026-10-18 : No occurrences of &, ~ and <> nor any octal literals *)

IMPLEMENTATION MODULE CgTypeMap;

(* AMD64 Backend *)

FROM ShortTypes IMPORT
  ShortCard, ShortInt;

FROM SuErrors IMPORT
  SourcePosition, ERROR;

FROM SuBase IMPORT
  CompUnitClass, ThisCompUnitClass;


VAR 
  CurActivationRecordOffset,
  CurParameterOffset     : LONGINT;
  ProcNumber             : ShortCard;

(* ------------------------------------------------------------------------
   Procedure InitTypeMap
   ------------------------------------------------------------------------
   Initialise MIN and MAX values for types REAL and LONGREAL.
   ------------------------------------------------------------------------ *)
PROCEDURE InitTypeMap;
VAR
  tr1 : RECORD 
          CASE : BOOLEAN OF
          | TRUE : r : REAL;
          | FALSE : c : CARDINAL;
          END (* CASE *)
        END; (* RECORD *)
          
  tr2 : RECORD 
          CASE : BOOLEAN OF
          | TRUE : r : LONGREAL;
          | FALSE : c2, c1 : CARDINAL;
          END (* CASE *)
        END; (* RECORD *)

BEGIN
  ProcNumber := CompUnitProcNumber;
  CurActivationRecordOffset := 0;

  (* IEEE MaxReal *)
  tr1.c := 07F7FFFFFH;
  MaxReal := tr1.r;

  (* IEEE MinReal *)
  tr1.c := 0FF7FFFFFH;
  MinReal := tr1.r;

  (* IEEE MaxLongReal *)
  tr2.c1 := 07FEFFFFFH;
  tr2.c2 := 0FFFFFFFFH;
  MaxLongReal := tr2.r;

  (* IEEE MinLongReal *)
  tr2.c1 := 0FFEFFFFFH;
  tr2.c2 := 0FFFFFFFFH;
  MinLongReal := tr2.r
END InitTypeMap;

(* ------------------------------------------------------------------------
   Function GenProcNumber
   ------------------------------------------------------------------------
   Return a unique procedure ID.
   ------------------------------------------------------------------------ *)
PROCEDURE GenProcNumber () : ShortCard;
BEGIN 
  IF ThisCompUnitClass = DefinitionModuleClass THEN
    INC (ProcNumber);
    RETURN ProcNumber
  ELSIF ThisCompUnitClass = ForeignModuleClass THEN
    RETURN CprocNumber
  ELSE
    RETURN UndefinedProcNumber
  END
END GenProcNumber;

(* ------------------------------------------------------------------------
   Function StackAlign
   ------------------------------------------------------------------------
   Return stack alignment.
   ------------------------------------------------------------------------ *)
PROCEDURE StackAlign ( i : LONGINT ) : LONGINT;
BEGIN
  RETURN ((StackAlignment - i MOD StackAlignment) MOD StackAlignment)
END StackAlign;

(* ------------------------------------------------------------------------
   Function MaxAlign
   ------------------------------------------------------------------------
   Return maximum alignment.
   ------------------------------------------------------------------------ *)
PROCEDURE MaxAlign ( i : LONGINT ) : LONGINT;
BEGIN
  RETURN ((MaxAlignment - i MOD MaxAlignment) MOD MaxAlignment)
END MaxAlign;

(* ------------------------------------------------------------------------
   Function AlignOffset
   ------------------------------------------------------------------------
   Return alignment offset.
   ------------------------------------------------------------------------ *)
PROCEDURE AlignOffset ( align : ShortCard; offset : LONGINT ) : LONGINT;
VAR aligni : LONGINT;
BEGIN
  aligni := VAL(LONGINT, align);
  RETURN (aligni - offset MOD aligni) MOD aligni
END AlignOffset;

(* ------------------------------------------------------------------------
   Procedure InitBlockAlign
   ------------------------------------------------------------------------
   Initialise alignment upon entering a block.
   ------------------------------------------------------------------------ *)
PROCEDURE InitBlockAlign
  ( InitialActivationRecordSize: LONGINT;
    VAR EnclosingActivationRecordOffset : LONGINT );
BEGIN
  EnclosingActivationRecordOffset := CurActivationRecordOffset;
  CurActivationRecordOffset := InitialActivationRecordSize;
  CurParameterOffset := ReservedParamFrameSize
END InitBlockAlign;

(* ------------------------------------------------------------------------
   Procedure FinishBlockAlign
   ------------------------------------------------------------------------
   Pass back size of activation record upon leaving a block.
   ------------------------------------------------------------------------ *)
PROCEDURE FinishBlockAlign
  ( EnclosingActivationRecordOffset : LONGINT;
    VAR ActivationRecordSize : LONGINT );
BEGIN
  ActivationRecordSize      := CurActivationRecordOffset;
  CurActivationRecordOffset := EnclosingActivationRecordOffset;
  INC(ActivationRecordSize, StackAlign (ActivationRecordSize))
END FinishBlockAlign;

(* ------------------------------------------------------------------------
   Procedure InitModuleFrameSize
   ------------------------------------------------------------------------
   Initialise static frame of current module.
   ------------------------------------------------------------------------ *)
PROCEDURE InitModuleFrameSize ( InitialModuleFrameSize : LONGINT );
BEGIN
  CurActivationRecordOffset := InitialModuleFrameSize
END InitModuleFrameSize;

(* ------------------------------------------------------------------------
   Procedure GetModuleFrameSize
   ------------------------------------------------------------------------
   Pass back static frame size of current module.
   ------------------------------------------------------------------------ *)
PROCEDURE GetModuleFrameSize ( VAR ModuleFrameSize : LONGINT );
BEGIN
  ModuleFrameSize := CurActivationRecordOffset
END GetModuleFrameSize;

(* ------------------------------------------------------------------------
   Procedure Add
   ------------------------------------------------------------------------
   Perform the operation 'op2 := op1 + op2', check for overflow.
   ------------------------------------------------------------------------ *)
PROCEDURE Add ( pos : SourcePosition; op1 : LONGINT; VAR op2 : LONGINT ); 
(* used during computation of types' sizes *)
BEGIN
  IF MaxLongInt - op1 >= op2 THEN
    INC(op2, op1)
  ELSE
    ERROR("size too large for this implementation", pos)
  END (* IF *)
END Add;

(* ------------------------------------------------------------------------
   Procedure AlignVariable
   ------------------------------------------------------------------------
   Calculate variable alignment and pass offset back in VarOffset.
   ------------------------------------------------------------------------ *)
PROCEDURE AlignVariable
  ( pos : SourcePosition;
    VarSize : LONGINT;
    VarAlign : ShortCard;
    VarIsGlobal : BOOLEAN;
    VAR VarOffset : LONGINT );
BEGIN
  IF VarIsGlobal THEN   
    Add(pos, AlignOffset(VarAlign, CurActivationRecordOffset), 
      CurActivationRecordOffset);
    VarOffset := CurActivationRecordOffset;
    Add(pos, VarSize, CurActivationRecordOffset)
  ELSE
    Add(pos, VarSize, CurActivationRecordOffset);
    Add(pos, AlignOffset (VarAlign, CurActivationRecordOffset), 
      CurActivationRecordOffset);
    VarOffset := -CurActivationRecordOffset
  END (* IF *)
END AlignVariable;

(* ------------------------------------------------------------------------
   Procedure AlignRecordField
   ------------------------------------------------------------------------
   Calculate record field alignment and pass back RecOffset & FieldOffset.
   ------------------------------------------------------------------------ *)
PROCEDURE AlignRecordField
  ( pos : SourcePosition;
    RecFieldSize : LONGINT; 
    RecFieldAlign: ShortCard;
    VAR size : LONGINT;
    VAR align : ShortCard;
    VAR RecOffset : LONGINT;
    VAR FieldOffset  : LONGINT);
VAR 
  CorrectOffset : LONGINT;
BEGIN
  CorrectOffset := AlignOffset(RecFieldAlign, RecOffset);
  Add(pos, CorrectOffset, RecOffset); 
  Add(pos, CorrectOffset, size);
  FieldOffset := RecOffset;
  Add(pos, RecFieldSize, size);
  Add(pos, RecFieldSize, RecOffset);
  IF RecFieldAlign > align THEN
    align:= RecFieldAlign
  END (* IF *)
END AlignRecordField;

(* ------------------------------------------------------------------------
   Procedure AlignParam
   ------------------------------------------------------------------------
   Calculate parameter alignment and pass back ParamOffset.
   ------------------------------------------------------------------------ *)
PROCEDURE AlignParam
  ( pos : SourcePosition;
    IsValueParam : BOOLEAN;
    IsOpenArray : BOOLEAN;
    ParamSize : LONGINT; 
    ParamAlign : ShortCard;
    VAR ParamOffset : LONGINT );
BEGIN
  Add(pos, StackAlign(CurParameterOffset), CurParameterOffset);
  IF IsValueParam THEN
    IF IsOpenArray THEN
	    ParamOffset := CurParameterOffset;
	    Add(pos, OpenArraySize, CurParameterOffset)
    ELSE (* not an open array *)
	    ParamOffset := CurParameterOffset;
	    Add(pos, ParamSize, CurParameterOffset)
    END (* IF *)
  ELSE (* VAR parameter *)  
    IF IsOpenArray THEN
      ParamOffset := CurParameterOffset;        
      Add(pos, OpenArraySize, CurParameterOffset);
    ELSE (* not an open array *)
      ParamOffset := CurParameterOffset;
    END; (* IF *)
    Add(pos, SizeADDRESS, CurParameterOffset)
  END (* IF *) 
END AlignParam;

(* ------------------------------------------------------------------------
   Procedure GetOpenArrayBounds
   ------------------------------------------------------------------------
   Pass back lwb and upb of open array.
   ------------------------------------------------------------------------ *)
PROCEDURE GetOpenArrayBounds
  ( ElemSize : LONGINT; ElemAlign : ShortCard;
    VAR lwb : LONGINT; VAR upb : LONGINT );
BEGIN
  INC(ElemSize, AlignOffset(ElemAlign, ElemSize));
  lwb := 0; upb := MaxLongInt DIV ElemSize - 1
END GetOpenArrayBounds;

(* ------------------------------------------------------------------------
   Function HighFieldOffset
   ------------------------------------------------------------------------
   Return offset of high field of the open array
   whose descriptor has offset 'base'.
   ------------------------------------------------------------------------ *)
PROCEDURE HighFieldOffset ( base : LONGINT ) : LONGINT;
BEGIN
  RETURN base + SizeADDRESS
END HighFieldOffset;

(* ------------------------------------------------------------------------
   Function GetParamSize
   ------------------------------------------------------------------------
   Returns storage size occupied by parameters
   to be called after all parameters are evaluated.
   ------------------------------------------------------------------------ *)
PROCEDURE GetParamSize () : LONGINT;
BEGIN 
  RETURN CurParameterOffset +
    StackAlign(CurParameterOffset) - ReservedParamFrameSize
END GetParamSize;

(* ------------------------------------------------------------------------
   Function GetArraySize
   ------------------------------------------------------------------------
   Returns storage size of array type.
   ------------------------------------------------------------------------ *)
PROCEDURE GetArraySize
  ( pos : SourcePosition;
    IndexLength : LONGCARD;
    CompSize : LONGINT;
    CompAlign : ShortCard) : LONGINT;
VAR
  AlignedSize, il : LONGINT;
BEGIN
  IF IndexLength > MaxLongInt THEN
    ERROR("index too large", pos);
    RETURN 0
  END; (* IF *)
  il := IndexLength;
  AlignedSize := CompSize;
  Add(pos, AlignOffset(CompAlign, AlignedSize), AlignedSize);
  IF (AlignedSize = 0) OR (il < MaxLongInt DIV AlignedSize) THEN
    RETURN (il - 1) * AlignedSize + CompSize
  ELSE
    ERROR("array too large", pos);
    RETURN 0
  END (* IF *)
END GetArraySize;

(* ------------------------------------------------------------------------
   Function AdjustedArrayElemSize
   ------------------------------------------------------------------------
   Returns ElemSize aligned to word boundary.
   ------------------------------------------------------------------------ *)
PROCEDURE AdjustedArrayElemSize
  ( ElemSize : LONGINT; ElemAlign: ShortCard ) : LONGINT;
BEGIN
  RETURN ElemSize + AlignOffset(ElemAlign, ElemSize)
END AdjustedArrayElemSize;

  (*----------------------------------------------------------------*)

(* +++ CvR 91/01/24 +++ *)
(* ------------------------------------------------------------------------
   Function GetArrayAlign
   ------------------------------------------------------------------------
   Returns array alignment.
   ------------------------------------------------------------------------ *)
PROCEDURE GetArrayAlign
  ( ElemSize : LONGINT;
    ElemAlign: ShortCard;
    ArraySize: LONGINT ) : ShortCard;
VAR
  Align: ShortCard;
BEGIN
  RETURN ElemAlign (* ??? *)
END GetArrayAlign;

(* --- CvR 91/01/24 --- *)
(* ------------------------------------------------------------------------
   Procedure GetEnumSize
   ------------------------------------------------------------------------
   Pass back allocation size and alignment of enumeration type.
   ------------------------------------------------------------------------ *)
PROCEDURE GetEnumSize
  ( MaxVal : LONGINT; VAR Size : LONGINT; VAR Align : ShortCard);
BEGIN
  IF MaxVal <= MaxChar THEN
    Size := ByteSize; Align := ByteSize;
  ELSIF MaxVal <= MaxShortCard THEN
    Size := SizeSHORTCARD; Align := AlignSHORTCARD;
  ELSE
    Size := SizeLONGCARD; Align := AlignLONGCARD;
  END (* IF *)
END GetEnumSize;

(* ------------------------------------------------------------------------
   Procedure GetSetSize
   ------------------------------------------------------------------------
   Pass back allocation size and alignment of set type.
   ------------------------------------------------------------------------ *)
PROCEDURE GetSetSize
  ( SetSize : LONGINT; VAR Size : LONGINT; VAR Align : ShortCard );
BEGIN 
  Size := SizeBITSET;
  Align := AlignBITSET;
END GetSetSize;

END CgTypeMap.
