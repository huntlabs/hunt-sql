module hunt.sql.ast.expr.SQLNumericLiteralExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.math.Number;
import hunt.container;
import hunt.sql.ast.SQLObject;

public abstract class SQLNumericLiteralExpr : SQLExprImpl , SQLLiteralExpr {

    public this(){

    }

    public abstract Number getNumber();

    public abstract void setNumber(Number number);

    public abstract override SQLNumericLiteralExpr clone();

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
