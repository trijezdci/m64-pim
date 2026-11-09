# Test Cases for 64-bit Integer Operations

## Group 1 : Type Conversions

Objective:

Verify zero data loss during data widening, narrowing, and conversion.

### Constant Assignment

* Run `SetZero`, `SetOne`, `SetMin` and `SetMax` across both modules, and verify resulting bit patterns.

### Pervasive Type Transfers

* Run `FromCard` and `ToCard`, and verify round trip result remains the same.
* Run `FromLongCard` and `ToLongCard`, and verify round trip result remains the same.
* Run `FromInt` and `ToInt`, and verify round trip result remains the same.
* Run `FromLongInt` and `ToLongInt`, and verify round trip result remains the same.

### Cross-Module Type Transfers

* Convert MAX(CARD64T) to INT64T and verify overflow status is reported.
* Cast MIN(INT64T) to CARD64T and verify bit pattern `0x80000000:00000000`.

### Widening

* Load `MAX(CARDINAL)` and `MAX(LONGCARD)` into CARD64T variable and verify upper 32 bits remain zero.

### Sign-Extension

* Load `MIN(INTEGER)` and `MIN(LONGINT)` into INT64T variable and verify the upper 32 bits are correctly padded with sign bits (`0xFFFFFFFF`).


## Group 2 : Relational Operations & Properties

Objective:

Verify comparison evaluations across upper and lower 32 bits.

### High-Word Dominance

* Verify that `1:0` is recognized as greater than `0:0xFFFFFFFF`.

### Sign-Bit Weight

* Verify that a signed high-word of `-1` (`0xFFFFFFFF`) evaluates as less than a high-word of `0`, regardless of low-word value.

### Zero/One/Min/Max Comparisons

* Run `isZero`, `isOne`, `isMin` and `isMax` and verify results.

### Decimal Digit Count Boundaries

* Verify digitCount transitions at base-10 exponent thresholds `9`->`10`, `99`->`100`, `999`->`1000`, then at the 9th to 10th to 11th, and the 19th to 20th digit boundaries.

## Group 3 : Base Arithmetic Operations

Objective:

Verify carry generation, borrow propagation, division by zero, under- and overflow.

### Carry Generation

* Add `1` to `0:FFFFFFFF` and verify low-word clears to `0` and high-word increments to `1`.

### Borrow Propagation

* Subtract `1` from `1:0` and verify high-word clears to `0` and low-word rolls over to `0xFFFFFFFF`.

### Two's Complement Asymmetry

* Run `Neg` on `1` and verify result is `-1`.
* Run `Neg` on `MAX(INTEGER)`, `MAX(LONGINT)` and `MAX(INT64T)`.
* Run `Abs` and `Neg` on `0` and verify result is `0`.
* Run `Abs` and `Neg` on `-1` and verify result is `1`.
* Run `Abs` and `Neg` on `MIN(INTEGER)` and `MIN(LONGINT)`.
* Run `Abs` and `Neg` on `MIN(INT64T)`, and verify overflow is reported.

### Multiplication

* Multiply 32-bit values whose partial products accumulate across all 64 bits and verify overflow detection.

### Division and Remainder

* Execute long division with large distinct values, and verify:
  (a) that (Quotient * Divisor) + Remainder = Dividend,
  (b) that dividing by zero reports division by zero.

## Group 4 : Exponential and Logarithmic Operations

Objective:

Verify exponent scaling and base transitions.

### Truncation Mapping

* Verify that `Log10` of any value from `1` to `9` returns `0`, values `10` and `99` return `1`, values `100` and `199` return `2`, values `10^10` and `10^11-1` return `10` and value `MAX(CARD64T)` returns `20`.

### Base Range Checking

* Verify `Pow2` and `Pow10` return proper values within their value ranges and report overflow beyond.

## Group 5 : Bitshift Operations

Objective:

Verify cross-register bit migration.

### Bit Migration

* Shift values left by factors larger than 32 bits and verify bits migrate completely out of the low-word, move into the high-word and populate the correct high-word positions with zero padding behind them.
* Shift values right by factors larger than 32 bits and verify bits migrate completely out of the high-word, move into the low-word and populate the correct low-word positions with zero padding before them.
* Shift negative values arithemetically right by factors larger than 32 bits and verify bits migrate completely out of the high-word, move into the low-word and populate the correct low-word positions with proper sign-extension.




