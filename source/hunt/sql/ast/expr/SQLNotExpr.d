module hunt.sql.ast.expr.SQLNotExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLExpr;
import hunt.collection;
import hunt.sql.ast.SQLDataType;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.util.StringBuilder;

public  class SQLNotExpr : SQLExprImpl //, Serializable 
{
    public SQLExpr            expr;

    public this(){

    }

    public this(SQLExpr expr){

        this.expr = expr;
    }

    public SQLExpr getExpr() {
        return this.expr;
    }

    public void setExpr(SQLExpr expr) {
        this.expr = expr;
    }

    override public void output(StringBuilder buf) {
        buf.append(" NOT ");
        this.expr.output(buf);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }

        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.expr);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        return result;
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(this) != typeid(obj)) {
            return false;
        }
        SQLNotExpr other = cast(SQLNotExpr) obj;
        if (expr is null) {
            if (other.expr !is null) {
                return false;
            }
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) {
            return false;
        }
        return true;
    }

    override public SQLNotExpr clone() {
        SQLNotExpr x = new SQLNotExpr();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        return x;
    }

    override public SQLDataType computeDataType() {
        return SQLBooleanExpr.DEFAULT_DATA_TYPE;
    }
}
