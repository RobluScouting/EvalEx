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
import 'package:eval_ex/abstract_lazy_operator.dart';
import 'package:eval_ex/expression.dart';
import 'package:eval_ex/operator.dart';

abstract class AbstractOperator extends AbstractLazyOperator implements IOperator {
  AbstractOperator(String oper, int precedence, bool leftAssoc, {bool booleanOperator}) :
      super(oper, precedence, leftAssoc, booleanOperator: booleanOperator);

  LazyNumber evalLazy(final LazyNumber v1, final LazyNumber v2) {
    return _LazyNumberImpl(this, v1, v2);
  }
}

class _LazyNumberImpl extends LazyNumber {
  AbstractOperator _abstractOperator;
  LazyNumber _v1;
  LazyNumber _v2;

  _LazyNumberImpl(this._abstractOperator, this._v1, this._v2);

  @override
  Decimal eval() {
    return _abstractOperator.eval(_v1.eval(), _v2.eval());
  }

  @override
  String getString() {
    return eval().toString();
  }
}