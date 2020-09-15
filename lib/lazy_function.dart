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

/// Base interface which is required for lazily evaluated functions. A function
/// is defined by a name, a number of parameters it accepts and of course
/// the logic for evaluating the result.
abstract class ILazyFunction {
  /// Gets the name of this function.<br>
  /// <br>
  /// The name is use to invoke this function in the expression.
  ///
  /// Returns the name of this function.
  String getName();

  /// Gets the number of parameters this function accepts.<br>
  ///
  /// A value of <code>-1</code> denotes that this function accepts a variable
  /// number of parameters.
  ///
  /// Returns the number of parameters this function accepts.
  int getNumParams();

  /// Gets whether the number of accepted parameters varies.<br>
  ///
  /// That means that the function does accept an undefined amount of
  /// parameters.
  ///
  /// Returns `true` if the number of accepted parameters varies.
  bool numParamsVaries();

  /// Gets whether this function evaluates to a boolean expression.
  ///
  /// Returns `true`> if this function evaluates to a boolean expression.
  bool isBooleanFunction();

  /// Lazily evaluate this function.
  ///
  /// [lazyParams] - The accepted parameters.
  /// Returns the lazy result of this function.
  LazyNumber lazyEval(List<LazyNumber> lazyParams);
}
