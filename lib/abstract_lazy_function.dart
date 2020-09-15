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

import 'lazy_function.dart';

/// Abstract implementation of a lazy function which implements all necessary
/// methods with the exception of the main logic.
abstract class AbstractLazyFunction implements ILazyFunction {
  /// Name of this function.
  String name;

  /// Number of parameters expected for this function. <code>-1</code>
  /// denotes a variable number of parameters.
  int numParams;

  /// Whether this function is a boolean function.
  bool booleanFunction;

  /// Creates a new function with given name and parameter count.
  ///
  /// [name] - The name of the function.
  /// [numParams] - The number of parameters for this function.
  /// `-1<` denotes a variable number of parameters.
  /// [booleanFunction] Whether this function is a boolean function.
  AbstractLazyFunction(String name, this.numParams,
      {this.booleanFunction = false})
      : name = name.toUpperCase();

  @override
  String getName() {
    return name;
  }

  @override
  int getNumParams() {
    return numParams;
  }

  @override
  bool numParamsVaries() {
    return numParams < 0;
  }

  @override
  bool isBooleanFunction() {
    return booleanFunction;
  }
}
