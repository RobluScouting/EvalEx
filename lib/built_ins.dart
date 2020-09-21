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

import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:eval_ex/abstract_lazy_function.dart';
import 'package:eval_ex/lazy_if_number.dart';

import 'abstract_function.dart';
import 'abstract_operator.dart';
import 'abstract_unary_operator.dart';
import 'expression.dart';

void addBuiltIns(Expression e) {
  e.addOperator(OperatorImpl("+", Expression.operatorPrecedenceAdditive, true,
      fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");
    return v1 + v2;
  }));

  e.addOperator(OperatorImpl("-", Expression.operatorPrecedenceAdditive, true,
      fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");
    return v1 - v2;
  }));

  e.addOperator(OperatorImpl(
      "*", Expression.operatorPrecedenceMultiplicative, true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");
    return v1 * v2;
  }));

  e.addOperator(OperatorImpl(
      "/", Expression.operatorPrecedenceMultiplicative, true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");
    return v1 / v2;
  }));

  e.addOperator(OperatorImpl(
      "%", Expression.operatorPrecedenceMultiplicative, true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");
    return v1 % v2;
  }));

  e.addOperator(
      OperatorImpl("^", e.powerOperatorPrecedence, false, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    // Do an more high performance estimate to see if this should be request
    // should be canned
    double test = math.pow(v1.toDouble(), v2.toDouble());
    if (test.isInfinite) {
      throw new ExpressionException("Exponentiation too expensive");
    } else if (test.isNaN) {
      throw new ExpressionException("Exponentiation invalid");
    }

    // Thanks to Gene Marin:
    // http://stackoverflow.com/questions/3579779/how-to-do-a-fractional-power-on-bigdecimal-in-java
    int signOf2 = v2.signum;
    double dn1 = v1.toDouble();
    v2 = v2 * Decimal.fromInt(signOf2);
    Decimal remainderOf2 = v2.remainder(Decimal.one);
    Decimal n2IntPart = v2 - remainderOf2;
    Decimal intPow = v1.pow(n2IntPart.toInt());
    Decimal doublePow =
        Decimal.parse(math.pow(dn1, remainderOf2.toDouble()).toString());

    Decimal result = intPow * doublePow;
    if (signOf2 == -1) {
      result = Decimal.one / result;
    }

    return result;
  }));

  e.addOperator(OperatorImpl("&&", Expression.operatorPrecedenceAnd, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    bool b1 = v1.compareTo(Decimal.zero) != 0;

    if (!b1) {
      return Decimal.zero;
    }

    bool b2 = v2.compareTo(Decimal.zero) != 0;

    return b2 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl("||", Expression.operatorPrecedenceOr, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    bool b1 = v1.compareTo(Decimal.zero) != 0;

    if (b1) {
      return Decimal.one;
    }

    bool b2 = v2.compareTo(Decimal.zero) != 0;

    return b2 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl(
      ">", Expression.operatorPrecedenceComparison, false, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    return v1.compareTo(v2) == 1 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl(
      ">=", Expression.operatorPrecedenceComparison, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    return v1.compareTo(v2) >= 0 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl(
      "<", Expression.operatorPrecedenceComparison, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    return v1.compareTo(v2) == -1 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl(
      "<=", Expression.operatorPrecedenceComparison, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    return v1.compareTo(v2) <= 0 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl("=", Expression.operatorPrecedenceEquality, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    if (v1 == v2) {
      return Decimal.one;
    }

    if (v1 == null || v2 == null) {
      return Decimal.zero;
    }

    return v1.compareTo(v2) == 0 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl("==", Expression.operatorPrecedenceEquality, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    if (v1 == v2) {
      return Decimal.one;
    }

    if (v1 == null || v2 == null) {
      return Decimal.zero;
    }

    return v1.compareTo(v2) == 0 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl("!=", Expression.operatorPrecedenceEquality, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    if (v1 == v2) {
      return Decimal.zero;
    }

    if (v1 == null || v2 == null) {
      return Decimal.one;
    }

    return v1.compareTo(v2) != 0 ? Decimal.one : Decimal.zero;
  }));

  e.addOperator(OperatorImpl("<>", Expression.operatorPrecedenceEquality, false,
      booleanOperator: true, fEval: (v1, v2) {
    assert(v1 != null, "First operand may not be null");
    assert(v2 != null, "Second operand may not be null");

    if (v1 == v2) {
      return Decimal.zero;
    }

    if (v1 == null || v2 == null) {
      return Decimal.one;
    }

    return v1.compareTo(v2) != 0 ? Decimal.one : Decimal.zero;
  }));

  e.addLazyFunction(LazyFunctionImpl("STREQ", 2, fEval: (params) {
    if (params[0].getString() == params[1].getString()) {
      return e.createLazyNumber(Decimal.one);
    } else {
      return e.createLazyNumber(Decimal.zero);
    }
  }));

  e.addOperator(UnaryOperatorImpl(
      "-", Expression.operatorPrecedenceUnary, false, fEval: (v1) {
    assert(v1 != null, "Operand may not be null");

    return v1 * Decimal.fromInt(-1);
  }));

  e.addOperator(UnaryOperatorImpl(
      "+", Expression.operatorPrecedenceUnary, false, fEval: (v1) {
    assert(v1 != null, "Operand may not be null");

    return v1 * Decimal.one;
  }));

  e.addFunc(FunctionImpl("FACT", 1, booleanFunction: false, fEval: (params) {
    assert(params.first != null, "Operand may not be null");

    if (params.first.toDouble() > 50) {
      throw new ExpressionException("Operand must be <= 50");
    }

    int number = params.first.toInt();

    Decimal factorial = Decimal.one;
    for (int i = 1; i <= number; i++) {
      factorial = factorial * Decimal.fromInt(i);
    }
    return factorial;
  }));

  e.addFunc(FunctionImpl("NOT", 1, booleanFunction: true, fEval: (params) {
    assert(params.first != null, "Operand may not be null");

    bool zero = params.first.compareTo(Decimal.zero) == 0;
    return zero ? Decimal.one : Decimal.zero;
  }));

  e.addLazyFunction(LazyFunctionImpl("IF", 3, fEval: (params) {
    return LazyIfNumber(params);
  }));

  e.addFunc(FunctionImpl("RANDOM", 0, fEval: (params) {
    double d = math.Random().nextDouble();
    return Decimal.parse(d.toString());
  }));

  /*
   * Trig functions
   */
  // Standard, radians

  e.addFunc(FunctionImpl("SINR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.sin(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("COSR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.cos(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("TANR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.tan(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("COTR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1.0 / math.tan(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("SECR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1 / math.cos(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("CSCR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1.0 / math.sin(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  // Standard, degrees

  e.addFunc(FunctionImpl("SIN", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.sin(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("COS", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.cos(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("TAN", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.tan(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("COT", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1.0 / math.tan(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("SEC", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1 / math.cos(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("CSC", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = 1.0 / math.sin(degreesToRads(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  // Inverse arc functions, radians

  e.addFunc(FunctionImpl("ASINR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.asin(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ACOSR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.acos(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ATANR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.atan(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ACOTR", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");

    if (params.first.toDouble() == 0) {
      throw new ExpressionException("Number must not be 0");
    }

    double d = math.atan(1.0 / params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ATAN2R", 2, fEval: (params) {
    assert(params[0] != null, "First operand may not be null");
    assert(params[1] != null, "Second operand may not be null");
    double d = math.atan2(params[0].toDouble(), params[1].toDouble());
    return Decimal.parse(d.toString());
  }));

  // Inverse arc functions, degrees

  e.addFunc(FunctionImpl("ASIN", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = degreesToRads(math.asin(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ACOS", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = degreesToRads(math.acos(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ATAN", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = radsToDegrees(math.atan(params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ACOT", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");

    if (params.first.toDouble() == 0.0) {
      throw new ExpressionException("Number must not be 0");
    }

    double d = radsToDegrees(math.atan(1.0 / params.first.toDouble()));
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ATAN2", 2, fEval: (params) {
    assert(params[0] != null, "First operand may not be null");
    assert(params[1] != null, "Second operand may not be null");
    double d =
        radsToDegrees(math.atan2(params[0].toDouble(), params[1].toDouble()));
    return Decimal.parse(d.toString());
  }));

  // Conversions
  e.addFunc(FunctionImpl("RAD", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = degreesToRads(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("DEG", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = radsToDegrees(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("MAX", -1, fEval: (params) {
    if (params.isEmpty) {
      throw new ExpressionException("MAX requires at least one parameter");
    }
    Decimal max;
    for (Decimal param in params) {
      assert(param != null, "Param may not be null");
      if (max == null || param.compareTo(max) > 0) {
        max = param;
      }
    }

    return max;
  }));

  e.addFunc(FunctionImpl("MIN", -1, fEval: (params) {
    if (params.isEmpty) {
      throw new ExpressionException("MIN requires at least one parameter");
    }
    Decimal min;
    for (Decimal param in params) {
      assert(param != null, "Param may not be null");
      if (min == null || param.compareTo(min) < 0) {
        min = param;
      }
    }

    return min;
  }));

  e.addFunc(FunctionImpl("ABS", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    return params.first.abs();
  }));

  e.addFunc(FunctionImpl("LOG", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = math.log(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("LOG10", 1, fEval: (params) {
    assert(params.first != null, "Operand may not be null.");
    double d = log10(params.first.toDouble());
    return Decimal.parse(d.toString());
  }));

  e.addFunc(FunctionImpl("ROUND", 2, fEval: (params) {
    assert(params.first != null, "First operand may not be null");
    assert(params[1] != null, "Second operand may not be null");
    Decimal toRound = params.first;
    return Decimal.parse(toRound.toStringAsFixed(params[1].toInt()));
  }));

  e.addFunc(FunctionImpl("FLOOR", 1, fEval: (params) {
    assert(params.first != null, "First operand may not be null");

    return params.first.floor();
  }));

  e.addFunc(FunctionImpl("CEILING", 1, fEval: (params) {
    assert(params.first != null, "First operand may not be null");

    return params.first.ceil();
  }));

  e.addFunc(FunctionImpl("SQRT", 1, fEval: (params) {
    assert(params.first != null, "First operand may not be null");

    return Decimal.parse(math.sqrt(params.first.toDouble()).toString());
  }));

  e.variables["theAnswerToLifeTheUniverseAndEverything"] =
      e.createLazyNumber(Decimal.fromInt(42));

  e.variables["e"] = e.createLazyNumber(Expression.e);
  e.variables["PI"] = e.createLazyNumber(Expression.pi);
  e.variables["NULL"] = null;
  e.variables["TRUE"] = e.createLazyNumber(Decimal.one);
  e.variables["FALSE"] = e.createLazyNumber(Decimal.zero);
}

class OperatorImpl extends AbstractOperator {
  Function(Decimal v1, Decimal v2) fEval;

  OperatorImpl(String oper, int precedence, bool leftAssoc,
      {bool booleanOperator = false, this.fEval})
      : super(oper, precedence, leftAssoc, booleanOperator: booleanOperator);

  @override
  Decimal eval(Decimal v1, Decimal v2) {
    return fEval(v1, v2);
  }
}

class UnaryOperatorImpl extends AbstractUnaryOperator {
  // Type defs?
  Function(Decimal v1) fEval;

  UnaryOperatorImpl(String oper, int precedence, bool leftAssoc, {this.fEval})
      : super(oper, precedence, leftAssoc);

  @override
  Decimal evalUnary(Decimal v1) {
    return fEval(v1);
  }
}

class FunctionImpl extends AbstractFunction {
  Function(List<Decimal>) fEval;

  FunctionImpl(String name, int numParams,
      {bool booleanFunction = false, this.fEval})
      : super(name, numParams, booleanFunction: booleanFunction);

  @override
  Decimal eval(List<Decimal> parameters) {
    return fEval(parameters);
  }
}

class LazyFunctionImpl extends AbstractLazyFunction {
  Function(List<LazyNumber>) fEval;

  LazyFunctionImpl(String name, int numParams,
      {bool booleanFunction = false, this.fEval})
      : super(name, numParams, booleanFunction: booleanFunction);

  @override
  LazyNumber lazyEval(List<LazyNumber> lazyParams) {
    return fEval(lazyParams);
  }
}

double log10(num x) => math.log(x) / math.ln10;

num degreesToRads(num deg) {
  return deg * (math.pi / 180);
}

num radsToDegrees(num rad) {
  return rad * (180 / math.pi);
}
