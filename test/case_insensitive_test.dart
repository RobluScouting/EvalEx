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
import 'package:eval_ex/built_ins.dart';
import 'package:eval_ex/expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("testVariableIsCaseInsensitive", () {
    Expression expression = new Expression("a");
    expression.setDecimalVariable("A", Decimal.fromInt(20));
    expect(expression.eval().toInt(), 20);

    expression = new Expression("a + B");
    expression.setDecimalVariable("A", Decimal.fromInt(10));
    expression.setDecimalVariable("b", Decimal.fromInt(10));
    expect(expression.eval().toInt(), 20);

    expression = new Expression("a+B");
    expression.setStringVariable("A", "c+d");
    expression.setDecimalVariable("b", Decimal.fromInt(10));
    expression.setDecimalVariable("C", Decimal.fromInt(5));
    expression.setDecimalVariable("d", Decimal.fromInt(5));
    expect(expression.eval().toInt(), 20);
  });

  test("testFunctionCaseInsensitive", () {
    Expression expression = Expression("a+testsum(1,3)");
    expression.setDecimalVariable("A", Decimal.one);
    expression.addFunc(FunctionImpl("testSum", -1, fEval: (params) {
      Decimal value;
      for (Decimal d in params) {
        value = value == null ? d : value + d;
      }
      return value;
    }));

    expect(expression.eval(), Decimal.fromInt(5));
  });
}
