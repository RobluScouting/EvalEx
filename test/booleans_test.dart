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

void assertToken(String surface, TokenType type, Token actual) {
  expect(actual.surface, surface);
  expect(actual.type, type);
}

void main() {
  test('testIsBoolean', () {
    Expression e = Expression("1==1");
    expect(e.isBoolean(), true);

    e = Expression("true==TRUE");
    expect(e.eval().toString(), "1");

    e = Expression("false==FALSE");
    expect(e.eval().toString(), "1");

    e = Expression("a==b")..setStringVariable("a", "1")..setStringVariable("b", "2");
    expect(e.isBoolean(), true);

    e = new Expression("(1==1)||(c==a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("(z+z==x-y)||(c==a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("NOT(a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("a+b");
    expect(e.isBoolean(), false);

    e = new Expression("(a==b)+(b==c)");
    expect(e.isBoolean(), false);

    e = new Expression("SQRT(2)");
    expect(e.isBoolean(), false);

    e = new Expression("SQRT(2) == SQRT(b)");
    expect(e.isBoolean(), true);

    e = new Expression("IF(a==b,x+y,x-y)");
    expect(e.isBoolean(), false);

    e = new Expression("IF(a==b,x==y,a==b)");
    expect(e.isBoolean(), true);
  });

  test('testAndTokenizer', () {
    Expression e = new Expression("1&&0");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("&&", TokenType.operator, i.current);
    i.moveNext();
    assertToken("0", TokenType.literal, i.current);
  });

  test('testAndRPN', () {
    expect(Expression("1&&0").toRPN(), "1 0 &&");
  });

  test('testAndEval', () {
    expect(Expression("1&&0").eval().toString(), "0");
    expect(Expression("1&&1").eval().toString(), "1");
    expect(Expression("0&&0").eval().toString(), "0");
    expect(Expression("0&&1").eval().toString(), "0");
  });

  test('testOrEval', () {
    expect(Expression("1||0").eval().toString(), "1");
    expect(Expression("1||1").eval().toString(), "1");
    expect(Expression("0||0").eval().toString(), "0");
    expect(Expression("0||1").eval().toString(), "1");
  });

  test('testCompare', () {
    expect(Expression("2>1").eval().toString(), "1");
    expect(Expression("2<1").eval().toString(), "0");
    expect(Expression("1>2").eval().toString(), "0");
    expect(Expression("1<2").eval().toString(), "1");
    expect(Expression("1=2").eval().toString(), "0");
    expect(Expression("1=1").eval().toString(), "1");
    expect(Expression("1>=1").eval().toString(), "1");
    expect(Expression("1.1>=1").eval().toString(), "1");
    expect(Expression("1>=2").eval().toString(), "0");
    expect(Expression("1<=1").eval().toString(), "1");
    expect(Expression("1.1<=1").eval().toString(), "0");
    expect(Expression("1<=2").eval().toString(), "1");
    expect(Expression("1=2").eval().toString(), "0");
    expect(Expression("1=1").eval().toString(), "1");
    expect(Expression("1!=2").eval().toString(), "1");
    expect(Expression("1!=1").eval().toString(), "0");
    expect(Expression("16>10").eval().toString(), "1");
    expect(Expression("16>10").eval().toString(), "1");
    expect(Expression("10.3>10").eval().toString(), "1");
  });

  test('testCompareCombined', () {
    expect(Expression("(2>1)||(1=0)").eval().toString(), "1");
    expect(Expression("(2>3)||(1=0)").eval().toString(), "0");
    expect(Expression("(2>3)||(1=0)||(1&&1)").eval().toString(), "1");
  });

  test('testMixed', () {
    expect(Expression("1.5 * 7 = 3").eval().toString(), "0");
    expect(Expression("1.5 * 7 = 10.5").eval().toString(), "1");
  });

  test('testNot', () {
    expect(Expression("not(1)").eval().toString(), "0");
    expect(Expression("not(0)").eval().toString(), "1");
    expect(Expression("not(1.5 * 7 = 3)").eval().toString(), "1");
    expect(Expression("not(1.5 * 7 = 10.5)").eval().toString(), "0");
  });

  test('testConstants', () {
    expect(Expression("TRUE!=FALSE").eval().toString(), "1");
    expect(Expression("TRUE==2").eval().toString(), "0");
    expect(Expression("NOT(TRUE)==FALSE").eval().toString(), "1");
    expect(Expression("NOT(FALSE)==TRUE").eval().toString(), "1");
    expect(Expression("TRUE && FALSE").eval().toString(), "0");
    expect(Expression("TRUE || FALSE").eval().toString(), "1");
  });

  test('testIf', () {
    expect(Expression("if(TRUE, 5, 3)").eval().toString(), "5");
    expect(Expression("IF(FALSE, 5, 3)").eval().toString(), "3");
    expect(Expression("If(2, 5.35, 3)").eval().toString(), "5.35");
  });

  test("testDecimals", () {
    expect(Expression("if(0.0, 1, 0)").eval().toString(), "0");
    expect(Expression("0.0 || 0.0").eval().toString(), "0");
    expect(Expression("not(0.0)").eval().toString(), "1");
    expect(Expression("0.0 && 0.0").eval().toString(), "0");
  });
}
