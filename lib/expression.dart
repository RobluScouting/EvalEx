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

import 'dart:collection';
import 'dart:core';

import 'package:decimal/decimal.dart';
import 'package:eval_ex/abstract_unary_operator.dart';
import 'package:eval_ex/built_ins.dart';
import 'package:eval_ex/func.dart';
import 'package:eval_ex/lazy_function.dart';
import 'package:eval_ex/lazy_operator.dart';
import 'package:eval_ex/utils.dart';

class Expression {
  /// Unary operators precedence: + and - as prefix
  static const int operatorPrecedenceUnary = 60;

  /// Equality operators precedence: =, ==, !=. <>
  static const int operatorPrecedenceEquality = 7;

  /// Comparative operators precedence: <,>,<=,>=
  static const int operatorPrecedenceComparison = 10;

  /// Or operator precedence: ||
  static const int operatorPrecedenceOr = 2;

  /// And operator precedence: &&
  static const int operatorPrecedenceAnd = 4;

  /// Power operator precedence: ^
  static const int operatorPrecedencePower = 40;

  /// An optional higher power operator precedence. {@link ExpressionSettings}
  static const int operatorPrecedencePowerHigher = 80;

  /// Multiplicative operators precedence: *,/,%
  static const int operatorPrecedenceMultiplicative = 30;

  /// Additive operators precedence: + and -
  static const int operatorPrecedenceAdditive = 20;

  /// Definition of PI as a constant, can be used in expressions as variable.
  static final Decimal pi = Decimal.parse(
      "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679");

  /// Definition of e: "Euler's number" as a constant, can be used in expressions as variable.
  static final Decimal e = Decimal.parse(
      "2.71828182845904523536028747135266249775724709369995957496696762772407663");

  /// Exception message for missing operators.
  static final String missingParametersForOperator =
      "Missing parameter(s) for operator ";

  /// The precedence of the power (^) operator. Default is 40.
  int powerOperatorPrecedence = operatorPrecedencePower;

  /// The characters (other than letters and digits) allowed as the first character in a variable.
  String _firstVarChars = "_";

  /// The characters (other than letters and digits) allowed as the second or subsequent characters in a variable.
  String _varChars = "_";

  /// The current infix expression, with optional variable substitutions.
  String _expressionString;

  /// The cached RPN (Reverse Polish Notation) of the expression.
  List<Token>? _rpn;

  /// All defined operators with name and implementation.
  Map<String, ILazyOperator> operators =
      SplayTreeMap((a, b) => a.compareTo(b));

  /// All defined functions with name and implementation.
  Map<String, ILazyFunction> functions =
      SplayTreeMap((a, b) => a.compareTo(b));

  /// All defined variables with name and value.
  Map<String, LazyNumber?> variables =
      SplayTreeMap((a, b) => a.compareTo(b));

  /// What character to use for decimal separators.
  static final String _decimalSeparator = ".";

  /// What character to use for minus sign (negative values).
  static final String _minusSign = "-";

  /// The BigDecimal representation of the left parenthesis, used for parsing varying numbers of function parameters.
  static final LazyNumber _paramsStart =
      LazyNumberImpl(eval: () => null, getString: () => null);

  /// Construct a LazyNumber from a BigDecimal
  LazyNumber createLazyNumber(final Decimal? decimal) {
    return LazyNumberImpl(
        eval: () => decimal, getString: () => decimal.toString());
  }

  /// Creates a new expression instance from an expression string
  ///
  /// [expression] the expression. E.g. ```2.4*sin(3)/(2-4)``` or ```sin(y)>0 & max(z, 3)>3```
  Expression(String expression,
      {this.powerOperatorPrecedence = Expression.operatorPrecedencePower})
      : _expressionString = expression {
    addBuiltIns(this);
  }

  /// Is the string a number?
  ///
  /// [st] The string.
  /// Returns `true`, if the input string is a number.
  bool isNumber(String st) {
    if (st[0] == _minusSign && st.length == 1) {
      return false;
    }
    if (st[0] == "+" && st.length == 1) {
      return false;
    }
    if (st[0] == _decimalSeparator && (st.length == 1 || !isDigit(st[1]))) {
      return false;
    }
    if (st[0] == 'e' || st[0] == 'E') {
      return false;
    }
    for (int i = 0; i < st.length; i++) {
      String ch = st[i];

      if (!isDigit(ch) &&
          ch != _minusSign &&
          ch != _decimalSeparator &&
          ch != 'e' &&
          ch != 'E' &&
          ch != "+") {
        return false;
      }
    }

    return true;
  }

