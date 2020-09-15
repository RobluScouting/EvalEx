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
  test("testVars", () {
    Expression ex = new Expression("a/2*PI+MIN(e,b)");
    List<String> usedVars = ex.getUsedVariables();

    expect(usedVars.length, 2);
    expect(usedVars.contains("a"), true);
    expect(usedVars.contains("b"), true);
  });

  test("testVarsLongNames", () {
    Expression ex = new Expression("var1/2*PI+MIN(var2,var3)");
    List<String> usedVars = ex.getUsedVariables();
    expect(usedVars.length, 3);
    expect(usedVars.contains("var1"), true);
    expect(usedVars.contains("var2"), true);
    expect(usedVars.contains("var3"), true);
  });

  test("testVarsNothing", () {
    Expression ex = new Expression("1/2");
    List<String> usedVars = ex.getUsedVariables();
    expect(usedVars.length, 0);
  });
}