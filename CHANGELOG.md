## [1.0.11] - 12/29/2020
Fixing static analysis issues introduced in latest Flutter releases

## [1.0.10] - 11/16/2020
Fixed formatting

## [1.0.9] - 11/16/2020
Bug fixes to ">" and "<" operators.

## [1.0.8] - 9/15/2020
Added STREQ function

## [1.0.7] - 9/15/2020
Made error text more consistent for "^"

## [1.0.6] - 9/15/2020
Typo spelling fix

## [1.0.5] - 9/15/2020
Typo spelling fix

## [1.0.4] - 9/15/2020
Switch assert errors for safeguards for "^" and "FACT" to ExpressionExceptions

## [1.0.3] - 9/15/2020
Added safeguards for "^" and "FACT" on really large numbers so they don't
kill evaluation performance.

## [1.0.2] - 9/15/2020
Fixed formatting

## [1.0.1] - 9/15/2020
Added examples and fixed formatting.

## [1.0.0] - 9/15/2020
Initial port of https://github.com/uklimaschewski/EvalEx.  
Differences in implementation currently:
  - Hyperbolic functions aren't supported
  - The SQRT function is currently limited to 64-bit precision
  - Built in operators/functions/variables are instead defined in built_ins.dart
  - Precision is handled slightly differently (no math context)