  /// Implementation of the `Shunting Yard` algorithm to transform an infix expression to a RPN
  /// expression.
  ///
  /// [expression] - The input expression in infx.
  /// Returns a RPN representation of the expression, with each token as a list member.
  List<Token> _shuntingYard(String expression) {
    List<Token> outputQueue = [];
    ListQueue<Token> stack = ListQueue();

    _Tokenizer tokenizer = _Tokenizer(this, expression);

    Token? lastFunction;
    Token? previousToken;

    while (tokenizer.moveNext()) {
      Token token = tokenizer.current!;

      switch (token.type) {
        case TokenType.stringParam:
          stack.addFirst(token);
          break;
        case TokenType.literal:
        case TokenType.hexLiteral:
          if (previousToken != null &&
              (previousToken.type == TokenType.literal ||
                  previousToken.type == TokenType.hexLiteral)) {
            throw new ExpressionException.pos("Missing operator", token.pos);
          }
          outputQueue.add(token);
          break;
        case TokenType.variable:
          outputQueue.add(token);
          break;
        case TokenType.function:
          stack.addFirst(token);
          lastFunction = token;
          break;
        case TokenType.comma:
          if (previousToken != null &&
              previousToken.type == TokenType.operator) {
            throw new ExpressionException.pos(
                missingParametersForOperator + previousToken.toString(),
                previousToken.pos);
          }
          while (!stack.isEmpty && stack.first.type != TokenType.openParen) {
            outputQueue.add(stack.removeFirst());
          }
          if (stack.isEmpty) {
            if (lastFunction == null) {
              throw new ExpressionException.pos("Unexpected comma", token.pos);
            }
          }
          break;
        case TokenType.operator:
          if (previousToken != null &&
              operators.containsKey(token.surface) &&
              (previousToken.type == TokenType.comma ||
                  previousToken.type == TokenType.openParen)) {
            if (!operators[token.surface]!.isUnaryOperator()) {
              throw new ExpressionException.pos(
                  missingParametersForOperator + token.toString(), token.pos);
            }
          }

          ILazyOperator? o1 = operators[token.surface];
          if (o1 == null) {
            throw new ExpressionException.pos(
                "Unknown operator " + token.toString(), token.pos + 1);
          }

          _shuntOperators(outputQueue, stack, o1);
          stack.addFirst(token);
          break;
        case TokenType.unaryOperator:
          if (previousToken != null &&
              previousToken.type != TokenType.operator &&
              previousToken.type != TokenType.comma &&
              previousToken.type != TokenType.openParen &&
              previousToken.type != TokenType.unaryOperator) {
            throw new ExpressionException.pos(
                "Invalid position for unary operator " + token.toString(),
                token.pos);
          }
          ILazyOperator? o1 = operators[token.surface];
          if (o1 == null) {
            throw new ExpressionException.pos(
                "Unknown unary operator " +
                    token.surface.substring(0, token.surface.length - 1),
                token.pos + 1);
          }

          _shuntOperators(outputQueue, stack, o1);
          stack.addFirst(token);
          break;
        case TokenType.openParen:
          if (previousToken != null) {
            if (previousToken.type == TokenType.literal ||
                previousToken.type == TokenType.closeParen ||
                previousToken.type == TokenType.variable ||
                previousToken.type == TokenType.hexLiteral) {
              // Implicit multiplication, e.g. 23(a+b) or (a+b)(a-b)
              Token multiplication = new Token();
              multiplication.append("*");
              multiplication.type = TokenType.operator;
              stack.addFirst(multiplication);
            }
            // if the ( is preceded by a valid function, then it
            // denotes the start of a parameter list
            if (previousToken.type == TokenType.function) {
              outputQueue.add(token);
            }
          }
          stack.addFirst(token);
          break;
        case TokenType.closeParen:
          if (previousToken != null &&
              previousToken.type == TokenType.operator &&
              !operators[previousToken.surface]!.isUnaryOperator()) {
            throw new ExpressionException.pos(
                missingParametersForOperator + previousToken.toString(),
                previousToken.pos);
          }
          while (!stack.isEmpty && stack.first.type != TokenType.openParen) {
            outputQueue.add(stack.removeFirst());
          }
          if (stack.isEmpty) {
            throw new ExpressionException("Mismatched parentheses");
          }
          stack.removeFirst();
          if (!stack.isEmpty && stack.first.type == TokenType.function) {
            outputQueue.add(stack.removeFirst());
          }
          break;
        case null:
        default:
          break;
      }

      previousToken = token;
    }

    while (!stack.isEmpty) {
      Token element = stack.removeFirst();
      if (element.type == TokenType.openParen ||
          element.type == TokenType.closeParen) {
        throw new ExpressionException("Mismatched parentheses");
      }
      outputQueue.add(element);
    }
    return outputQueue;
  }

