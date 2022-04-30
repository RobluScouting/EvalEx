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
import 'package:test/test.dart';

void main() {
  test("testNestedVars", () {
    String x = "1";
    String y = "2";
    String z = "2*x + 3*y";
    String a = "2*x + 4*z";

    Expression e = new Expression(a)
      ..setStringVariable("x", x)
      ..setStringVariable("y", y)
      ..setStringVariable("z", z);

    expect(e.eval().toString(), "34");
  });

  test("testReplacements", () {
    Expression e = new Expression("3+a+aa+aaa")
      ..setStringVariable("a", "1*x")
      ..setStringVariable("aa", "2*x")
      ..setStringVariable("aaa", "3*x")
      ..setStringVariable("x", "2");

    expect(e.eval().toString(), "15");
  });

  test("testNestedOutOfOrdersVars", () {
    String x = "7";
    String y = "5";
    String z = "a+b";
    String a = "p+q";
    String p = "b+q";
    String q = "x+y";
    String b = "x*2+y";
    Expression e = new Expression(z)
      ..setStringVariable("q", q)
      ..setStringVariable("p", p)
      ..setStringVariable("a", a)
      ..setStringVariable("b", b)
      ..setStringVariable("x", x)
      ..setStringVariable("y", y);

    // a+b = p+q+b = b+q+q+b = 2b+2q = 2(x*2 + y) + 2(x+y) = 2(7*2+5) + 2(7+5) =
    String res = e.eval().toString();
    expect(res, "62");
  });

  test("testNestedOutOfOrderVarsWithFunc", () {
    String x = "7";
    String y = "5";
    String z = "a+b";
    String a = "p+q";
    String p = "b+q";
    String q = "myAvg(x,b)";
    String b = "x*2+y";
    Expression e = new Expression(z)
      ..setStringVariable("q", q)
      ..setStringVariable("p", p)
      ..setStringVariable("a", a)
      ..setStringVariable("b", b)
      ..setStringVariable("x", x)
      ..setStringVariable("y", y);

    e.addFunc(FunctionImpl("myAvg", 2, fEval: (params) {
      expect(params.length, 2);
      Decimal two = Decimal.fromInt(2);
      Decimal res = ((params[0] + params[1]) / two).toDecimal();
      return res;
    }));

    // a+b = p+q+b = b+q+q+b = 2b+2q = 2(x*2 + y) + 2(myAvg(x+b)) = 2(7*2+5) + 2((7+(7*2+5))/2 = 38 + 26 = 64
    String res = e.eval().toString();
    expect(res, "64");
  });

  test("testNestedOutOfOrderVarsWithOperators", () {
    Expression e = new Expression("a+y");

    e.addOperator(OperatorImpl(">>", 30, true, fEval: (v1, v2) {
      return Decimal.parse("12345.678");
    }));

    e.setStringVariable("b", "123.45678"); // e=((123.45678 >> 2))+2+y
    e.setStringVariable("x", "b >> 2"); // e=((b >> 2)+2)+y
    e.setStringVariable("a", "X+2"); // e=(x+2)+y
    e.setStringVariable(
        "y", "5"); // e=((123.45678>>2)+2)+5 = 12345.678+2+5 = 12352.678
    expect(e.eval().toString(), "12352.678");
  });
}
