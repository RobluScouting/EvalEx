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
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("testVars", () {
    expect(Expression("PI").eval()?.toStringAsFixed(7), "3.1415927");
    expect(Expression("PI").eval()?.toString(),
        "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679");
    expect(Expression("PI").eval()?.toStringAsFixed(34),
        "3.1415926535897932384626433832795029");
    expect(Expression("PI").eval()?.toStringAsFixed(16), "3.1415926535897932");
    expect(Expression("PI").eval()?.toStringAsFixed(7), "3.1415927");
    expect(Expression("PI*2.0").eval()?.toStringAsFixed(7), "6.2831853");
    expect(
        (Expression("3*x")..setDecimalVariable("x", Decimal.fromInt(7)))
            .eval()
            .toString(),
        "21");
    expect(
        (Expression("(a^2)+(b^2)")
              ..setDecimalVariable("a", Decimal.fromInt(2))
              ..setDecimalVariable("b", Decimal.fromInt(4)))
            .eval()
            .toString(),
        "20");
    expect(
        (Expression("a^(2+b)^2")
              ..setStringVariable("a", "2")
              ..setStringVariable("b", "4"))
            .eval()
            .toString(),
        "68719476736");
  });

  test("testSubstitution", () {
    Expression e = new Expression("x+y");

    expect(
        (e..setStringVariable("x", "1")..setStringVariable("y", "1"))
            .eval()
            .toString(),
        "2");
    expect((e..setStringVariable("y", "0")).eval().toString(), "1");
    expect((e..setStringVariable("x", "0")).eval().toString(), "0");
  });

  test("testWith", () {
    expect(
        (Expression("3*x")..setDecimalVariable("x", Decimal.fromInt(7)))
            .eval()
            .toString(),
        "21");

    expect(
        (Expression("(a^2)+(b^2)")
              ..setDecimalVariable("a", Decimal.fromInt(2))
              ..setDecimalVariable("b", Decimal.fromInt(4)))
            .eval()
            .toString(),
        "20");

    expect(
        (Expression("a^(2+b)^2")
              ..setStringVariable("a", "2")
              ..setStringVariable("b", "4"))
            .eval()
            .toString(),
        "68719476736");

    expect(
        (Expression("_a^(2+_b)^2")
              ..setStringVariable("_a", "2")
              ..setStringVariable("_b", "4"))
            .eval()
            .toString(),
        "68719476736");
  });

  test("testNames", () {
    expect(
        (Expression("3*longname")
              ..setDecimalVariable("longname", Decimal.fromInt(7)))
            .eval()
            .toString(),
        "21");

    expect(
        (Expression("3*longname1")
              ..setDecimalVariable("longname1", Decimal.fromInt(7)))
            .eval()
            .toString(),
        "21");

    expect(
        (Expression("3*_longname1")
              ..setDecimalVariable("_longname1", Decimal.fromInt(7)))
            .eval()
            .toString(),
        "21");
  });

  test("failsIfVariableDoesNotExist", () {
    expect(() => Expression("3*unknown").eval(),
        throwsA(isInstanceOf<ExpressionException>()));
  });

  test("testNullVariable", () {
    Expression e;
    e = new Expression("a")..setStringVariable("a", "null");
    expect(e.eval(), null);

    e = new Expression("a")..setDecimalVariable("a", null);
    expect(e.eval(), null);

    String err = "";

    try {
      new Expression("a+1")..setStringVariable("a", "null").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }

    expect(err, "First operand may not be null.");
  });
}
