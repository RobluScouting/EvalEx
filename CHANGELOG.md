## [1.0.0] - 9/15/2020
Initial port of https://github.com/uklimaschewski/EvalEx.  
Differences in implementation currently:
  - Hyperbolic functions aren't supported
  - The SQRT function is currently limited to 64-bit precision
  - Built in operators/functions/variables are instead defined in built_ins.dart
  - Precision is handled slightly differently (no math context)
