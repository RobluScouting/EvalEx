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
  test("testSimple", () {
    Expression e = new Expression("max(1)");
    expect(e.eval().toString(), "1");

    e = new Expression("max(4,8)");
    expect(e.eval().toString(), "8");

    e = new Expression("max(12,4,8)");
    expect(e.eval().toString(), "12");

    e = new Expression("max(12,4,8,16,32)");
    expect(e.eval().toString(), "32");
  });

  test("testNested", () {
    Expression e = new Expression("max(1,2,max(3,4,5,max(9,10,3,4,5),8),7)");
    expect(e.eval().toString(), "10");
  });

  test("testZero", () {
    Expression e = new Expression("max(0)");
    expect(e.eval().toString(), "0");

    e = new Expression("max(0,3)");
    expect(e.eval().toString(), "3");

    e = new Expression("max(2,0,-3)");
    expect(e.eval().toString(), "2");

    e = new Expression("max(-2,0,-3)");
    expect(e.eval().toString(), "0");

    e = new Expression("max(0,0,0,0)");
    expect(e.eval().toString(), "0");
  });

  test("testError", () {
    String err = "";
    Expression e = new Expression("max()");

    try {
      e.eval();
    } on ExpressionException catch(e) {
      err = e.msg;
    }

    expect(err, "MAX requires at least one parameter");
  });

  test("testCustomFunction1", () {
    Expression e = new Expression("3 * AVG(2,4)");
    e.addFunc(FunctionImpl("AVG", -1, fEval: (params) {
      if(params.length == 0) {
        throw new ExpressionException("AVG requires at least one parameter");
      }

      Decimal avg = Decimal.zero;
      for (Decimal parameter in params) {
        avg = avg + parameter;
      }
      return avg / Decimal.fromInt(params.length);
    }));

    expect(e.eval().toString(), "9");
  });

  test("testCustomFunction2", () {
    Expression e = new Expression("4 * AVG(2,4,6,8,10,12)");
    e.addFunc(FunctionImpl("AVG", -1, fEval: (params) {
      if(params.length == 0) {
        throw new ExpressionException("AVG requires at least one parameter");
      }

      Decimal avg = Decimal.zero;
      for (Decimal parameter in params) {
        avg = avg + parameter;
      }
      return avg / Decimal.fromInt(params.length);
    }));

    expect(e.eval().toString(), "28");
  });
}