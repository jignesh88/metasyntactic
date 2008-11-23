package org.metasyntactic.automata.compiler.framework.parsers.packrat.expressions;

/**
 * Created by IntelliJ IDEA. User: cyrusn Date: Jun 20, 2008 Time: 7:58:35 PM To change this template use File |
 * Settings | File Templates.
 */
public class OneOrMoreExpression extends Expression {
  private final Expression child;

  public OneOrMoreExpression(Expression child) {
    this.child = child;
  }

  public Expression getChild() {
    return child;
  }

  @Override public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof OneOrMoreExpression)) {
      return false;
    }

    OneOrMoreExpression that = (OneOrMoreExpression) o;

    if (!child.equals(that.child)) {
      return false;
    }

    return true;
  }

  @Override public int hashCodeWorker() {
    return child.hashCode();
  }

  @Override public <TInput, TResult> TResult accept(ExpressionVisitor<TInput, TResult> visitor) {
    return visitor.visit(this);
  }

  @Override public <TInput> void accept(ExpressionVoidVisitor<TInput> visitor) {
    visitor.visit(this);
  }

  @Override public String toString() {
    return "(OneOrMore " + child + ")";
  }
}
