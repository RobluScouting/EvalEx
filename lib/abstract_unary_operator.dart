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
import 'package:eval_ex/abstract_operator.dart';

import 'expression.dart';

/// Abstract implementation of an unary operator.<br>
/// This abstract implementation implements eval so that it forwards its first
/// parameter to evalUnary.
abstract class AbstractUnaryOperator extends AbstractOperator {
  /// Creates a new operator.
  ///
  /// [oper] - The operator name (pattern).
  /// [precedence] - The operators precedence.
  /// [leftAssoc] - `true` if the operator is left associative, else `false<`
  AbstractUnaryOperator(String oper, int precedence, bool leftAssoc)
      : super(oper, precedence, leftAssoc);

  @override
  LazyNumber evalLazy(final LazyNumber v1, final LazyNumber v2) {
    if (v2 != null) {
      throw ExpressionException(
          "Did not expect a second parameter for unary operator");
    }

    return LazyNumberImpl(eval: () {
      return evalUnary(v1.eval());
    }, getString: () {
      return evalUnary(v1.eval()).toString();
    });
  }

  @override
  Decimal eval(Decimal v1, Decimal v2) {
    if (v2 != null) {
      throw ExpressionException(
          "Did not expect a second parameter for unary operator");
    }

    return evalUnary(v1);
  }

  Decimal evalUnary(Decimal v1);
}
