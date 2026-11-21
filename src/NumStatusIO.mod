(*!m2pim+mocka*) (* Copyright (C) 2026 by Benjamin Kowarsch *)

IMPLEMENTATION MODULE NumStatusIO;

(* Console IO library for Type NumStatus.Status *)

IMPORT InOut, NumStatus;

FROM NumStatus IMPORT Status;


(* --------------------------------------------------------------------------
 * Procedure:  NumStatusIO.Write(stat)
 * --------------------------------------------------------------------------
 * Write stat to console.
 * ----------------------------------------------------------------------- *)

PROCEDURE Write ( stat : Status );
VAR
  ch : CHAR;
  index : CARDINAL;
  identStr : NumStatus.IdentString;
BEGIN
  identStr := NumStatus.identString(stat);
  FOR index := 0 TO NumStatus.MaxIdentLen DO
    ch := identStr^[index];
    InOut.Write(ch);
    IF ch = CHR(0) THEN
      RETURN
    END (* IF *)
  END (* FOR *)
END Write;


END NumStatusIO.
