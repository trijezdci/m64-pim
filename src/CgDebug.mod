(*!m2pim+mocka*)

(* ------------------------------------------------------------------------ *
 * MOCKA Modula-2 Compiler System, Version 1807                             *
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
 * ------------------------------------------------------------------------ *)

(* BK 2026-10-18 : No occurrences of &, ~ and <> nor any octal literals *)

IMPLEMENTATION MODULE CgDebug;

(* ------------------------------------------------------------------------ *
 * STABS Debug Format Type Mapping for AMD64 / LP64 Targets                 *
 * ------------------------------------------------------------------------ *
 * STABS ("symbol table strings") is a legacy debugging data format used by *
 * source-level debuggers to map executable binary code back to source code *
 * variables, data types,  and line numbers.  The following table shows the *
 * mapping of  internal MOCKA data types  to STABS primitive IDs for 64-bit *
 * target architectures.                                                    *
 *                                                                          *
 * STABS | MOCKA          | MOCKA               | Allocation Size and       *
 *   ID  | Internal Type  | Class Token         | Generic Representation    *
 * ------+----------------+---------------------+-------------------------- *
 *   1   | BOOLEAN        | ClassBOOLEAN        | 1 Byte (Enum)             *
 *   2   | CHAR           | ClassCHAR           | 1 Byte (0..255)           *
 *  [3]  | [SHORTCARD]    | ClassSHORTCARD      | DELETED (Re-routed)       *
 *   4   | LONGCARD       | ClassLONGCARD       | 8 Bytes (64-bit Unsig)    *
 *   5   | CARDINAL       | (Shadows LONGCARD)  | 4 Bytes (32-bit Unsig)    *
 *  [6]  | [SHORTINT]     | ClassSHORTINT       | DELETED (Re-routed)       *
 *   7   | LONGINT        | ClassLONGINT        | 8 Bytes (64-bit Signed)   *
 *   8   | INTEGER        | (Shadows LONGINT)   | 4 Bytes (32-bit Signed)   *
 *   9   | REAL           | ClassREAL           | 4 Bytes (Float)           *
 *   10  | LONGREAL       | ClassLONGREAL       | 8 Bytes (Float)           *
 *   11  | BITSET         | ClassBITSET         | 4 Bytes (32-bit Vector)   *
 *   12  | PROC           | ClassPROC           | 8 Bytes (64-bit Pointer)  *
 *   13  | WORD           | ClassWORD           | 1 Byte                    *
 *   14  | BYTE           | (Shadows ClassCHAR) | 1 Byte                    *
 *   15  | ADDRESS        | ClassADDRESS        | 8 Bytes (64-bit Pointer)  *
 *   16  | VOID           | ClassVOID           | 0 Bytes (Empty/Return)    *
 * ------------------------------------------------------------------------ *)

FROM ShortTypes IMPORT
  ShortCard, ShortInt;

FROM SYSTEM IMPORT
  ADR;

FROM Strings1 IMPORT
  EmptyString, Assign, Append, StrEq, Length;

FROM SuAlloc IMPORT
  ALLOCATE;

FROM InOut IMPORT
  WriteString, WriteLn, WriteInt;

FROM RealConv IMPORT
  LongReal2Str;

FROM libc IMPORT
  getcwd;

FROM SuBase IMPORT
  NameOfSourceFile, Enabled, DefineOption, DebugOption;

FROM SuErrors IMPORT
  SourcePosition, CompilerError;

FROM SuValues IMPORT
  Value, ValueClass, ConvToBool, ConvToChar, ConvToLongReal, ConvToString, ConvToSet;

FROM SuTokens IMPORT
  Ident, GetIdentRepr;

FROM CgAssOut IMPORT
  AssString, AssHString, AssLn, AssChar, AssInt, flush;

FROM DfTable IMPORT
  Type, TypeClass, Object, ObjectClass, ObjectList, RecordField, VariableKind;

FROM DfScopes IMPORT
  TypeVOID, CompUnitObject, RootObject;

FROM CgBase IMPORT
  ElfOption;

VAR
  DebugConstOption, DebugEnumOption : CARDINAL;


  (* =========================================================================
     MODULE CgDebug.TypeTable
     =========================================================================
     
     ========================================================================= *)

MODULE TypeTable;

  IMPORT ShortCard Type, Object, isEqual, CompilerError, ADR;
  
  EXPORT InitTypeTable, EnterType, CheckTypeId;

  CONST
    MaxTypes = 1000;

  VAR
    typeTable : ARRAY [1..MaxTypes] OF Type;
    lastTypeId : ShortCard;

  (* -------------------------------------------------------------------------
     Procedure TypeTable.InitTypeTable
     -------------------------------------------------------------------------
     
     ------------------------------------------------------------------------- *)

  PROCEDURE InitTypeTable;
  VAR
    n : CARDINAL;
  BEGIN
    FOR n := 1 TO 16 DO 
      typeTable[n] := NIL
    END; (* FOR *)
    lastTypeId := 17;
  END InitTypeTable;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.EnterType(obj, typeId, name)
     -------------------------------------------------------------------------
     
     ------------------------------------------------------------------------- *)

  PROCEDURE EnterType
    ( VAR obj : Object; VAR typeId : CARDINAL; name : ARRAY OF CHAR );
  BEGIN
    IF isEqual(obj^.name, name) THEN
      typeTable[typeId] := obj^.TypeOfType;
      DEC(typeId);
      obj := obj^.next
    ELSE
      CompilerError("assertion violation (-g Option)")
    END
  END EnterType;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.CheckTypeId(type, typeId, isNewTypeId)
     -------------------------------------------------------------------------
     
     ------------------------------------------------------------------------- *)

  PROCEDURE CheckTypeId
    ( type : Type; VAR typeId : CARDINAL; VAR isNewTypeId : BOOLEAN );
  BEGIN
    typeTable[lastTypeId] := type;
    typeId := 1;
    WHILE typeTable[typeId] # type DO
      INC(typeId)
    END;
    isNewTypeId := (typeId = lastTypeId);
    IF isNewTypeId THEN
      IF lastTypeId = MaxTypes THEN
        CompilerError("Too many types for -g Option")
      END;
      INC(lastTypeId)
    END
  END CheckTypeId;