  void _shuntOperators(
      List<Token> outputQueue, ListQueue<Token> stack, ILazyOperator o1) {
    Token? nextToken = stack.isEmpty ? null : stack.first;
    while (nextToken != null &&
        (nextToken.type == TokenType.operator ||
            nextToken.type == TokenType.unaryOperator) &&
        ((o1.isLeftAssoc() &&
                o1.getPrecedence() <=
                    (operators[nextToken.surface]?.getPrecedence() ?? 0)) ||
            (o1.getPrecedence() <
                (operators[nextToken.surface]?.getPrecedence() ?? 0)))) {
      outputQueue.add(stack.removeFirst());
      nextToken = stack.isEmpty ? null : stack.first;
    }
  }

  /// Evaluates the expression.
  ///
  /// Returns the result of the expression. Trailing zeros are stripped.
  Decimal? eval() {
    ListQueue<LazyNumber> stack = ListQueue();

    for (final Token token in getRPN()) {
      switch (token.type) {
        case TokenType.unaryOperator:
          {
            final LazyNumber value = stack.removeFirst();
            LazyNumber result = new LazyNumberImpl(eval: () {
              return operators[token.surface]?.evalLazy(value, null).eval();
            }, getString: () {
              return operators[token.surface]
                  ?.evalLazy(value, null)
                  .eval()
                  .toString();
            });
            stack.addFirst(result);
            break;
          }
        case TokenType.operator:
          if (operators[token.surface]!.isUnaryOperator()) {
            LazyNumber value = stack.removeFirst();
            LazyNumberImpl result = new LazyNumberImpl(eval: () {
              return operators[token.surface]!.evalLazy(value, null).eval();
            }, getString: () {
              return operators[token.surface]!
                  .evalLazy(value, null)
                  .eval()
                  .toString();
            });

            stack.addFirst(result);
          } else {
            final LazyNumber v1 = stack.removeFirst();
            final LazyNumber v2 = stack.removeFirst();
            LazyNumber result = new LazyNumberImpl(eval: () {
              return operators[token.surface]?.evalLazy(v2, v1).eval();
            }, getString: () {
              return operators[token.surface]
                  ?.evalLazy(v2, v1)
                  .eval()
                  .toString();
            });

            stack.addFirst(result);
          }

          break;
        case TokenType.variable:
          if (!variables.containsKey(token.surface)) {
            throw new ExpressionException(
                "Unknown operator or function: " + token.toString());
          }

          stack.addFirst(LazyNumberImpl(eval: () {
            LazyNumber? lazyVariable = variables[token.surface];
            Decimal? value = lazyVariable == null ? null : lazyVariable.eval();
            return value;
          }, getString: () {
            LazyNumber? lazyVariable = variables[token.surface];
            return lazyVariable?.getString();
          }));
          break;
        case TokenType.function:
          ILazyFunction f = functions[token.surface.toUpperCase()]!;
          List<LazyNumber> p = [];
          // pop parameters off the stack until we hit the start of
          // this function's parameter list
          while (!stack.isEmpty && stack.first != _paramsStart) {
            p.insert(0, stack.removeFirst());
          }

          if (stack.first == _paramsStart) {
            stack.removeFirst();
          }

          LazyNumber? fResult = f.lazyEval(p);
          stack.addFirst(fResult);
          break;
        case TokenType.openParen:
          stack.addFirst(_paramsStart);
          break;
        case TokenType.literal:
          stack.addFirst(LazyNumberImpl(eval: () {
            if (token.surface.toLowerCase() == "null") {
              return null;
            }

            return Decimal.parse(token.surface);
          }, getString: () {
            return Decimal.parse(token.surface).toString();
          }));
          break;
        case TokenType.stringParam:
          stack.addFirst(LazyNumberImpl(eval: () {
            return null;
          }, getString: () {
            return token.surface;
          }));
          break;
        case TokenType.hexLiteral:
          stack.addFirst(LazyNumberImpl(eval: () {
            BigInt bigInt = BigInt.parse(token.surface.substring(2), radix: 16);
            return Decimal.parse(bigInt.toString());
          }, getString: () {
            BigInt bigInt = BigInt.parse(token.surface.substring(2), radix: 16);
            return Decimal.parse(bigInt.toString()).toString();
          }));
          break;
        default:
          throw new ExpressionException.pos(
              "Unexpected token " + token.surface, token.pos);
      }
    }

    Decimal? result = stack.removeFirst().eval();
    if (result == null) {
      return null;
    }

    // if (stripTrailingZeros) {
    //   result = result.stripTrailingZeros();
    // }
    return result;
  }

