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

import 'package:eval_ex/expression.dart';
import 'package:test/test.dart';

void main() {
  test("testSimple", () {
    Expression e = new Expression("1e10");
    expect(e.eval().toString(), "10000000000");

    e = new Expression("1E10");
    expect(e.eval().toString(), "10000000000");

    e = new Expression("123.456E3");
    expect(e.eval().toString(), "123456");

    e = new Expression("2.5e0");
    expect(e.eval().toString(), "2.5");
  });

  test("testNegative", () {
    Expression e = new Expression("1e-10");
    expect(e.eval().toString(), "0.0000000001");

    e = new Expression("1E-10");
    expect(e.eval().toString(), "0.0000000001");

    e = new Expression("2135E-4");
    expect(e.eval().toString(), "0.2135");
  });

  test("testPositive", () {
    Expression e = new Expression("1e+10");
    expect(e.eval().toString(), "10000000000");

    e = new Expression("1E+10");
    expect(e.eval().toString(), "10000000000");
  });

  test("testCombined", () {
    Expression e = new Expression("sqrt(152.399025e6)");
    expect(e.eval().toString(), "12345");

    e = new Expression("sin(3.e1)");
    expect(e.eval().toString(), "0.49999999999999994");

    e = new Expression("sin( 3.e1)");
    expect(e.eval().toString(), "0.49999999999999994");

    e = new Expression("sin(3.e1 )");
    expect(e.eval().toString(), "0.49999999999999994");

    e = new Expression("sin( 3.e1 )");
    expect(e.eval().toString(), "0.49999999999999994");

    e = new Expression("2.2e-16 * 10.2");
    expect(e.eval().toString(), "0.000000000000002244");
  });

  test("testError1", () {
    Expression e = new Expression("1234e-2.3");
    expect(() => e.eval(), throwsA(isA<FormatException>()));
  });

  test("testError2", () {
    Expression e = new Expression("1234e2.3");
    expect(() => e.eval(), throwsA(isA<FormatException>()));
  });

  test("testError3", () {
    String err = "";
    Expression e = new Expression("e2");
    try {
      e.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown operator or function: e2");
  });
}