END (* MODULE *) TypeTable;


(* =========================================================================
   MODULE CgDebug.StabStrings
   =========================================================================
   ========================================================================= *)

MODULE StabStrings;

  IMPORT Append, StrEq, LongReal2Str, Ident, GetIdentRepr, WriteString, WriteLn,
    ALLOCATE, AssString, AssChar, AssLn, flush;
   
  EXPORT StripAssign, AppendIntToString, AppendRealToString, isEqual, DynString,
    EmptyDynString, AssignString, AppendString, AppendChar, AppendInt, AppendIdent,
    AppendDynString, AssStabs;

  (* -------------------------------------------------------------------------
     Procedure StabStrings.StripAssign(dst, src)
     -------------------------------------------------------------------------
     Assigns string src to dst, stripping leading "_", terminated with CHR(0).
     ------------------------------------------------------------------------- *)

  PROCEDURE StripAssign ( VAR dst, src : ARRAY OF CHAR );
  VAR
    n, m, high: ShortCard;
  BEGIN
    (* high := MAX(HIGH(dst), HIGH(src)) *)
    high := HIGH(dst);
    IF high > HIGH(src) THEN
      high := HIGH(src)
    END;
    n := 0;
    m := 0;
    IF src[0] = "_" THEN
      m := 1
    END;
    WHILE (m <= high) AND (src[m] # CHR(0)) DO
      dst[n] := src[m];
      INC(n);
      INC(m)
    END;
    IF n <= HIGH(dst) THEN
      dst[n] := CHR(0)
    END
  END StripAssign;


  (* -------------------------------------------------------------------------
     Procedure StabStrings.AppendIntToString(str, i)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendIntToString ( VAR str : ARRAY OF CHAR; i : LONGINT );
  VAR
    n : CARDINAL;
    z, p : LONGINT;
  BEGIN
    n := 0;
    WHILE str[n] # CHR(0) DO
      INC(n)
    END; (* WHILE *)
    IF i < 0 THEN
      IF i = -9223372036854775807-1 (* 64-bit LONGINT Minimum *) THEN
        Append(str, "-9223372036854775808"); 
        RETURN
      ELSE
        str[n] := "-";
        INC(n);
        z := - i;
      END (* IF *)
    ELSE
      z := i
    END; (* IF *)
    p := 1000000000000000000; (* 19-digit base power *)
    WHILE p > z DO
      p := p DIV 10
    END; (* WHILE *)
    IF p = 0 THEN
      p := 1
    END; (* IF *)
    WHILE p > 0 DO
      str[n] := VAL(CHAR, ORD("0") + z DIV p);
      z := z MOD p;
      p := p DIV 10;
      INC(n)
    END; (* WHILE *)
    str[n] := CHR(0)
  END AppendIntToString;
  
  
  (* -------------------------------------------------------------------------
     Procedure StabStrings.AppendRealToString(str, i)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendRealToString ( VAR str : ARRAY OF CHAR; i : LONGREAL );
  VAR
    ok : BOOLEAN;
    realStr : ARRAY [0..50] OF CHAR;
  BEGIN
    LongReal2Str(i, 20, -20, realStr, ok); 
    IF ok THEN
      Append(str, realStr)
    ELSE
      WriteString("Warning: No Debugging of Real Constant");
      WriteLn;
      Append(str, "0.0")
    END
  END AppendRealToString;
  
  
  (* -------------------------------------------------------------------------
     Function TypeTable.isEqual(ident, str)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)

  PROCEDURE isEqual ( ident : Ident; str : ARRAY OF CHAR ) : BOOLEAN;
  VAR
    t : ARRAY [0..255] OF CHAR;
  BEGIN
    GetIdentRepr(ident, t);
    RETURN StrEq(t, str);
  END isEqual;

  (****** Procedures for DynStrings (dynamic with pointers) *****)

  CONST
    SubStringLength = 256;
    KritAssLength = 800;

  TYPE DynString = POINTER TO SubStringElement;
  
  TYPE SubStringElement = RECORD
    SubString : ARRAY [0..SubStringLength-1] OF CHAR;
    SubStringLength : CARDINAL;
    Next : DynString
  END; (* RECORD *)


  (* -------------------------------------------------------------------------
     Procedure TypeTable.EmptyDynString(str)
     -------------------------------------------------------------------------
     str := ""
     ------------------------------------------------------------------------- *)

  PROCEDURE EmptyDynString ( VAR str : DynString );
  BEGIN
    str := NIL
  END EmptyDynString;
  
  
  (* -------------------------------------------------------------------------
     Procedure TypeTable.AssignString(dst, src)
     -------------------------------------------------------------------------
     Assigns string src to dst, terminated by CHR(0).
     ------------------------------------------------------------------------- *)

  PROCEDURE AssignString ( VAR dst : DynString; VAR src : ARRAY OF CHAR );
  BEGIN
    dst := NIL;
    AppendString(dst, src)
  END AssignString;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.AppendString(dest, suffix)
     -------------------------------------------------------------------------
     Appends string suffix to dest, terminated by CHR(0).
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendString ( VAR dest : DynString; VAR suffix : ARRAY OF CHAR );
  VAR
    suffixPos, suffixHigh, subStrPos: CARDINAL;
    subString : DynString;
  BEGIN
    IF suffix[0] = CHR(0) THEN
      RETURN
    END; (* IF *)
    
    suffixPos := 0;
    suffixHigh := HIGH(suffix);
    IF dest = NIL THEN
      NEW(dest);
      dest^.SubStringLength := 0;
      dest^.Next := NIL;
      subString := dest
    ELSE
      subString := dest;
      WHILE subString^.Next # NIL DO
        subString := subString^.Next
      END (* WHILE *)
    END; (* IF *)
    subStrPos := subString^.SubStringLength;
    LOOP
      IF subStrPos = SubStringLength THEN
        NEW(subString^.Next);
        subString^.SubStringLength := SubStringLength;
        subString := subString^.Next;
        subString^.Next := NIL;
        subStrPos := 0
      END; (* IF *)
      subString^.SubString[subStrPos] := suffix[suffixPos];
      IF suffixPos = suffixHigh THEN
        subString^.SubStringLength := subStrPos + 1;
        EXIT
      END; (* IF *)
      INC(suffixPos);
      INC(subStrPos);
      IF suffix[suffixPos] = CHR(0) THEN
        subString^.SubStringLength := subStrPos;
        EXIT
      END (* IF *)
    END (* LOOP *)
  END AppendString;
   

  (* -------------------------------------------------------------------------
     Procedure TypeTable.AppendDynString(dest, suffix)
     -------------------------------------------------------------------------
     Appends dynamic string suffix to dest, terminated by CHR(0).
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendDynString ( VAR dest, suffix : DynString );
  VAR
    n : CARDINAL;
    subString : DynString;
  BEGIN
    IF suffix = NIL THEN
      RETURN
    END; (* IF *)
    
    IF dest = NIL THEN
      dest := suffix
    ELSE
      subString := dest;
      
      WHILE subString^.Next # NIL DO
        subString := subString^.Next
      END; (* WHILE *)
      
      IF (subString^.SubStringLength + suffix^.SubStringLength
         < SubStringLength) AND (suffix^.Next = NIL) THEN
        FOR n := 0 TO suffix^.SubStringLength DO
          subString^.SubString[n + subString^.SubStringLength]
           := suffix^.SubString[n]
        END; (* FOR *)
        INC(subString^.SubStringLength, suffix^.SubStringLength)
      ELSE
        subString^.Next := suffix
      END (* IF *)
    END; (* IF *)
    suffix := NIL
  END AppendDynString;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.AppendInt(str, i)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)
  
  PROCEDURE AppendInt ( VAR str : DynString; i : LONGINT );
  VAR
    subStrPos : CARDINAL;
    z, p : LONGINT;
    subString : DynString;
  BEGIN
    subString := str;
    IF str = NIL THEN
      NEW(str);
      str^.SubStringLength := 0;
      str^.Next := NIL;
      subString := str
    ELSE
      subString := str;
      WHILE subString^.Next # NIL DO
        subString := subString^.Next
      END (* WHILE *)
    END; (* IF *)
    subStrPos := subString^.SubStringLength;
    IF subStrPos + 21 >= SubStringLength THEN
      NEW(subString^.Next);
      subString := subString^.Next;
      subString^.Next := NIL;
      subStrPos := 0
    END; (* IF *)
    IF i < 0 THEN
      IF i = -9223372036854775807-1 (* 64-bit LONGINT Min *) THEN
        AppendString(str, "-9223372036854775808"); 
        RETURN
      ELSE
        subString^.SubString[subStrPos] := "-";
        INC(subStrPos);
        z := - i;
      END; (* IF *)
    ELSE
      z := i
    END; (* IF *)
    p := 1000000000000000000; (* Extended base power up to 19 digits *)
    WHILE p > z DO
      p := p DIV 10
    END; (* WHILE *)
    IF p = 0 THEN
      p := 1
    END; (* IF *)
    WHILE p > 0 DO
      subString^.SubString[subStrPos] := VAL(CHAR, ORD("0") + z DIV p);
      z := z MOD p;
      p := p DIV 10;
      INC(subStrPos)
    END; (* WHILE *)
    subString^.SubStringLength := subStrPos
  END AppendInt;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.AppendChar(str, ch)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendChar ( VAR str : DynString; ch : CHAR );
  VAR
    subString : DynString;
  BEGIN
    subString := str;
    IF str = NIL THEN
      NEW(str);
      str^.SubStringLength := 0;
      str^.Next := NIL;
      subString := str
    ELSE
      subString := str;
      WHILE subString^.Next # NIL DO
        subString := subString^.Next
      END (* WHILE *)
    END (* IF *);
    IF subString^.SubStringLength = SubStringLength THEN
      NEW(subString^.Next);
      subString := subString^.Next;
      subString^.Next := NIL;
      subString^.SubStringLength := 0;
    END; (* IF *)
    subString^.SubString[subString^.SubStringLength] := ch;
    INC(subString^.SubStringLength)
  END AppendChar;


  (* -------------------------------------------------------------------------
     Procedure TypeTable.AppendIdent(str, ident)
     -------------------------------------------------------------------------
     ------------------------------------------------------------------------- *)

  PROCEDURE AppendIdent ( VAR str : DynString; ident : Ident );
  VAR
    t : ARRAY [0..255] OF CHAR;
  BEGIN
    GetIdentRepr(ident, t);
    AppendString(str, t);
  END AppendIdent;
  

  (* -------------------------------------------------------------------------
     Procedure TypeTable.AssStabs(ident, front, middle, end)
     -------------------------------------------------------------------------
     Emit Stabs in the format
        .stabs " ident front middle ", end
     or splits a long Stabs in the format
        .stabs " ident front middle1 \\", end
        .stabs " middle2 \\", end
        ...
        .stabs " middleN ", end
     ------------------------------------------------------------------------- *)

  PROCEDURE AssStabs
    ( ident : Ident;
      front : ARRAY OF CHAR; middle : DynString; end : ARRAY OF CHAR );
  VAR
    subStrPos, assLength : CARDINAL;
    subString : DynString;
    identString : ARRAY [0..255] OF CHAR;
    semicolon : BOOLEAN;
  BEGIN
    flush;
    AssString('  .stabs "');
    IF ident # NIL THEN
      GetIdentRepr(ident, identString);
      AssString(identString);
    END; (* IF *)
    AssString(front);
    IF middle # NIL THEN
      subString := middle;
      subStrPos := 0;
      assLength := 0;
      semicolon := FALSE;
      LOOP
        IF subStrPos = subString^.SubStringLength THEN
          IF substring^.Next = NIL THEN
            EXIT
          ELSE
            subString := subString^.Next;
            subStrPos := 0
          END (* IF *)
        END; (* IF *)
        IF (asslength > KritAssLength) AND semicolon AND
          (((substring^.SubString[subStrpos] >= "A") AND 
          (subString^.SubString[subStrPos] <= "Z")) OR 
          ((subString^.SubString[subStrPos] >= "a") AND
          (subString^.SubString[subStrPos] <= "z"))) THEN
          AssString('\\",');
          AssString(end);
          AssLn;
          flush;
          AssString('  .stabs "');
          AssChar(subString^.SubString[subStrPos]);
          asslength := 1;
        ELSE
          AssChar(substring^.SubString[subStrPos]);
          semicolon :=
            (subString^.SubString[subStrPos] = ";") OR
            (subString^.SubString[subStrPos] = ",")
        END; (* IF *)
        INC(subStrPos);
        INC(assLength)
      END (* LOOP *)
    END; (* IF *)
    AssString('",');
    AssString(end);
    AssLn
  END AssStabs;
    
END (* MODULE *) StabStrings;


(* =========================================================================
   MODULE ValueConversions
   =========================================================================
   ========================================================================= *)

MODULE ValueConversions;

(* Why is this a separate module when there is only one function in it and
   no local constants, types nor variables are defined either??? WTF?! *)

  IMPORT Value, ValueClass, CompilerError;
  
  EXPORT toLongInt;

  PROCEDURE toLongInt ( val : Value ) : LONGINT;
  (* converts val to LONGINT *)
  BEGIN
    CASE val.class OF
    | BoolValue :
        IF val.BoolVal THEN
          RETURN 1
        ELSE
          RETURN 0
        END;
    | CardinalValue :
        RETURN val.CardinalVal;
    | LongCardValue :
      (* Why does it use a cast here when conversions are used elsewhere? *)
        RETURN LONGINT(val.LongCardVal);
    | IntegerValue :
        RETURN val.IntegerVal;
    | LongIntValue :
        RETURN val.LongIntVal;
    | CharValue :
        RETURN ORD(val.CharVal)
    ELSE
      CompilerError("illegal call to toLongInt")
    END (* CASE *)
  END toLongInt;

END (* MODULE *) ValueConversions;


(* =========================================================================
   M a i n   M o d u l e
   ========================================================================= *)

VAR
  blockNumber, lineNumber : LONGCARD;  (* for internal label generation *)
  lastLineNumber : ShortCard;
  staticDefString : DynString;
  CurProcEntry : ARRAY [0..511] OF CHAR;


(* -------------------------------------------------------------------------
   Procedure CgDebug.OpenDebug
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE OpenDebug;
VAR
  ok : BOOLEAN;
  n : CARDINAL;
  obj : Object;
  cwd : ARRAY [0..511] OF CHAR;
BEGIN
  IF NOT Enabled(DebugOption) THEN
    RETURN
  END; (* IF *)
 
  (* get current working directory *)
  IF getcwd(ADR(cwd[0]), HIGH(cwd)) = NIL THEN
    cwd[0] := CHR(0);
  END; (*IF *)

  (* Emit Name of Source File *)
  AssString('  .stabs "');
  AssString(cwd);
    
  IF Enabled(ElfOption) THEN
    AssString('/",100,0,0,.LBB0');
    AssLn;
    AssString('  .stabs "');
    AssString(NameOfSourceFile);
    AssString('",100,0,0,.LBB0');
    AssLn;
    AssString(".LBB0:");

  (* the following code is obsolete on 64-bit systems *)
  ELSE (* a.out *)
    AssString('/",100,0,0,LBB0');
    AssLn;
    AssString('  .stabs "');
    AssString(NameOfSourceFile);
    AssString('",100,0,0,LBB0');
    AssLn;
    AssString("LBB0:");
  END; (* IF *)
  AssLn;

(* BK 2026-10-18 : removed obsolete N_MAIN entry (stabn 66) *)

  (* Emit Standard Data Types *)
  StandardTypesDebug;

  (* Initialize Type Table *)
  InitTypeTable;
  n := 15;
    
  obj := CompUnitObject^.next^.FirstLocalObject;
  REPEAT
    obj := obj^.next
  UNTIL isEqual(obj^.name, "ADDRESS");
    
  EnterType(obj, n, "ADDRESS");  (* ID 15 *)
  EnterType(obj, n, "BYTE");     (* ID 14 *)
  EnterType(obj, n, "WORD");     (* ID 13 *)
    
  obj := CompUnitObject^.next;
  REPEAT
    obj := obj^.next
  UNTIL isEqual(obj^.name, "PROC");
    
  EnterType(obj, n, "PROC");      (* ID 12 *)
  EnterType(obj, n, "BITSET");    (* ID 11 *)
  EnterType(obj, n, "LONGREAL");  (* ID 10 *)
  EnterType(obj, n, "REAL");      (* ID 9  *)
  EnterType(obj, n, "INTEGER");   (* ID 8  *)
  EnterType(obj, n, "LONGINT");   (* ID 7  *)
  typeTable[6] := NIL; DEC(n);    (* ID 6, UNUSED *)
  EnterType(obj, n, "CARDINAL");  (* ID 5  *)
  EnterType(obj, n, "LONGCARD");  (* ID 4  *)
  typeTable[3] := NIL; DEC(n);    (* ID 3, UNUSED *)
  EnterType(obj, n, "CHAR");      (* ID 2  *)
  EnterType(obj, n, "BOOLEAN");   (* ID 1  *)

  (* Initialize internal Labelnumbers *)
  blockNumber := 0;
  lineNumber := 0;

  (* Initialize Defining String for static Variables *)
  EmptyDynString(staticDefString)
END OpenDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.CloseDebug
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE CloseDebug;
VAR
  staticFront : ARRAY [0..511] OF CHAR;
BEGIN
  IF NOT Enabled(DebugOption) THEN
    RETURN
  END; (* IF *)

  IF RootObject^.SizeOfActivationRecord > 0 THEN
    flush;
    GetIdentRepr(CompUnitObject^.name, staticFront);
    StripAssign(staticFront, staticFront);
    Append(staticFront, "_s:Gs");
    AppendIntToString(staticFront, RootObject^.SizeOfActivationRecord);
    AppendChar(staticDefString, ";");
    AssStabs(NIL, staticFront, staticDefString, "32,0,0,0");
  END (* IF *)
END CloseDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.StandardTypesDebug
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE StandardTypesDebug;
BEGIN
  IF Enabled(DebugEnumOption) THEN
    AssString('  .stabs "BOOLEAN:t1=eTRUE:1,FALSE:0,;",0x80,0,0,0');
  ELSE
    AssString('  .stabs "BOOLEAN:t1=r1;0;255;",0x80,0,0,0');
  END;
  AssLn;
  AssString('  .stabs "CHAR:t2=r2;0;255;",0x80,0,0,0');
  AssLn;

  (* CARDINAL and INTEGER are native 32-bit types *)
  AssString('  .stabs "CARDINAL:t5=r5;0;4294967295;",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "INTEGER:t8=r8;-2147483648;2147483647;",0x80,0,0,0');
  AssLn;

  (* LONGCARD and LONGINT are native 64-bit types *)
  AssString('  .stabs "LONGCARD:t4=r4;0;-1;",0x80,0,0,0'); 
  AssLn;
  AssString('  .stabs "LONGINT:t7=r7;-9223372036854775808;9223372036854775807;",0x80,0,0,0');
  AssLn;

  AssString('  .stabs "REAL:t9=r8;4;0;",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "LONGREAL:t10=r8;8;0;",0x80,0,0,0');
  AssLn;

  (* BITSET remains 32-bit, mapped to a 32-bit unsigned range (like CARDINAL) *)
  AssString('  .stabs "BITSET:t11=r5;0;4294967295",0x80,0,0,0');
  AssLn;

  AssString('  .stabs "WORD:t13=r13;0;255;",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "BYTE:t14=r2;0;255",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "VOID:t16=16",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "ADDRESS:t15=*16",0x80,0,0,0');
  AssLn;
  AssString('  .stabs "PROC:t12=*f16;",0x80,0,0,0');
  AssLn
END StandardTypesDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.TypeDebug(type, typeDefString)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE TypeDebug ( type : Type; VAR typeDefString : DynString );
VAR
  isNew : BOOLEAN;
  typeId : CARDINAL;
  tds, t : DynString;
  constant : ObjectList;
  field : RecordField;
  typeFront : ARRAY [0..511] OF CHAR;
  
BEGIN (* TypeDebug *)
  CheckTypeId(type, typeId, isNew);
  EmptyDynString(typeDefString);
  AppendInt(typeDefString, typeId);
  IF isNew THEN
    CASE type^.class OF
      ClassBOOLEAN :
        AssignString(tds, "1");
    | ClassCHAR :
        AssignString(tds, "2");
    | ClassSHORTCARD :
        AssignString(tds, "5"); (* -> CARDINAL *)
    | ClassLONGCARD, ClassSIorLI, ClassSIorSCorLIorLC, ClassSCorLIorLC, ClassLIorLC :
       AssignString(tds, "4");
    | ClassSHORTINT :
        AssignString(tds, "8"); (* -> INTEGER *)
    | ClassLONGINT :
       AssignStrin(tds, "7");
    | ClassREAL :
       AssignString(tds, "9");
    | ClassLONGREAL, ClassSRorLR :
        AssignString(tds, "10");
    | ClassBITSET :
        AssignString(tds, "11");
    | ClassPROC :
        AssignString(tds, "12");
    | ClassWORD :
        AssignString(tds, "13");
    | ClassADDRESS, ClassOPAQUE, ClassSTRING :
        AssignString(tds, "15");
    | ClassVOID :
        AssignString(tds, "16");
    | EnumerationType :
        IF Enabled(DebugEnumOption) THEN
          AssignString(tds, "e");
          constant := type^.constants;
          WHILE constant # NIL DO
            AppendIdent(tds, constant^.object^.name);
            AppendChar(tds, ":");
            IF constant^.object^.class = ConstantObj THEN
              AppendInt(tds, toLongInt(constant^.object^.value))
            ELSE
              CompilerError("assertion violation (-g Option)")
            END; (* IF *)
            AppendChar(tds, ",");
            constant := constant^.next
          END; (* WHILE *)
          AppendChar(tds, ";")
        ELSE
(* Die dbx-Enumeration hat immer 32 bit, die Modula-2-Enumeration
   8/16/32 bit, daher Enum = BYTE/SHORTCARD/LONGCARD *)
          CASE type^.size OF
            1: AssignString(tds, "14");
          | 2: AssignString(tds, "3")
          ELSE
            AssignString(tds, "4")
          END (* CASE *)
        END (* IF *)
    | SubrangeType:
(* Laut Grammatik muesste das so gehen, tut es aber nicht
   AssignString(tds, "r");
   TypeDebug(type^.BaseTypeOfSubrangeType, t);
   Append(tds, t);
   Append(tds, ";");
   AppendInt(tds, toLongInt(type^.first));
   Append(tds, ";");
   AppendInt(tds, toLongInt(type^.last));
*)
       (* Alternative: Subrange = BaseTypeOfSubrangeType *)
       TypeDebug(type^.BaseTypeOfSubrangeType, tds);
    | ArrayType :
      IF type^.IsOpenArray THEN
         AssignString(tds, "s8start:*");
         TypeDebug(type^.ComponentType, t);
         AppendDynString(tds, t);
         AppendString(tds, ",0,32;high:5,32,32;;")
      ELSE
        AssignString(tds, "a");
        CASE type^.IndexType^.class OF
          ClassBOOLEAN :
            AppendString(tds, "r1;0;1");
        | ClassCHAR :
            AppendString(tds, "r2;0;255");
        | SubrangeType :
            AppendChar(tds, "r");
            TypeDebug(type^.IndexType^.BaseTypeOfSubrangeType,t);
            AppendDynString(tds, t);
            AppendChar(tds, ";");
            AppendInt(tds, toLongInt(type^.IndexType^.first));
            AppendChar(tds, ";");
            AppendInt(tds, toLongInt(type^.IndexType^.last));
        | EnumerationType :
            AppendChar(tds, "r");
            TypeDebug(type^.IndexType,t);
            AppendDynString(tds, t);
            AppendString(tds, ";0;");
            AppendInt(tds, toLongInt(type^.IndexType^.MaxVal))
        ELSE
          CompilerError("assertion violation (-g option)")
        END; (* CASE *)
        AppendChar(tds, ";");
        TypeDebug(type^.ComponentType, t);
        AppendDynString(tds, t)
      END (* IF *)
    | RecordType :
        AssignString(tds, "s");
        AppendInt(tds, type^.size);
        field := type^.FirstField;
        WHILE field # NIL DO
          AppendIdent(tds, field^.name);
          AppendChar(tds, ":");
          TypeDebug(field^.type, t);
          AppendDynString(tds, t);
          AppendChar(tds, ",");
          AppendInt(tds, 8 * field^.offset);
          AppendChar(tds, ",");
          AppendInt(tds, 8 * field^.type^.size);
          AppendChar(tds, ";");
          field := field^.next
        END; (* WHILE *)
        AppendChar(tds, ";");
    | SetType :
        AssignString(tds, "4");
    | PointerType :
        AssignString(tds, "*");
        TypeDebug(type^.BaseTypeOfPointerType, t);
        AppendDynString(tds, t);
    | ProcedureType:
        AssignString(tds, "12")
        (* Prozedur-Typen nur als PROC ohne Argumente und Ergebnis *)
    ELSE
      CompilerError("assertion violation (-g option)")
    END (* CASE *);

    (* Wenn der Typ einen Namen hat, wird ein eigener stabs-Eintrag generiert und
       nur die Typ-Nummer in typeDefString zurueckgegeben *)
    IF ((type^.DefiningObject = NIL) OR (type^.DefiningObject^.name = NIL)) THEN
      AppendChar(typeDefString, "=");
      AppendDynString(typeDefString, tds)
    (* ansonsten wird die Typ-Information an den uebergeordeten stabs-Eintrag
     weitergegeben. *)
    ELSE
      Assign(typeFront, ":t");
      AppendIntToString(typFfront, typeId);
      Append(typeFront, "=");
      AssStabs(type^.DefiningObject^.name, typeFront, tds, "128,0,0,0")
    END (* IF *)
  END (* IF NOT isNew *)
END TypeDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.ProedureDebug(proc)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE ProcedureDebug ( proc : Object );
VAR
  s, d : INTEGER;
  tds : DynString;
  procFront, procEnd : ARRAY [0..511] OF CHAR;
BEGIN
  IF Enabled(DebugOption) THEN
    Assign(CurProcEntry, proc^.procindex^.Entry^);
    StripAssign(procfront, proc^.procindex^.Entry^);
    CASE proc^.class OF
      ProcedureObj :
        Append(procFront, ":F");
        IF proc^.TypeOfProcedure^.ResultType # TypeVOID THEN
          TypeDebug(proc^.TypeOfProcedure^.ResultType, tds)
        ELSE
          AssignString(tds, "16")
        END (* IF *)
(*
        AppendIntToString(procend, proc^.TypeOfProcedure^.ResultType^.size);
*)
    | ModuleObj :
        Append(procFront, ":F");
        AssignString(tds, "16");
    ELSE
      CompilerError("Assertion violation (-g Option)")
    END; (* CASE *)
    Assign(procEnd, "36,0,0,");
    Append(procEnd, proc^.procindex^.Entry^);
    AssStabs(NIL, procFront, tds, procEnd)
  END (* IF Enabled(DebugOption) *)
END ProcedureDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.BeginDebugBlock
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE BeginDebugBlock;
BEGIN
  IF NOT Enabled(DebugOption) THEN
    RETURN
  END; (* IF *)
  
  INC(blockNumber);
  IF Enabled(ElfOption) THEN
    AssString(".LBB");
  (* the following code is obsolete on 64-bit *)
  ELSE (* a.out *)
    AssString("LBB")
  END; (* IF *)
  AssInt(blockNumber);
  AssChar(":");
  AssLn
END BeginDebugBlock;


(* -------------------------------------------------------------------------
   Procedure CgDebug.EndDebugBlock
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE EndDebugBlock;
BEGIN
  IF NOT Enabled(DebugOption) THEN
    RETURN
  END; (* IF *)
  
  IF Enabled(ElfOption) THEN
    AssString(".LBE");
  (* the following code is obsolete on 64-bit *)
  ELSE (* a.out *)
    AssString("LBE");
  END; (* IF *)
  
  AssInt(blockNumber);
  AssChar(":");
  AssLn
END EndDebugBlock;


(* -------------------------------------------------------------------------
   Procedure CgDebug.LocalObjectsDebug(firstLocalObj)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE LocalObjectsDebug ( firstLocalObj : Object );
VAR
  obj : Object;
  tds : DynString;


(* -------------------------------------------------------------------------
   Procedure LocalObjectsDebug.StaticVariableDebug(obj)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

  PROCEDURE StaticVariableDebug ( obj : Object );
  VAR
    tds : DynString;
  BEGIN
    AppendIdent(staticDefString, obj^.name);
    AppendChar(staticDefString, ":");
    TypeDebug(obj^.TypeOfVariable, tds);
    AppendDynString(staticDefString, tds);
    AppendChar(staticDefString, ",");
    AppendInt(staticDefString, 8 * obj^.offset);
    AppendChar(staticDefString, ",");
    AppendInt(staticDefString, 8 * obj^.TypeOfVariable^.size);
    AppendChar(staticDefString, ";");
  END StaticVariableDebug;

(* -------------------------------------------------------------------------
   Procedure LocalObjectsDebug.LocalVariableDebug(obj)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

  PROCEDURE LocalVariableDebug ( obj : Object );
  VAR
    tds : DynString;
    varFront, varEnd : ARRAY [0..511] OF CHAR;
  BEGIN
    TypeDebug(obj^.TypeOfVariable, tds);
    CASE obj^.kind OF
      LocalVar :
        Assign(varFront, ":");
        Assign(varEnd, "128,0,");
    | VarParam :
        IF (obj^.TypeOfVariable^.class = ArrayType) AND 
           (obj^.TypeOfVariable^.IsOpenArray) THEN
           Assign(varFront, ":p")
        ELSE
          Assign(varFront, ":v")
        END; (* IF *)
        Assign(varEnd, "160,0,");
    | ValueParam :
        Assign(varFront, ":p");
        Assign(varEnd, "160,0,")
    END; (* CASE *)
    AppendIntToString(varEnd, obj^.TypeOfVariable^.size);
    Append(varEnd, ",");
    AppendIntToString(varEnd, obj^.offset);
    AssStabs(obj^.name, varFront, tds, varEnd)
  END LocalVariableDebug;

(* -------------------------------------------------------------------------
   Procedure LocalObjectsDebug.LocalVariableDebug(obj)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

  PROCEDURE ConstantDebug ( obj : Object );
  VAR
    def : BOOLEAN;
    tds : DynString;
    constFront : ARRAY [0..511] OF CHAR;
  BEGIN
    IF Enabled(DebugConstOption) THEN
      Assign(constFront, ":c=");
      EmptyDynString(tds);
      def := TRUE;
      CASE obj^.TypeOfConstant^.class OF
        ClassSIorSCorLIorLC, ClassSIorLI, ClassSCorLIorLC,  ClassLIorLC,
        ClassSHORTCARD, ClassLONGCARD, ClassSHORTINT, ClassLONGINT,
        EnumerationType :
          Append(constFront, "i");
          AppendIntToString(constFront, toLongInt(obj^.value));
      | ClassBOOLEAN :
          IF ConvToBool(obj^.value) THEN
            Append(constFront, "i1")
          ELSE
            Append(constFront, "i0")
          END (* IF *)
      | ClassCHAR :
          Append(constFront, "i");
          AppendIntToString(constFront, ORD(ConvToChar(obj^.value)));
      | ClassSRorLR, ClassREAL, ClassLONGREAL :
          Append(constFront, "r");
          AppendRealToString(constFront, ConvToLongReal(obj^.value));
      | ClassNIL :
          Append(constFront, "i0");
  (*
      | ClassSTRING :
          Append(constFront, "s``");
          ConvToString(obj^.value, tds);
          Append(constFront, tds);
          Append(constFront, "''");
  *)
      | ClassBITSET, SetType :
          Append(constFront, "i");
          AppendIntToString(constFront, INTEGER(ConvToSet(obj^.value)))
      ELSE
  (*
        WriteString('Warning: No Debugging of "');
        GetIdentRepr(obj^.name, tds); WriteString(tds); 
        WriteString('"');
                    WriteLn;
  *)
        def := FALSE
      END; (* CASE *)
      IF def THEN
        AssStabs(obj^.name, constFront, tds, "128,0,0,0")
      END (* IF *)
    END (* IF NOT Enabled(DebugConstOption) *)
  END ConstantDebug;

(* -------------------------------------------------------------------------
   Procedure LocalObjectsDebug.isStatic(obj)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

  PROCEDURE isStatic ( obj : Object ) : BOOLEAN;
  BEGIN 
    WHILE obj^.DefiningScope^.class = ModuleObj DO
      obj := obj^.DefiningScope
    END; (* WHILE *)
    RETURN obj^.DefiningScope = RootObject;
  END isStatic;

(* -------------------------------------------------------------------------
   Body of CgDebug.LocalObjectsDebug
   ------------------------------------------------------------------------- *)

BEGIN (* LocalObjectsDebug *)
 IF Enabled(DebugOption) THEN

    obj := firstLocalObj;
    WHILE obj # NIL DO
      CASE obj^.class OF
      | ModuleObj:
      | ProcedureObj:
      | StandardProcedureObj:
          (* do nothing *)
      | VariableObj:
          IF isStatic(obj) THEN
            StaticVariableDebug(obj)
          ELSE
            LocalVariableDebug(obj)
          END; (* IF *)
      | ConstantObj:
   ConstantDebug(obj);
      | TypeObj:
          TypeDebug(obj^.TypeOfType, tds);
      | FieldObj:
      | PseudoObj:
      | ErrorObj:
          (* do nothing *)
      END;
      obj := obj^.next;
    END;
    IF Enabled(ElfOption) THEN
      AssString("  .stabn 192,0,0,.LBB"); AssInt(blockNumber); 
      AssChar("-"); AssString(CurProcEntry); AssLn;
      AssString("  .stabn 224,0,0,.LBE"); AssInt(blockNumber);
      AssChar("-"); AssString(CurProcEntry); AssLn;
    ELSE
      AssString("  .stabn 192,0,0,LBB"); AssInt(blockNumber); AssLn;
      AssString("  .stabn 224,0,0,LBE"); AssInt(blockNumber); AssLn;
    END;
  END (* IF Enabled(DebugOption) *)
END LocalObjectsDebug;


(* -------------------------------------------------------------------------
   Procedure CgDebug.LineNumberDebug(pos)
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE LineNumberDebug ( pos: SourcePosition );
BEGIN
  IF NOT Enabled(DebugOption) THEN
    RETURN
  END; (* IF *)
  
  IF Enabled(ElfOption) THEN
    INC(lineNumber);
    AssHString(".LN");
    AssInt(lineNumber);
    AssHString(":");
    AssLn;
    AssHString("  .stabn  68,0,");
    AssInt(pos.line);
    AssHString(",.LN");
    AssInt(lineNumber);
    AssHString("-");
    AssString(CurProcEntry)
  (* the following code is obsolete on 64-bit *)
  ELSE (* a.out *)
    AssHString("  .stabd  68,0,");
    AssInt(pos.line)
  END; (* IF *)
  
  AssHString("    # line "); AssInt(pos.line);
  AssHString(", column "); AssInt(pos.col);
  AssLn;
  lastLineNumber := pos.line
END LineNumberDebug;

(* -------------------------------------------------------------------------
   Procedure CgDebug.LastLineNumberDebug;
   -------------------------------------------------------------------------
   ------------------------------------------------------------------------- *)

PROCEDURE LastLineNumberDebug;
VAR
  lastPos : SourcePosition;
BEGIN
  lastPos.line := lastLineNumber + 1;
  lastPos.col := 0;
  LineNumberDebug(lastPos)
END LastLineNumberDebug;


(* =========================================================================
   Body of MAIN MODULE CgDebug
   ========================================================================= *)

BEGIN
  DefineOption(DebugOption, "g", TRUE, TRUE);
  DefineOption(DebugConstOption, "gc", TRUE, TRUE);
  DefineOption(DebugEnumOption, "ge", TRUE, TRUE)
END CgDebug.
