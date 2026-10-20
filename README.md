## What this repository is for
Intermediary port of MOCKA i386 to AMD64 for use as dev tool for the 64-bit MOCKA rewrite.

## What work is being done

### 64-bit conversion
* remove types `SHORTCARD` and `SHORTINT`
* change `CARDINAL` and `INTEGER` from aliases to native 32-bit types
* change `LONGCARD` and `LONGINT` from 32-bit to 64-bit
* change all pointer types to 64-bit

**Note:** type `BITSET` will remain 32-bit

### Some clean-up
* readability
* remove octal literals
* remove synonyms `&`, `~` and `<>`
* make `TSIZE` pervasive and move `SIZE` into `SYSTEM`
