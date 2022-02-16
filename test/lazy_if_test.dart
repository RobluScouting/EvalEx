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
  test("testLazyIf", () {
    Expression expression = new Expression("if(a=0,0,12/a)")
      ..setDecimalVariable("a", Decimal.zero);
    expect(expression.eval(), Decimal.zero);
  });

  test("testLazyIfWithNestedFunctions", () {
    Expression expression = new Expression("if(a=0,0,abs(12/a))")
      ..setDecimalVariable("a", Decimal.zero);
    expect(expression.eval(), Decimal.zero);
  });

  test("testLazyIfWithNestedSuccessIf", () {
    Expression expression = new Expression("if(a=0,0,if(5/a>3,2,4))")
      ..setDecimalVariable("a", Decimal.zero);
    expect(expression.eval(), Decimal.zero);
  });

  test("testLazyIfWithNestedFailingIf()", () {
    Expression expression = new Expression("if(a=0,if(5/a>3,2,4),0)")
      ..setDecimalVariable("a", Decimal.zero);

    expect(() => expression.eval(), throwsA(isInstanceOf<ExpressionException>()));
  });

  test("testLazyIfWithNull", () {
    String err = "";

    try {
      new Expression("if(a,0,12/a)")..setStringVariable("a", "null").eval();
    } on AssertionError catch (e) {
      err = e.message.toString();
    }

    expect(err, "Condition may not be null.");
  });
}