  /// Sets the characters other than letters and digits that are valid as the first character of a
  /// variable.
  ///
  /// [chars] - The new set of variable characters.
  /// Returns the expression, allows to chain methods.
  Expression setFirstVariableCharacters(String chars) {
    this._firstVarChars = chars;
    return this;
  }

  /// Sets the characters other than letters and digits that are valid as the second and subsequent
  /// characters of a variable.
  ///
  /// [chars] - The new set of variable characters.
  /// Returns the expression, allows to chain methods.
  Expression setVariableCharacters(String chars) {
    this._varChars = chars;
    return this;
  }

  /// Adds an operator to the list of supported operators.
  ///
  /// [operator] - The operator to add.
  /// Returns the previous operator with that name, or <code>null</code> if there was none.
  T addOperator<T extends ILazyOperator>(T operator) {
    String key = operator.getOper();
    if (operator is AbstractUnaryOperator) {
      key += "u";
    }
    operators[key] = operator;
    return operator;
  }

  /// Adds a function to the list of supported functions
  ///
  /// [function] - The function to add.
  /// Returns the previous operator with that name, or <code>null</code> if there was none.
  IFunc addFunc(IFunc function) {
    functions[function.getName()] = function;
    return function;
  }

  /// Adds a lazy function function to the list of supported functions
  ///
  /// [function] - The function to add.
  /// Returns the previous operator with that name, or <code>null</code> if there was none.
  ILazyFunction addLazyFunction(ILazyFunction function) {
    functions[function.getName()] = function;
    return function;
  }

  /// Sets a variable value.
  ///
  /// [variable] - The variable name.
  /// [value] - The variable value.
  /// Returns the expression, allows to chain methods.
  Expression setDecimalVariable(String variable, Decimal? value) {
    return setLazyVariable(variable, createLazyNumber(value));
  }

  /// Sets a variable value.
  ///
  /// [variable] The variable name.
  /// [value] - The variable value.
  /// Returns the expression, allows to chain methods.
  Expression setLazyVariable(String variable, LazyNumber? value) {
    variables[variable] = value;
    return this;
  }

  /// Sets a variable value.
  ///
  /// [variable] - The variable to set.
  /// [value] - The variable value.
  /// Returns the expression, allows to chain methods.
  Expression setStringVariable(String variable, String value) {
    if (isNumber(value)) {
      variables[variable] = createLazyNumber(Decimal.parse(value));
    } else if (value.toLowerCase() == "null") {
      variables[variable] = null;
    } else {
      final String expStr = value;
      variables[variable] = LazyNumberImpl(eval: () {
        Expression innerE = Expression(expStr);
        innerE.variables = variables;
        innerE.functions = functions;
        innerE.operators = operators;
        Decimal? val = innerE.eval();
        return val;
      }, getString: () {
        return expStr;
      });

      _rpn = null;
    }
    return this;
  }

