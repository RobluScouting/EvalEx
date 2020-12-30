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
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("testSimple", () {
    expect(Expression("1+2").toRPN(), "1 2 +");
    expect(Expression("1+2/4").toRPN(), "1 2 4 / +");
    expect(Expression("(1+2)/4").toRPN(), "1 2 + 4 /");
    expect(Expression("(1.9+2.8)/4.7").toRPN(), "1.9 2.8 + 4.7 /");
    expect(Expression("(1.98+2.87)/4.76").toRPN(), "1.98 2.87 + 4.76 /");
    expect(Expression("3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3").toRPN(),
        "3 4 2 * 1 5 - 2 3 ^ ^ / +");
  });

  test("testFunctions", () {
    expect(Expression("SIN(23.6)").toRPN(), "( 23.6 SIN");
    expect(Expression("MAX(-7,8)").toRPN(), "( 7 -u 8 MAX");
    expect(Expression("MAX(SIN(3.7),MAX(2.6,-8.0))").toRPN(),
        "( ( 3.7 SIN ( 2.6 8.0 -u MAX MAX");
  });

  test("testOperatorsInFunctions", () {
    expect(Expression("SIN(23.6/4)").toRPN(), "( 23.6 4 / SIN");
  });

  test("testNested", () {
    Expression e = new Expression("x+y");
    e.setStringVariable("x", "a+b");
    expect(e.toRPN(), "a b + y +");
  });

  test("testComplexNested", () {
    Expression e = new Expression("x+y");
    e.setStringVariable("a", "p/q");
    e.setStringVariable("p", "q*y");
    e.setStringVariable("x", "p*12"); // x y + = p 12 * y +
    e.setStringVariable("y", "a"); // p 12 * p q / +
    e.setStringVariable("p", "15");
    e.setStringVariable("q", "14");
    String rpn = e.toRPN();
    expect(rpn, "p 12 * p q / +");
  });
}
