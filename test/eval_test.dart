/*
 * Copyright 2012-2020 Udo Klimaschewski
 *
 * http://about.me/udo.klimaschewski
 * http://UdoJava.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:decimal/decimal.dart';
import 'package:eval_ex/expression.dart';
import 'package:test/test.dart';

void main() {
  test("testsInAB", () {
    String err = "";
    try {
      Expression expression = Expression("sin(a+x)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown operator or function: a");
  });

  test("testInvalidExpressions1", () {
    String err = "";
    try {
      Expression expression = Expression("12 18 2");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing operator at character position 3");
  });

  test("testInvalidExpressions3", () {
    String err = "";
    try {
      Expression expression = Expression("12 + * 18");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator * at character position 6");
  });

  test("testInvalidExpressions4", () {
    String err = "";
    try {
      Expression expression = Expression("");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Empty expression");
  });

  test("testInvalidExpressions5", () {
    String err = "";
    try {
      Expression expression = Expression("1 1+2/");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing operator at character position 2");
  });

  test("testBrackets", () {
    expect(new Expression("(1+2)").eval().toString(), "3");
    expect(new Expression("((1+2))").eval().toString(), "3");
    expect(new Expression("(((1+2)))").eval().toString(), "3");
    expect(new Expression("(1+2)*(1+2)").eval().toString(), "9");
    expect(new Expression("(1+2)*(1+2)+1").eval().toString(), "10");
    expect(new Expression("(1+2)*((1+2)+1)").eval().toString(), "12");
  });

  test("testUnknown1", () {
    expect(() => Expression("7#9").eval().toString(),
        throwsA(isA<ExpressionException>()));
  });

  test("testUnknown2", () {
    expect(() => Expression("123.6*-9.8-7#9").eval().toString(),
        throwsA(isA<ExpressionException>()));
  });

  test("testSimple", () {
    expect(new Expression("1+2").eval().toString(), "3");
    expect(new Expression("4/2").eval().toString(), "2");
    expect(new Expression("3+4/2").eval().toString(), "5");
    expect(new Expression("(3+4)/2").eval().toString(), "3.5");
    expect(new Expression("4.2*1.9").eval().toString(), "7.98");
    expect(new Expression("8%3").eval().toString(), "2");
    expect(new Expression("8%2").eval().toString(), "0");
    expect(new Expression("2*.1").eval().toString(), "0.2");
  });

  test("testUnaryMinus", () {
    expect(Expression("-3").eval().toString(), "-3");
    expect(Expression("-SQRT(4)").eval().toString(), "-2");
    expect(Expression("-(5*3+(+10-13))").eval().toString(), "-12");
    expect(Expression("-2+3/4*-1").eval().toString(), "-2.75");
    expect(Expression("-3^2").eval().toString(), "9");
    expect(Expression("4^-0.5").eval().toString(), "0.5");
    expect(Expression("-2+3/4").eval().toString(), "-1.25");
    expect(Expression("-(3+-4*-1/-2)").eval().toString(), "-1");
    expect(Expression("2+-.2").eval().toString(), "1.8");
  });

  test("testUnaryPlus", () {
    expect(Expression("+3").eval().toString(), "3");
    expect(Expression("+(3-1+2)").eval().toString(), "4");
    expect(Expression("+(3-(+1)+2)").eval().toString(), "4");
    expect(Expression("+3^2").eval().toString(), "9");
  });

  test("testPow", () {
    expect(Expression("2^4").eval().toString(), "16");
    expect(Expression("2^8").eval().toString(), "256");
    expect(Expression("3^2").eval().toString(), "9");
    expect(Expression("2.5^2").eval().toString(), "6.25");
    expect(Expression("2.6^3.5").eval().toString(), "28.34044843681906296");
    expect(Expression("PI^2").eval()!.toStringAsPrecision(128),
        "9.8696044010893586188344909998761511353136994072407906264133493762200448224192052430017734037185522313078742635808502091666098354");

    expect(() => Expression("9^9^9").eval(),
        throwsA(isA<ExpressionException>()));
  });

  test("testSqrt", () {
    expect(Expression("SQRT(16)").eval().toString(), "4");
    expect(Expression("SQRT(2)").eval().toString(), "1.4142135623730951");
    // TODO - due to a bad SQRT implementation
    //expect(Expression("SQRT(2)").eval().toStringAsPrecision(128), "1.41421356237309504880168872420969807856967187537694807317667973799073247846210703885038753432764157273501384623091229702492483605");
    expect(Expression("SQRT(5)").eval().toString(), "2.23606797749979");
    expect(Expression("SQRT(9875)").eval().toString(), "99.37303457175895");
    expect(Expression("SQRT(5.55)").eval().toString(), "2.355843797877949");
    expect(Expression("SQRT(0)").eval().toString(), "0");
  });

  test("testFunctions", () {
    expect(Expression("Random()").eval().toString(), isNot(equals("1.5")));
    expect(Expression("SIN(23.6)").eval().toString(), "0.40034903255689497");
    expect(Expression("MAX(-7,8)").eval().toString(), "8");
    expect(Expression("MAX(3,max(4,5))").eval().toString(), "5");
    expect(Expression("MAX(3,max(MAX(9.6,-4.2),Min(5,9)))").eval().toString(),
        "9.6");
    expect(Expression("LOG(10)").eval().toString(), "2.302585092994046");
  });

  test("testExpectedParameterNumbers", () {
    String err = "";
    try {
      Expression expression = Expression("Random(1)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Function Random expected 0 parameters, got 1");

    try {
      Expression expression = Expression("SIN(1, 6)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Function SIN expected 1 parameters, got 2");
  });

  test("testVariableParameterNumbers", () {
    String err = "";
    try {
      Expression expression = Expression("min()");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "MIN requires at least one parameter");

    expect(Expression("min(1)").eval().toString(), "1");
    expect(Expression("min(1, 2)").eval().toString(), "1");
    expect(Expression("min(1, 2, 3)").eval().toString(), "1");
    expect(Expression("max(3, 2, 1)").eval().toString(), "3");
    expect(
        Expression("max(3, 2, 1, 4, 5, 6, 7, 8, 9, 0)").eval().toString(), "9");
  });

  test("testOrphanedOperators", () {
    String err = "";
    try {
      Expression expression = Expression("/");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator / at character position 1");

    try {
      Expression expression = Expression("3/");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing parameter(s) for operator /");

    try {
      Expression expression = Expression("/3");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator / at character position 1");

    try {
      Expression expression = Expression("SIN(MAX(23,45,12))/");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing parameter(s) for operator /");
  });

  test("closeParenAtStartCausesExpressionException", () {
    expect(() => Expression("(").eval(),
        throwsA(isA<ExpressionException>()));
  });

  test("testOrphanedOperatorsInFunctionParameters", () {
    String err = "";
    try {
      Expression expression = Expression("min(/)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator / at character position 5");

    try {
      Expression expression = Expression("min(3/)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing parameter(s) for operator / at character position 5");

    try {
      Expression expression = Expression("min(/3)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator / at character position 5");

    try {
      Expression expression = Expression("SIN(MAX(23,45,12,23.6/))");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing parameter(s) for operator / at character position 21");

    try {
      Expression expression = Expression("SIN(MAX(23,45,12/,23.6))");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Missing parameter(s) for operator / at character position 16");

    try {
      Expression expression = Expression("SIN(MAX(23,45,>=12,23.6))");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator >= at character position 15");

    try {
      Expression expression = Expression("SIN(MAX(>=23,45,12,23.6))");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator >= at character position 9");
  });

  test("testExtremeFunctionNesting", () {
    expect(Expression("Random()").eval().toString(), isNot(equals("1.5")));
    expect(Expression("SIN(SIN(COS(23.6)))").eval().toString(),
        "0.0002791281464253652");
    expect(
        Expression("MIN(0, SIN(SIN(COS(23.6))), 0-MAX(3,4,MAX(0,SIN(1))), 10)")
            .eval()
            .toString(),
        "-4");
  });

  test("testTrigonometry", () {
    expect(Expression("SIN(30)").eval().toString(), "0.49999999999999994");
    expect(Expression("cos(30)").eval().toString(), "0.8660254037844387");
    expect(Expression("TAN(30)").eval().toString(), "0.5773502691896257");
    expect(Expression("RAD(30)").eval().toString(), "0.5235987755982988");
    expect(Expression("DEG(30)").eval().toString(), "1718.8733853924696");
    expect(
        Expression("atan(0.5773503)").eval().toString(), "30.000001323978292");
    expect(Expression("atan2(0.5773503, 1)").eval().toString(),
        "30.000001323978292");
    expect(Expression("atan2(2, 3)").eval().toString(), "33.690067525979785");
    expect(Expression("atan2(2, -3)").eval().toString(), "146.30993247402023");
    expect(
        Expression("atan2(-2, -3)").eval().toString(), "-146.30993247402023");
    expect(Expression("atan2(-2, 3)").eval().toString(), "-33.690067525979785");
    expect(Expression("SEC(30)").eval().toString(), "1.1547005383792515");
    expect(Expression("SEC(45)").eval().toString(), "1.414213562373095");
    expect(Expression("SEC(60)").eval().toString(), "1.9999999999999996");
    expect(Expression("SEC(75)").eval().toString(), "3.8637033051562737");
    expect(Expression("CSC(30)").eval().toString(), "2.0000000000000004");
    expect(Expression("CSC(45)").eval().toString(), "1.414213562373095");
    expect(Expression("CSC(60)").eval().toString(), "1.1547005383792517");
    expect(Expression("CSC(75)").eval().toString(), "1.035276180410083");
    expect(Expression("COT(30)").eval().toString(), "1.7320508075688774");
    expect(Expression("COT(45)").eval().toString(), "1.0000000000000002");
    expect(Expression("COT(60)").eval().toString(), "0.577350269189626");
    expect(Expression("COT(75)").eval().toString(), "0.2679491924311227");
    expect(Expression("ACOT(30)").eval().toString(), "1.9091524329963763");
    expect(Expression("ACOT(45)").eval().toString(), "1.2730300200567113");
    expect(Expression("ACOT(60)").eval().toString(), "0.9548412538721887");
    expect(Expression("ACOT(75)").eval().toString(), "0.7638984609299951");
    // TODO hyperbolic not implemented yet
    // expect(Expression("SINH(30)").eval().toString(), "5343237000000");
    // expect(Expression("COSH(30)").eval().toString(), "5343237000000");
    // expect(Expression("TANH(30)").eval().toString(), "1");
    // expect(Expression("SECH(30)").eval().toString(), "0.0000000000001871525");
    // expect(Expression("SECH(45)").eval().toString(), "0.00000000000000000005725037");
    // expect(Expression("SECH(60)").eval().toString(), "0.00000000000000000000000001751302");
    // expect(Expression("SECH(75)").eval().toString(), "0.000000000000000000000000000000005357274");
    // expect(Expression("CSCH(30)").eval().toString(), "0.0000000000001871525");
    // expect(Expression("CSCH(45)").eval().toString(), "0.00000000000000000005725037");
    // expect(Expression("CSCH(60)").eval().toString(), "0.00000000000000000000000001751302");
    // expect(Expression("CSCH(75)").eval().toString(), "0.000000000000000000000000000000005357274");
    // expect(Expression("COTH(30)").eval().toString(), "1");
    // expect(Expression("COTH(1.2)").eval().toString(), "1.199538");
    // expect(Expression("COTH(2.4)").eval().toString(), "1.016596");
    // expect(Expression("ASINH(30)").eval().toString(), "4.094622");
    // expect(Expression("ASINH(45)").eval().toString(), "4.499933");
    // expect(Expression("ASINH(60)").eval().toString(), "4.787561");
    // expect(Expression("ASINH(75)").eval().toString(), "5.01068");
    // expect(Expression("ACOSH(1)").eval().toString(), "0");
    // expect(Expression("ACOSH(30)").eval().toString(), "4.094067");
    // expect(Expression("ACOSH(45)").eval().toString(), "4.499686");
    // expect(Expression("ACOSH(60)").eval().toString(), "4.787422");
    // expect(Expression("ACOSH(75)").eval().toString(), "5.010591");
    // expect(Expression("ATANH(0)").eval().toString(), "0");
    // expect(Expression("ATANH(0.5)").eval().toString(), "0.5493061");
    // expect(Expression("ATANH(-0.5)").eval().toString(), "-0.5493061");
  });

  test("testMinMaxAbs", () {
    expect(Expression("MAX(3.78787,3.78786)").eval().toString(), "3.78787");
    expect(Expression("max(3.78786,3.78787)").eval().toString(), "3.78787");
    expect(Expression("MIN(3.78787,3.78786)").eval().toString(), "3.78786");
    expect(Expression("Min(3.78786,3.78787)").eval().toString(), "3.78786");
    expect(Expression("aBs(-2.123)").eval().toString(), "2.123");
    expect(Expression("abs(2.123)").eval().toString(), "2.123");
  });

  test("testRounding", () {
    expect(Expression("round(3.78787,1)").eval().toString(), "3.8");
    expect(Expression("round(3.78787,3)").eval().toString(), "3.788");
    expect(Expression("round(3.7345,3)").eval().toString(), "3.735");
    expect(Expression("round(-3.7345,3)").eval().toString(), "-3.735");
    expect(Expression("round(-3.78787,2)").eval().toString(), "-3.79");
    expect(Expression("round(123.78787,2)").eval().toString(), "123.79");
    expect(Expression("floor(3.78787)").eval().toString(), "3");
    expect(Expression("ceiling(3.78787)").eval().toString(), "4");
    expect(Expression("floor(-2.1)").eval().toString(), "-3");
    expect(Expression("ceiling(-2.1)").eval().toString(), "-2");
  });

  test("testMathContext", () {
    Expression e;
    e = new Expression("2.5/3");
    expect(e.eval()!.toStringAsPrecision(2), "0.83");

    e = new Expression("2.5/3");
    expect(e.eval()!.toStringAsPrecision(3), "0.833");

    e = new Expression("2.5/3");
    expect(e.eval()!.toStringAsPrecision(8), "0.83333333");
  });

  test("unknownFunctionsFailGracefully", () {
    String err = "";
    try {
      new Expression("unk(1,2,3)").eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown function unk at character position 1");
  });

  test("unknownOperatorsFailGracefully", () {
    String err = "";
    try {
      new Expression("a |*| b").eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown operator |*| at character position 3");
  });

  test("testNull", () {
    expect(Expression("null").eval(), null);
  });

  test("testCalculationWithNull", () {
    String err = "";
    try {
      new Expression("null+1").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }
    expect(err, "First operand may not be null.");

    err = "";
    try {
      new Expression("1 + NULL").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }
    expect(err, "Second operand may not be null.");

    err = "";
    try {
      new Expression("round(Null, 1)").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }
    expect(err, "Operand #1 may not be null.");

    err = "";
    try {
      new Expression("round(1, Null)").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }
    expect(err, "Operand #2 may not be null.");
  });

  test("canEvalHexExpression", () {
    Decimal result = new Expression("0xcafe").eval()!;
    expect(result.toString(), "51966");
  });

  test("hexExpressionCanUseUpperCaseCharacters", () {
    Decimal result = new Expression("0XCAFE").eval()!;
    expect(result.toString(), "51966");
  });

  test("hexMinus", () {
    Decimal result = new Expression("-0XCAFE").eval()!;
    expect(result.toString(), "-51966");
  });

  test("hexMinusBlanks", () {
    Decimal result = new Expression("  0xa + -0XCAFE  ").eval()!;
    expect(result.toString(), "-51956");
  });

  test("longHexExpressionWorks", () {
    Decimal result = new Expression("0xcafebabe").eval()!;
    expect(result.toString(), "3405691582");
  });

  test("hexExpressionDoesNotAllowNonHexCharacters", () {
    expect(() => Expression("0xbaby").eval(),
        throwsA(isA<ExpressionException>()));
  });

  test("throwsExceptionIfDoesNotContainHexDigits", () {
    expect(() => Expression("0x").eval(),
        throwsA(isA<FormatException>()));
  });

  test("hexExpressionsEvaluatedAsExpected", () {
    Decimal result = new Expression("0xcafe + 0xbabe").eval()!;
    expect(result.toString(), "99772");
  });

  test("testResultZeroStripping", () {
    Expression expression = new Expression("200.40000 / 2");
    expect(expression.eval().toString(), "100.2");
  });

  test("testImplicitMultiplication", () {
    Expression expression = new Expression("22(3+1)");
    expect(expression.eval().toString(), "88");

    expression = new Expression("(a+b)(a-b)")
      ..setStringVariable("a", "1")
      ..setStringVariable("b", "2");

    expect(expression.eval().toString(), "-3");

    expression = new Expression("0xA(a+b)")
      ..setStringVariable("a", "1")
      ..setStringVariable("b", "2");

    expect(expression.eval().toString(), "30");
  });

  test("testNoLeadingZeros", () {
    Expression e = new Expression("0.1 + .1");
    expect(e.eval().toString(), "0.2");

    e = new Expression(".2*.3");
    expect(e.eval().toString(), "0.06");

    e = new Expression(".2*.3+.1");
    expect(e.eval().toString(), "0.16");
  });

  test("testUnexpectedComma", () {
    String err = "";
    try {
      Expression expression = new Expression("2+3,8");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }
    expect(err, "Unexpected comma at character position 3");
  });

  test("testStrEq", () {
    Expression e =
        new Expression("STREQ(\"test32asd234@#\",\"test32asd234@#\")");
    expect(e.eval().toString(), "1");

    e = new Expression("STREQ(\"test\",\"test32asd234@#\")");
    expect(e.eval().toString(), "0");

    e = new Expression("STREQ(\"\",\"\")");
    expect(e.eval().toString(), "1");
  });

  test("testMultipleCases", () {
    Expression expression = new Expression("L * l * h");

    expression.setStringVariable("L", "30");
    expression.setStringVariable("l", "40");
    expression.setStringVariable("h", "50");

    expect(expression.variables['L']!.getString(), "30");
    expect(expression.variables['l']!.getString(), "40");
    expect(expression.variables['h']!.getString(), "50");
  });
}
