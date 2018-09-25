module hunt.sql.ast.expr.SQLNullExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.container;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLEvalVisitor;

public  class SQLNullExpr : SQLExprImpl , SQLLiteralExpr, SQLValuableExpr {

    public this(){

    }

    override public void output(StringBuffer buf) {
        buf.append("NULL");
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    override public size_t toHash() @trusted nothrow {
        return 0;
    }

    override public bool opEquals(Object o) {
        return cast(SQLNullExpr)o is null ? false : true;
    }

   override
    public Object getValue() {
        return cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL);
    }

    override public SQLNullExpr clone() {
        return new SQLNullExpr();
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
