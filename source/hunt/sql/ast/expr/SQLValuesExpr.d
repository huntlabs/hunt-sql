module hunt.sql.ast.expr.SQLValuesExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.collection;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLListExpr;

public class SQLValuesExpr : SQLExprImpl {

    private List!SQLListExpr values;

    this()
    {
        values = new ArrayList!SQLListExpr();
    }
    public List!SQLListExpr getValues() {
        return values;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLListExpr(visitor, values);
        }
        visitor.endVisit(this);
    }

    public override bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(SQLValuesExpr) != typeid(o)) return false;

        SQLValuesExpr that = cast(SQLValuesExpr) o;

        return (cast(Object)(values)).opEquals(cast(Object)(that.values));
    }

    public override size_t toHash() @trusted nothrow {
        return (cast(Object)values).toHash();
    }

    public override SQLExpr clone() {
        SQLValuesExpr x = new SQLValuesExpr();

        foreach (SQLListExpr value ; values) {
            SQLListExpr value2 = value.clone();
            value2.setParent(x);
            x.values.add(value2);
        }

        return x;
    }

    public override  List!SQLObject getChildren() {
        return cast(List!SQLObject)values;
    }
}
