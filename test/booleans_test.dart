import 'package:eval_ex/expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('testIsBoolean', () {
    Expression e = Expression("1==1");
    expect(e.isBoolean(), true);

  });
}
