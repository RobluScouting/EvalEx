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
  test("testBadVarChar", () {
    String err = "";
    try {
      Expression expression = new Expression("a.b/2*PI+MIN(e,b)");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }
    expect(err, "Unknown operator . at character position 2");
  });

  test("testAddedVarChar", () {
    String err = "";
    Expression expression;

    try {
      expression =
          new Expression("a.b/2*PI+MIN(e,b)").setVariableCharacters("_");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }
    expect(err, "Unknown operator . at character position 2");

    try {
      expression =
          new Expression("a.b/2*PI+MIN(e,b)").setVariableCharacters("_.");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }
    expect(err, "Unknown operator or function: a.b");

    expression =
        new Expression("a.b/2*PI+MIN(e,b)").setVariableCharacters("_.");
    expect(
        (expression..setStringVariable("a.b", "2")..setStringVariable("b", "3"))
            .eval()
            ?.toStringAsPrecision(7),
        "5.859874");

    try {
      expression =
          new Expression(".a.b/2*PI+MIN(e,b)").setVariableCharacters("_.");
      expression.eval();
    } on ExpressionException catch (e) {
      err = e.msg;
    }

    expect(err, "Unknown unary operator . at character position 1");

    expression = new Expression("a.b/2*PI+MIN(e,b)")
        .setVariableCharacters("_.")
        .setFirstVariableCharacters(".");
    expect(
        (expression..setStringVariable("a.b", "2")..setStringVariable("b", "3"))
            .eval()
            ?.toStringAsFixed(7),
        "5.8598745");
  });

  test("testFirstVarChar", () {
    Expression expression = new Expression("a.b*\$PI")
        .setVariableCharacters(".")
        .setFirstVariableCharacters("\$");
    expect(
        (expression
              ..setStringVariable("a.b", "2")
              ..setStringVariable("\$PI", "3"))
            .eval()
            .toString(),
        "6");
  });
}