  /// Creates a new inner expression for nested expression.
  ///
  /// [expression] The string expression.
  /// Returns the inner Expression instance.
  Expression _createEmbeddedExpression(final String expression) {
    final Map<String, LazyNumber?> outerVariables = variables;
    final Map<String, ILazyFunction> outerFunctions = functions;
    final Map<String, ILazyOperator> outerOperators = operators;
    Expression exp = new Expression(expression);
    exp.variables = outerVariables;
    exp.functions = outerFunctions;
    exp.operators = outerOperators;
    return exp;
  }

  /// Get an iterator for this expression, allows iterating over an expression token by token.
  ///
  /// Returns a new iterator instance for this expression.
  Iterator<Token?> getExpressionTokenizer() {
    final String expression = this._expressionString;

    return _Tokenizer(this, expression);
  }

  /// Cached access to the RPN notation of this expression, ensures only one calculation of the RPN
  /// per expression instance. If no cached instance exists, a new one will be created and put to the
  /// cache.
  ///
  /// Returns the cached RPN instance.
  List<Token> getRPN() {
    if (_rpn == null) {
      _rpn = _shuntingYard(this._expressionString);
      _validate(_rpn!);
    }
    return _rpn!;
  }

  /// Check that the expression has enough numbers and variables to fit the requirements of the
  /// operators and functions, also check for only 1 result stored at the end of the evaluation.
  void _validate(List<Token> rpn) {
    // Thanks to Norman Ramsey:
    // http://http://stackoverflow.com/questions/789847/postfix-notation-validation
    // each push on to this stack is a new function scope, with the value of
    // each
    // layer on the stack being the count of the number of parameters in
    // that scope
    ListQueue<int> stack = ListQueue();

    // push the 'global' scope
    stack.addFirst(0);

    for (final Token token in rpn) {
      switch (token.type) {
        case TokenType.unaryOperator:
          if (stack.first < 1) {
            throw new ExpressionException(
                missingParametersForOperator + token.toString());
          }
          break;
        case TokenType.operator:
          ILazyOperator? op = operators[token.surface];
          int numOperands = 2;
          if (op?.isUnaryOperator() ?? false) {
            numOperands = 1;
          }

          if (stack.first < numOperands) {
            throw new ExpressionException(
                missingParametersForOperator + token.toString());
          }
          if (numOperands > 1) {
            // pop the operator's 2 parameters and add the result
            int peek = stack.removeFirst();
            stack.addFirst(peek - numOperands + 1);
          }

          break;
        case TokenType.function:
          ILazyFunction? f = functions[token.surface.toUpperCase()];
          if (f == null) {
            throw new ExpressionException.pos(
                "Unknown function " + token.toString(), token.pos + 1);
          }

          int numParams = stack.removeFirst();
          if (!f.numParamsVaries() && numParams != f.getNumParams()) {
            throw new ExpressionException("Function " +
                token.toString() +
                " expected " +
                f.getNumParams().toString() +
                " parameters, got " +
                numParams.toString());
          }
          if (stack.isEmpty) {
            throw new ExpressionException(
                "Too many function calls, maximum scope exceeded");
          }
          // push the result of the function
          int peek = stack.removeFirst();
          stack.addFirst(peek + 1);
          break;
        case TokenType.openParen:
          stack.addFirst(0);
          break;
        default:
          int peek = stack.removeFirst();
          stack.addFirst(peek + 1);
      }
    }

    if (stack.length > 1) {
      throw new ExpressionException(
          "Too many unhandled function parameter lists");
    } else if (stack.first > 1) {
      throw new ExpressionException("Too many numbers or variables");
    } else if (stack.first < 1) {
      throw new ExpressionException("Empty expression");
    }
  }

  /// Get a string representation of the RPN (Reverse Polish Notation) for this expression.
  ///
  /// Returns a string with the RPN representation for this expression.
  String toRPN() {
    String result = "";
    for (Token t in getRPN()) {
      if (result.isNotEmpty) {
        result += " ";
      }
      if (t.type == TokenType.variable && variables.containsKey(t.surface)) {
        LazyNumber innerVariable = variables[t.surface]!;
        String innerExp = innerVariable.getString();
        if (isNumber(innerExp)) {
          // if it is a number, then we don't
          // expan in the RPN
          result += t.toString();
        } else {
          // expand the nested variable to its RPN representation
          Expression exp = _createEmbeddedExpression(innerExp);
          String nestedExpRpn = exp.toRPN();
          result += nestedExpRpn;
        }
      } else {
        result += t.toString();
      }
    }
    return result.toString();
  }

