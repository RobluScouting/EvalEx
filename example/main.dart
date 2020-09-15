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

void main() {
  Expression exp = Expression("2 ^ 4 + 8");
  print(exp.eval().toString()); // 24

  // With a variable
  exp = Expression("a ^ b + c");
  // Variables may contain alphanumeric characters, and "_". This can be changed
  // by using setVariableCharacters(..) and setFirstVariableCharacters(..) (what chars variable are allowed to start with).
  exp.setStringVariable("a", "2");
  exp.setStringVariable("b", "4");
  exp.setStringVariable("c", "8");
  print(exp.eval().toString()); // 24

  // With a function
  exp = Expression("MAX(-7,8)");
  print(exp.eval().toString()); // 8

  // Boolean logic
  exp = Expression("1>0 && 5 == 5");
  print(exp.eval().toString()); // 1

  exp = Expression("1>0 && 5 == 4");
  print(exp.eval().toString()); // 0
}
