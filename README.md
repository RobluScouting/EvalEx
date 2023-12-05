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

  // Adding a custom operator

  Expression exp = Expression('23 custom_operator 20');
  exp.addOperator(OperatorImpl("custom_operator", Expression.operatorPrecedenceAdditive, true,
      fEval: (v1, v2) {
    return v1 + v2;
  }));
  print(exp.eval()); // 43

  // Adding a custom function

  exp = Expression('cube(4) + 2');
  exp.addFunc(FunctionImpl("cube", 1, booleanFunction: false, fEval: (params) {
   num n = pow(params.first.toDouble(),3);
   return Decimal.parse(n.toString());
  }));
  print(exp.eval()) // 66

  // Custom function for returning the difference between two numbers

  exp = Expression('difference(4,2)');
  exp.addFunc(FunctionImpl("difference", 2, booleanFunction: false, fEval: (params) {
   return (params[0]-params[1]).abs();
  }));
  print(exp.eval()); // 2
}
```
# Built-in functions and operators

## Operators

| Operator             | Description                                                           |
|----------------------|-----------------------------------------------------------------------|
| +                    | Addition                                                              |
| -                    | Subtraction                                                           |
| *                    | Multiplication                                                        |
| /                    | Division                                                              |
| %                    | Percentage Operator                                                   |
| mod                  | modulus                                                               |
| yroot                | Yth Root Operator                                                     |
| logbase              | Logarithm with a Base Operator                                        |
| ^                    | Power                                                                 |
| &&                   | Returns 1 if both expressions are true, 0 otherwise                   |
| \|\|                 | Returns 1 if either or both expressions are true, 0 otherwise         |
| >                    | Returns 1 if the left expression is greater than the right            |
| >=                   | Returns 1 if the left expression is greater than or equal to the right|
| <                    | Returns 1 if the right expression is greater than the left            |
| <=                   | Returns 1 if the right expression is greater than or equal to the left|
| =                    | Returns 1 if the left and right expressions are equal                 |
| ==                   | Returns 1 if the left and right expressions are equal                 |
| !=                   | Returns 1 if the left and right expressions are NOT equal             |
| <>                   | Returns 1 if the left and right expressions are NOT equal             |

# Trigonometry

## Standard, degrees

| Function             | Description                                         |
|----------------------|-----------------------------------------------------|
| SIND(exp)            | Evaluates the SIN of exp, assuming exp is in degrees|
| COSD(exp)            | Evaluates the COS of exp, assuming exp is in degrees|
| TAND(exp)            | Evaluates the TAN of exp, assuming exp is in degrees|
| COTD(exp)            | Evaluates the COT of exp, assuming exp is in degrees|
| SECD(exp)            | Evaluates the SEC of exp, assuming exp is in degrees|
| CSCD(exp)            | Evaluates the CSC of exp, assuming exp is in degrees|

## Inverse arc functions, degrees

| Function             | Description                                                                      |
|----------------------|----------------------------------------------------------------------------------|
| ASIND(exp)           | Evaluates the ASIN of exp, assuming exp is in degrees                            |
| ACOSD(exp)           | Evaluates the ACOS of exp, assuming exp is in degrees                            |
| ATAND(exp)           | Evaluates the ATAN of exp, assuming exp is in degrees                            |
| ACOTD(exp)           | Evaluates the ACOT of exp, assuming exp is in degrees                            |
| ASECD(exp)           | Evaluates the ASEC of exp, assuming exp is in degrees                            |
| ACSCD(exp)           | Evaluates the ACSC of exp, assuming exp is in degrees                            |
| ATAN2D(exp1, exp1)   | Evaluates the ARCTAN between exp1 and exp2, assuming exp1 and exp2 are in degrees|

## Standard, radians

| Function             | Description                                         |
|----------------------|-----------------------------------------------------|
| SINR(exp)            | Evaluates the SIN of exp, assuming exp is in radians|
| COSR(exp)            | Evaluates the COS of exp, assuming exp is in radians|
| TANR(exp)            | Evaluates the TAN of exp, assuming exp is in radians|
| COTR(exp)            | Evaluates the COT of exp, assuming exp is in radians|
| SECR(exp)            | Evaluates the SEC of exp, assuming exp is in radians|
| CSCR(exp)            | Evaluates the CSC of exp, assuming exp is in radians|

## Inverse arc functions, radians

| Function             | Description                                                                      |
|----------------------|----------------------------------------------------------------------------------|
| ASINR(exp)           | Evaluates the ASIN of exp, assuming exp is in radians                            |
| ACOSR(exp)           | Evaluates the ACOS of exp, assuming exp is in radians                            |
| ATANR(exp)           | Evaluates the ATAN of exp, assuming exp is in radians                            |
| ACOTR(exp)           | Evaluates the ACOT of exp, assuming exp is in radians                            |
| ASECR(exp)           | Evaluates the ASEC of exp, assuming exp is in radians                            |
| ACSCR(exp)           | Evaluates the ACSC of exp, assuming exp is in radians                            |
| ATAN2R(exp1, exp1)   | Evaluates the ARCTAN between exp1 and exp2, assuming exp1 and exp2 are in radians|

## Standard, gradians

| Function             | Description                                          |
|----------------------|------------------------------------------------------|
| SING(exp)            | Evaluates the SIN of exp, assuming exp is in gradians|
| COSG(exp)            | Evaluates the COS of exp, assuming exp is in gradians|
| TANG(exp)            | Evaluates the TAN of exp, assuming exp is in gradians|
| COTG(exp)            | Evaluates the COT of exp, assuming exp is in gradians|
| SECG(exp)            | Evaluates the SEC of exp, assuming exp is in gradians|
| CSCG(exp)            | Evaluates the CSC of exp, assuming exp is in gradians|

## Inverse arc functions, gradians

| Function             | Description                                                                       |
|----------------------|-----------------------------------------------------------------------------------|
| ASING(exp)           | Evaluates the ASIN of exp, assuming exp is in gradians                            |
| ACOSG(exp)           | Evaluates the ACOS of exp, assuming exp is in gradians                            |
| ATANG(exp)           | Evaluates the ATAN of exp, assuming exp is in gradians                            |
| ACOTG(exp)           | Evaluates the ACOT of exp, assuming exp is in gradians                            |
| ASECG(exp)           | Evaluates the ASEC of exp, assuming exp is in gradians                            |
| ACSCG(exp)           | Evaluates the ACSC of exp, assuming exp is in gradians                            |
| ATAN2G(exp1, exp1)   | Evaluates the ARCTAN between exp1 and exp2, assuming exp1 and exp2 are in gradians|

## Standard, hyperbolic

| Function             | Description              |
|----------------------|--------------------------|
| SINH(exp)            | Evaluates the SINH of exp|
| COSH(exp)            | Evaluates the COSH of exp|
| TANH(exp)            | Evaluates the TANH of exp|
| COTH(exp)            | Evaluates the COTH of exp|
| SECH(exp)            | Evaluates the SECH of exp|
| CSCH(exp)            | Evaluates the CSCH of exp|

## Inverse arc, hyperbolic

| Function             | Description              |
|----------------------|--------------------------|
| ASINH(exp)           | Evaluates the SINH of exp|
| ACOSH(exp)           | Evaluates the COSH of exp|
| ATANH(exp)           | Evaluates the TANH of exp|
| ACOTH(exp)           | Evaluates the COTH of exp|
| ASECH(exp)           | Evaluates the SECH of exp|
| ACSCH(exp)           | Evaluates the CSCH of exp|

## Converters
| Function             | Description             |
|----------------------|-------------------------|
| RAD(deg)             | Converts deg to radians |
| DEG(rad)             | Converts rad to degrees |
| GRAD(deg)            | Converts deg to gradians|

## More
| Function             | Description                                                              |
|----------------------|--------------------------------------------------------------------------|
| STREQ("str1","str2") | Returns 1 if the literal "str1" is equal to "str2", otherwise returns 0  |
| FACT(int)            | Computes the factorial of arg1                                           |
| NOT(expression)      | Returns 1 if arg1 evaluates to 0, otherwise returns 0                    |
| IF(cond,exp1,exp2)   | Returns exp1 if cond evaluates to 1, otherwise returns exp2              |
| RANDOM()             | Returns a random decimal between 0 and 1                                 |
| MAX(a,b,...)         | Returns the maximum value from the provided list of 1 or more expressions|
| MIN(a,b,...)         | Returns the minimum value from the provided list of 1 or more expressions|
| ABS(exp)             | Returns the absolute value of exp                                        |
| LOG(exp)             | Returns the natural logarithm of exp                                     |
| LOG10(exp)           | Returns the log base 10 of exp                                           |
| ROUND(exp,precision) | Returns exp rounded to precision decimal points                          |
| FLOOR(exp)           | Returns the floor of exp                                                 |
| CEILING(exp)         | Returns the ceiling of exp                                               |
| DMS(exp)             | Decimal Degrees to Degrees, Minutes, and Seconds Converter               |
| SQRT(exp)            | Computes the square root of exp                                          |
| CUBEROOT(exp)        | Computes the cube root of exp                                            |
| e                    | Euler's number                                                           |
| PI                   | Ratio of circle's circumference to diameter                              |
| NULL                 | Alias for null                                                           |
| TRUE or true         | Alias for 1                                                              |
| FALSE or false       | Alias for 0                                                              |

## Adding custom functions, operators, and variables
You can also define your custom functions, operators, and variables in built_ins.dart

## Differences from https://github.com/uklimaschewski/EvalEx.
  - The SQRT function is currently limited to 64-bit precision
  - Built in operators/functions/variables are instead defined in built_ins.dart