  /// Checks whether the expression is a boolean expression. An expression is considered a boolean
  /// expression, if the last operator or function is boolean. The IF function is handled special. If
  /// the third parameter is boolean, then the IF is also considered boolean, else non-boolean.
  ///
  /// Returns `true` if the last operator/function was a boolean.
  bool isBoolean() {
    List<Token> rpnList = getRPN();
    if (rpnList.isNotEmpty) {
      for (int i = rpnList.length - 1; i >= 0; i--) {
        Token t = rpnList[i];

        /*
                 * The IF function is handled special. If the third parameter is
                 * boolean, then the IF is also considered a boolean. Just skip
                 * the IF function to check the second parameter.
                 */
        if (t.surface == "IF") {
          continue;
        }
        if (t.type == TokenType.function) {
          return functions[t.surface]!.isBooleanFunction();
        } else if (t.type == TokenType.operator) {
          return operators[t.surface]!.isBooleanOperator();
        }
      }
    }
    return false;
  }

  /// Returns a list of the variables in the expression.
  ///
  /// Returns a list of the variable names in this expression.
  List<String> getUsedVariables() {
    List<String> result = [];
    _Tokenizer tokenizer = new _Tokenizer(this, _expressionString);
    while (tokenizer.moveNext()) {
      Token nextToken = tokenizer.current!;
      String token = nextToken.toString();
      if (nextToken.type != TokenType.variable ||
          token == "PI" ||
          token == "e" ||
          token == "TRUE" ||
          token == "FALSE") {
        continue;
      }
      result.add(token);
    }
    return result;
  }

  /// Exposing declared operators in the expression.
  ///
  /// Returns all declared operators.
  Iterable<String> getDeclaredOperators() {
    return operators.keys;
  }

  /// Exposing declared variables in the expression.
  ///
  /// Returns all declared variables.
  Iterable<String> getDeclaredVariables() {
    return variables.keys;
  }

  /// Exposing declared functions.
  ///
  /// Returns all declared functions.
  Iterable<String> getDeclaredFunctions() {
    return functions.keys;
  }
}

class LazyNumberImpl extends LazyNumber {
  final Function _eval;
  final Function _getString;

  LazyNumberImpl({required Function eval, required Function getString})
      : _eval = eval,
        _getString = getString;

  @override
  Decimal? eval() {
    return _eval();
  }

  @override
  String getString() {
    return _getString();
  }
}

/// The expression evaluators exception class.
class ExpressionException implements Exception {
  final String msg;

  const ExpressionException(this.msg);

  const ExpressionException.pos(String message, int characterPosition)
      : msg = "$message at character position $characterPosition";

  @override
  String toString() => "ExpressionException: $msg";
}

/// LazyNumber interface created for lazily evaluated functions
abstract class LazyNumber {
  Decimal? eval();

  String getString();
}

enum TokenType {
  variable,
  function,
  literal,
  operator,
  unaryOperator,
  openParen,
  comma,
  closeParen,
  hexLiteral,
  stringParam
}

class Token {
  String surface = "";
  TokenType? type;
  int pos = 0;

  void append(String c) => surface += c;

  String charAt(int pos) => surface[pos];

  int length() {
    return surface.length;
  }

  @override
  String toString() {
    return surface;
  }
}

/// Expression tokenizer that allows to iterate over a {@link String} expression token by token.
/// Blank characters will be skipped.
class _Tokenizer extends Iterator<Token?> {
  final List<String> _hexDigits = [
    'x',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  ];

  Expression _expression;

  /// Actual position in expression string.
  int pos = 0;

  /// The original input expression.
  String input;

  /// The previous token or <code>null</code> if none.
  Token? previousToken;

  /// The next token, or null if none
  Token? nextToken = new Token();

  /// Creates a new tokenizer for an expression.
  ///
  /// [input] The expression string.
  _Tokenizer(this._expression, String input) : input = input.trim();

  /// Peek at the next character, without advancing the iterator.
  ///
  /// Returns the next character or character 0, if at end of string.
  String? peekNextChar() {
    if (pos < (input.length - 1)) {
      return input[pos + 1];
    } else {
      return null;
    }
  }

  bool isHexDigit(String ch) {
    return _hexDigits.any((e) => e == ch || e.toUpperCase() == ch);
  }

