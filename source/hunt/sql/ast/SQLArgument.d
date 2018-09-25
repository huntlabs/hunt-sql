module hunt.sql.ast.SQLArgument;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLParameter;
import hunt.sql.visitor.SQLASTVisitor;

/**
 * Created by wenshao on 29/05/2017.
 */
public class SQLArgument : SQLObjectImpl {
    private SQLParameter.ParameterType type;
    private SQLExpr expr;

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
        }

        visitor.endVisit(this);
    }

    public override SQLArgument clone() {
        SQLArgument x = new SQLArgument();

        x.type = type;

        if (expr !is null) {
            x.setExpr(expr.clone());
        }

        return x;
    }

    public SQLParameter.ParameterType getType() {
        return type;
    }

    public SQLExpr getExpr() {
        return expr;
    }

    public void setType(SQLParameter.ParameterType type) {
        this.type = type;
    }

    public void setExpr(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.expr = x;
    }
}
