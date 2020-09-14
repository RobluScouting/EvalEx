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

import 'abstract_lazy_function.dart';
import 'expression.dart';
import 'func.dart';

abstract class AbstractFunction extends AbstractLazyFunction implements IFunc {
  AbstractFunction(String name, int numParams, {bool booleanFunction = false})
      : super(name, numParams, booleanFunction: booleanFunction);

  LazyNumber lazyEval(final List<LazyNumber> lazyParams) {
    return _LazyNumberImpl(this, lazyParams);
  }
}

class _LazyNumberImpl extends LazyNumber {
  AbstractFunction _abstractFunction;
  List<LazyNumber> _lazyParams;
  List<Decimal> _params;

  _LazyNumberImpl(this._abstractFunction, this._lazyParams);

  @override
  Decimal eval() {
      return _abstractFunction.eval(_getParams());
  }

  @override
  String getString() {
    return eval().toString();
  }

  List<Decimal> _getParams() {
    if (_params == null) {
      _params = List();
      _params.addAll(_lazyParams.map((e) => e.eval()));
    }

    return _params;
  }
}
