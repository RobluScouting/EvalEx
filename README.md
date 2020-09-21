# eval_ex

A Dart port of https://github.com/uklimaschewski/EvalEx.  
EvalEx supports mathematical and boolean expression evaluation, using arbitrary precision.
EvalEx supports functions, variables, and operators and additionally makes it very easy to
add your own custom functions or operators.

EvalEx uses [decimal](https://pub.dev/packages/decimal) to support arbitrary precision arithmetic.  
View package on [pub.dev](https://pub.dev/packages/eval_ex).

## Basic example

```dart
void main() {
  Expression exp = Expression("2 ^ 4 + 8");
  print(exp.eval().toString()); // 24

  // With a variable
  exp = Expression("a ^ b + c");
  // Variables may contain alphanumeric characters, and "_". This can be changed
  // by using setVariableCharacters(..) and setFirstVariableCharacters(..) (what chars variable are allowed to start with).
  exp.setStringVariable("a", "2");
  exp.setStringVariable("b", "4");
  exp.setStringVariable("c", "8");
  print(exp.eval().toString()); // 24
  
  // With a function
  exp = Expression("MAX(-7,8)");
  print(exp.eval().toString()); // 8

  // Boolean logic
  exp = Expression("1>0 && 5 == 5");
  print(exp.eval().toString()); // 1
  
  exp = Expression("1>0 && 5 == 4");
  print(exp.eval().toString()); // 0
}
 
```

## Built-in functions and operators
| Function             | Description                                                                       |
|----------------------|-----------------------------------------------------------------------------------|
| +                    | Addition                                                                          |
| -                    | Subtraction                                                                       |
| *                    | Multiplication                                                                    |
| /                    | Division                                                                          |
| %                    | Modulus                                                                           |
| ^                    | Power                                                                             |
| &&                   | Returns 1 if both expressions are true, 0 otherwise                               |
| \|\|                 | Returns 1 if either or both expressions are true, 0 otherwise                     |
| >                    | Returns 1 if the left expression is greater than the right                        |
| >=                   | Returns 1 if the left expression is greater than or equal to the right            |
| <                    | Returns 1 if the right expression is greater than the left                        |
| <=                   | Returns 1 if the right expression is greater than or equal to the left            |
| =                    | Returns 1 if the left and right expressions are equal                             |
| ==                   | Returns 1 if the left and right expressions are equal                             |
| !=                   | Returns 1 if the left and right expressions are NOT equal                         |
| <>                   | Returns 1 if the left and right expressions are NOT equal                         |
| STREQ("str1","str2") | Returns 1 if the literal "str1" is equal to "str2", otherwise returns 0           |
| FACT(int)            | Computes the factorial of arg1                                                    |
| NOT(expression)      | Returns 1 if arg1 evaluates to 0, otherwise returns 0                             |
| IF(cond,exp1,exp2)   | Returns exp1 if cond evaluates to 1, otherwise returns exp2                       |
| Random()             | Returns a random decimal between 0 and 1                                          |
| SINR(exp)            | Evaluates the SIN of exp, assuming exp is in radians                              |
| COSR(exp)            | Evaluates the COS of exp, assuming exp is in radians                              |
| TANR(exp)            | Evaluates the TAN of exp, assuming exp is in radians                              |
| COTR(exp)            | Evaluates the COT of exp, assuming exp is in radians                              |
| SECR(exp)            | Evaluates the SEC of exp, assuming exp is in radians                              |
| CSCR(exp)            | Evaluates the CSC of exp, assuming exp is in radians                              |
| SIN(exp)             | Evaluates the SIN of exp, assuming exp is in degrees                              |
| COS(exp)             | Evaluates the COS of exp, assuming exp is in degrees                              |
| TAN(exp)             | Evaluates the TAN of exp, assuming exp is in degrees                              |
| COT(exp)             | Evaluates the COT of exp, assuming exp is in degrees                              |
| SEC(exp)             | Evaluates the SEC of exp, assuming exp is in degrees                              |
| CSC(exp)             | Evaluates the CSC of exp, assuming exp is in degrees                              |
| ASINR(exp)           | Evaluates the ARCSIN of exp, assuming exp is in radians                           |
| ACOSR(exp)           | Evaluates the ARCCOS of exp, assuming exp is in radians                           |
| ATANR(exp)           | Evaluates the ARCTAN of exp, assuming exp is in radians                           |
| ACOTR(exp)           | Evaluates the ARCCOT of exp, assuming exp is in radians                           |
| ATAN2R(exp1, exp1)   | Evaluates the ARCTAN between exp1 and exp2, assuming exp1 and exp2 are in radians |
| ASIN(exp)            | Evaluates the ARCSIN of exp, assuming exp is in degrees                           |
| ACOS(exp)            | Evaluates the ARCCOS of exp, assuming exp is in degrees                           |
| ATAN(exp)            | Evaluates the ARCTAN of exp, assuming exp is in degrees                           |
| ACOT(exp)            | Evaluates the ARCCOT of exp, assuming exp is in degrees                           |
| ATAN2(exp1, exp1)    | Evaluates the ARCTAN between exp1 and exp2, assuming exp1 and exp2 are in degrees |
| RAD(deg)             | Converts deg to radians                                                           |
| DEG(rad)             | Converts rad to degrees                                                           |
| MAX(a,b,...)         | Returns the maximum value from the provided list of 1 or more expressions         |
| MIN(a,b,...)         | Returns the minimum value from the provided list of 1 or more expressions         |
| ABS(exp)             | Returns the absolute value of exp                                                 |
| LOG(exp)             | Returns the natural logarithm of exp                                              |
| LOG10(exp)           | Returns the log base 10 of exp                                                    |
| ROUND(exp,precision) | Returns exp rounded to precision decimal points                                   |
| FLOOR(exp)           | Returns the floor of exp                                                          |
| CEILING(exp)         | Returns the ceiling of exp                                                        |
| SQRT(exp)            | Computes the square root of exp                                                   |
| e                    | Euler's number                                                                    |
| PI                   | Ratio of circle's circumference to diameter                                       |
| NULL                 | Alias for null                                                                    |
| TRUE or true         | Alias for 1                                                                       |
| FALSE or true        | Alias for 0                                                                       |

## Adding custom functions, operators, and variables
Custom functions, operators, and variables can be defined by adding them in built_ins.dart

## Differences from https://github.com/uklimaschewski/EvalEx.
  - Hyperbolic functions aren't supported
  - The SQRT function is currently limited to 64-bit precision
  - Built in operators/functions/variables are instead defined in built_ins.dart