  @override
  Token? get current {
    return previousToken;
  }

  @override
  bool moveNext() {
    Token token = new Token();

    if (pos >= input.length) {
      previousToken = null;
      return false;
    }
    String ch = input[pos];
    while (isWhitespace(ch) && pos < input.length) {
      ch = input[++pos];
    }
    token.pos = pos;

    bool isHex = false;

    if (isDigit(ch) ||
        (ch == Expression._decimalSeparator && isDigit(peekNextChar()))) {
      if (ch == '0' && (peekNextChar() == 'x' || peekNextChar() == 'X')) {
        isHex = true;
      }
      while ((isHex && isHexDigit(ch)) ||
          (isDigit(ch) ||
                  ch == Expression._decimalSeparator ||
                  ch == 'e' ||
                  ch == 'E' ||
                  (ch == Expression._minusSign &&
                      token.length() > 0 &&
                      ('e' == token.charAt(token.length() - 1) ||
                          'E' == token.charAt(token.length() - 1))) ||
                  (ch == '+' &&
                      token.length() > 0 &&
                      ('e' == token.charAt(token.length() - 1) ||
                          'E' == token.charAt(token.length() - 1)))) &&
              (pos < input.length)) {
        token.append(input[pos++]);
        ch = pos == input.length ? "" : input[pos];
      }
      token.type = isHex ? TokenType.hexLiteral : TokenType.literal;
    } else if (ch == '"') {
      pos++;
      if (previousToken?.type != TokenType.stringParam) {
        ch = input[pos];
        while (ch != '"') {
          token.append(input[pos++]);
          ch = pos == input.length ? "" : input[pos];
        }
        token.type = TokenType.stringParam;
      } else {
        return moveNext();
      }
    } else if (isLetter(ch) || _expression._firstVarChars.indexOf(ch) >= 0) {
      while ((isLetter(ch) ||
              isDigit(ch) ||
              _expression._varChars.indexOf(ch) >= 0 ||
              token.length() == 0 &&
                  _expression._firstVarChars.indexOf(ch) >= 0) &&
          (pos < input.length)) {
        token.append(input[pos++]);
        ch = pos == input.length ? "" : input[pos];
      }
      // Remove optional white spaces after function or variable name
      if (isWhitespace(ch)) {
        while (isWhitespace(ch) && pos < input.length) {
          ch = input[pos++];
        }
        pos--;
      }
      if (_expression.operators.containsKey(token.surface)) {
        token.type = TokenType.operator;
      } else if (ch == '(') {
        token.type = TokenType.function;
      } else {
        token.type = TokenType.variable;
      }
    } else if (ch == '(' || ch == ')' || ch == ',') {
      if (ch == '(') {
        token.type = TokenType.openParen;
      } else if (ch == ')') {
        token.type = TokenType.closeParen;
      } else {
        token.type = TokenType.comma;
      }
      token.append(ch);
      pos++;
    } else {
      String greedyMatch = "";
      int initialPos = pos;
      ch = input[pos];
      int validOperatorSeenUntil = -1;
      while (!isLetter(ch) &&
          !isDigit(ch) &&
          _expression._firstVarChars.indexOf(ch) < 0 &&
          !isWhitespace(ch) &&
          ch != '(' &&
          ch != ')' &&
          ch != ',' &&
          (pos < input.length)) {
        greedyMatch += ch;
        pos++;
        if (_expression.operators.containsKey(greedyMatch)) {
          validOperatorSeenUntil = pos;
        }
        ch = pos == input.length ? "" : input[pos];
      }
      if (validOperatorSeenUntil != -1) {
        token.append(input.substring(initialPos, validOperatorSeenUntil));
        pos = validOperatorSeenUntil;
      } else {
        token.append(greedyMatch);
      }

      if (previousToken == null ||
          (previousToken!.type == TokenType.operator &&
              !_expression.operators[previousToken!.surface]!
                  .isUnaryOperator()) ||
          previousToken!.type == TokenType.openParen ||
          previousToken!.type == TokenType.comma ||
          previousToken!.type == TokenType.unaryOperator) {
        token.surface += "u";
        token.type = TokenType.unaryOperator;
      } else {
        token.type = TokenType.operator;
      }
    }
    previousToken = token;
    return true;
  }
}
