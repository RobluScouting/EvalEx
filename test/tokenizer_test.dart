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

void assertToken(String surface, TokenType type, Token actual) {
  expect(actual.surface, surface);
  expect(actual.type, type);
}

void main() {
  test("testSpacesFunctions", () {
    Expression e;
    Iterator<Token> i;

    e = new Expression("sin (30)");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("sin", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("30", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    expect(i.moveNext(), false);
  });

  test("testSpacesFunctionsVariablesOperators", () {
    Expression e;
    Iterator<Token> i;

    e = new Expression("   sin   (   30   +   x   )   ");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("sin", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("30", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("x", TokenType.variable, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    expect(i.moveNext(), false);
  });

  test("testNumbers", () {
    Expression e;
    Iterator<Token> i;

    e = new Expression("1");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("-1");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("123");
    i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("123", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("-123");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("123", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("123.4");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("123.4", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("-123.456");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("123.456", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression(".1");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken(".1", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("-.1");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken(".1", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);
  });

  test("testTokenizerExtraSpaces", () {
    Expression e = new Expression("1 ");
    Iterator<Token> i = e.getExpressionTokenizer();
    expect(i.moveNext(), true);
    assertToken("1", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("       ");
    i = e.getExpressionTokenizer();
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("   1      ");
    i = e.getExpressionTokenizer();
    expect(i.moveNext(), true);
    assertToken("1", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);

    e = new Expression("  1   +   2    ");
    i = e.getExpressionTokenizer();
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2", TokenType.literal, i.current);
    expect(i.moveNext(), false);
    expect(i.current, null);
  });

  test("testTokenizer1", () {
    Expression e = new Expression("1+2");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2", TokenType.literal, i.current);
  });

  test("testTokenizer2", () {
    Expression e = new Expression("1 + 2");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2", TokenType.literal, i.current);
  });

  test("testTokenizer3", () {
    Expression e = new Expression(" 1 + 2 ");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2", TokenType.literal, i.current);
  });

  test("testTokenizer4", () {
    Expression e = new Expression("1+2-3/4*5");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2", TokenType.literal, i.current);
    i.moveNext();
    assertToken("-", TokenType.operator, i.current);
    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("4", TokenType.literal, i.current);
    i.moveNext();
    assertToken("*", TokenType.operator, i.current);
    i.moveNext();
    assertToken("5", TokenType.literal, i.current);
  });

  test("testTokenizer5", () {
    Expression e = new Expression("1+2.1-3.45/4.982*5.0");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2.1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("-", TokenType.operator, i.current);
    i.moveNext();
    assertToken("3.45", TokenType.literal, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("4.982", TokenType.literal, i.current);
    i.moveNext();
    assertToken("*", TokenType.operator, i.current);
    i.moveNext();
    assertToken("5.0", TokenType.literal, i.current);
    i.moveNext();
  });

  test("testTokenizer6", () {
    Expression e = new Expression("-3+4*-1");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("4", TokenType.literal, i.current);
    i.moveNext();
    assertToken("*", TokenType.operator, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
  });

  test("testTokenizer7", () {
    Expression e = new Expression("(-3+4)*-1/(7-(5*-8))");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("4", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);

    i.moveNext();
    assertToken("*", TokenType.operator, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("7", TokenType.literal, i.current);
    i.moveNext();
    assertToken("-", TokenType.operator, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("5", TokenType.literal, i.current);
    i.moveNext();
    assertToken("*", TokenType.operator, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("8", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
  });

  test("testTokenizer8", () {
    Expression e = new Expression("(1.9+2.8)/4.7");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("1.9", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("2.8", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("4.7", TokenType.literal, i.current);
  });

  test("testTokenizerFunction1", () {
    Expression e = new Expression("ABS(3.5)");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("ABS", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("3.5", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
  });

  test("testTokenizerFunction2", () {
    Expression e = new Expression("3-ABS(3.5)/9");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("-", TokenType.operator, i.current);
    i.moveNext();
    assertToken("ABS", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("3.5", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("9", TokenType.literal, i.current);
  });

  test("testTokenizerFunction3", () {
    Expression e = new Expression("MAX(3.5,5.2)");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("MAX", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("3.5", TokenType.literal, i.current);
    i.moveNext();
    assertToken(",", TokenType.comma, i.current);
    i.moveNext();
    assertToken("5.2", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
  });

  test("testTokenizerFunction4", () {
    Expression e = new Expression("3-MAX(3.5,5.2)/9");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("-", TokenType.operator, i.current);
    i.moveNext();
    assertToken("MAX", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("3.5", TokenType.literal, i.current);
    i.moveNext();
    assertToken(",", TokenType.comma, i.current);
    i.moveNext();
    assertToken("5.2", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("9", TokenType.literal, i.current);
  });

  test("testTokenizerFunction5", () {
    Expression e = new Expression("3/MAX(-3.5,-5.2)/9");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("MAX", TokenType.function, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("3.5", TokenType.literal, i.current);
    i.moveNext();
    assertToken(",", TokenType.comma, i.current);
    i.moveNext();
    assertToken("-u", TokenType.unaryOperator, i.current);
    i.moveNext();
    assertToken("5.2", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
    i.moveNext();
    assertToken("/", TokenType.operator, i.current);
    i.moveNext();
    assertToken("9", TokenType.literal, i.current);
  });

  test("testInsertImplicitMultiplication", () {
    Expression e = new Expression("22(3+1)");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("22", TokenType.literal, i.current);
    i.moveNext();
    assertToken("(", TokenType.openParen, i.current);
    i.moveNext();
    assertToken("3", TokenType.literal, i.current);
    i.moveNext();
    assertToken("+", TokenType.operator, i.current);
    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken(")", TokenType.closeParen, i.current);
  });

  test("testBracesCustomOperatorAndInIf", () {
    Expression e = new Expression("if( (a=0) and (b=0), 0, 1)");

    e.addOperator(OperatorImpl("AND", Expression.operatorPrecedenceAnd, false,
        booleanOperator: true, fEval: (v1, v2) {
      bool b1 = v1.compareTo(Decimal.zero) != 0;
      if (!b1) {
        return Decimal.zero;
      }
      bool b2 = v2.compareTo(Decimal.zero) != 0;
      return b2 ? Decimal.one : Decimal.zero;
    }));

    Decimal result =
        (e..setStringVariable("a", "0")..setStringVariable("b", "0")).eval();

    expect(result.toString(), "0");
  });
}
