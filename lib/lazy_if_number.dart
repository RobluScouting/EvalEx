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
import 'package:eval_ex/expression.dart';

/// Lazy Number for IF function created for lazily evaluated IF condition
class LazyIfNumber implements LazyNumber {
  List<LazyNumber?> _lazyParams;

  LazyIfNumber(this._lazyParams);

  @override
  Decimal? eval() {
    LazyNumber? condition = _lazyParams[0];

    if (condition == null) {
      throw new AssertionError("Condition may not be null.");
    }

    Decimal? result = condition.eval();

    if (result == null) {
      throw new AssertionError("Condition may not be null.");
    }

    bool isTrue = result.compareTo(Decimal.zero) != 0;
    return isTrue ? _lazyParams[1]?.eval() : _lazyParams[2]?.eval();
  }

  @override
  String getString() {
    LazyNumber? condition = _lazyParams[0];
    if (condition == null) {
      throw new AssertionError("Condition may not be null.");
    }

    return condition.getString();
  }
}
