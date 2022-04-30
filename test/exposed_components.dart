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
  test("testDeclaredOperators", () {
    Expression expression = new Expression("c+d");
    int originalOperator = expression.getDeclaredOperators().length;

    expression.addOperator(OperatorImpl("\$\$", -1, true, fEval: (v1, v2) {
      return null;
    }));

    // "Operator List should have the new $$ operator"
    expect(expression.getDeclaredOperators().contains("\$\$"), true);
    // "Should have an extra operators"
    expect(expression.getDeclaredOperators().length, originalOperator + 1);
  });

  test("testDeclaredVariables", () {
    Expression expression = new Expression("c+d");
    int originalCounts = expression.getDeclaredVariables().length;
    expression.setDecimalVariable("var1", Decimal.fromInt(12));

    // "Function list should have new func1 function declared"
    expect(expression.getDeclaredVariables().contains("var1"), true);
    // "Function list should have one more function declared"
    expect(expression.getDeclaredVariables().length, originalCounts + 1);
  });

  test("testDeclaredFunctionGetter", () {
    Expression expression = new Expression("c+d");
    int originalFunctionCount = expression.getDeclaredFunctions().length;

    expression.addFunc(FunctionImpl("func1", 3, fEval: (params) {
      return null;
    }));

    // "Function list should have new func1 function declared"
    expect(expression.getDeclaredFunctions().contains("FUNC1"), true);
    // "Function list should have one more function declared"
    expect(expression.getDeclaredFunctions().length, originalFunctionCount + 1);
  });
}
