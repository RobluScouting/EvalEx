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

import 'lazy_operator.dart';

/// Abstract implementation of an operator.
abstract class AbstractLazyOperator implements ILazyOperator {
  /// This operators name (pattern).
  String oper;

  /// Operators precedence.
  int precedence;

  /// Operator is left associative.
  bool leftAssoc;

  /// Whether this operator is boolean or not.
  bool booleanOperator;

  bool unaryOperator;

  /// Creates a new operator.
  ///
  /// [oper] - The operator name (pattern).
  /// [precedence] - The operators precedence.
  /// [leftAssoc] - `true` if the operator is left associative, else `false`.
  /// [booleanOperator] - Whether this operator is boolean.
  AbstractLazyOperator(this.oper, this.precedence, this.leftAssoc,
      {this.booleanOperator = false, this.unaryOperator = false});

  @override
  String getOper() {
    return oper;
  }

  @override
  int getPrecedence() {
    return precedence;
  }

  @override
  bool isLeftAssoc() {
    return leftAssoc;
  }

  @override
  bool isBooleanOperator() {
    return booleanOperator;
  }

  @override
  bool isUnaryOperator() {
    return unaryOperator;
  }
}
