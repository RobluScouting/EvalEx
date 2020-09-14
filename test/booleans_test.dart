import 'package:eval_ex/expression.dart';
import 'package:test/test.dart';

void assertToken(String surface, TokenType type, Token actual) {
  expect(actual.surface, surface);
  expect(actual.type, type);
}

void main() {
  test('testIsBoolean', () {
    Expression e = Expression("1==1");
    expect(e.isBoolean(), true);

    e = Expression("a==b")
      ..setStringVariable("a", "1")
      ..setStringVariable("b", "2");
    expect(e.isBoolean(), true);

    e = new Expression("(1==1)||(c==a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("(z+z==x-y)||(c==a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("NOT(a+b)");
    expect(e.isBoolean(), true);

    e = new Expression("a+b");
    expect(e.isBoolean(), false);

    e = new Expression("(a==b)+(b==c)");
    expect(e.isBoolean(), false);

    e = new Expression("SQRT(2)");
    expect(e.isBoolean(), false);

    e = new Expression("SQRT(2) == SQRT(b)");
    expect(e.isBoolean(), true);

    e = new Expression("IF(a==b,x+y,x-y)");
    expect(e.isBoolean(), false);

    e = new Expression("IF(a==b,x==y,a==b)");
    expect(e.isBoolean(), true);
  });

  test('testAndTokenizer', () {
    Expression e = new Expression("1&&0");
    Iterator<Token> i = e.getExpressionTokenizer();

    i.moveNext();
    assertToken("1", TokenType.literal, i.current);
    i.moveNext();
    assertToken("&&",TokenType.operator, i.current);
    i.moveNext();
    assertToken("0", TokenType.literal, i.current);
  });

  test('testAndRPN', () {
    expect(Expression("1&&0").toRPN(), "1 0 &&");
  });

  test('testAndEval', () {
    expect(Expression("1&&0").eval().toString(), "0");
    expect(Expression("1&&1").eval().toString(), "1");
    expect(Expression("0&&0").eval().toString(), "0");
    expect(Expression("0&&1").eval().toString(), "0");
  });

  test('testOrEval', () {
    expect(Expression("1||0").eval().toString(), "1");
    expect(Expression("1||1").eval().toString(), "1");
    expect(Expression("0||0").eval().toString(), "0");
    expect(Expression("0||1").eval().toString(), "1");
  });

  test('testCompare', () {
    expect(Expression("2>1").eval().toString(), "1");
    expect(Expression("2<1").eval().toString(), "0");
    expect(Expression("1>2").eval().toString(), "0");
    expect(Expression("1<2").eval().toString(), "1");
    expect(Expression("1=2").eval().toString(), "0");
    expect(Expression("1=1").eval().toString(), "1");
    expect(Expression("1>=1").eval().toString(), "1");
    expect(Expression("1.1>=1").eval().toString(), "1");
    expect(Expression("1>=2").eval().toString(), "0");
    expect(Expression("1<=1").eval().toString(), "1");
    expect(Expression("1.1<=1").eval().toString(), "0");
    expect(Expression("1<=2").eval().toString(), "1");
    expect(Expression("1=2").eval().toString(), "0");
    expect(Expression("1=1").eval().toString(), "1");
    expect(Expression("1!=2").eval().toString(), "1");
    expect(Expression("1!=1").eval().toString(), "0");
  });

  test('testCompareCombined', () {
    expect(new Expression("(2>1)||(1=0)").eval().toString(), "1");
    expect(new Expression("(2>3)||(1=0)").eval().toString(), "0");
    expect(new Expression("(2>3)||(1=0)||(1&&1)").eval().toString(), "1");
  });

  test('testMixed', () {
    expect(new Expression("1.5 * 7 = 3").eval().toString(), "0");
    expect(new Expression("1.5 * 7 = 10.5").eval().toString(), "1");
  });

  test('testNot', () {
    expect(new Expression("not(1)").eval().toString(), "0");
    expect(new Expression("not(0)").eval().toString(), "1");
    expect(new Expression("not(1.5 * 7 = 3)").eval().toString(), "1");
    expect(new Expression("not(1.5 * 7 = 10.5)").eval().toString(), "0");
  });

  test('testConstants', () {
    expect(new Expression("TRUE!=FALSE").eval().toString(), "1");
    expect(new Expression("TRUE==2").eval().toString(), "0");
    expect(new Expression("NOT(TRUE)==FALSE").eval().toString(), "1");
    expect(new Expression("NOT(FALSE)==TRUE").eval().toString(), "1");
    expect(new Expression("TRUE && FALSE").eval().toString(), "0");
    expect(new Expression("TRUE || FALSE").eval().toString(), "1");
  });

  test('testIf', () {
    expect(new Expression("if(TRUE, 5, 3)").eval().toString(), "5");
    expect(new Expression("IF(FALSE, 5, 3)").eval().toString(), "3");
    expect(new Expression("If(2, 5.35, 3)").eval().toString(), "5.35");
  });

  test("testDecimals",  () {
    expect(new Expression("if(0.0, 1, 0)").eval().toString(), "0");
    expect(new Expression("0.0 || 0.0").eval().toString(), "0");
    expect(new Expression("not(0.0)").eval().toString(), "1");
    expect(new Expression("0.0 && 0.0").eval().toString(), "0");
  });

}


