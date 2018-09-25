module hunt.sql.ast.expr.SQLUnaryExpr;

import hunt.sql.ast.expr.SQLUnaryOperator;
import hunt.sql.ast.SQLExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExprImpl;
import hunt.container;
import hunt.sql.ast.SQLObject;

public class SQLUnaryExpr : SQLExprImpl // Serializable 
{

    private static  long serialVersionUID = 1L;
    private SQLExpr           expr;
    private SQLUnaryOperator  operator;

    public this(){

    }

    public this(SQLUnaryOperator operator, SQLExpr expr){
        this.operator = operator;
        this.setExpr(expr);
    }

    override public SQLUnaryExpr clone() {
        SQLUnaryExpr x = new SQLUnaryExpr();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        x.operator = operator;
        return x;
    }

    public SQLUnaryOperator getOperator() {
        return operator;
    }

    public void setOperator(SQLUnaryOperator operator) {
        this.operator = operator;
    }

    public SQLExpr getExpr() {
        return this.expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }
        this.expr = expr;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }

        visitor.endVisit(this);
    }

    public override List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.expr);
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        result = prime * result + hashOf(operator);
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(SQLUnaryExpr) != typeid(obj)) {
            return false;
        }
        SQLUnaryExpr other = cast(SQLUnaryExpr) obj;
        if (expr is null) {
            if (other.expr !is null) {
                return false;
            }
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) {
            return false;
        }
        if (operator != other.operator) {
            return false;
        }
        return true;
    }
}
